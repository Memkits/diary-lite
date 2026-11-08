# Diary Lite

一个按“大标签”记录当天日志的轻量日记：Rust/HTTP 后端 + [UnionID](https://github.com/worktools/unionid) 存储，Calcit.js 前端，架构与 `memkits/copyboard-lite` 相同，记录项参考 `topixim/diary`。

## 使用方式

打开后看到当天的 9 个大标签：饮食、睡眠、心情、地点、亮点、见面、运动、病痛，以及占满一行的正文。

- 已记录的标签显示为彩色，带条数和最近一条内容；未记录的标签为灰色虚线样式。
- 点击标签展开记录区，输入后 `⌘/Ctrl + Enter` 提交。一般一个标签记一条即可，也可以继续追加多条。
- 每条记录有自己的创建时间；编辑后会额外显示“修改于”时间。删除需要再点一次确认。
- 正文同样可以分多段提交，每段一条记录。
- 顶部可切换前一天、后一天或回到今天。

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

前端使用 Calcit 0.35.1 与 `calcit-lang/js-ffi` 0.2.13；代码在 `calcit.cirru` 的 `app.diary` 命名空间，只通过 `calcit edit` / `calcit tree` 修改。

## 后端 API

所有 `/api/entries`、`/api/days` 请求都需要登录（Bearer token 或会话 Cookie），数据按用户隔离。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| `POST` | `/api/auth/login` | `{username, password}`，返回 token |
| `GET` | `/api/entries?date=YYYY-MM-DD` | 当天全部记录，按创建时间排序 |
| `POST` | `/api/entries` | `{date, field, content}` 新增一条 |
| `PUT` | `/api/entries/{id}` | `{content}` 修改一条，更新 `updated_at` |
| `DELETE` | `/api/entries/{id}` | 删除一条 |
| `GET` | `/api/days?from=&to=` | 区间内每天已记录的标签，供日历概览使用 |

`field` 取值：`food`、`sleep`、`mood`、`place`、`highlight`、`met`、`exercise`、`pains`、`text`。

鉴权配置缺失或无效时后端拒绝启动：`DIARY_USERS` 为逗号分隔的 `用户名:密码`，`DIARY_SECRET` 至少 32 字节。会话有效期三天，每次成功请求滑动续期。可用 `DIARY_ADDR`、`DIARY_DB` 修改监听地址和数据库路径。

## 测试

```bash
cargo test
```

覆盖登录与配置校验、同一标签多条记录、编辑与删除、日期与字段校验、用户隔离、重开数据库后的持久化和 schema 漂移拒绝。

部署方式与 copyboard-lite 相同，见 [部署建议](docs/DEPLOYMENT.md)。
