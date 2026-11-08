
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {}
    :default $ {} (:description |) (:init-fn 'app.diary/main!) (:mode :native) (:reload-fn 'app.diary/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |js-ffi/
      :type-slots $ {}
    :server $ {} (:description |) (:init-fn 'app.diary/main!) (:mode :native) (:reload-fn 'app.diary/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |js-ffi/
      :type-slots $ {}
  :files $ {} $ 'app.diary
    %{} 'FileEntry
      :defs $ {}
        '*cal-selected $ %{} 'CodeEntry
          :doc "|Date inspected in the calendar panel; empty hides the panel."
          :code $ quote $ defref *cal-selected
            day-key $ today-noon-ms
          :examples $ []
          :schema $ quote $ Ref String
        '*day-ms $ %{} 'CodeEntry
          :doc "|Local noon of the visible day, so stepping by 24h never skips a day across DST."
          :code $ quote $ defref *day-ms (today-noon-ms)
          :examples $ []
          :schema $ quote $ Ref Number
        '*days $ %{} 'CodeEntry
          :doc "|Recorded tag keys by date; dates without records are absent."
          :code $ quote $ defref *days
            assert-type ({})
              Map String $ List String
          :examples $ []
          :schema $ quote $ Ref
            Map String $ List String
        '*editing $ %{} 'CodeEntry
          :doc "|Id of the entry being edited; 0 when composing a new entry."
          :code $ quote $ defref *editing 0
          :examples $ []
          :schema $ quote $ Ref Number
        '*entries $ %{} 'CodeEntry (:doc "|Entries of the visible day, oldest first.")
          :code $ quote $ defref *entries ([])
          :examples $ []
          :schema $ quote $ Ref (List app.diary/DiaryEntry)
        '*month $ %{} 'CodeEntry (:doc "|Month shown by the calendar page.")
          :code $ quote $ defref *month
            month-of-key $ day-key $ today-noon-ms
          :examples $ []
          :schema $ quote $ Ref app.diary/YearMonth
        '*options $ %{} 'CodeEntry
          :doc "|Values used before, by tag key, from /api/options."
          :code $ quote $ defref *options
            assert-type ({})
              Map String $ List String
          :examples $ []
          :schema $ quote $ Ref
            Map String $ List String
        '*pending-delete $ %{} 'CodeEntry
          :doc "|Id of the entry whose delete button awaits a second click; 0 when none."
          :code $ quote $ defref *pending-delete 0
          :examples $ []
          :schema $ quote $ Ref Number
        '*pop-field $ %{} 'CodeEntry
          :doc "|Tag that just gained a record and should play its feedback animation on the next render."
          :code $ quote $ defref *pop-field |
          :examples $ []
          :schema $ quote $ Ref String
        '*queue $ %{} 'CodeEntry
          :doc "|Tag changes waiting to be saved, applied one at a time so quick taps cannot race."
          :code $ quote $ defref *queue
            assert-type ([]) (List app.diary/QueueItem)
          :examples $ []
          :schema $ quote $ Ref (List app.diary/QueueItem)
        '*queue-running $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *queue-running false
          :examples $ []
          :schema $ quote $ Ref Bool
        '*selected $ %{} 'CodeEntry
          :doc "|Key of the opened tag; empty when no tag is open."
          :code $ quote $ defref *selected |
          :examples $ []
          :schema $ quote $ Ref String
        '*sheet-pushed $ %{} 'CodeEntry
          :doc "|True when the open sheet owns a history entry, so closing it can go back instead of stacking entries."
          :code $ quote $ defref *sheet-pushed false
          :examples $ []
          :schema $ quote $ Ref Bool
        '*swipe-x $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *swipe-x 0
          :examples $ []
          :schema $ quote $ Ref Number
        '*swipe-y $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *swipe-y 0
          :examples $ []
          :schema $ quote $ Ref Number
        '*swiped $ %{} 'CodeEntry
          :doc "|True when the current touch became a swipe, so its trailing click is ignored."
          :code $ quote $ defref *swiped false
          :examples $ []
          :schema $ quote $ Ref Bool
        '*touch? $ %{} 'CodeEntry
          :doc "|Whether the latest pointer was a finger; touch users get the keyboard dismissed after saving."
          :code $ quote $ defref *touch? false
          :examples $ []
          :schema $ quote $ Ref Bool
        '*view $ %{} 'CodeEntry (:doc "|Active page: day, calendar or me.")
          :code $ quote $ defref *view |day
          :examples $ []
          :schema $ quote $ Ref String
        'DaySummary $ %{} 'CodeEntry (:doc "|Tags recorded on one date, from /api/days.")
          :code $ quote $ defstruct DaySummary (:date String)
            :fields $ List String
          :examples $ []
          :schema $ quote StructDef
        'DiaryEntry $ %{} 'CodeEntry
          :doc "|A decoded record returned by the backend; one tag may hold several of them."
          :code $ quote $ defstruct DiaryEntry (:id Number) (:field String) (:content String) (:created-at Number) (:updated-at Number)
          :examples $ []
          :schema $ quote StructDef
        'EntryArrayHost $ %{} 'CodeEntry (:doc "|JSON array of entries returned by fetch.")
          :code $ quote $ deftrait EntryArrayHost (:length Number)
            .for-each! $ Fn app.diary/EntryArrayHost
              Fn JsObject Number JsObject $ -> Unit
              -> Unit
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} $ :for-each! |forEach
          :schema $ quote Trait
        'FieldSpec $ %{} 'CodeEntry
          :doc "|One big diary tag: storage key, display label and the guiding question."
          :code $ quote $ defstruct FieldSpec (:key String) (:label String) (:hint String)
          :examples $ []
          :schema $ quote StructDef
        'LocalDateHost $ %{} 'CodeEntry
          :doc "|Local calendar fields of a host Date, used for day keys and clock labels."
          :code $ quote $ deftrait LocalDateHost
            .get-full-year $ Fn app.diary/LocalDateHost $ -> Number
            .get-month $ Fn app.diary/LocalDateHost $ -> Number
            .get-date $ Fn app.diary/LocalDateHost $ -> Number
            .get-day $ Fn app.diary/LocalDateHost $ -> Number
            .get-hours $ Fn app.diary/LocalDateHost $ -> Number
            .get-minutes $ Fn app.diary/LocalDateHost $ -> Number
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} (:get-date |getDate) (:get-day |getDay) (:get-full-year |getFullYear) (:get-hours |getHours) (:get-minutes |getMinutes) (:get-month |getMonth)
          :schema $ quote Trait
        'QueueItem $ %{} 'CodeEntry
          :doc "|One pending tag change; adds carry their date and tag so they stay correct if the page moves on."
          :code $ quote $ defstruct QueueItem (:date String) (:field String) (:value String) (:add? Bool)
          :examples $ []
          :schema $ quote StructDef
        'Route $ %{} 'CodeEntry
          :doc "|Decoded location hash; the hash is the single source of truth for navigation."
          :code $ quote $ defstruct Route (:view String) (:day String) (:field String) (:month app.diary/YearMonth)
          :examples $ []
          :schema $ quote StructDef
        'YearMonth $ %{} 'CodeEntry (:doc "|A calendar month with a 1-based month number.")
          :code $ quote $ defstruct YearMonth (:year Number) (:month Number)
          :examples $ []
          :schema $ quote StructDef
        'add-months $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-months (month delta)
            let
                total $ +
                  * 12 $ :year month
                  - (:month month) 1
                  , delta
              YearMonth :year
                floor $ / total 12
                , :month $ + 1 $ floor-mod total 12
          :examples $ []
          :schema $ quote $ Fn app.diary/YearMonth Number (-> app.diary/YearMonth)
          :tests $ [] $ %{} 'TestEntry (:name |wraps-across-years)
            :code $ quote $ do
              assert= |2027-01 $ month-key $ add-months (YearMonth :year 2026 :month 12) 1
              assert= |2025-12 $ month-key $ add-months (YearMonth :year 2026 :month 1) -1
        'api-base $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def api-base
            let
                location $ browser/location-snapshot
                hostname $ location :hostname
                query $ shared/search-params-create $ location :search
                environment $ option:unwrap-or (shared/search-params-get query |env) |
                local-host? $ or (= hostname |localhost) (= hostname |127.0.0.1)
              if
                and local-host? $ not= environment |prod
                , |http://127.0.0.1:11031 |https://diary-lite.chenyong.life
          :examples $ []
          :schema $ quote String
        'api-request! $ %{} 'CodeEntry
          :doc "|Sends one authorized request; resolves to the response, renewing the sliding session token on the way."
          :code $ quote $ defn api-request! (path method body) (hint-fn Async)
            let
                request $ js-await $ shared/fetch-request (str api-base path) method (auth-headers) body
              match request
                (:ok response)
                  do
                    store-renewed-token! $ shared/headers-get (response :headers) |x-diary-token
                    , response
                (:err error) (raise error)
          :examples $ []
          :schema $ quote $ Fn String js-ffi.shared/HttpMethod (Option String) (-> js-ffi.shared/ResponseHost) (:features :js-ffi) (:async)
        'apply-queue-item! $ %{} 'CodeEntry
          :doc "|Saves one change and reports success. Removing a value not on screen is a no-op."
          :code $ quote $ defn apply-queue-item! (item) (hint-fn Async)
            try
              if (:add? item)
                let
                    response $ js-await $ api-request! |/api/entries (%:: shared/HttpMethod :post)
                      Option :some $ contract/expect-string |body $ js/JSON.stringify
                        js-object
                          :date $ :date item
                          :field $ :field item
                          :content $ :value item
                  when
                    not $ response :ok?
                    handle-failure! (response :status) "|保存失败"
                  when (response :ok?)
                    reset! *pop-field $ :field item
                  response :ok?
                let
                    matches $ if
                      = (:date item) (day-key @*day-ms)
                      &list:filter
                        entries-of $ :field item
                        fn (entry)
                          = (:value item) (:content entry)
                      assert-type ([]) (List app.diary/DiaryEntry)
                  if (empty? matches) true $ let
                      response $ js-await $ api-request!
                        str |/api/entries/ $ :id $ &list:nth matches 0
                        %:: shared/HttpMethod :delete
                        Option :none
                    when
                      not $ response :ok?
                      handle-failure! (response :status) "|删除失败"
                    response :ok?
              fn (error) (shared/console-error! |Failed-to-save-tag) (set-status! "|保存失败" |error) false
          :examples $ []
          :schema $ quote $ Fn app.diary/QueueItem (-> Bool) (:features :js-ffi) (:async)
        'apply-route! $ %{} 'CodeEntry
          :doc "|Moves application state to the location hash, animates what changed and loads data that is not on screen yet."
          :code $ quote $ defn apply-route! (load?)
            let
                route $ parse-route
                  :hash $ browser/location-snapshot
                  day-key $ today-noon-ms
                view $ :view route
                view-changed? $ not= view @*view
                prev-day $ day-key @*day-ms
                prev-month $ month-key @*month
                prev-index $ month-index @*month
                next-day $ :day route
                day-changed? $ and (= view |day) (not= next-day prev-day)
                field-changed? $ not= @*selected $ :field route
                month-changed? $ and (= view |calendar)
                  not= prev-month $ month-key $ :month route
              reset! *view view
              when day-changed?
                reset! *day-ms $ key->noon-ms next-day
                reset! *entries $ []
              sync-selected! (:field route) day-changed?
              when month-changed?
                reset! *month $ :month route
                reset! *cal-selected $ if
                  =
                    month-key $ :month route
                    &str:slice
                      day-key $ today-noon-ms
                      , 0 7
                  day-key $ today-noon-ms
                  , |
              render!
              when
                and field-changed?
                  not= | $ :field route
                  or (not @*touch?)
                    and
                      empty? $ entries-of $ :field route
                      not $ tag-field? $ :field route
                browser/element-focus! $ by-id |#entry-content
              when view-changed? $ replay-class!
                by-id $ str |#view- view
                , |view-in
              when day-changed? $ replay-class! (by-id |#tags)
                if (day-after? next-day prev-day) |slide-next |slide-prev
              when month-changed? $ replay-class! (by-id |#cal-grid)
                if
                  >
                    month-index $ :month route
                    , prev-index
                  , |slide-next |slide-prev
              when
                and load? (or view-changed? day-changed? month-changed?)
                  option:some? $ get-token
                load-current!
              , &unit
          :examples $ []
          :schema $ quote $ Fn Bool (-> Unit) (:features :js-ffi)
        'auth-headers $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn auth-headers ()
            let
                token $ option:unwrap-or (get-token) |
                headers $ shared/headers-create
              shared/headers-set! headers |Content-Type |application/json
              shared/headers-set! headers |Authorization $ str "|Bearer " token
              , headers
          :examples $ []
          :schema $ quote $ Fn (-> js-ffi.shared/HeadersHost) (:features :js-ffi)
        'by-id $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn by-id (selector)
            option:unwrap $ browser/query-selector selector
          :examples $ []
          :schema $ quote $ Fn String (-> js-ffi.browser/DomElementHost) (:features :js-ffi)
        'cancel-edit! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn cancel-edit! () (reset! *editing 0) (load-composer!) (render!)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'clock-label $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn clock-label (ms)
            let
                d $ local-date ms
              str
                two-digits $ d .get-hours
                , |: $ two-digits $ d .get-minutes
          :examples $ []
          :schema $ quote $ Fn Number (-> String) (:features :js-ffi)
        'close-detail! $ %{} 'CodeEntry
          :doc "|Closes the sheet; going back drops its history entry, so the back gesture is not left with a stale step."
          :code $ quote $ defn close-detail! ()
            when (not= @*selected |)
              if @*sheet-pushed
                do (reset! *sheet-pushed false) (js/history.back)
                replace-route! $ str |#/day/ $ day-key @*day-ms
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'day-after? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn day-after? (key other)
            >
              option:unwrap-or (key-day-number key) 0
              option:unwrap-or (key-day-number other) 0
          :examples $ []
          :schema $ quote $ Fn String String (-> Bool)
        'day-key $ %{} 'CodeEntry
          :doc "|YYYY-MM-DD of a local timestamp; this is the date key stored by the backend."
          :code $ quote $ defn day-key (ms)
            let
                d $ local-date ms
              str (d .get-full-year) |-
                two-digits $ + 1 $ d .get-month
                , |- $ two-digits $ d .get-date
          :examples $ []
          :schema $ quote $ Fn Number (-> String) (:features :js-ffi)
        'day-length $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def day-length 86400000
          :examples $ []
          :schema $ quote Number
        'day-state $ %{} 'CodeEntry
          :doc "|complete when every tag has a record, partial when some are missing, none when nothing was written."
          :code $ quote $ defn day-state (recorded total)
            cond
                = recorded 0
                , |none
              (>= recorded total) |complete
              true |partial
          :examples $ []
          :schema $ quote $ Fn Number Number (-> String)
          :tests $ [] $ %{} 'TestEntry (:name |classifies-days)
            :code $ quote $ do
              assert= |none $ day-state 0 9
              assert= |partial $ day-state 4 9
              assert= |complete $ day-state 9 9
        'day-title $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn day-title (ms)
            let
                d $ local-date ms
                weekdays $ [] "|周日" "|周一" "|周二" "|周三" "|周四" "|周五" "|周六"
                offset $ round $ /
                  - ms $ today-noon-ms
                  , day-length
                relative $ cond
                    = offset 0
                    , "| · 今天"
                  (= offset -1) "| · 昨天"
                  (= offset 1) "| · 明天"
                  true |
              str
                + 1 $ d .get-month
                , "|月" (d .get-date) "|日 "
                  &list:nth weekdays $ d .get-day
                  , relative
          :examples $ []
          :schema $ quote $ Fn Number (-> String) (:features :js-ffi)
        'days-from-civil $ %{} 'CodeEntry
          :doc "|Days since 1970-01-01 of a proleptic Gregorian date; pure, so calendar layout never depends on the host timezone."
          :code $ quote $ defn days-from-civil (year month day)
            let
                y $ if (<= month 2) (- year 1) year
                era $ floor $ / y 400
                yoe $ - y $ * era 400
                mp $ floor-mod (+ month 9) 12
                doy $ +
                  floor $ /
                    + 2 $ * 153 mp
                    , 5
                  - day 1
                doe $ + (* yoe 365)
                  floor $ / yoe 4
                  - 0 $ floor $ / yoe 100
                  , doy
              -
                + doe $ * era 146097
                , 719468
          :examples $ []
          :schema $ quote $ Fn Number Number Number (-> Number)
          :tests $ [] $ %{} 'TestEntry (:name |counts-from-unix-epoch)
            :code $ quote $ do
              assert= 0 $ days-from-civil 1970 1 1
              assert= 59 $ days-from-civil 1970 3 1
              assert= 19782 $ days-from-civil 2024 2 29
              assert= -1 $ days-from-civil 1969 12 31
        'days-in-month $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn days-in-month (year month)
            let
                next-year $ if (= month 12) (+ year 1) year
                next-month $ if (= month 12) 1 $ + month 1
              - (days-from-civil next-year next-month 1) (days-from-civil year month 1)
          :examples $ []
          :schema $ quote $ Fn Number Number (-> Number)
          :tests $ [] $ %{} 'TestEntry (:name |handles-leap-years-and-december)
            :code $ quote $ do
              assert= 29 $ days-in-month 2024 2
              assert= 28 $ days-in-month 2026 2
              assert= 31 $ days-in-month 2026 12
        'decode-entries $ %{} 'CodeEntry
          :doc "|Checks every field of the fetched JSON array and copies it into DiaryEntry values."
          :code $ quote $ defn decode-entries (value)
            if (js/Array.isArray value)
              let
                  host $ unsafe-coerce value EntryArrayHost
                  *acc $ ref $ assert-type ([]) (List app.diary/DiaryEntry)
                host .for-each! $ fn (raw _index _array)
                  swap! *acc conj $ decode-entry raw
                  , &unit
                , @*acc
              raise |Expected-entries-array
          :examples $ []
          :schema $ quote $ Fn JsObject
            -> $ List app.diary/DiaryEntry
            :features :js-ffi
        'decode-entry $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-entry (raw)
            let
                entry $ contract/expect-object |entry raw
              DiaryEntry :id
                contract/expect-number |id $ contract/object-field |entry entry |id
                , :field
                  contract/expect-string |field $ contract/object-field |entry entry |field
                  , :content
                    contract/expect-string |content $ contract/object-field |entry entry |content
                    , :created-at
                      contract/expect-number |created_at $ contract/object-field |entry entry |created_at
                      , :updated-at $ contract/expect-number |updated_at $ contract/object-field |entry entry |updated_at
          :examples $ []
          :schema $ quote $ Fn JsObject (-> app.diary/DiaryEntry) (:features :js-ffi)
        'decode-strings $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-strings (value)
            if (js/Array.isArray value)
              let
                  host $ unsafe-coerce value EntryArrayHost
                  *acc $ ref $ assert-type ([]) (List String)
                host .for-each! $ fn (raw _index _array)
                  swap! *acc conj $ contract/expect-string |field raw
                  , &unit
                , @*acc
              raise |Expected-strings-array
          :examples $ []
          :schema $ quote $ Fn (JsNullish JsObject)
            -> $ List String
            :features :js-ffi
        'decode-summaries $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-summaries (value)
            if (js/Array.isArray value)
              let
                  host $ unsafe-coerce value EntryArrayHost
                  *acc $ ref $ assert-type ([]) (List app.diary/DaySummary)
                host .for-each! $ fn (raw _index _array)
                  let
                      summary $ contract/expect-object |summary raw
                      raw-fields $ contract/object-field |summary summary |fields
                    swap! *acc conj $ DaySummary :date
                      contract/expect-string |date $ contract/object-field |summary summary |date
                      , :fields $ decode-strings raw-fields
                  , &unit
                , @*acc
              raise |Expected-summaries-array
          :examples $ []
          :schema $ quote $ Fn JsObject
            -> $ List app.diary/DaySummary
            :features :js-ffi
        'delete-entry! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn delete-entry! (id) (hint-fn Async)
            try
              let
                  response $ js-await $ api-request! (str |/api/entries/ id) (%:: shared/HttpMethod :delete) (Option :none)
                reset! *pending-delete 0
                if (response :ok?)
                  do
                    when (= id @*editing) (cancel-edit!)
                    set-status! "|已删除" |online
                    js-await $ load-day!
                  handle-failure! (response :status) "|删除失败"
              fn (error) (shared/console-error! |Failed-to-delete-entry) (set-status! "|删除失败" |error)
          :examples $ []
          :schema $ quote $ Fn Number (-> Unit) (:features :js-ffi) (:async)
        'draft-key $ %{} 'CodeEntry
          :doc "|localStorage key of the unsent text of one tag on one date."
          :code $ quote $ defn draft-key (date field)
            str |diary-lite-draft: (browser/storage-get-or user-key |) |: date |: field
          :examples $ []
          :schema $ quote $ Fn String String (-> String) (:features :js-ffi)
        'enqueue! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn enqueue! (items)
            reset! *queue $ concat @*queue items
            render-detail!
            render-tags!
            when
              and (not @*queue-running)
                not $ empty? @*queue
              reset! *queue-running true
              run-queue!
            , &unit
          :examples $ []
          :schema $ quote $ Fn (List app.diary/QueueItem) (-> Unit) (:features :js-ffi)
        'entries-of $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn entries-of (key)
            &list:filter @*entries $ fn (entry)
              = key $ :field entry
          :examples $ []
          :schema $ quote $ Fn String
            -> $ List app.diary/DiaryEntry
        'field-specs $ %{} 'CodeEntry
          :doc "|Diary tags, following the record items of topixim/diary."
          :code $ quote $ def field-specs
            [] (FieldSpec :key |food :label "|食物" :hint "|吃了什么？") (FieldSpec :key |sleep :label "|睡眠" :hint "|睡得怎么样？") (FieldSpec :key |mood :label "|心情" :hint "|感觉如何？") (FieldSpec :key |place :label "|地点" :hint "|去了哪里？") (FieldSpec :key |highlight :label "|亮点" :hint "|今天的亮点？") (FieldSpec :key |met :label "|见面" :hint "|见了谁？") (FieldSpec :key |exercise :label "|运动" :hint "|做了什么运动？") (FieldSpec :key |pains :label "|病痛" :hint "|哪里不舒服？") (FieldSpec :key |text :label "|正文" :hint "|今天想记下的事，可以分几段提交。")
          :examples $ []
          :schema $ quote $ List app.diary/FieldSpec
        'fields-of-day $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn fields-of-day (key)
            option:unwrap-or (&map:get @*days key)
              assert-type ([]) (List String)
          :examples $ []
          :schema $ quote $ Fn String
            -> $ List String
        'find-spec $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn find-spec (key)
            find field-specs $ fn (spec)
              = key $ :key spec
          :examples $ []
          :schema $ quote $ Fn String
            -> $ Option app.diary/FieldSpec
        'floor-mod $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn floor-mod (a b)
            - a $ * b $ floor (/ a b)
          :examples $ []
          :schema $ quote $ Fn Number Number (-> Number)
        'get-token $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn get-token () (browser/storage-get token-key)
          :examples $ []
          :schema $ quote $ Fn
            -> $ Option String
            :features :js-ffi
        'group-entries $ %{} 'CodeEntry
          :doc "|Merges neighbouring short values created close together into display groups; stored entries stay separate, and longer text keeps its own row."
          :code $ quote $ defn group-entries (entries)
            foldl entries
              assert-type ([])
                List $ List app.diary/DiaryEntry
              fn (acc entry)
                if (empty? acc)
                  conj acc $ [] entry
                  let
                      group $ &list:nth acc $ - (count acc) 1
                      previous $ &list:nth group $ - (count group) 1
                    if
                      and
                        short-value? $ :content entry
                        short-value? $ :content previous
                        <=
                          - (:created-at entry) (:created-at previous)
                          , group-gap-ms
                      conj
                        &list:slice acc 0 $ - (count acc) 1
                        conj group entry
                      conj acc $ [] entry
          :examples $ []
          :schema $ quote $ Fn (List app.diary/DiaryEntry)
            -> $ List $ List app.diary/DiaryEntry
          :tests $ [] $ %{} 'TestEntry (:name |groups-close-short-values)
            :code $ quote $ let
                item $ fn (id content at)
                  DiaryEntry :id id :field |food :content content :created-at at :updated-at at
                sizes $ fn (entries)
                  &list:map (group-entries entries)
                    fn (group) (count group)
              assert= ([])
                sizes $ []
              assert= ([] 3)
                sizes $ [] (item 1 |a 0) (item 2 |b 60000) (item 3 |c 360000)
              assert= ([] 2 1)
                sizes $ [] (item 1 |a 0) (item 2 |b 300000) (item 3 |c 600001)
              assert= ([] 1 1 1)
                sizes $ [] (item 1 |a 0) (item 2 "|two words" 1000) (item 3 |c 2000)
        'group-gap-ms $ %{} 'CodeEntry
          :doc "|Tag entries created within this gap of the previous one are shown together."
          :code $ quote $ def group-gap-ms 300000
          :examples $ []
          :schema $ quote Number
        'handle-failure! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-failure! (status label)
            if (= 401 status) (logout!) (set-status! label |error)
          :examples $ []
          :schema $ quote $ Fn Number String (-> Unit)
        'handle-shortcut! $ %{} 'CodeEntry
          :doc "|Desktop keys outside text fields: 1-9 open a tag, arrows step days or months, Esc closes the panel."
          :code $ quote $ defn handle-shortcut! (event)
            let
                key-event $ browser/keyboard-event-host event
                key $ key-event :key
                target $ browser/event-target-element event
                typing? $ and (option:some? target)
                  browser/element-matches? (option:unwrap target) "|input, textarea"
                modified? $ or (key-event :meta-key?) (key-event :ctrl-key?) (key-event :alt-key?)
                signed-in? $ option:some? $ get-token
              when
                and signed-in? (not typing?) (not modified?)
                cond
                    = key |Escape
                    close-detail!
                  (= key |ArrowLeft) (shift-current! -1)
                  (= key |ArrowRight) (shift-current! 1)
                  (and (= @*view |day) (= 1 (count key)))
                    let
                        index $ option:unwrap-or (parse-digits key) 0
                      when
                        and (>= index 1)
                          <= index $ count field-specs
                        key-event .prevent-default!
                        select-field! $ :key $ &list:nth field-specs (- index 1)
                  true &unit
              , &unit
          :examples $ []
          :schema $ quote $ Fn js-ffi.browser/EventHost (-> Unit) (:features :js-ffi)
        'key->noon-ms $ %{} 'CodeEntry
          :doc "|Local noon of a date key, anchored on today so DST only moves it within the same day."
          :code $ quote $ defn key->noon-ms (key)
            let
                today $ today-noon-ms
              + today $ * day-length $ -
                option:unwrap-or (key-day-number key) 0
                option:unwrap-or
                  key-day-number $ day-key today
                  , 0
          :examples $ []
          :schema $ quote $ Fn String (-> Number) (:features :js-ffi)
        'key-day-number $ %{} 'CodeEntry
          :doc "|Day number of a YYYY-MM-DD key, none when it is not a real date."
          :code $ quote $ defn key-day-number (key)
            if
              and
                = 10 $ count key
                = |- $ &str:slice key 7 8
              let
                  month $ parse-month $ &str:slice key 0 7
                  day $ parse-digits $ &str:slice key 8 10
                if
                  and (option:some? month) (option:some? day)
                  let
                      ym $ option:unwrap month
                      d $ option:unwrap day
                    if
                      and (>= d 1)
                        <= d $ days-in-month (:year ym) (:month ym)
                      Option :some $ days-from-civil (:year ym) (:month ym) d
                      Option :none
                  Option :none
              Option :none
          :examples $ []
          :schema $ quote $ Fn String
            -> $ Option Number
          :tests $ [] $ %{} 'TestEntry (:name |validates-calendar-dates)
            :code $ quote $ do
              assert= true $ option:some? $ key-day-number |2024-02-29
              assert= true $ option:none? $ key-day-number |2026-02-29
              assert= true $ option:none? $ key-day-number |2026-1-1
        'load-composer! $ %{} 'CodeEntry
          :doc "|Fills the composer with the saved draft of the open tag, so long text survives switching tags, days or an expired session."
          :code $ quote $ defn load-composer! ()
            browser/element-set-value! (by-id |#entry-content)
              if (= @*selected |) | $ browser/storage-get-or
                draft-key (day-key @*day-ms) @*selected
                , |
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'load-current! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-current! ()
            when (empty? @*options) (load-options!)
            cond
                = @*view |calendar
                load-month!
              (= @*view |me) (load-year!)
              true $ load-day!
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'load-day! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-day! () (hint-fn Async)
            try
              let
                  date $ day-key @*day-ms
                  response $ js-await $ api-request! (str |/api/entries?date= date) (%:: shared/HttpMethod :get) (Option :none)
                if (response :ok?)
                  let
                      result $ js-await $ shared/response-json response
                    match result
                      (:ok data)
                        if
                          = date $ day-key @*day-ms
                          do
                            reset! *entries $ decode-entries data
                            sync-day-summary! date
                            show-board! $ option:unwrap-or (browser/storage-get user-key) |
                            render!
                            set-status! "|已同步" |online
                          , &unit
                      (:err error) (raise error)
                  handle-failure! (response :status) "|加载失败"
              fn (error) (shared/console-error! |Failed-to-load-day) (set-status! "|连接失败" |error)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
        'load-month! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-month! ()
            let
                date-keys $ month-keys @*month
              load-range! (&list:nth date-keys 0)
                &list:nth date-keys $ - (count date-keys) 1
                , date-keys
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'load-options! $ %{} 'CodeEntry
          :doc "|Refreshes the value history; on failure the presets keep working. Called when the panel closes, not after each save, so options never move while they are being tapped."
          :code $ quote $ defn load-options! () (hint-fn Async)
            try
              let
                  response $ js-await $ api-request! |/api/options (%:: shared/HttpMethod :get) (Option :none)
                when (response :ok?)
                  let
                      result $ js-await $ shared/response-json response
                    match result
                      (:ok data)
                        let
                            object $ contract/expect-object |options data
                          reset! *options $ foldl ([] |food |sleep |place |exercise |pains) @*options $ fn (acc key)
                            assoc acc key $ decode-strings $ contract/object-field |options object key
                          , &unit
                      (:err error) (raise error)
                , &unit
              fn (error) (shared/console-error! |Failed-to-load-options) &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
        'load-range! $ %{} 'CodeEntry
          :doc "|Refreshes the summaries of the given dates; dates missing from the response had their records removed."
          :code $ quote $ defn load-range! (from to date-keys) (hint-fn Async)
            try
              let
                  response $ js-await $ api-request! (str |/api/days?from= from |&to= to) (%:: shared/HttpMethod :get) (Option :none)
                if (response :ok?)
                  let
                      result $ js-await $ shared/response-json response
                    match result
                      (:ok data)
                        let
                            cleared $ foldl date-keys @*days $ fn (acc key) (dissoc acc key)
                          reset! *days $ foldl (decode-summaries data) cleared $ fn (acc summary)
                            assoc acc (:date summary) (:fields summary)
                          show-board! $ option:unwrap-or (browser/storage-get user-key) |
                          render!
                          set-status! "|已同步" |online
                      (:err error) (raise error)
                  handle-failure! (response :status) "|加载失败"
              fn (error) (shared/console-error! |Failed-to-load-days) (set-status! "|连接失败" |error)
          :examples $ []
          :schema $ quote $ Fn String String (List String) (-> Unit) (:features :js-ffi) (:async)
        'load-year! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-year! ()
            let
                date-keys $ year-keys
              load-range!
                &list:nth date-keys $ - (count date-keys) 1
                &list:nth date-keys 0
                , date-keys
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'local-date $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn local-date (ms)
            unsafe-coerce (shared/date-from-ms ms) LocalDateHost
          :examples $ []
          :schema $ quote $ Fn Number (-> app.diary/LocalDateHost) (:features :js-ffi)
        'login! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn login! () (hint-fn Async)
            try
              let
                  username $ browser/element-value $ by-id |#username
                  password-input $ by-id |#password
                  password $ browser/element-value password-input
                  headers $ shared/headers-create
                shared/headers-set! headers |Content-Type |application/json
                let
                    request $ js-await $ shared/fetch-request (str api-base |/api/auth/login) (%:: shared/HttpMethod :post) headers
                      Option :some $ contract/expect-string |body $ js/JSON.stringify
                        js-object (:username username) (:password password)
                  match request
                    (:ok response)
                      if (response :ok?)
                        let
                            data-result $ js-await $ shared/response-json response
                          match data-result
                            (:ok data)
                              let
                                  token $ contract/expect-string |token $ contract/object-field |login-response data |token
                                  user $ contract/expect-string |username $ contract/object-field |login-response data |username
                                browser/storage-set! token-key token
                                browser/storage-set! user-key user
                                browser/element-set-value! password-input |
                                set-status! "|正在同步" |online
                                load-current!
                            (:err error) (raise error)
                        set-status! "|登录失败" |error
                    (:err error) (raise error)
              fn (error) (shared/console-error! |Failed-to-login) (set-status! "|登录失败" |error)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
        'logout! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn logout! () (browser/storage-remove! token-key) (browser/storage-remove! user-key)
            reset! *entries $ []
            reset! *days $ assert-type ({})
              Map String $ List String
            browser/history-replace-state! |#/
            apply-route! false
            show-login!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (wire-events!) (apply-route! false)
            if
              option:some? $ get-token
              do (set-status! "|验证登录" |online) (load-current!)
              show-login!
            println |Diary-Lite-started
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'monday-index $ %{} 'CodeEntry
          :doc "|Column of a date in a Monday-first week, 0 to 6."
          :code $ quote $ defn monday-index (year month day)
            floor-mod
              + 3 $ days-from-civil year month day
              , 7
          :examples $ []
          :schema $ quote $ Fn Number Number Number (-> Number)
          :tests $ [] $ %{} 'TestEntry (:name |finds-weekday-columns)
            :code $ quote $ do
              assert= 6 $ monday-index 2026 11 8
              assert= 0 $ monday-index 2026 11 9
        'month-index $ %{} 'CodeEntry (:doc "|Comparable position of a month.")
          :code $ quote $ defn month-index (month)
            + (:month month)
              * 12 $ :year month
          :examples $ []
          :schema $ quote $ Fn app.diary/YearMonth (-> Number)
        'month-key $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn month-key (month)
            str (:year month) |- $ two-digits $ :month month
          :examples $ []
          :schema $ quote $ Fn app.diary/YearMonth (-> String)
        'month-keys $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn month-keys (month)
            &list:map
              range 1 $ + 1 $ days-in-month (:year month) (:month month)
              fn (day)
                str (month-key month) |- $ two-digits day
          :examples $ []
          :schema $ quote $ Fn app.diary/YearMonth
            -> $ List String
          :tests $ [] $ %{} 'TestEntry (:name |lists-every-day)
            :code $ quote $ do
              assert= 29 $ count $ month-keys (YearMonth :year 2024 :month 2)
              assert= |2024-02-01 $ &list:nth
                month-keys $ YearMonth :year 2024 :month 2
                , 0
        'month-of-key $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn month-of-key (key)
            option:unwrap $ parse-month $ &str:slice key 0 7
          :examples $ []
          :schema $ quote $ Fn String (-> app.diary/YearMonth)
        'navigate! $ %{} 'CodeEntry
          :doc "|Adds a history entry so the phone's back gesture walks through pages."
          :code $ quote $ defn navigate! (hash)
            when
              not= hash $ :hash $ browser/location-snapshot
              browser/history-push-state! hash
              apply-route! true
            , &unit
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'open-day! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn open-day! (key field)
            reset! *sheet-pushed $ not= field |
            navigate! $ if (= field |) (str |#/day/ key) (str |#/day/ key |/ field)
          :examples $ []
          :schema $ quote $ Fn String String (-> Unit) (:features :js-ffi)
        'option-on? $ %{} 'CodeEntry
          :doc "|Displayed state: what is saved, flipped once for every change still in the queue."
          :code $ quote $ defn option-on? (key value)
            let
                date $ day-key @*day-ms
                saved? $ not $ empty?
                  &list:filter (entries-of key)
                    fn (entry)
                      = value $ :content entry
                pending $ count $ &list:filter @*queue
                  fn (item)
                    and
                      = date $ :date item
                      = key $ :field item
                      = value $ :value item
              if
                = 1 $ floor-mod pending 2
                not saved?
                , saved?
          :examples $ []
          :schema $ quote $ Fn String String (-> Bool) (:features :js-ffi)
        'parse-digits $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-digits (text)
            match (parse-float text)
              (:ok value)
                if
                  and (>= value 0)
                    = value $ floor value
                  Option :some value
                  Option :none
              (:err _message) (Option :none)
          :examples $ []
          :schema $ quote $ Fn String
            -> $ Option Number
        'parse-month $ %{} 'CodeEntry (:doc "|Decodes YYYY-MM; anything else is none.")
          :code $ quote $ defn parse-month (text)
            if
              and
                = 7 $ count text
                = |- $ &str:slice text 4 5
              let
                  year $ parse-digits $ &str:slice text 0 4
                  month $ parse-digits $ &str:slice text 5 7
                if
                  and (option:some? year) (option:some? month)
                  let
                      y $ option:unwrap year
                      m $ option:unwrap month
                    if
                      and (>= y 1) (>= m 1) (<= m 12)
                      Option :some $ YearMonth :year y :month m
                      Option :none
                  Option :none
              Option :none
          :examples $ []
          :schema $ quote $ Fn String
            -> $ Option app.diary/YearMonth
          :tests $ [] $ %{} 'TestEntry (:name |rejects-invalid-months)
            :code $ quote $ do
              assert= 11 $ :month $ option:unwrap (parse-month |2026-11)
              assert= true $ option:none? $ parse-month |2026-13
              assert= true $ option:none? $ parse-month |nonsense
        'parse-route $ %{} 'CodeEntry
          :doc "|Decodes the location hash. Unknown or future targets fall back to today so a stale link still opens."
          :code $ quote $ defn parse-route (hash today)
            let
                parts $ split hash |/
                segment $ part-at parts 1
                target $ part-at parts 2
                this-month $ month-of-key today
              cond
                  = segment |calendar
                  let
                      parsed $ parse-month target
                    Route :view |calendar :day | :field | :month $ if (option:some? parsed) (option:unwrap parsed) this-month
                (= segment |me)
                  Route :view |me :day | :field | :month this-month
                true $ let
                    valid? $ and
                      option:some? $ key-day-number target
                      not $ day-after? target today
                    field $ part-at parts 3
                  Route :view |day :day (if valid? target today) :field
                    if
                      option:some? $ find-spec field
                      , field |
                    , :month this-month
          :examples $ []
          :schema $ quote $ Fn String String (-> app.diary/Route)
          :tests $ [] $ %{} 'TestEntry (:name |decodes-navigation-targets)
            :code $ quote $ do
              assert= |2026-11-08 $ :day $ parse-route | |2026-11-08
              assert= |2026-11-07 $ :day $ parse-route |#/day/2026-11-07 |2026-11-08
              assert= |food $ :field $ parse-route |#/day/2026-11-07/food |2026-11-08
              assert= | $ :field $ parse-route |#/day/2026-11-07/nope |2026-11-08
              assert= |2026-11-08 $ :day $ parse-route |#/day/2027-01-01 |2026-11-08
              assert= |calendar $ :view $ parse-route |#/calendar/2026-02 |2026-11-08
              assert= 2 $ :month $ :month (parse-route |#/calendar/2026-02 |2026-11-08)
              assert= |me $ :view $ parse-route |#/me |2026-11-08
        'part-at $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn part-at (parts index)
            if
              > (count parts) index
              &list:nth parts index
              , |
          :examples $ []
          :schema $ quote $ Fn (List String) Number (-> String)
        'preset-options $ %{} 'CodeEntry (:doc "|Starting options before a value history exists.")
          :code $ quote $ defn preset-options (key)
            cond
                = key |food
                [] "|米饭" "|面条" "|粥" "|鸡蛋" "|牛奶" "|蔬菜" "|水果" "|肉" "|鱼" "|面包" "|咖啡" "|外卖"
              (= key |sleep)
                [] "|早睡" "|晚睡" "|熬夜" "|睡得好" "|睡得差" "|多梦" "|午睡" "|失眠" "|早醒"
              (= key |place)
                [] "|家" "|公司" "|商场" "|公园" "|餐厅" "|咖啡馆" "|健身房" "|医院" "|出差"
              (= key |exercise)
                [] "|走路" "|跑步" "|骑车" "|健身" "|游泳" "|瑜伽" "|爬山" "|球类" "|拉伸"
              (= key |pains)
                [] "|头痛" "|颈椎" "|肩膀" "|腰痛" "|胃痛" "|牙痛" "|感冒" "|咳嗽" "|过敏" "|疲劳"
              true $ assert-type ([]) (List String)
          :examples $ []
          :schema $ quote $ Fn String
            -> $ List String
        'quick-options $ %{} 'CodeEntry
          :doc "|Used values first, then presets, capped; values recorded on this day always stay visible so they can be toggled off."
          :code $ quote $ defn quick-options (key)
            let
                used $ option:unwrap-or (&map:get @*options key)
                  assert-type ([]) (List String)
                merged $ &list:distinct $ concat used (preset-options key)
                capped $ &list:slice merged 0 $ if
                  > (count merged) 24
                  , 24 (count merged)
                recorded $ &list:filter
                  &list:map (entries-of key)
                    fn (entry) (:content entry)
                  , short-value?
              &list:distinct $ concat capped recorded
          :examples $ []
          :schema $ quote $ Fn String
            -> $ List String
        'refresh-if-active! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn refresh-if-active! ()
            when
              option:some? $ get-token
              match (browser/visibility-state)
                (:visible) (load-current!)
                _ &unit
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (render!)
            if
              option:some? $ get-token
              load-current!
              show-login!
            println |Diary-Lite-reloaded
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render! $ %{} 'CodeEntry (:doc "|Draws the active page and marks the active tab.")
          :code $ quote $ defn render! ()
            each ([] |day |calendar |me)
              fn (view)
                let
                    active? $ = view @*view
                  browser/element-set-hidden!
                    by-id $ str |#view- view
                    not active?
                  set-class!
                    by-id $ str |#tab- view
                    , |active active?
                  if active?
                    browser/element-set-attribute!
                      by-id $ str |#tab- view
                      , |aria-current |page
                    browser/element-remove-attribute!
                      by-id $ str |#tab- view
                      , |aria-current
            cond
                = @*view |calendar
                render-calendar!
              (= @*view |me) (render-me!)
              true $ render-day!
            render-detail!
            reset! *pop-field |
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-cal-day $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-cal-day (key today)
            let
                fields $ fields-of-day key
                total $ count field-specs
                recorded $ count fields
                future? $ day-after? key today
                state $ day-state recorded total
                cell $ browser/create-element |button
                number $ browser/create-element |span
                dots $ browser/create-element |span
              browser/element-set-attribute! cell |type |button
              browser/element-set-class-name! cell $ str "|cal-day " (if future? |future state)
                if (= key today) "| today" |
                if (= key @*cal-selected) "| selected" |
              browser/element-set-attribute! cell |aria-label $ str key "|，" $ cond (future? "|未到")
                (= state |none) "|完全没写"
                (= state |complete) "|全部记录"
                true $ str "|已记录" recorded "|项，缺" (- total recorded) "|项"
              when future? $ set-disabled! cell true
              browser/element-set-class-name! number |cal-num
              browser/element-set-text-content! number $ str $ option:unwrap-or
                parse-digits $ &str:slice key 8 10
                , 0
              browser/element-set-class-name! dots |cal-dots
              each field-specs $ fn (spec)
                let
                    dot $ browser/create-element |i
                  when
                    &list:includes? fields $ :key spec
                    browser/element-set-class-name! dot |on
                    browser/element-data-set! dot |field $ :key spec
                  browser/append-child! dots dot
                  , &unit
              browser/append-child! cell number
              browser/append-child! cell dots
              browser/element-add-event-listener! cell |click $ fn (_event)
                tap-guard! $ fn () (reset! *cal-selected key) (render-calendar!)
                  replay-class! (by-id |#cal-panel) |view-in
                  when @*touch? $ browser/element-scroll-to-bottom! $ by-id |html
                  , &unit
              , cell
          :examples $ []
          :schema $ quote $ Fn String String (-> js-ffi.browser/DomElementHost) (:features :js-ffi)
        'render-cal-panel! $ %{} 'CodeEntry
          :doc "|Details of the inspected date: which tags exist and which are missing, each one jumping straight to that record."
          :code $ quote $ defn render-cal-panel! (today)
            let
                panel $ by-id |#cal-panel
                key @*cal-selected
                visible? $ and (not= key |)
                  not $ day-after? key today
                  = (&str:slice key 0 7) (month-key @*month)
              browser/element-set-hidden! panel $ not visible?
              when visible? $ let
                  fields $ fields-of-day key
                  total $ count field-specs
                  recorded $ count fields
                  chips $ by-id |#cal-chips
                  state $ day-state recorded total
                browser/element-set-text-content! (by-id |#cal-panel-title)
                  day-title $ key->noon-ms key
                browser/element-set-text-content! (by-id |#cal-panel-summary)
                  cond
                      = state |none
                      , "|这天完全没写"
                    (= state |complete) "|全部记录了"
                    true $ str "|已记录 " recorded "| 项，缺 " (- total recorded) "| 项"
                browser/element-set-inner-html! chips |
                each field-specs $ fn (spec)
                  let
                      chip $ browser/create-element |button
                      field $ :key spec
                    browser/element-set-attribute! chip |type |button
                    browser/element-set-class-name! chip $ if (&list:includes? fields field) "|chip done" |chip
                    browser/element-data-set! chip |field field
                    browser/element-set-text-content! chip $ :label spec
                    browser/element-add-event-listener! chip |click $ fn (_event) (open-day! key field)
                    browser/append-child! chips chip
                    , &unit
              , &unit
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'render-calendar! $ %{} 'CodeEntry
          :doc "|Month grid: every date shows whether it is complete, partial or unwritten, with one dot per tag."
          :code $ quote $ defn render-calendar! ()
            let
                month @*month
                today $ day-key $ today-noon-ms
                grid $ by-id |#cal-grid
                date-keys $ month-keys month
                past-keys $ &list:filter date-keys $ fn (key)
                  not $ day-after? key today
                total $ count field-specs
                state-count $ fn (state)
                  count $ &list:filter past-keys $ fn (key)
                    = state $ day-state
                      count $ fields-of-day key
                      , total
              browser/element-set-text-content! (by-id |#cal-title)
                str (:year month) "|年" (:month month) "|月"
              browser/element-set-text-content! (by-id |#count-complete)
                str $ state-count |complete
              browser/element-set-text-content! (by-id |#count-partial)
                str $ state-count |partial
              browser/element-set-text-content! (by-id |#count-none)
                str $ state-count |none
              set-disabled! (by-id |#next-month)
                not $ < (month-index month)
                  month-index $ month-of-key today
              browser/element-set-inner-html! grid |
              each
                range 0 $ monday-index (:year month) (:month month) 1
                fn (_blank)
                  browser/append-child! grid $ browser/create-element |span
                  , &unit
              each date-keys $ fn (key)
                browser/append-child! grid $ render-cal-day key today
                , &unit
              render-cal-panel! today
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-day! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-day! ()
            browser/element-set-text-content! (by-id |#day-title) (day-title @*day-ms)
            browser/element-set-text-content! (by-id |#day-progress)
              let
                  done $ count $ &list:filter field-specs
                    fn (spec)
                      not $ empty? $ entries-of (:key spec)
                str "|已记录 " done "| / " (count field-specs) "| 项"
            set-disabled! (by-id |#next-day)
              not $ day-after?
                day-key $ today-noon-ms
                day-key @*day-ms
            render-tags!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-detail! $ %{} 'CodeEntry
          :doc "|Slides the record sheet in and out; its content stays in place while it slides away."
          :code $ quote $ defn render-detail! ()
            let
                spec-opt $ find-spec @*selected
                open? $ option:some? spec-opt
                detail $ by-id |#detail
              set-class! detail |open open?
              set-class! (by-id |#sheet-backdrop) |open open?
              if open? (browser/element-remove-attribute! detail |inert) (browser/element-set-attribute! detail |inert |)
              when open? $ let
                  spec $ option:unwrap spec-opt
                  entries $ entries-of $ :key spec
                  list-node $ by-id |#entry-list
                  editing @*editing
                browser/element-data-set! detail |field $ :key spec
                browser/element-set-text-content! (by-id |#detail-title) (:label spec)
                browser/element-set-text-content! (by-id |#detail-hint)
                  str (day-title @*day-ms) "| · " $ :hint spec
                render-quick-chips! $ :key spec
                set-class! (by-id |#entry-form) |compact $ tag-field? $ :key spec
                browser/element-set-placeholder! (by-id |#entry-content)
                  cond
                      not= editing 0
                      , "|修改这条记录…"
                    (tag-field? (:key spec))
                      , "|其他的直接输入，用逗号或空格分隔"
                    (empty? entries) (:hint spec)
                    true "|再记一条…"
                browser/element-set-text-content! (by-id |#entry-submit)
                  if (= editing 0) "|记录" "|保存修改"
                browser/element-set-hidden! (by-id |#entry-cancel) (= editing 0)
                browser/element-set-inner-html! list-node |
                each
                  if
                    tag-field? $ :key spec
                    group-entries entries
                    &list:map entries $ fn (entry) ([] entry)
                  fn (group)
                    let
                        newest $ &list:nth entries $ - (count entries) 1
                        fresh? $ and
                          = @*pop-field $ :key spec
                          = (:id newest)
                            :id $ &list:nth group $ - (count group) 1
                      browser/append-child! list-node $ if
                        > (count group) 1
                        render-entry-group group fresh?
                        let
                            card $ render-entry $ &list:nth group 0
                          when fresh? $ browser/element-class-add! card |entry-new
                          , card
                      , &unit
              , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-entry $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-entry (entry)
            let
                id $ :id entry
                card $ browser/create-element |article
                time-node $ browser/create-element |time
                text-node $ browser/create-element |p
                actions $ browser/create-element |div
                edit-button $ browser/create-element |button
                remove-button $ browser/create-element |button
                edited? $ >
                  - (:updated-at entry) (:created-at entry)
                  , 1000
                confirming? $ = id @*pending-delete
              browser/element-set-class-name! card $ str |entry $ if (= id @*editing) "| editing" |
              browser/element-set-text-content! time-node $ str
                clock-label $ :created-at entry
                if edited?
                  str "| · 修改于 " $ clock-label $ :updated-at entry
                  , |
              browser/element-set-text-content! text-node $ :content entry
              browser/element-set-class-name! actions |entry-actions
              browser/element-set-attribute! edit-button |type |button
              browser/element-set-text-content! edit-button "|编辑"
              browser/element-set-attribute! remove-button |type |button
              browser/element-set-class-name! remove-button $ if confirming? "|remove confirming" |remove
              browser/element-set-text-content! remove-button $ if confirming? "|确认删除" "|删除"
              browser/element-add-event-listener! edit-button |click $ fn (_event) (start-edit! entry)
              browser/element-add-event-listener! remove-button |click $ fn (_event)
                if confirming? (delete-entry! id)
                  do (reset! *pending-delete id) (render-detail!)
                , &unit
              browser/append-child! actions time-node
              browser/append-child! actions edit-button
              browser/append-child! actions remove-button
              browser/append-child! card text-node
              browser/append-child! card actions
              , card
          :examples $ []
          :schema $ quote $ Fn app.diary/DiaryEntry (-> js-ffi.browser/DomElementHost) (:features :js-ffi)
        'render-entry-group $ %{} 'CodeEntry
          :doc "|One row for several values: a shared time span, and each value can still be edited or removed on its own."
          :code $ quote $ defn render-entry-group (group fresh?)
            let
                card $ browser/create-element |article
                values $ browser/create-element |div
                actions $ browser/create-element |div
                time-node $ browser/create-element |time
                first-at $ :created-at $ &list:nth group 0
                last-at $ :created-at $ &list:nth group
                  - (count group) 1
                first-label $ clock-label first-at
                last-label $ clock-label last-at
                edited? $ not $ empty?
                  &list:filter group $ fn (entry)
                    >
                      - (:updated-at entry) (:created-at entry)
                      , 1000
              browser/element-set-class-name! card "|entry entry-group"
              browser/element-set-class-name! values |group-values
              browser/element-set-class-name! actions |entry-actions
              browser/element-set-text-content! time-node $ str first-label
                if (= first-label last-label) | $ str "|–" last-label
                if edited? "| · 有修改" |
              each group $ fn (entry)
                browser/append-child! values $ render-group-value entry $ and fresh?
                  = (:id entry)
                    :id $ &list:nth group $ - (count group) 1
                , &unit
              browser/append-child! actions time-node
              browser/append-child! card values
              browser/append-child! card actions
              , card
          :examples $ []
          :schema $ quote $ Fn (List app.diary/DiaryEntry) Bool (-> js-ffi.browser/DomElementHost) (:features :js-ffi)
        'render-group-value $ %{} 'CodeEntry
          :doc "|A value inside a merged row: tap the text to edit, the cross to delete after confirming."
          :code $ quote $ defn render-group-value (entry fresh?)
            let
                id $ :id entry
                content $ :content entry
                pill $ browser/create-element |span
                edit-button $ browser/create-element |button
                remove-button $ browser/create-element |button
                confirming? $ = id @*pending-delete
              browser/element-set-class-name! pill $ str |group-value
                if (= id @*editing) "| editing" |
                if confirming? "| confirming" |
                if fresh? "| entry-new" |
              browser/element-set-attribute! edit-button |type |button
              browser/element-set-class-name! edit-button |group-value-text
              browser/element-set-text-content! edit-button content
              browser/element-set-attribute! edit-button |aria-label $ str "|编辑 " content
              browser/element-set-attribute! edit-button |title $ str
                clock-label $ :created-at entry
                , "| 记录" $ if
                  >
                    - (:updated-at entry) (:created-at entry)
                    , 1000
                  str "|，"
                    clock-label $ :updated-at entry
                    , "| 修改"
                  , |
              browser/element-set-attribute! remove-button |type |button
              browser/element-set-class-name! remove-button |group-value-remove
              browser/element-set-text-content! remove-button $ if confirming? "|确认删除" "|×"
              browser/element-set-attribute! remove-button |aria-label $ str (if confirming? "|确认删除 " "|删除 ") content
              browser/element-add-event-listener! edit-button |click $ fn (_event) (start-edit! entry)
              browser/element-add-event-listener! remove-button |click $ fn (_event)
                if confirming? (delete-entry! id)
                  do (reset! *pending-delete id) (render-detail!)
                , &unit
              browser/append-child! pill edit-button
              browser/append-child! pill remove-button
              , pill
          :examples $ []
          :schema $ quote $ Fn app.diary/DiaryEntry Bool (-> js-ffi.browser/DomElementHost) (:features :js-ffi)
        'render-me! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-me! ()
            let
                today $ today-noon-ms
                date-keys $ year-keys
                total $ count field-specs
                started $ if
                  empty? $ fields-of-day $ day-key today
                  - today day-length
                  , today
                written $ &list:filter date-keys $ fn (key)
                  not $ empty? $ fields-of-day key
                complete $ &list:filter written $ fn (key)
                  = |complete $ day-state
                    count $ fields-of-day key
                    , total
              browser/element-set-text-content! (by-id |#stat-streak)
                str $ streak-from started 0
              browser/element-set-text-content! (by-id |#stat-written)
                str $ count written
              browser/element-set-text-content! (by-id |#stat-complete)
                str $ count complete
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-quick-chips! $ %{} 'CodeEntry
          :doc "|Quick options of a tag field; keeps keyboard focus on the same option across redraws."
          :code $ quote $ defn render-quick-chips! (key)
            let
                container $ by-id |#quick-chips
                tagged? $ tag-field? key
                active $ browser/document-active-element
                focused $ if (option:some? active)
                  option:unwrap-or
                    browser/element-data-get (option:unwrap active) |value
                    , |
                  , |
              browser/element-set-hidden! container $ not tagged?
              browser/element-set-inner-html! container |
              when tagged? $ each (quick-options key)
                fn (value)
                  let
                      chip $ browser/create-element |button
                      on? $ option-on? key value
                    browser/element-set-attribute! chip |type |button
                    browser/element-set-class-name! chip $ if on? "|quick-chip on" |quick-chip
                    browser/element-set-attribute! chip |aria-pressed $ if on? |true |false
                    browser/element-data-set! chip |value value
                    browser/element-set-text-content! chip value
                    browser/element-add-event-listener! chip |click $ fn (_event) (toggle-option! key value)
                    browser/append-child! container chip
                    when (= value focused) (browser/element-focus! chip)
                    , &unit
              , &unit
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'render-tags! $ %{} 'CodeEntry
          :doc "|Big tags: recorded tags are colored with their count and latest content, unrecorded ones stay gray."
          :code $ quote $ defn render-tags! ()
            let
                container $ by-id |#tags
              browser/element-set-inner-html! container |
              each field-specs $ fn (spec)
                let
                    key $ :key spec
                    entries $ entries-of key
                    recorded? $ not $ empty? entries
                    tile $ browser/create-element |button
                    label $ browser/create-element |span
                    meta $ browser/create-element |span
                    preview $ browser/create-element |span
                  browser/element-set-attribute! tile |type |button
                  browser/element-set-class-name! tile $ str |tag (if recorded? "| recorded" "| empty")
                    if (= key |text) "| wide" |
                    if (= key @*selected) "| active" |
                    if (= key @*pop-field) "| pop" |
                  browser/element-set-attribute! tile |aria-pressed $ if (= key @*selected) |true |false
                  browser/element-data-set! tile |field key
                  browser/element-set-class-name! label |tag-label
                  browser/element-set-text-content! label $ :label spec
                  browser/element-set-class-name! meta |tag-meta
                  browser/element-set-text-content! meta $ if recorded?
                    str (count entries)
                      if (tag-field? key) "| 项" "| 条"
                    , "|未记录"
                  browser/element-set-class-name! preview |tag-preview
                  browser/element-set-text-content! preview $ cond
                      not recorded?
                      :hint spec
                    (tag-field? key)
                      join-string
                        &list:map entries $ fn (entry) (:content entry)
                        , "|、"
                    true $ option:unwrap-or
                      option:map (&list:last entries)
                        fn (entry) (:content entry)
                      , |
                  browser/element-add-event-listener! tile |click $ fn (_event)
                    tap-guard! $ fn () $ if (= key @*selected) (close-detail!) (select-field! key)
                  browser/append-child! tile label
                  browser/append-child! tile meta
                  browser/append-child! tile preview
                  browser/append-child! container tile
                  , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'replace-route! $ %{} 'CodeEntry
          :doc "|Moves within a page without growing history, used for stepping days and months."
          :code $ quote $ defn replace-route! (hash) (browser/history-replace-state! hash) (apply-route! true)
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'replay-class! $ %{} 'CodeEntry
          :doc "|Restarts a CSS animation class; reading scrollHeight forces the reflow that makes the removal take effect."
          :code $ quote $ defn replay-class! (element class-name) (browser/element-class-remove! element class-name) (browser/element-scroll-height element) (browser/element-class-add! element class-name)
          :examples $ []
          :schema $ quote $ Fn js-ffi.browser/DomElementHost String (-> Unit) (:features :js-ffi)
        'restore-unsaved! $ %{} 'CodeEntry
          :doc "|Puts values that could not be saved back into their drafts, so nothing typed or tapped is lost."
          :code $ quote $ defn restore-unsaved! (items)
            each items $ fn (item)
              when (:add? item)
                let
                    key $ draft-key (:date item) (:field item)
                    existing $ browser/storage-get-or key |
                  browser/storage-set! key $ if (= existing |) (:value item)
                    str existing "| " $ :value item
              , &unit
            when (= @*editing 0) (load-composer!)
            , &unit
          :examples $ []
          :schema $ quote $ Fn (List app.diary/QueueItem) (-> Unit) (:features :js-ffi)
        'run-queue! $ %{} 'CodeEntry
          :doc "|Applies queued changes in order, reloading after each so removals see fresh entries; stops at the first failure."
          :code $ quote $ defn run-queue! () (hint-fn Async)
            if (empty? @*queue)
              do (reset! *queue-running false) (set-status! "|已同步" |online) &unit
              let
                  ok? $ js-await $ apply-queue-item! (&list:nth @*queue 0)
                if ok?
                  do
                    reset! *queue $ &list:rest @*queue
                    js-await $ load-day!
                    js-await $ run-queue!
                    , &unit
                  let
                      unsaved @*queue
                    reset! *queue $ assert-type ([]) (List app.diary/QueueItem)
                    reset! *queue-running false
                    restore-unsaved! unsaved
                    render!
                    , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
        'save-draft! $ %{} 'CodeEntry
          :doc "|Stores composer text on every input; text of an entry being edited is not a draft."
          :code $ quote $ defn save-draft! ()
            when
              and (= @*editing 0) (not= @*selected |)
              let
                  key $ draft-key (day-key @*day-ms) @*selected
                  text $ browser/element-value $ by-id |#entry-content
                if (= text |) (browser/storage-remove! key) (browser/storage-set! key text)
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'select-field! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-field! (key)
            let
                hash $ str |#/day/ (day-key @*day-ms) |/ key
              if (= @*selected |)
                do (reset! *sheet-pushed true) (navigate! hash)
                replace-route! hash
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'set-class! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn set-class! (element class-name on?)
            if on? (browser/element-class-add! element class-name) (browser/element-class-remove! element class-name)
          :examples $ []
          :schema $ quote $ Fn js-ffi.browser/DomElementHost String Bool (-> Unit) (:features :js-ffi)
        'set-disabled! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn set-disabled! (element disabled?)
            if disabled? (browser/element-set-attribute! element |disabled |) (browser/element-remove-attribute! element |disabled)
          :examples $ []
          :schema $ quote $ Fn js-ffi.browser/DomElementHost Bool (-> Unit) (:features :js-ffi)
        'set-status! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn set-status! (label state)
            let
                target $ by-id |#status
              browser/element-set-text-content! target label
              browser/element-set-class-name! target $ str "|status " state
          :examples $ []
          :schema $ quote $ Fn String String (-> Unit) (:features :js-ffi)
        'shift-current! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn shift-current! (delta)
            cond
                = @*view |day
                shift-day! delta
              (= @*view |calendar) (shift-month! delta)
              true &unit
            , &unit
          :examples $ []
          :schema $ quote $ Fn Number (-> Unit) (:features :js-ffi)
        'shift-day! $ %{} 'CodeEntry
          :doc "|Steps the visible day; 0 means today and days after today are ignored."
          :code $ quote $ defn shift-day! (days)
            let
                today $ today-noon-ms
                target $ if (= days 0) today $ + @*day-ms (* days day-length)
              when
                not $ day-after? (day-key target) (day-key today)
                do
                  when (not= @*selected |) (reset! *sheet-pushed false)
                  replace-route! $ str |#/day/ (day-key target)
                    if (= @*selected |) | $ str |/ @*selected
              , &unit
          :examples $ []
          :schema $ quote $ Fn Number (-> Unit) (:features :js-ffi)
        'shift-month! $ %{} 'CodeEntry
          :doc "|Steps the calendar; 0 means this month and later months are ignored."
          :code $ quote $ defn shift-month! (delta)
            let
                this-month $ month-of-key $ day-key (today-noon-ms)
                target $ if (= delta 0) this-month $ add-months @*month delta
              when
                <= (month-index target) (month-index this-month)
                replace-route! $ str |#/calendar/ $ month-key target
              , &unit
          :examples $ []
          :schema $ quote $ Fn Number (-> Unit) (:features :js-ffi)
        'short-value? $ %{} 'CodeEntry
          :doc "|Whether a recorded text can appear as a quick option; mirrors the backend rule."
          :code $ quote $ defn short-value? (content)
            and
              <= (count content) 16
              = 1 $ count $ split-tokens content
          :examples $ []
          :schema $ quote $ Fn String (-> Bool)
        'show-board! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn show-board! (username)
            browser/element-set-hidden! (by-id |#login-panel) true
            browser/element-set-hidden! (by-id |#board) false
            browser/element-set-text-content! (by-id |#current-user) username
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'show-login! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn show-login! ()
            browser/element-set-hidden! (by-id |#login-panel) false
            browser/element-set-hidden! (by-id |#board) true
            set-status! "|请登录" |
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'split-tokens $ %{} 'CodeEntry
          :doc "|Splits typed text on commas and whitespace into distinct values."
          :code $ quote $ defn split-tokens (text)
            let
                unified $ foldl ([] "| " "|\n" "|\t" "|　" "|，" "|、") text $ fn (acc separator) (&str:replace acc separator |,)
              &list:distinct $ &list:filter (split unified |,)
                fn (token) (not= token |)
          :examples $ []
          :schema $ quote $ Fn String
            -> $ List String
          :tests $ [] $ %{} 'TestEntry (:name |splits-on-commas-and-spaces)
            :code $ quote $ do
              assert= ([] "|跑步" "|游泳" "|骑车" "|走路") (split-tokens "|跑步,游泳，骑车 走路")
              assert= ([] |a |b |c) (split-tokens "| a、b　c\n a ,, ")
              assert= 0 $ count $ split-tokens "| , ，"
        'start-edit! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn start-edit! (entry)
            reset! *editing $ :id entry
            reset! *pending-delete 0
            let
                input $ by-id |#entry-content
              browser/element-set-value! input $ :content entry
              render!
              browser/element-focus! input
          :examples $ []
          :schema $ quote $ Fn app.diary/DiaryEntry (-> Unit) (:features :js-ffi)
        'store-renewed-token! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn store-renewed-token! (token)
            when (option:some? token)
              browser/storage-set! token-key $ option:unwrap token
            , &unit
          :examples $ []
          :schema $ quote $ Fn (Option String) (-> Unit) (:features :js-ffi)
        'streak-from $ %{} 'CodeEntry
          :doc "|Consecutive recorded days walking backwards from the given noon timestamp."
          :code $ quote $ defn streak-from (ms acc)
            if
              empty? $ fields-of-day $ day-key ms
              , acc $ recur (- ms day-length) (+ acc 1)
          :examples $ []
          :schema $ quote $ Fn Number Number (-> Number) (:features :js-ffi)
        'submit-entry! $ %{} 'CodeEntry
          :doc "|Tag fields split the text into separate values; other fields save it whole. Editing replaces the entry with the first value."
          :code $ quote $ defn submit-entry! () (hint-fn Async)
            let
                input $ by-id |#entry-content
                typed $ .trim $ browser/element-value input
                field @*selected
                editing @*editing
                date $ day-key @*day-ms
                tagged? $ tag-field? field
                tokens $ if tagged? (split-tokens typed)
                  assert-type ([]) (List String)
                content $ if
                  and tagged? $ not $ empty? tokens
                  &list:nth tokens 0
                  , typed
              when
                and (not= field |) (not= content |)
                if
                  and tagged? $ = editing 0
                  submit-tokens! tokens field date
                  do (set-status! "|保存中" |online)
                    try
                      let
                          response $ js-await $ if (= editing 0)
                            api-request! |/api/entries (%:: shared/HttpMethod :post)
                              Option :some $ contract/expect-string |body $ js/JSON.stringify
                                js-object (:date date) (:field field) (:content content)
                            api-request! (str |/api/entries/ editing) (%:: shared/HttpMethod :put)
                              Option :some $ contract/expect-string |body $ js/JSON.stringify
                                js-object $ :content content
                        if (response :ok?)
                          do
                            when (= editing 0)
                              browser/storage-remove! $ draft-key date field
                              reset! *pop-field field
                            set-status!
                              if (= editing 0) "|已记录" "|已修改"
                              , |online
                            when
                              and (= field @*selected)
                                = date $ day-key @*day-ms
                              reset! *editing 0
                              load-composer!
                            js-await $ load-day!
                            when
                              and tagged? $ > (count tokens) 1
                              submit-tokens! (&list:rest tokens) field date
                          handle-failure! (response :status) "|保存失败"
                      fn (error) (shared/console-error! |Failed-to-save-entry) (set-status! "|保存失败" |error)
                if @*touch? (browser/element-blur! input) (browser/element-focus! input)
              , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
        'submit-tokens! $ %{} 'CodeEntry
          :doc "|Saves typed values of a tag field as separate entries, skipping ones already recorded."
          :code $ quote $ defn submit-tokens! (tokens field date)
            browser/storage-remove! $ draft-key date field
            load-composer!
            enqueue! $ &list:map
              &list:filter tokens $ fn (token)
                not $ option-on? field token
              fn (token)
                QueueItem :date date :field field :value token :add? true
          :examples $ []
          :schema $ quote $ Fn (List String) String String (-> Unit) (:features :js-ffi)
        'sync-day-summary! $ %{} 'CodeEntry
          :doc "|Keeps the calendar in step with the entries just loaded for one date."
          :code $ quote $ defn sync-day-summary! (date)
            let
                fields $ &list:map
                  &list:filter field-specs $ fn (spec)
                    not $ empty? $ entries-of (:key spec)
                  fn (spec) (:key spec)
              reset! *days $ if (empty? fields) (dissoc @*days date) (assoc @*days date fields)
              , &unit
          :examples $ []
          :schema $ quote $ Fn String (-> Unit)
        'sync-selected! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sync-selected! (field day-changed?)
            when
              or day-changed? $ not= field @*selected
              reset! *selected field
              reset! *editing 0
              reset! *pending-delete 0
              load-composer!
            when (= field |) (reset! *sheet-pushed false)
            when
              and (= field |)
                option:some? $ get-token
              load-options!
            , &unit
          :examples $ []
          :schema $ quote $ Fn String Bool (-> Unit) (:features :js-ffi)
        'tag-field? $ %{} 'CodeEntry
          :doc "|Tags holding enumerable values; the others stay free text."
          :code $ quote $ defn tag-field? (key)
            &list:includes? ([] |food |sleep |place |exercise |pains) key
          :examples $ []
          :schema $ quote $ Fn String (-> Bool)
          :tests $ [] $ %{} 'TestEntry (:name |only-enumerable-tags)
            :code $ quote $ do
              assert= true $ tag-field? |pains
              assert= false $ tag-field? |mood
              assert= false $ tag-field? |text
        'tap-guard! $ %{} 'CodeEntry
          :doc "|Runs a tap action unless the gesture that produced this click was a swipe."
          :code $ quote $ defn tap-guard! (action)
            if @*swiped (reset! *swiped false) (action)
            , &unit
          :examples $ []
          :schema $ quote $ Fn
            Fn $ -> Unit
            -> Unit
        'today-noon-ms $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn today-noon-ms ()
            let
                now $ shared/now-ms
                d $ local-date now
                minutes $ +
                  * 60 $ d .get-hours
                  d .get-minutes
              + now $ * 60000 $ - 720 minutes
          :examples $ []
          :schema $ quote $ Fn (-> Number) (:features :js-ffi)
        'toggle-option! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn toggle-option! (key value)
            enqueue! $ [] $ QueueItem :date (day-key @*day-ms) :field key :value value :add?
              not $ option-on? key value
          :examples $ []
          :schema $ quote $ Fn String String (-> Unit) (:features :js-ffi)
        'token-key $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def token-key |diary-lite-token
          :examples $ []
          :schema $ quote String
        'two-digits $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn two-digits (n)
            &str:pad-left (str n) 2 |0
          :examples $ []
          :schema $ quote $ Fn Number (-> String)
        'user-key $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def user-key |diary-lite-user
          :examples $ []
          :schema $ quote String
        'wire-events! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn wire-events! ()
            browser/element-add-event-listener! (by-id |#login-form) |submit $ fn (event) (event .prevent-default!) (login!) &unit
            browser/element-add-event-listener! (by-id |#entry-form) |submit $ fn (event) (event .prevent-default!) (submit-entry!) &unit
            browser/element-add-event-listener! (by-id |#entry-content) |keydown $ fn (event)
              let
                  key-event $ browser/keyboard-event-host event
                when
                  and
                    = |Enter $ key-event :key
                    or (key-event :meta-key?) (key-event :ctrl-key?)
                  key-event .prevent-default!
                  submit-entry!
                when
                  and
                    = |Enter $ key-event :key
                    tag-field? @*selected
                    not $ key-event :shift-key?
                    not $ or (key-event :meta-key?) (key-event :ctrl-key?)
                    not= 229 $ key-event :key-code
                  key-event .prevent-default!
                  submit-entry!
                when
                  = |Escape $ key-event :key
                  if (= 0 @*editing) (close-detail!) (cancel-edit!)
                , &unit
            browser/element-add-event-listener! (by-id |#entry-content) |input $ fn (_event) (save-draft!)
            browser/element-add-event-listener! (by-id |#entry-cancel) |click $ fn (_event) (cancel-edit!)
            browser/element-add-event-listener! (by-id |#detail-close) |click $ fn (_event) (close-detail!)
            browser/element-add-event-listener! (by-id |#sheet-backdrop) |click $ fn (_event) (close-detail!)
            browser/element-add-event-listener! (by-id |#sheet-handle) |click $ fn (_event) (close-detail!)
            browser/element-add-event-listener! (by-id |#sheet-handle) |pointerdown $ fn (event)
              reset! *swipe-y $
                browser/pointer-input-event-host event
                , :client-y
              , &unit
            browser/element-add-event-listener! (by-id |#sheet-handle) |pointerup $ fn (event)
              when
                >
                  -
                      browser/pointer-input-event-host event
                      , :client-y
                    , @*swipe-y
                  , 30
                close-detail!
              , &unit
            browser/element-add-event-listener! (by-id |#prev-day) |click $ fn (_event) (shift-day! -1)
            browser/element-add-event-listener! (by-id |#next-day) |click $ fn (_event) (shift-day! 1)
            browser/element-add-event-listener! (by-id |#today) |click $ fn (_event) (shift-day! 0)
            browser/element-add-event-listener! (by-id |#prev-month) |click $ fn (_event) (shift-month! -1)
            browser/element-add-event-listener! (by-id |#next-month) |click $ fn (_event) (shift-month! 1)
            browser/element-add-event-listener! (by-id |#this-month) |click $ fn (_event) (shift-month! 0)
            browser/element-add-event-listener! (by-id |#cal-open-day) |click $ fn (_event) (open-day! @*cal-selected |)
            browser/element-add-event-listener! (by-id |#tab-day) |click $ fn (_event)
              if (= @*view |day) (shift-day! 0)
                navigate! $ str |#/day/ $ day-key @*day-ms
            browser/element-add-event-listener! (by-id |#tab-calendar) |click $ fn (_event)
              navigate! $ str |#/calendar/ $ month-key @*month
            browser/element-add-event-listener! (by-id |#tab-me) |click $ fn (_event) (navigate! |#/me)
            browser/element-add-event-listener! (by-id |#logout) |click $ fn (_event) (logout!)
            wire-swipe! (by-id |#tags)
              fn () $ shift-day! 1
              fn () $ shift-day! -1
            wire-swipe! (by-id |#cal-grid)
              fn () $ shift-month! 1
              fn () $ shift-month! -1
            browser/add-event-listener! |pointerdown $ fn (event)
              reset! *touch? $ = |touch $
                browser/pointer-input-event-host event
                , :pointer-type
              , &unit
            browser/document-add-event-listener! |keydown $ fn (event) (handle-shortcut! event)
            browser/add-event-listener! |popstate $ fn (_event) (apply-route! true)
            browser/document-add-event-listener! |visibilitychange $ fn (_event) (refresh-if-active!)
            browser/add-event-listener! |online $ fn (_event) (refresh-if-active!)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'wire-swipe! $ %{} 'CodeEntry
          :doc "|Horizontal finger swipes step days or months; vertical movement stays with page scrolling through touch-action."
          :code $ quote $ defn wire-swipe! (element on-next on-prev)
            browser/element-add-event-listener! element |pointerdown $ fn (event)
              let
                  pointer $ browser/pointer-input-event-host event
                reset! *swipe-x $ pointer :client-x
                reset! *swipe-y $ pointer :client-y
                reset! *swiped false
                , &unit
            browser/element-add-event-listener! element |pointerup $ fn (event)
              let
                  pointer $ browser/pointer-input-event-host event
                  dx $ - (pointer :client-x) @*swipe-x
                  dy $ - (pointer :client-y) @*swipe-y
                when
                  and
                    = |touch $ pointer :pointer-type
                    > (abs dx) 60
                    > (abs dx)
                      * 2 $ abs dy
                  reset! *swiped true
                  if (< dx 0) (on-next) (on-prev)
                , &unit
          :examples $ []
          :schema $ quote $ Fn js-ffi.browser/DomElementHost
            Fn $ -> Unit
            Fn $ -> Unit
            -> Unit
            :features :js-ffi
        'year-keys $ %{} 'CodeEntry (:doc "|The latest 365 local dates, newest first.")
          :code $ quote $ defn year-keys ()
            let
                today $ today-noon-ms
              &list:map (range 0 365)
                fn (offset)
                  day-key $ - today $ * offset day-length
          :examples $ []
          :schema $ quote $ Fn
            -> $ List String
            :features :js-ffi
      :ns $ %{} 'NsEntry
        :doc "|Diary Lite: one day as big tags, each holding timed entries."
        :code $ quote $ ns app.diary
          :require (js-ffi.browser :as browser) (js-ffi.shared :as shared) (js-ffi.contract :as contract)
