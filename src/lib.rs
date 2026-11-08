use std::collections::BTreeMap;
use std::path::Path;
use std::sync::Arc;
use std::sync::atomic::{AtomicI64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

use axum::extract::{Path as AxumPath, Query, State};
use axum::http::{HeaderMap, HeaderValue, StatusCode, header};
use axum::middleware::{self, Next};
use axum::response::{IntoResponse, Response};
use axum::routing::{get, put};
use axum::{Json, Router};
use base64::Engine as _;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use hmac::{Hmac, Mac};
use serde::{Deserialize, Serialize};
use sha2::Sha256;
use tokio::sync::Mutex;
use unionid::Engine;

unionid_query::queries! {
    schema "schema/diary.unid"

    query list_day_query {
        from entries
        filter owner == $owner
        filter date == $date
        sort {created_at, id}
    }

    query list_range_query {
        from entries
        filter owner == $owner
        filter date >= $from
        filter date <= $to
        select {date, field}
    }

    query list_values_query {
        from entries
        filter owner == $owner
        select {field, content, created_at}
    }

    query latest_entry_query {
        from entries
        sort -id
        take 1
    }

    query insert_entry_query {
        insert entries $entry
        returning
    }

    query update_entry_query {
        update entries
        filter id == $id
        filter owner == $owner
        set {
          content = $content
          updated_at = $updated_at
        }
        returning
    }

    query delete_entry_query {
        delete entries
        filter id == $id
        filter owner == $owner
        returning id
    }
}

const SCHEMA: &str = include_str!("../schema/diary.unid");

/// The diary tags, following the record items of topixim/diary.
pub const FIELDS: [&str; 9] = [
    "food",
    "sleep",
    "mood",
    "place",
    "highlight",
    "met",
    "exercise",
    "pains",
    "text",
];

/// Tags recorded as short enumerable values, offered back as quick options.
pub const TAG_FIELDS: [&str; 4] = ["food", "place", "exercise", "pains"];
const MAX_OPTION_CHARS: usize = 16;
const MAX_OPTIONS_PER_FIELD: usize = 24;

const TOKEN_TTL_SECONDS: i64 = 3 * 24 * 60 * 60;
const SESSION_COOKIE_NAME: &str = "diary_session";
const SESSION_TOKEN_HEADER: &str = "x-diary-token";
const MAX_RANGE_DAYS: usize = 400;

type HmacSha256 = Hmac<Sha256>;
type ApiResult = Result<Response, (StatusCode, Json<ApiError>)>;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DiaryEntry {
    pub id: i64,
    pub owner: String,
    pub date: String,
    pub field: String,
    pub content: String,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct NewEntry {
    pub date: String,
    pub field: String,
    pub content: String,
}

#[derive(Debug, Deserialize)]
pub struct EntryUpdate {
    pub content: String,
}

#[derive(Debug, Deserialize)]
pub struct DayQuery {
    pub date: String,
}

#[derive(Debug, Deserialize)]
pub struct RangeQuery {
    pub from: String,
    pub to: String,
}

/// One day in the overview: which tags have at least one record.
#[derive(Debug, Serialize, Deserialize, PartialEq)]
pub struct DaySummary {
    pub date: String,
    pub fields: Vec<String>,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginResponse {
    pub token: String,
    pub username: String,
}

#[derive(Clone)]
pub struct AppState {
    engine: Arc<Mutex<Engine>>,
    ids: Arc<AtomicI64>,
    users: Arc<BTreeMap<String, String>>,
    secret: Arc<Vec<u8>>,
}

#[derive(Debug, Serialize)]
struct ApiError {
    error: String,
}

struct Session {
    username: String,
    token: String,
}

pub fn app(database_path: impl AsRef<Path>) -> Result<Router, unionid::Error> {
    let users_source = std::env::var("DIARY_USERS")
        .map_err(|_| unionid::Error::new("E_AUTH_CONFIG", "DIARY_USERS must be configured"))?;
    let users = parse_users(&users_source)?;
    let secret = std::env::var("DIARY_SECRET")
        .map_err(|_| unionid::Error::new("E_AUTH_CONFIG", "DIARY_SECRET must be configured"))?
        .into_bytes();
    app_with_auth(database_path, users, secret)
}

pub fn app_with_auth(
    database_path: impl AsRef<Path>,
    users: BTreeMap<String, String>,
    secret: Vec<u8>,
) -> Result<Router, unionid::Error> {
    if users.is_empty() || secret.len() < 32 {
        return Err(unionid::Error::new(
            "E_AUTH_CONFIG",
            "at least one user and a secret of 32 or more bytes are required",
        ));
    }
    let mut engine = Engine::open_redb(database_path.as_ref())?;
    if !engine.execute("from entries | take 1").ok {
        let initialized = engine.execute(SCHEMA);
        if !initialized.ok {
            return Err(initialized
                .error
                .unwrap_or_else(|| unionid::Error::new("E_SCHEMA", initialized.message)));
        }
    }
    let schema = engine.schema_info();
    if schema.revision != list_day_query::LIST_DAY_QUERY_SCHEMA_REVISION
        || schema.hash != list_day_query::LIST_DAY_QUERY_SCHEMA_HASH
    {
        return Err(unionid::Error::new(
            "E_SCHEMA_CHANGED",
            "database schema does not match the Diary schema",
        ));
    }

    let now = unix_millis();
    let latest_id = latest_entry_query::latest_entry_query(
        &mut engine,
        latest_entry_query::LatestEntryQueryParams,
    )?
    .map(|entry| entry.id);
    let next_id = latest_id.map_or(now, |id| now.max(id.saturating_add(1)));
    let state = AppState {
        engine: Arc::new(Mutex::new(engine)),
        ids: Arc::new(AtomicI64::new(next_id)),
        users: Arc::new(users),
        secret: Arc::new(secret),
    };

    Ok(Router::new()
        .route("/health", get(health))
        .route(
            "/api/auth/login",
            axum::routing::post(login).options(preflight),
        )
        .route(
            "/api/entries",
            get(list_day).post(create_entry).options(preflight),
        )
        .route(
            "/api/entries/{id}",
            put(update_entry).delete(delete_entry).options(preflight),
        )
        .route("/api/days", get(list_range).options(preflight))
        .route("/api/options", get(list_options).options(preflight))
        .layer(middleware::from_fn(cors))
        .with_state(state))
}

async fn health() -> Json<serde_json::Value> {
    Json(serde_json::json!({"ok": true, "database": "unionid"}))
}

async fn login(State(state): State<AppState>, Json(input): Json<LoginRequest>) -> ApiResult {
    let Some(expected) = state.users.get(&input.username) else {
        return Err(unauthorized());
    };
    if !password_matches(&state.secret, expected, &input.password) {
        return Err(unauthorized());
    }
    let token = issue_token(
        &state.secret,
        &input.username,
        unix_seconds() + TOKEN_TTL_SECONDS,
    );
    let response = Json(LoginResponse {
        token: token.clone(),
        username: input.username,
    })
    .into_response();
    Ok(with_session(response, &token))
}

async fn list_day(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(query): Query<DayQuery>,
) -> ApiResult {
    let session = authorize(&headers, &state)?;
    validate_date(&query.date)?;
    let mut engine = state.engine.lock().await;
    let entries: Vec<DiaryEntry> = list_day_query::list_day_query(
        &mut engine,
        list_day_query::ListDayQueryParams {
            owner: session.username.clone(),
            date: query.date,
        },
    )
    .map_err(internal_error)?
    .into_iter()
    .map(|row| DiaryEntry {
        id: row.id,
        owner: row.owner,
        date: row.date,
        field: row.field,
        content: row.content,
        created_at: row.created_at,
        updated_at: row.updated_at,
    })
    .collect();
    Ok(with_session(Json(entries).into_response(), &session.token))
}

async fn list_range(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(query): Query<RangeQuery>,
) -> ApiResult {
    let session = authorize(&headers, &state)?;
    validate_date(&query.from)?;
    validate_date(&query.to)?;
    if query.from > query.to {
        return Err(unprocessable("from must not be after to"));
    }
    let mut engine = state.engine.lock().await;
    let rows = list_range_query::list_range_query(
        &mut engine,
        list_range_query::ListRangeQueryParams {
            owner: session.username.clone(),
            from: query.from,
            to: query.to,
        },
    )
    .map_err(internal_error)?;
    let mut days: BTreeMap<String, Vec<String>> = BTreeMap::new();
    for row in rows {
        let fields = days.entry(row.date).or_default();
        if !fields.contains(&row.field) {
            fields.push(row.field);
        }
    }
    let summaries: Vec<DaySummary> = days
        .into_iter()
        .rev()
        .take(MAX_RANGE_DAYS)
        .map(|(date, mut fields)| {
            fields.sort_by_key(|field| FIELDS.iter().position(|known| known == field));
            DaySummary { date, fields }
        })
        .collect();
    Ok(with_session(
        Json(summaries).into_response(),
        &session.token,
    ))
}

/// Values used before in each tag field, most used first, then most recently used.
async fn list_options(State(state): State<AppState>, headers: HeaderMap) -> ApiResult {
    let session = authorize(&headers, &state)?;
    let mut engine = state.engine.lock().await;
    let rows = list_values_query::list_values_query(
        &mut engine,
        list_values_query::ListValuesQueryParams {
            owner: session.username.clone(),
        },
    )
    .map_err(internal_error)?;
    let mut usage: BTreeMap<String, BTreeMap<String, (usize, i64)>> = TAG_FIELDS
        .iter()
        .map(|field| ((*field).to_owned(), BTreeMap::new()))
        .collect();
    for row in rows {
        if !is_option_value(&row.content) {
            continue;
        }
        if let Some(values) = usage.get_mut(&row.field) {
            let used = values.entry(row.content).or_default();
            used.0 += 1;
            used.1 = used.1.max(row.created_at);
        }
    }
    let options: BTreeMap<String, Vec<String>> = usage
        .into_iter()
        .map(|(field, values)| {
            let mut values: Vec<(String, (usize, i64))> = values.into_iter().collect();
            values.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
            let names = values
                .into_iter()
                .take(MAX_OPTIONS_PER_FIELD)
                .map(|(name, _)| name)
                .collect();
            (field, names)
        })
        .collect();
    Ok(with_session(Json(options).into_response(), &session.token))
}

/// Longer free text recorded in a tag field stays an entry but is not offered as an option.
fn is_option_value(content: &str) -> bool {
    content.chars().count() <= MAX_OPTION_CHARS
        && !content
            .chars()
            .any(|ch| ch.is_whitespace() || matches!(ch, ',' | '，' | '、'))
}

async fn create_entry(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(input): Json<NewEntry>,
) -> ApiResult {
    let session = authorize(&headers, &state)?;
    validate_date(&input.date)?;
    if !FIELDS.contains(&input.field.as_str()) {
        return Err(unprocessable("unknown field"));
    }
    let content = checked_content(&input.content)?;
    let now = unix_millis();
    let entry = Entry {
        id: state.ids.fetch_add(1, Ordering::Relaxed),
        owner: session.username.clone(),
        date: input.date,
        field: input.field,
        content,
        created_at: now,
        updated_at: now,
    };
    let mut engine = state.engine.lock().await;
    let row = insert_entry_query::insert_entry_query(
        &mut engine,
        insert_entry_query::InsertEntryQueryParams { entry },
    )
    .map_err(internal_error)?
    .rows;
    let created = DiaryEntry {
        id: row.id,
        owner: row.owner,
        date: row.date,
        field: row.field,
        content: row.content,
        created_at: row.created_at,
        updated_at: row.updated_at,
    };
    Ok(with_session(
        (StatusCode::CREATED, Json(created)).into_response(),
        &session.token,
    ))
}

async fn update_entry(
    State(state): State<AppState>,
    headers: HeaderMap,
    AxumPath(id): AxumPath<i64>,
    Json(input): Json<EntryUpdate>,
) -> ApiResult {
    let session = authorize(&headers, &state)?;
    let content = checked_content(&input.content)?;
    let mut engine = state.engine.lock().await;
    let output = update_entry_query::update_entry_query(
        &mut engine,
        update_entry_query::UpdateEntryQueryParams {
            id,
            owner: session.username.clone(),
            content,
            updated_at: unix_millis(),
        },
    )
    .map_err(internal_error)?;
    let Some(row) = output.rows.into_iter().next() else {
        return Err(not_found());
    };
    let updated = DiaryEntry {
        id: row.id,
        owner: row.owner,
        date: row.date,
        field: row.field,
        content: row.content,
        created_at: row.created_at,
        updated_at: row.updated_at,
    };
    Ok(with_session(Json(updated).into_response(), &session.token))
}

async fn delete_entry(
    State(state): State<AppState>,
    headers: HeaderMap,
    AxumPath(id): AxumPath<i64>,
) -> ApiResult {
    let session = authorize(&headers, &state)?;
    let mut engine = state.engine.lock().await;
    let affected_rows = delete_entry_query::delete_entry_query(
        &mut engine,
        delete_entry_query::DeleteEntryQueryParams {
            id,
            owner: session.username.clone(),
        },
    )
    .map_err(internal_error)?
    .affected_rows;
    match affected_rows {
        0 => Err(not_found()),
        _ => Ok(with_session(
            StatusCode::NO_CONTENT.into_response(),
            &session.token,
        )),
    }
}

fn checked_content(content: &str) -> Result<String, (StatusCode, Json<ApiError>)> {
    let content = content.trim();
    if content.is_empty() {
        return Err(unprocessable("content must not be empty"));
    }
    Ok(content.to_owned())
}

/// Accepts calendar dates written as `YYYY-MM-DD`, so text order equals date order.
fn validate_date(date: &str) -> Result<(), (StatusCode, Json<ApiError>)> {
    let bytes = date.as_bytes();
    let shaped = bytes.len() == 10
        && bytes[4] == b'-'
        && bytes[7] == b'-'
        && bytes
            .iter()
            .enumerate()
            .all(|(index, byte)| index == 4 || index == 7 || byte.is_ascii_digit());
    let valid = shaped && {
        let year: u32 = date[0..4].parse().unwrap_or(0);
        let month: u32 = date[5..7].parse().unwrap_or(0);
        let day: u32 = date[8..10].parse().unwrap_or(0);
        let leap =
            (year.is_multiple_of(4) && !year.is_multiple_of(100)) || year.is_multiple_of(400);
        let days_in_month = match month {
            1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
            4 | 6 | 9 | 11 => 30,
            2 if leap => 29,
            2 => 28,
            _ => 0,
        };
        year > 0 && (1..=days_in_month).contains(&day)
    };
    if valid {
        Ok(())
    } else {
        Err(unprocessable("date must be a valid YYYY-MM-DD"))
    }
}

async fn preflight() -> StatusCode {
    StatusCode::NO_CONTENT
}

async fn cors(request: axum::extract::Request, next: Next) -> Response {
    let mut response = next.run(request).await;
    let headers = response.headers_mut();
    headers.insert(
        header::ACCESS_CONTROL_ALLOW_ORIGIN,
        HeaderValue::from_static("*"),
    );
    headers.insert(
        header::ACCESS_CONTROL_ALLOW_METHODS,
        HeaderValue::from_static("GET, POST, PUT, DELETE, OPTIONS"),
    );
    headers.insert(
        header::ACCESS_CONTROL_ALLOW_HEADERS,
        HeaderValue::from_static("authorization, content-type"),
    );
    headers.insert(
        header::ACCESS_CONTROL_EXPOSE_HEADERS,
        HeaderValue::from_static(SESSION_TOKEN_HEADER),
    );
    response
}

fn unix_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock is before Unix epoch")
        .as_millis() as i64
}

fn unix_seconds() -> i64 {
    unix_millis() / 1_000
}

fn parse_users(source: &str) -> Result<BTreeMap<String, String>, unionid::Error> {
    let mut users = BTreeMap::new();
    for entry in source.split(',').filter(|entry| !entry.trim().is_empty()) {
        let Some((username, password)) = entry.split_once(':') else {
            return Err(unionid::Error::new(
                "E_AUTH_CONFIG",
                "DIARY_USERS entries must use username:password",
            ));
        };
        if !valid_username(username) || password.is_empty() {
            return Err(unionid::Error::new(
                "E_AUTH_CONFIG",
                "usernames must be 3-32 ASCII letters, digits, '_' or '-' and passwords cannot be empty",
            ));
        }
        users.insert(username.to_owned(), password.to_owned());
    }
    Ok(users)
}

fn valid_username(username: &str) -> bool {
    (3..=32).contains(&username.len())
        && username
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'-'))
}

fn password_matches(secret: &[u8], expected: &str, supplied: &str) -> bool {
    let mut expected_mac = HmacSha256::new_from_slice(secret).expect("HMAC accepts any key size");
    expected_mac.update(expected.as_bytes());
    let expected_digest = expected_mac.finalize().into_bytes();

    let mut supplied_mac = HmacSha256::new_from_slice(secret).expect("HMAC accepts any key size");
    supplied_mac.update(supplied.as_bytes());
    supplied_mac.verify_slice(&expected_digest).is_ok()
}

fn issue_token(secret: &[u8], username: &str, expires_at: i64) -> String {
    let payload = format!("{username}:{expires_at}");
    let encoded = URL_SAFE_NO_PAD.encode(payload.as_bytes());
    let mut mac = HmacSha256::new_from_slice(secret).expect("HMAC accepts any key size");
    mac.update(encoded.as_bytes());
    let signature = URL_SAFE_NO_PAD.encode(mac.finalize().into_bytes());
    format!("{encoded}.{signature}")
}

fn authorize(
    headers: &HeaderMap,
    state: &AppState,
) -> Result<Session, (StatusCode, Json<ApiError>)> {
    let bearer = headers
        .get(header::AUTHORIZATION)
        .and_then(|value| value.to_str().ok())
        .and_then(|value| value.strip_prefix("Bearer "));
    let cookie = session_cookie(headers);
    let username = [bearer, cookie]
        .into_iter()
        .flatten()
        .find_map(|token| verify_token(&state.secret, token))
        .filter(|username| state.users.contains_key(username))
        .ok_or_else(unauthorized)?;
    let token = issue_token(&state.secret, &username, unix_seconds() + TOKEN_TTL_SECONDS);
    Ok(Session { username, token })
}

fn session_cookie(headers: &HeaderMap) -> Option<&str> {
    headers
        .get(header::COOKIE)?
        .to_str()
        .ok()?
        .split(';')
        .filter_map(|part| part.trim().split_once('='))
        .find_map(|(name, value)| (name == SESSION_COOKIE_NAME).then_some(value))
}

fn with_session(mut response: Response, token: &str) -> Response {
    let token_header = HeaderValue::from_str(token).expect("signed token is a valid header value");
    response
        .headers_mut()
        .insert(SESSION_TOKEN_HEADER, token_header);
    let cookie = format!(
        "{SESSION_COOKIE_NAME}={token}; Max-Age={TOKEN_TTL_SECONDS}; Path=/api; HttpOnly; Secure; SameSite=Lax"
    );
    response.headers_mut().insert(
        header::SET_COOKIE,
        HeaderValue::from_str(&cookie).expect("session cookie is a valid header value"),
    );
    response
}

fn verify_token(secret: &[u8], token: &str) -> Option<String> {
    let (encoded, signature) = token.split_once('.')?;
    let signature = URL_SAFE_NO_PAD.decode(signature).ok()?;
    let mut mac = HmacSha256::new_from_slice(secret).ok()?;
    mac.update(encoded.as_bytes());
    mac.verify_slice(&signature).ok()?;

    let payload = String::from_utf8(URL_SAFE_NO_PAD.decode(encoded).ok()?).ok()?;
    let (username, expires_at) = payload.rsplit_once(':')?;
    if !valid_username(username) || expires_at.parse::<i64>().ok()? <= unix_seconds() {
        return None;
    }
    Some(username.to_owned())
}

fn unauthorized() -> (StatusCode, Json<ApiError>) {
    (
        StatusCode::UNAUTHORIZED,
        Json(ApiError {
            error: "invalid username, password, or session".into(),
        }),
    )
}

fn not_found() -> (StatusCode, Json<ApiError>) {
    (
        StatusCode::NOT_FOUND,
        Json(ApiError {
            error: "entry not found".into(),
        }),
    )
}

fn unprocessable(message: &str) -> (StatusCode, Json<ApiError>) {
    (
        StatusCode::UNPROCESSABLE_ENTITY,
        Json(ApiError {
            error: message.into(),
        }),
    )
}

fn internal_error(error: impl ToString) -> (StatusCode, Json<ApiError>) {
    (
        StatusCode::INTERNAL_SERVER_ERROR,
        Json(ApiError {
            error: error.to_string(),
        }),
    )
}

#[cfg(test)]
mod tests {
    use axum::body::{Body, to_bytes};
    use axum::http::{Method, Request, header};
    use tower::ServiceExt;

    use super::*;

    const SECRET: &[u8] = b"test-secret-at-least-32-bytes-long";

    fn temp_database(name: &str) -> std::path::PathBuf {
        std::env::temp_dir().join(format!(
            "diary-lite-{name}-{}-{}.redb",
            std::process::id(),
            unix_millis()
        ))
    }

    fn test_users() -> BTreeMap<String, String> {
        BTreeMap::from([
            ("alice".into(), "alice-pass".into()),
            ("bob".into(), "bob-pass".into()),
        ])
    }

    fn service(database: &Path) -> Router {
        app_with_auth(database, test_users(), SECRET.to_vec()).unwrap()
    }

    async fn login_as(service: Router, username: &str, password: &str) -> String {
        let response = service
            .oneshot(
                Request::post("/api/auth/login")
                    .header(header::CONTENT_TYPE, "application/json")
                    .body(Body::from(
                        serde_json::json!({"username": username, "password": password}).to_string(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);
        let body = to_bytes(response.into_body(), usize::MAX).await.unwrap();
        serde_json::from_slice::<LoginResponse>(&body)
            .unwrap()
            .token
    }

    async fn send(
        service: Router,
        method: Method,
        uri: &str,
        token: &str,
        body: Option<serde_json::Value>,
    ) -> (StatusCode, Vec<u8>) {
        let request = Request::builder()
            .method(method)
            .uri(uri)
            .header(header::AUTHORIZATION, format!("Bearer {token}"))
            .header(header::CONTENT_TYPE, "application/json");
        let body = body.map_or_else(Body::empty, |value| Body::from(value.to_string()));
        let response = service.oneshot(request.body(body).unwrap()).await.unwrap();
        assert_eq!(response.headers()[header::ACCESS_CONTROL_ALLOW_ORIGIN], "*");
        let status = response.status();
        let body = to_bytes(response.into_body(), usize::MAX).await.unwrap();
        (status, body.to_vec())
    }

    async fn create(
        service: Router,
        token: &str,
        date: &str,
        field: &str,
        content: &str,
    ) -> DiaryEntry {
        let (status, body) = send(
            service,
            Method::POST,
            "/api/entries",
            token,
            Some(serde_json::json!({"date": date, "field": field, "content": content})),
        )
        .await;
        assert_eq!(status, StatusCode::CREATED);
        serde_json::from_slice(&body).unwrap()
    }

    async fn day(service: Router, token: &str, date: &str) -> Vec<DiaryEntry> {
        let (status, body) = send(
            service,
            Method::GET,
            &format!("/api/entries?date={date}"),
            token,
            None,
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        serde_json::from_slice(&body).unwrap()
    }

    #[test]
    fn configuration_tokens_and_dates_reject_invalid_input() {
        let database = temp_database("auth-config");
        let empty_users = app_with_auth(&database, BTreeMap::new(), SECRET.to_vec())
            .expect_err("empty users must fail");
        assert_eq!(empty_users.code, "E_AUTH_CONFIG");
        let short_secret = app_with_auth(&database, test_users(), b"too-short".to_vec())
            .expect_err("short secrets must fail");
        assert_eq!(short_secret.code, "E_AUTH_CONFIG");
        for invalid in ["alice", "al:password", "alice:", "invalid user:password"] {
            assert!(parse_users(invalid).is_err(), "input: {invalid}");
        }

        let future = issue_token(SECRET, "alice", unix_seconds() + 60);
        assert_eq!(verify_token(SECRET, &future).as_deref(), Some("alice"));
        assert!(verify_token(SECRET, &format!("{future}x")).is_none());
        assert!(verify_token(SECRET, &issue_token(SECRET, "alice", unix_seconds())).is_none());

        for valid in ["2026-11-08", "2024-02-29", "2026-12-31"] {
            assert!(validate_date(valid).is_ok(), "{valid}");
        }
        for invalid in [
            "2026-2-1",
            "2026-02-30",
            "2025-02-29",
            "2026-13-01",
            "2026/11/08",
            "0000-01-01",
        ] {
            assert!(validate_date(invalid).is_err(), "{invalid}");
        }
        assert!(!database.exists());
    }

    #[tokio::test]
    async fn entries_support_multiple_records_edits_and_deletes() {
        let database = temp_database("entries");
        let service = service(&database);
        let token = login_as(service.clone(), "alice", "alice-pass").await;

        let breakfast = create(
            service.clone(),
            &token,
            "2026-11-08",
            "food",
            "  粥和鸡蛋 \n",
        )
        .await;
        assert_eq!(breakfast.content, "粥和鸡蛋");
        assert_eq!(breakfast.created_at, breakfast.updated_at);
        let lunch = create(service.clone(), &token, "2026-11-08", "food", "面条").await;
        let text = create(service.clone(), &token, "2026-11-08", "text", "第一段").await;
        create(service.clone(), &token, "2026-11-07", "sleep", "七小时").await;

        let entries = day(service.clone(), &token, "2026-11-08").await;
        assert_eq!(
            entries.iter().map(|entry| entry.id).collect::<Vec<_>>(),
            vec![breakfast.id, lunch.id, text.id]
        );

        let (status, body) = send(
            service.clone(),
            Method::PUT,
            &format!("/api/entries/{}", lunch.id),
            &token,
            Some(serde_json::json!({"content": "牛肉面"})),
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        let edited: DiaryEntry = serde_json::from_slice(&body).unwrap();
        assert_eq!(edited.content, "牛肉面");
        assert_eq!(edited.created_at, lunch.created_at);
        assert!(edited.updated_at >= lunch.updated_at);

        let (status, _) = send(
            service.clone(),
            Method::DELETE,
            &format!("/api/entries/{}", breakfast.id),
            &token,
            None,
        )
        .await;
        assert_eq!(status, StatusCode::NO_CONTENT);
        let entries = day(service.clone(), &token, "2026-11-08").await;
        assert_eq!(entries.len(), 2);
        assert_eq!(entries[0].content, "牛肉面");

        let (status, body) = send(
            service.clone(),
            Method::GET,
            "/api/days?from=2026-11-01&to=2026-11-30",
            &token,
            None,
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        let days: Vec<DaySummary> = serde_json::from_slice(&body).unwrap();
        assert_eq!(
            days,
            vec![
                DaySummary {
                    date: "2026-11-08".into(),
                    fields: vec!["food".into(), "text".into()],
                },
                DaySummary {
                    date: "2026-11-07".into(),
                    fields: vec!["sleep".into()],
                },
            ]
        );

        drop(service);
        let _ = std::fs::remove_file(database);
    }

    #[tokio::test]
    async fn options_list_used_values_by_frequency_per_owner() {
        let database = temp_database("options");
        let service = service(&database);
        let alice = login_as(service.clone(), "alice", "alice-pass").await;
        let bob = login_as(service.clone(), "bob", "bob-pass").await;
        for (field, content) in [
            ("exercise", "跑步"),
            ("exercise", "游泳"),
            ("exercise", "游泳"),
            ("exercise", "下午和朋友 打了两小时球"),
            ("food", "面条"),
            ("mood", "开心"),
        ] {
            create(service.clone(), &alice, "2026-11-08", field, content).await;
        }

        let (status, body) = send(service.clone(), Method::GET, "/api/options", &alice, None).await;
        assert_eq!(status, StatusCode::OK);
        let options: BTreeMap<String, Vec<String>> = serde_json::from_slice(&body).unwrap();
        assert_eq!(options["exercise"], vec!["游泳", "跑步"]);
        assert_eq!(options["food"], vec!["面条"]);
        assert!(options["place"].is_empty());
        assert!(!options.contains_key("sleep"));
        assert!(!options.contains_key("mood"));

        let (_, body) = send(service.clone(), Method::GET, "/api/options", &bob, None).await;
        let options: BTreeMap<String, Vec<String>> = serde_json::from_slice(&body).unwrap();
        assert!(options["exercise"].is_empty());

        let anonymous = service
            .clone()
            .oneshot(Request::get("/api/options").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(anonymous.status(), StatusCode::UNAUTHORIZED);
        drop(service);
        let _ = std::fs::remove_file(database);
    }

    #[tokio::test]
    async fn invalid_input_is_rejected() {
        let database = temp_database("validation");
        let service = service(&database);
        let token = login_as(service.clone(), "alice", "alice-pass").await;
        for body in [
            serde_json::json!({"date": "2026-11-08", "field": "food", "content": "  \n "}),
            serde_json::json!({"date": "2026-11-08", "field": "unknown", "content": "x"}),
            serde_json::json!({"date": "2026-11-31", "field": "food", "content": "x"}),
        ] {
            let (status, _) = send(
                service.clone(),
                Method::POST,
                "/api/entries",
                &token,
                Some(body),
            )
            .await;
            assert_eq!(status, StatusCode::UNPROCESSABLE_ENTITY);
        }
        let (status, _) = send(
            service.clone(),
            Method::GET,
            "/api/days?from=2026-11-30&to=2026-11-01",
            &token,
            None,
        )
        .await;
        assert_eq!(status, StatusCode::UNPROCESSABLE_ENTITY);
        drop(service);
        let _ = std::fs::remove_file(database);
    }

    #[tokio::test]
    async fn users_are_isolated_and_data_persists() {
        let database = temp_database("isolation");
        let service = service(&database);
        let alice = login_as(service.clone(), "alice", "alice-pass").await;
        let bob = login_as(service.clone(), "bob", "bob-pass").await;
        let entry = create(service.clone(), &alice, "2026-11-08", "mood", "开心").await;

        assert!(day(service.clone(), &bob, "2026-11-08").await.is_empty());
        let (status, _) = send(
            service.clone(),
            Method::PUT,
            &format!("/api/entries/{}", entry.id),
            &bob,
            Some(serde_json::json!({"content": "hijack"})),
        )
        .await;
        assert_eq!(status, StatusCode::NOT_FOUND);
        let (status, _) = send(
            service.clone(),
            Method::DELETE,
            &format!("/api/entries/{}", entry.id),
            &bob,
            None,
        )
        .await;
        assert_eq!(status, StatusCode::NOT_FOUND);

        let anonymous = service
            .clone()
            .oneshot(
                Request::get("/api/entries?date=2026-11-08")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(anonymous.status(), StatusCode::UNAUTHORIZED);
        drop(service);

        let reopened = app_with_auth(&database, test_users(), SECRET.to_vec()).unwrap();
        let alice = login_as(reopened.clone(), "alice", "alice-pass").await;
        let next = create(reopened.clone(), &alice, "2026-11-08", "mood", "平静").await;
        assert!(next.id > entry.id);
        let entries = day(reopened.clone(), &alice, "2026-11-08").await;
        assert_eq!(entries.len(), 2);
        assert_eq!(entries[0].content, "开心");
        drop(reopened);
        let _ = std::fs::remove_file(database);
    }

    #[tokio::test]
    async fn preflight_and_session_cookie() {
        let database = temp_database("cors");
        let service = service(&database);
        let preflight = service
            .clone()
            .oneshot(
                Request::builder()
                    .method(Method::OPTIONS)
                    .uri("/api/entries/1")
                    .header(header::ORIGIN, "http://127.0.0.1:5173")
                    .header(header::ACCESS_CONTROL_REQUEST_METHOD, "PUT")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(preflight.status(), StatusCode::NO_CONTENT);
        assert_eq!(
            preflight.headers()[header::ACCESS_CONTROL_ALLOW_METHODS],
            "GET, POST, PUT, DELETE, OPTIONS"
        );

        let login = service
            .clone()
            .oneshot(
                Request::post("/api/auth/login")
                    .header(header::CONTENT_TYPE, "application/json")
                    .body(Body::from(
                        serde_json::json!({"username": "alice", "password": "alice-pass"})
                            .to_string(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();
        let cookie = login.headers()[header::SET_COOKIE].to_str().unwrap();
        assert!(cookie.starts_with("diary_session="));
        assert!(cookie.contains("Max-Age=259200"));
        let cookie_pair = cookie.split(';').next().unwrap().to_owned();
        let renewed = service
            .oneshot(
                Request::get("/api/entries?date=2026-11-08")
                    .header(header::COOKIE, cookie_pair)
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(renewed.status(), StatusCode::OK);
        assert!(renewed.headers().contains_key(SESSION_TOKEN_HEADER));
        let _ = std::fs::remove_file(database);
    }

    #[test]
    fn unexpected_schema_drift_is_rejected() {
        let database = temp_database("schema-drift");
        drop(service(&database));
        let mut engine = Engine::open_redb(&database).unwrap();
        let changed = engine.execute("type Unexpected = text");
        assert!(changed.ok, "{}", changed.message);
        drop(engine);
        let error = app_with_auth(&database, test_users(), SECRET.to_vec())
            .expect_err("schema drift must fail closed");
        assert_eq!(error.code, "E_SCHEMA_CHANGED");
        let _ = std::fs::remove_file(database);
    }
}
