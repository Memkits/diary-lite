# Diary Lite

一个按“大标签”记录当天日志的轻量日记：Rust/HTTP 后端 + [UnionID](https://github.com/worktools/unionid) 存储，Calcit.js 前端，架构与 `memkits/copyboard-lite` 相同，记录项参考 `topixim/diary`。

## 使用方式

手机上是底部导航和底部弹层，适合随手记一条；宽屏（900px 以上）是顶部导航和左右分栏，记录区常驻右侧，适合长时间书写。没提交的内容会按日期和标签自动存为草稿，切换标签、换天、刷新或登录过期都不会丢。

桌面快捷键：`1`–`9` 打开标签，`←` `→` 切换日期或月份，`⌘/Ctrl + Enter` 提交，`Esc` 收起。

**记录**：当天的 9 个大标签，食物、睡眠、心情、地点、亮点、见面、运动、病痛，以及占满一行的正文。

- 已记录的标签显示为彩色，带条数和最近一条内容；未记录的标签为灰色虚线样式。
- 点击标签从底部滑出记录弹层，点背景、下滑把手或按 Esc 收起。桌面端可用 `⌘/Ctrl + Enter` 提交。
- 一般一个标签记一条即可，也可以继续追加多条。正文同样可以分多段提交，每段一条记录。
- 食物、地点、运动、病痛是枚举项：弹层里有快捷标签，点一下记录，再点一下取消。推荐词最多 12 个，按历史使用次数排序，预设词只补空位，用得多了就会被常用词自动替换；当天已记录的值始终显示。也可以直接输入，保存时按逗号（`,` `，` `、`）和空白拆成多条，已记录过的值会跳过，回车提交。睡眠、心情、亮点、见面和正文仍是整段文本。
- 这四项里 5 分钟内连续创建的短值会合并成一行显示，时间显示为起止范围；数据仍是分开的记录，点值可以修改，点 × 可以删除。
- 每条记录有自己的创建时间；编辑后会额外显示“修改于”时间。删除需要再点一次确认。
- 左右滑动或点箭头切换日期，不能切到未来；再点一次底部的“记录”回到今天。

**日历**：按月查看每天的状态，每天 9 个圆点对应 9 个标签。

- 实心表示全部记录，浅色表示缺条目，虚线表示完全没写；顶部统计本月截至今天的三类天数。
- 点某一天可以看到哪些标签已记、哪些缺少，点标签直接打开那天的记录弹层补写。

**我的**：连续记录天数、近一年写过和写完整的天数、账号与退出登录。

## 开发

```bash
# 后端，默认 http://127.0.0.1:11031
DIARY_USERS='alice:change-me,bob:another-password' \
DIARY_SECRET='replace-with-at-least-32-random-bytes' \
cargo run

# 另一个终端：前端，默认 http://127.0.0.1:5173
caps
yarn install
yarn compile
yarn dev
```

前端使用 Calcit 0.38.0 与 `calcit-lang/js-ffi` 0.2.14；代码在 `calcit.cirru` 的 `app.diary` 命名空间，只通过 `calcit edit` / `calcit tree` 修改。

## 后端 API

所有 `/api/entries`、`/api/days` 请求都需要登录（Bearer token 或会话 Cookie），数据按用户隔离。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| `POST` | `/api/auth/login` | `{username, password}`，返回 token |
| `GET` | `/api/entries?date=YYYY-MM-DD` | 当天全部记录，按创建时间排序 |
| `POST` | `/api/entries` | `{date, field, content}` 新增一条 |
| `PUT` | `/api/entries/{id}` | `{content}` 修改一条，更新 `updated_at` |
| `DELETE` | `/api/entries/{id}` | 删除一条 |
| `GET` | `/api/options` | 枚举项用过的值，按使用次数排序；含空白、逗号或超过 16 字的内容不算 |
| `GET` | `/api/days?from=&to=` | 区间内每天已记录的标签，供日历页使用 |

`field` 取值：`food`、`sleep`、`mood`、`place`、`highlight`、`met`、`exercise`、`pains`、`text`。

鉴权配置缺失或无效时后端拒绝启动：`DIARY_USERS` 为逗号分隔的 `用户名:密码`，`DIARY_SECRET` 至少 32 字节。会话有效期三天，每次成功请求滑动续期。可用 `DIARY_ADDR`、`DIARY_DB` 修改监听地址和数据库路径。

## 测试

```bash
cargo test
calcit test app.diary --require-match
```

后端测试覆盖登录与配置校验、同一标签多条记录、编辑与删除、日期与字段校验、用户隔离、重开数据库后的持久化和 schema 漂移拒绝；Calcit 测试覆盖日期计算、路由解析和每天的状态分类。

生产地址是 `https://diary-lite.chenyong.life`，Caddy 配置在 `deploy/Caddyfile.diary-lite.chenyong.life`。部署方式与 copyboard-lite 相同，见 [部署建议](docs/DEPLOYMENT.md)。
