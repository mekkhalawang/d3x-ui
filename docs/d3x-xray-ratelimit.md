# D3X-UI 单客户限速：Xray 内核补丁说明

> **状态（2026-11-20）**：✅ **端到端已验收通过**。单线程 ≈ 设定值（实测 +0.7%），4 并发总和 ≈ 设定值（实测 +0.05%）。本机与 VPS 双重实测。开启方式：环境变量 `XUI_RATELIMIT_ENABLE=1`（面板侧安全阀，默认关）。攻坚过程与踩坑见 `docs/d3x-handoff.md` 的 P0 条目。

这份文档只讲一件事：**我们给 Xray 内核加了什么、为什么这么加、以后升级内核要怎么把补丁重新打上**。

面板侧的字段、接口、UI 不在这里展开。

## 1. 结论先说

- 限速**不在面板进程里做**，面板只是把「谁限多少」写进一个旁路文件。
- 真正掐流量的是 Xray 内核里新增的方向整形器（`shaper.go`），按 `session.Inbound.User.Email` 找到该用户的令牌桶。
- 补丁只动 4 个文件，**不碰 protobuf**，所以升级内核时不需要装 `protoc` 重新生成代码。

## 2. 改动清单

补丁文件：`patches/xray-ratelimit.patch`
内核源码：`third_party/xray-core/`（开发用，发布时拉上游 tarball + 打补丁现场编译）

| 文件                               | 改动                                                              |
| ---------------------------------- | ----------------------------------------------------------------- |
| `app/dispatcher/ratelimit.go`      | 新增。读取限速文件、维护每用户令牌桶                              |
| `app/dispatcher/shaper.go`         | 新增。方向整形器：**先扣令牌、再直写**（见下方"两个致命教训"）    |
| `app/dispatcher/default.go`        | 在 `Dispatch()` 与 `WrapLink()`（VLESS/Trojan 走这里）两处挂 hook |
| `app/dispatcher/ratelimit_test.go` | 新增。文件加载、热更新、令牌桶速率/持续/超突发/多并发 6 个用例    |

### 数据流

```
面板 UI（Mbps）
  → model.Client.speedLimitUp / speedLimitDown（存 kbps）
  → 生成 Xray 配置时调用 syncRateLimitFile()
  → $XUI_BIN_FOLDER/ratelimit.json
  → 内核启动时带 XRAY_RATELIMIT_FILE 环境变量
  → 每条新连接 Dispatch() 时按 email 取桶
```

`ratelimit.json` 格式（字节/秒，0 或缺省表示不限）：

```json
{ "users": { "alice@example.com": { "up": 125000, "down": 1000000 } } }
```

### 为什么用旁路文件，而不是写进 Xray 配置

Xray 的 `policy` 是 protobuf 消息。要在 `policy.levels` 里加 `rateLimit` 字段，必须改 `.proto` 并重新生成 `config.pb.go`，每次升级内核都要重新跑 `protoc`，冲突面也大。

旁路文件把补丁压到 4 个文件、10 行 hook，升级时只需要重新贴一次。

代价：限速配置不在 Xray 配置里，`xray -test` 看不到。这是有意的取舍。

### 作用范围

- 挂载点有两处：`Dispatch()`（VMess 等）与 `WrapLink()`（**VLESS / Trojan 在 v26.11.9 走的是 DispatchLink，只挂 Dispatch 会完全不生效**）。
- 限速按 **email** 聚合：同一用户开多条连接共用一个桶，不能靠多开连接绕过。
- 只对**新建立的连接**生效；已在传输中的连接要断开重连才会用上新限额。
- 单位换算：面板存 kbps，内核要 bytes/s，面板侧 `kbps * 125`。

### 两个致命教训（都是实测打过脸的，升级内核别踩回去）

**教训 1：令牌桶的 `wait()` 绝不能"清零再补差额"。**
错误写法是 tokens 不足时 `tokens = 0` 并只睡 `(n - tokens)/rate`——醒来的 tokens ≈ 差额 < n，永远不够，无限振荡。burst（初始额度）耗尽后彻底卡死，表现为 **0 B/s**。正确写法：**保留已有 tokens，只睡缺口**，醒后 tokens 自然凑满 n；同时 request 大于 burst 时把容量上限抬到 n（Close 冲刷、大块读会超过 64KB 的 burst 下限）。

**教训 2：整形器绝不能"攒批再写"。**
攒够 64KB 才放行会把**请求-响应型流量憋死**：TLS 握手第一趟只有几 KB，对端在等它，批永远攒不满 → 死锁 → **0 字节**。直连大文件测试会掩盖这个坑（数据流自身能凑满批），必须用 HTTPS 目标验。正确写法：**先扣令牌、马上直写**，突发额度天然放行握手，节奏靠令牌桶的 sleep 控制。

> 早期记录的"84 KB/s 是小包+延迟 ACK 导致"后经复盘证实是误诊——那次实测用的是带教训 1 bug 的桶，84KB/s ≈ burst/观测时长。不存在"小包必须攒批"的问题。

## 3. 怎么验证补丁生效

内核仓库内：

```bash
go test ./app/dispatcher/ -run 'RateLimit|TokenBucket' -count=1
```

面板仓库内：

```bash
go test ./internal/web/service/ -run TestSyncRateLimitFile -count=1
```

端到端（测试机）：

1. 给某个客户设 1 Mbps 下行；
2. `cat /usr/local/d3x-ui/bin/ratelimit.json` 应出现该 email，`down` 为 `125000`；
3. 用该客户下载一个大文件，速度应稳定在 ~1 Mbps（约 125 KB/s）；
4. 同一客户开 3 条连接同时下载，总速度仍应 ~1 Mbps。

## 4. 升级 Xray 内核的完整步骤

> 前提：面板 `go.mod` 里有 `replace github.com/xtls/xray-core => ./third_party/xray-core`，所以 CI 和本地都用仓库内的内核，不会去拉上游模块。

### 4.1 先备份当前基线

```bash
git -C . log --oneline -1           # 记录当前面板提交
git -C third_party/xray-core log -1 # 如果是 git 仓库；内置副本没有 .git 就记版本号
```

当前基线：`xtls/xray-core@676eaf66f8f0`（对应 v26.11.9 系列）。

### 4.2 取新内核源码

```bash
# 以目标版本 tag 或 commit 为准
curl -L -o xray.zip https://github.com/XTLS/Xray-core/archive/<NEW_COMMIT>.zip
unzip xray.zip
rm -rf third_party/xray-core
mv Xray-core-<NEW_COMMIT> third_party/xray-core
```

### 4.3 重新打补丁

先试自动：

```bash
cd third_party/xray-core
git init -q && git add -A && git commit -qm base   # 仅为 git apply 提供上下文
git apply --3way ../../patches/xray-ratelimit.patch
```

如果 `git apply` 报冲突，不要硬合，按下面手工改（只有三处）：

1. **新增 `app/dispatcher/ratelimit.go`**
   直接把补丁里这个文件整段复制过去，不需要改任何 import。

2. **改 `app/dispatcher/default.go` 的 `Dispatch()`**
   找到构造 `inboundLink` / `outboundLink` 之后、`return inboundLink, outboundLink` 之前的位置，加入：

   ```go
   if limit := lookupRateLimit(user.Email); limit != nil {
       if limit.up != nil {
           inboundLink.Writer = newRateLimitWriter(inboundLink.Writer, limit.up)
       }
       if limit.down != nil {
           outboundLink.Writer = newRateLimitWriter(outboundLink.Writer, limit.down)
       }
   }
   ```

   注意它必须在 `if user != nil && len(user.Email) > 0 { ... }` 块**内部**，因为要用 `user.Email`。

3. **新增 `app/dispatcher/ratelimit_test.go`**
   从补丁里复制，编译不过时优先看 `buf.MultiBuffer` / `buf.Writer` 的接口有没有变。

### 4.4 如果新内核改了 Dispatch 的结构

这是升级时唯一需要动脑的情况。判断方法：

- 还能找到 `inboundLink.Writer` 和 `outboundLink.Writer` → 照 4.3 第 2 步贴。
- 改成返回 `transport.Link` 的其它构造方式 → 找到「写回客户端」和「写往出口」的两个 `buf.Writer`，分别套 `newRateLimitWriter(..., limit.down)` 和 `newRateLimitWriter(..., limit.up)`。
- 如果 `session.Inbound.User` 拿不到 email → 先确认 Xray 是否改了会话结构；`user.Email` 是面板统计流量的既有依赖，通常不会消失。

### 4.5 编译与回归

```bash
# 内核自身
cd third_party/xray-core
go build ./...
go test ./app/dispatcher/ -run 'RateLimit|TokenBucket' -count=1

# 面板
cd ../..
go build ./...
go test ./internal/web/service/ -run TestSyncRateLimitFile -count=1
```

### 4.6 更新版本记录

- `go.mod` 里 `github.com/xtls/xray-core vX.Y.Z` 的版本号可以顺手改成新版本（因为被 `replace` 覆盖，不改也能编，但留着旧号以后会误导）。
- 更新本文档第 4.1 节的「当前基线」。
- 提交信息写清楚：`chore(xray): bump core to <version> and re-apply ratelimit patch`。

### 4.7 发布

内核是面板旁边的**独立可执行文件**（发布包里的 `xray-linux-*`）。它的来源已经改成从本仓库的 `third_party/xray-core` 现场编译：

- `.github/workflows/release.yml`（Linux 7 平台 + Windows）
- `DockerInit.sh`（Docker 镜像）

**不要改回从 GitHub Releases 下载 Xray**——那样限速补丁会静默丢失，面板照常工作，但谁都不限速，很难被发现。

升级内核后必须重新打 tag 发版，不能只替换服务器上的二进制——否则下次一键安装又回到旧内核。

## 5. 已知边界

- 不覆盖 `WrapLink()` 路径。
- 不做「按连接」限速，只做「按客户」；同一客户的所有连接共享额度。
- 令牌桶 burst 下限 64 KiB，所以 1 Mbps 的限额允许约 0.5 秒的突发，这是为了避免小包被拆得太碎。
- 限速文件里是明文 email，权限 0600；不要把它放进 Web 可访问目录。
- MTProto / TUIC 走的是独立 sidecar，不经过 Xray `Dispatch()`，这套限速对它们无效。
