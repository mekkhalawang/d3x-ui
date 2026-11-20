# D3X-UI 二次开发交接说明

## 明天从哪开始（5 分钟）

1. `cd E://D3X-UI//repo && git checkout feat/d3x-ui`
2. **P0 限速已验收通过**（2026-11-20，单线程 +0.7%、4 并发总和 +0.05%），见「三、已完成-2026-11-20」；下一个大项是 **P1 argo 接入面板**（调研已完成，见 `docs/x-ui-yg-argo-analysis.md`）
3. **发布**：仓库 Settings 开启 Actions → 打 tag `v3.11.0-d3.1` → 服务器执行
   `bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh)`
4. 推 GitHub 记得带 SOCKS：`git -c http.proxy=socks5h://127.0.0.1:3066 push`
5. 限速开关 `XUI_RATELIMIT_ENABLE=1` 现在可以放心开（内核端已验证）；不开仍是默认不限速

> 状态快照：2026-11-20 12:45。本文件写给「下一个接手的任务」，避免重复考古。

## 一、项目现状

仓库 `github.com/mekkhalawang/d3x-ui`，基于上游 `MHSanaei/3x-ui` v3.11.0（commit `5297fd3`）**冻结**，不再跟随上游。
本地分支 `feat/d3x-ui`（尚未推送），基线 tag `v3.11.0-base`。

### 已完成并验证

| 项 | 内容 | 验证方式 |
|---|---|---|
| 品牌改名 | 模块 `github.com/mekkhalawang/d3x-ui/v3`；二进制/服务 `d3x-ui`；路径 `/usr/local/d3x-ui`、`/etc/d3x-ui`；`d3x-ui.db`、`d3x-ui.log`；脚本 `d3x-ui.sh`、`d3x-ui.service.*`、`d3x-ui.rc`；图标 | 972 个文件批量替换 + VPS 实跑 |
| 一键安装链路 | `install.sh` / `update.sh` / `d3x-ui.sh` 全部指向 `mekkhalawang/d3x-ui`；发布 tag 改为 stable（否则 `/releases/latest` 跳过 prerelease，脚本 404） | 待推 tag 后端到端验证 |
| HY2 允许不安全 | `tlsSettings.settings.allowInsecure`（panel-only，生成 Xray 配置前被 strip）→ 分享链接 `insecure=1`、Clash `skip-cert-verify`；仅 hysteria 协议显示 | 前后端单测 + Chrome 实测（安全页最底部） |
| 旧版入站交互 | 入站行首 `+` 展开客户表：启用开关、到期时间点击改、流量、限速、删除；`添加客户端` 复用完整 `ClientFormModal`；`编辑` 用 `ClientEditModal`（hydrate 后走 clients 页同一套 update/attach/detach/links） | Chrome 实测 |
| 侧边栏 | 默认固定展开（旧版观感） | Chrome 实测 |
| 去赞助 | 登录页/仪表盘赞助位、赞助页与路由、侧边栏菜单、命令面板入口、14 语言文案全部删除 | HTML 检索 0 命中 + 菜单截图 |
| 内核限速补丁（面板侧） | `model.Client/ClientRecord.speedLimitUp/Down`（kbps）、UI 用 Mbps、`ratelimit.json` 写入、`XRAY_RATELIMIT_FILE` 传给子进程、发布与 Docker 改为从 `third_party/xray-core` 现场编译内核 | 单测 + 实机落库验证 |
| 修掉的真实 bug | 客户更新时 `applyClientRecordMerge` 与 `Updates` 白名单漏了限速两列，导致改完被吃掉 | `TestUpdateByEmailJSONPersistsSpeedLimits` |

### 未完成（按优先级）

#### ✅ P0：限速内核端到端 —— 已解决（2026-11-20）

**验收数据**（修复后 `wait()` + 直写整形器）：

| 场景 | 设定 | 实测 | 误差 |
|---|---|---|---|
| 本机单线程（VLESS→本地 HTTP 源站） | 2 500 000 B/s | 2 524 695 B/s | +1% |
| 本机 4 并发总和（30s 固定窗口） | 2 500 000 B/s | 2 500 737 B/s | +0.03% |
| VPS 单线程（VLESS→speed.cloudflare.com） | 2 500 000 B/s | 2 517 602 B/s | +0.7% |

**根因是两个叠加的 bug（都不是原先猜的方向/所有权问题）：**

1. **`tokenBucket.wait()` 令牌桶算错**（`app/dispatcher/ratelimit.go`）：tokens 不足时把计数清零、只睡差额，醒来 tokens≈差额 < n 永远凑不齐 → 无限振荡；burst 耗尽后彻底 0 B/s。另有 request > burst 被容量上限卡死的问题。修复：保留 tokens 只睡缺口；上限抬到 max(burst, n)。
2. **`shaperWriter` 攒批 64KB 再写**（`app/dispatcher/shaper.go`）：TLS 握手第一趟几 KB 永远凑不满批，对端等它 → 死锁 → 0 字节。修复：先扣令牌、马上直写。**"84KB/s 是小包延迟 ACK"是误诊**——那次实测带着 bug 1 的桶，84KB/s ≈ burst/观测时长。

**复现/验证工具**（在仓库外，别丢）：
- 本机最小复现：`E:\D3X-UI\.tmp\xray-repro\`（run.sh single/multi、agg.sh 30s 固定窗口聚合）
  - ⚠️ 本机 `NO_PROXY` 含 127.0.0.1，curl 必须 `--noproxy ""` 才走代理，否则测的是直连（400MB/s 假象，曾把整轮排查带偏）
  - ⚠️ freedom 出站默认 block 回环（防 SSRF），本地源站要在 `settings.finalRules` 加 `{"action":"allow","ip":["127.0.0.0/8"]}`
- VPS 测试：`/root/ratetest/`（vpsdbg.sh 单线程、vpsmulti.sh 四并发、ratetest.sh 全套）
  - ⚠️ SSH 长连接会被掐断：长任务必须 `setsid nohup ... < /dev/null > log 2>&1 &` 再轮询
  - ⚠️ `pkill -f 'xray -c'` 会杀掉自己的 shell（命令行含同样字符串），用 `[x]ray` 括号技巧
  - VPS 登录：16.5.162.29:2666 root 密码认证（plink `-pw` + `-hostkey "ssh-ed25519 255 SHA256:KAbZZN1kh..."`），本机 `forwarder.py` 在 2222 端口转发

**已知小瑕疵**（不影响验收）：同一用户多条并发流分配不均（convoy 效应，有的拿多有的拿少），但**总和精确**。要完美公平需给令牌桶加 FIFO ticket 队列，可作为后续打磨。

**安全阀**：面板侧写 `ratelimit.json` 需要 `XUI_RATELIMIT_ENABLE=1`；未开启时文件里是空 `users`。内核端已验证，可以开。

#### P1：argo 接入面板 —— MVP 已落地（2026-11-20，commit 3b1f1c64）

调研结论见 `docs/x-ui-yg-argo-analysis.md`（要点：x-ui-yg 的 argo 不在面板里，全在 SSH 脚本；它的分享链接精髓 = 优选 IP 入口 + 隧道域名作 Host/SNI + 8880/8443）。已实现：
- `internal/cloudflared/`：quick（随机 trycloudflare.com，域名从启动日志抓）+ named（token 模式）双隧道监督进程，按需下载官方二进制、崩溃退避重启、日志尾窗。
- `internal/web/service/argo.go` + `controller/argo.go`：配置存 Setting、`/panel/api/argo/*`（status/config/启停/links）、入站校验（WS + 关 TLS）。
- **分享链接走既有 Host 机制**：隧道活跃时自动 upsert Host 行（add=优选 IP、host/sni=隧道域、8443 wss + 8880 ws）→ 订阅/二维码里每个 client 自动多出 Argo 变体（不像 x-ui-yg 只导 clients[0]）。
- 前端 `/argo` 页：双隧道卡片、配置表单、按用户列链接、日志尾窗；14 语言文案已同步（i18n 键对齐测试强制）。
- 30s 对账 job：按设置启停隧道、同步 Host 行。

**待办**：① 真机验证（要 CF 账号：quick 隧道试跑 + named token 跑通，确认域名抓取与链接可用）；② macOS 二进制下载未做（用 `XUI_CLOUDFLARED_PATH` 兜底）；③ 多条 named 隧道/hostname→入站映射表（现在一条 named）；④ 与发布链路（P2）一起在 VPS 上验收。

#### P1b：客户端页实时速度

客户端页**已有**「速度」列（`pages/clients/ClientsPage.tsx` 的 `key: 'speed'`，数据来自 `useClients()` 的 `clientSpeed`，由内核 stats 差分 + WebSocket 推送）。
待办：
- 在有真实流量的机器上确认它会跳字（测试机上无流量，一直显示 `—`）。
- 入站页展开的客户表目前**没有**速度列（只有累计流量），可考虑补一列。

#### P1b：内核源码不再进仓库

仓库里**不再 vendored 内核**，只有 `patches/xray-ratelimit.patch`（相对上游 `676eaf66f8f0`）。
`release.yml` 与 `DockerInit.sh` 的流程是：拉上游源码 tarball → `patch -p1` → `go build ./main`。
好处：仓库小、升级内核 = 换 commit + 重新打补丁；代价：CI 多一次下载与打补丁（已验证命令可用，见下）。

#### P2：发布与分发

- 分支未推送；Actions 未启用；没有 tag → 一键安装还没真正跑通。
- 步骤：推 `feat/d3x-ui` → 仓库 Settings 启用 Actions → 打 tag `v3.11.0-d3.1` → 拿到 8 平台产物 → 服务器执行
  `bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh)`。
- 注意 `release.yml` / `DockerInit.sh` 现在是「拉源码 + 打补丁 + 编译」，**不要再改回下载上游二进制**，否则限速补丁会静默失效。
- 推 GitHub 走 SOCKS 代理：`git -c http.proxy=socks5h://127.0.0.1:3066 push`（直连和透明代理都推不动）。

#### P3：其它

- 入站页「编辑客户」目前是内嵌弹窗（已做），但**客户页的批量操作、主机规则、外链管理**等高级入口仍只在客户页，需要两页之间互跳的地方还要再打磨。
- 旧版 3x-ui 的 `x-ui.sh` 菜单文案、telegram 机器人等上游特有的功能还没逐项对齐。

## 二、环境与坐标

| 用途 | 位置 |
|---|---|
| 本地仓库 | `E:\D3X-UI\repo`，分支 `feat/d3x-ui` |
| 本地工具链 | Go `E:\D3X-UI\tools\go\go`；Node `E:\D3X-UI\tools\node-v26.13.1-win-x64`；MinGW `E:\D3X-UI\tools\mingw\mingw64` |
| 编译要点 | `CGO_ENABLED=1`、`CC` 必须写 gcc 的**绝对路径**、`GOCACHE`/`TMP` 放 E 盘（C 盘只剩 3.8G） |
| 测试 VPS | `16.5.162.29:2666`，root，经本机 `127.0.0.1:3066` SOCKS 代理 |
| 本机 → VPS 转发 | `E:\D3X-UI\forwarder.py`（SSH 用）、`E:\D3X-UI\webproxy.py 8092 16.5.162.29 2053`（面板 HTTP，用它就能在本机 Chrome 打开测试面板） |
| 测试面板 | `http://127.0.0.1:8092`，`admin / D3xTest123`，数据目录 `/root/d3xrun2` |
| 限速测试脚本 | 本机 `E:\D3X-UI\ratetest.sh` / `ratdir.sh` / `ratscale.sh`，VPS 上 `/root/ratetest/` |

## 三、容易踩的坑（都已踩过）

1. `XUI_DEBUG=true` 时前端 JS/CSS 从**磁盘**读，测试机没有 dist → 页面全白。生产/演示请用 `XUI_DEBUG=false`（走内嵌）。
2. 手动往库里插客户只写 `clients` 账本**不够**，必须写 `client_inbounds` 关联行，否则面板认为该客户没挂在任何入站上，更新时只改账本、不写入站 settings（这个假故障排查了很久）。
3. Chrome 里 `127.0.0.1:8090` 这个源被 PWA 的 Service Worker 缓存过，出现白屏时换一个端口号即可。
4. `plink` 的 `-hostkey` 参数偶发报「not a valid format」，改用完整格式 `ssh-ed25519 255 SHA256:...`。
5. SSH 会话里跑长时间编译/测速会被断开，用 `setsid nohup ... > log 2>&1 &` 后台跑再轮询日志。

## 四、关键文件

| 文件 | 作用 |
|---|---|
| `internal/web/service/xray_ratelimit.go` | 生成 `ratelimit.json`（含 `XUI_RATELIMIT_ENABLE` 开关） |
| `internal/web/service/client_speed_limit_test.go` | 限速字段落库回归测试 |
| 补丁涉及的内核文件 | `app/dispatcher/ratelimit.go`（旁路文件 + 令牌桶）、`app/dispatcher/shaper.go`（方向整形器，P0 攻坚对象）、`app/dispatcher/default.go`（`Dispatch` / `WrapLink` 两处 hook） |
| `internal/xray/process.go` | 给内核子进程注入 `XRAY_RATELIMIT_FILE` |
| `patches/xray-ratelimit.patch` | 内核补丁（相对上游 v26.11.9 / `676eaf66f8f0`）；升级内核时重新打它 |
| `internal/web/service/xray_ratelimit.go` | 生成 `ratelimit.json`（含 `XUI_RATELIMIT_ENABLE` 开关） |
| `.github/workflows/release.yml` / `DockerInit.sh` | 拉上游内核源码 → `patch -p1` → 编译出带限速的 xray |
| `docs/d3x-xray-ratelimit.md` | 内核补丁原理 + 升级内核步骤 |
| `frontend/src/pages/inbounds/list/InboundClientsPanel.tsx` | 入站展开的客户表 |
| `frontend/src/pages/clients/ClientEditModal.tsx` | 内嵌完整客户编辑弹窗 |
