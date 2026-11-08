use std::net::SocketAddr;
use std::path::PathBuf;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let address: SocketAddr = std::env::var("DIARY_ADDR")
        .unwrap_or_else(|_| "127.0.0.1:11031".into())
        .parse()?;
    let database = std::env::var_os("DIARY_DB")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("data/diary.redb"));
    if let Some(parent) = database.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let listener = tokio::net::TcpListener::bind(address).await?;
    println!("diary-lite API listening on http://{address}");
    axum::serve(listener, diary_lite::app(database)?).await?;
    Ok(())
}
