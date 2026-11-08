
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
        '*day-ms $ %{} 'CodeEntry
          :doc "|Local noon of the visible day, so stepping by 24h never skips a day across DST."
          :code $ quote $ defref *day-ms (today-noon-ms)
          :examples $ []
          :schema $ quote $ Ref Number
        '*editing $ %{} 'CodeEntry
          :doc "|Id of the entry being edited; 0 when composing a new entry."
          :code $ quote $ defref *editing 0
          :examples $ []
          :schema $ quote $ Ref Number
        '*entries $ %{} 'CodeEntry (:doc "|Entries of the visible day, oldest first.")
          :code $ quote $ defref *entries ([])
          :examples $ []
          :schema $ quote $ Ref (List app.diary/DiaryEntry)
        '*pending-delete $ %{} 'CodeEntry
          :doc "|Id of the entry whose delete button awaits a second click; 0 when none."
          :code $ quote $ defref *pending-delete 0
          :examples $ []
          :schema $ quote $ Ref Number
        '*selected $ %{} 'CodeEntry
          :doc "|Key of the opened tag; empty when no tag is open."
          :code $ quote $ defref *selected |
          :examples $ []
          :schema $ quote $ Ref String
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
                , |http://127.0.0.1:11031 |https://diary.chenyong.life
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
          :code $ quote $ defn cancel-edit! () (reset! *editing 0)
            browser/element-set-value! (by-id |#entry-content) |
            render!
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
        'close-detail! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn close-detail! () (reset! *selected |) (reset! *editing 0) (reset! *pending-delete 0) (render!)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
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
            [] (FieldSpec :key |food :label "|饮食" :hint "|吃了什么？") (FieldSpec :key |sleep :label "|睡眠" :hint "|睡得怎么样？") (FieldSpec :key |mood :label "|心情" :hint "|感觉如何？") (FieldSpec :key |place :label "|地点" :hint "|去了哪里？") (FieldSpec :key |highlight :label "|亮点" :hint "|今天的亮点？") (FieldSpec :key |met :label "|见面" :hint "|见了谁？") (FieldSpec :key |exercise :label "|运动" :hint "|做了什么运动？") (FieldSpec :key |pains :label "|病痛" :hint "|哪里不舒服？") (FieldSpec :key |text :label "|正文" :hint "|今天想记下的事，可以分几段提交。")
          :examples $ []
          :schema $ quote $ List app.diary/FieldSpec
        'find-spec $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn find-spec (key)
            find field-specs $ fn (spec)
              = key $ :key spec
          :examples $ []
          :schema $ quote $ Fn String
            -> $ Option app.diary/FieldSpec
        'get-token $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn get-token () (browser/storage-get token-key)
          :examples $ []
          :schema $ quote $ Fn
            -> $ Option String
            :features :js-ffi
        'handle-failure! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-failure! (status label)
            if (= 401 status) (logout!) (set-status! label |error)
          :examples $ []
          :schema $ quote $ Fn Number String (-> Unit)
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
                            show-board! $ option:unwrap-or (browser/storage-get user-key) |
                            render!
                            set-status! "|已同步" |online
                          , &unit
                      (:err error) (raise error)
                  handle-failure! (response :status) "|加载失败"
              fn (error) (shared/console-error! |Failed-to-load-day) (set-status! "|连接失败" |error)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
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
                                js-await $ load-day!
                            (:err error) (raise error)
                        do (logout!) (set-status! "|登录失败" |error)
                    (:err error) (raise error)
              fn (error) (shared/console-error! |Failed-to-login) (set-status! "|登录失败" |error)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
        'logout! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn logout! () (browser/storage-remove! token-key) (browser/storage-remove! user-key)
            reset! *entries $ []
            reset! *selected |
            reset! *editing 0
            show-login!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (wire-events!) (render!)
            if
              option:some? $ get-token
              do (set-status! "|验证登录" |online) (load-day!)
              show-login!
            println |Diary-Lite-started
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'refresh-if-active! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn refresh-if-active! ()
            when
              option:some? $ get-token
              match (browser/visibility-state)
                (:visible) (load-day!)
                _ &unit
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (render!)
            if
              option:some? $ get-token
              load-day!
              show-login!
            println |Diary-Lite-reloaded
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render! ()
            browser/element-set-text-content! (by-id |#day-title) (day-title @*day-ms)
            browser/element-set-text-content! (by-id |#day-progress)
              let
                  done $ count $ &list:filter field-specs
                    fn (spec)
                      not $ empty? $ entries-of (:key spec)
                str "|已记录" done "| / " (count field-specs) "| 项"
            render-tags!
            render-detail!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-detail! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-detail! ()
            let
                detail $ by-id |#detail
                spec-opt $ find-spec @*selected
              browser/element-set-hidden! detail $ option:none? spec-opt
              when (option:some? spec-opt)
                let
                    spec $ option:unwrap spec-opt
                    entries $ entries-of $ :key spec
                    list-node $ by-id |#entry-list
                    editing @*editing
                  browser/element-set-text-content! (by-id |#detail-title) (:label spec)
                  browser/element-set-text-content! (by-id |#detail-hint) (:hint spec)
                  browser/element-set-placeholder! (by-id |#entry-content)
                    if (= editing 0)
                      if (empty? entries) (:hint spec) "|再记一条…"
                      , "|修改这条记录…"
                  browser/element-set-text-content! (by-id |#entry-submit)
                    if (= editing 0) "|记录" "|保存修改"
                  browser/element-set-hidden! (by-id |#entry-cancel) (= editing 0)
                  browser/element-set-inner-html! list-node |
                  each entries $ fn (entry)
                    browser/append-child! list-node $ render-entry entry
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
                  browser/element-set-attribute! tile |aria-pressed $ if (= key @*selected) |true |false
                  browser/element-set-class-name! label |tag-label
                  browser/element-set-text-content! label $ :label spec
                  browser/element-set-class-name! meta |tag-meta
                  browser/element-set-text-content! meta $ if recorded?
                    str (count entries) "| 条"
                    , "|未记录"
                  browser/element-set-class-name! preview |tag-preview
                  browser/element-set-text-content! preview $ if recorded?
                    option:unwrap-or
                      option:map (&list:last entries)
                        fn (entry) (:content entry)
                      , |
                    :hint spec
                  browser/element-add-event-listener! tile |click $ fn (_event)
                    if (= key @*selected) (close-detail!) (select-field! key)
                  browser/append-child! tile label
                  browser/append-child! tile meta
                  browser/append-child! tile preview
                  browser/append-child! container tile
                  , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'select-field! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-field! (key) (reset! *selected key) (reset! *editing 0) (reset! *pending-delete 0)
            browser/element-set-value! (by-id |#entry-content) |
            render!
            let
                detail $ by-id |#detail
              browser/element-scroll-into-view! detail
              browser/element-focus! $ by-id |#entry-content
          :examples $ []
          :schema $ quote $ Fn String (-> Unit) (:features :js-ffi)
        'set-status! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn set-status! (label state)
            let
                target $ by-id |#status
              browser/element-set-text-content! target label
              browser/element-set-class-name! target $ str "|status " state
          :examples $ []
          :schema $ quote $ Fn String String (-> Unit) (:features :js-ffi)
        'shift-day! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn shift-day! (days)
            reset! *day-ms $ if (= days 0) (today-noon-ms)
              + @*day-ms $ * days day-length
            reset! *entries $ []
            reset! *editing 0
            reset! *pending-delete 0
            browser/element-set-value! (by-id |#entry-content) |
            render!
            set-status! "|加载中" |online
            load-day!
            , &unit
          :examples $ []
          :schema $ quote $ Fn Number (-> Unit) (:features :js-ffi)
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
        'submit-entry! $ %{} 'CodeEntry
          :doc "|Creates a new entry in the open tag, or saves the entry being edited."
          :code $ quote $ defn submit-entry! () (hint-fn Async)
            let
                input $ by-id |#entry-content
                content $ .trim $ browser/element-value input
                field @*selected
                editing @*editing
              when
                and (not= field |) (not= content |)
                set-status! "|保存中" |online
                try
                  let
                      response $ js-await $ if (= editing 0)
                        api-request! |/api/entries (%:: shared/HttpMethod :post)
                          Option :some $ contract/expect-string |body $ js/JSON.stringify
                            js-object
                              :date $ day-key @*day-ms
                              :field field
                              :content content
                        api-request! (str |/api/entries/ editing) (%:: shared/HttpMethod :put)
                          Option :some $ contract/expect-string |body $ js/JSON.stringify
                            js-object $ :content content
                    if (response :ok?)
                      do (browser/element-set-value! input |) (reset! *editing 0)
                        set-status!
                          if (= editing 0) "|已记录" "|已修改"
                          , |online
                        js-await $ load-day!
                        browser/element-focus! input
                      handle-failure! (response :status) "|保存失败"
                  fn (error) (shared/console-error! |Failed-to-save-entry) (set-status! "|保存失败" |error)
              , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi) (:async)
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
                  = |Escape $ key-event :key
                  if (= 0 @*editing) (close-detail!) (cancel-edit!)
                , &unit
            browser/element-add-event-listener! (by-id |#entry-cancel) |click $ fn (_event) (cancel-edit!)
            browser/element-add-event-listener! (by-id |#detail-close) |click $ fn (_event) (close-detail!)
            browser/element-add-event-listener! (by-id |#prev-day) |click $ fn (_event) (shift-day! -1)
            browser/element-add-event-listener! (by-id |#next-day) |click $ fn (_event) (shift-day! 1)
            browser/element-add-event-listener! (by-id |#today) |click $ fn (_event) (shift-day! 0)
            browser/element-add-event-listener! (by-id |#logout) |click $ fn (_event) (logout!)
            browser/document-add-event-listener! |visibilitychange $ fn (_event) (refresh-if-active!)
            browser/add-event-listener! |online $ fn (_event) (refresh-if-active!)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
      :ns $ %{} 'NsEntry
        :doc "|Diary Lite: one day as big tags, each holding timed entries."
        :code $ quote $ ns app.diary
          :require (js-ffi.browser :as browser) (js-ffi.shared :as shared) (js-ffi.contract :as contract)
