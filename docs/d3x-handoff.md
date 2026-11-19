# D3X-UI 二次开发交接说明

> 状态快照：2026-11-19 21:30。本文件写给「下一个接手的任务」，避免重复考古。

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

#### P0：限速内核端到端不成立 ⚠️

**现象**：给用户设 20 Mbps（2 500 000 B/s），单线程下载实测 **84 944 B/s**（只有设定值的 3%），改成队列式整形后变成 **0 B/s**（传输直接断流）。

**已排除**：
- 不是配置问题：`ratelimit.json` 正确写出，面板/账本/settings 三处一致。
- 不是方向问题：只限上行时下载 40 MB/s，只限下行时才被压住 → 上行=Reader、下行=Writer 的映射是对的。
- 不是 VLESS 走错入口：v26.11.9 的 VLESS 走 `DispatchLink`（VMess 走 `Dispatch`），第一版只挂 `Dispatch` 所以完全没限速，已补 `WrapLink` 处的 hook。
- 不是令牌桶算错：桶速率打印为 2 500 000 B/s，`wait()` 的 deficit ≤ 单次 8 KB。

**已知的两个坑**（都写在 `docs/d3x-xray-ratelimit.md`）：
1. 直接在数据通路上 `time.Sleep` 会把管道堵死：写侧被阻塞 → 上游停读 → socket 窗口耗尽 → 实际速率远低于设定值（这是 84 KB/s 的来源）。
2. 把写操作挪到独立 goroutine（队列整形）破坏了 Xray 的同步写契约：VLESS 入站的 writer 不能被别的 goroutine 调用，表现为传输断流（这是 0 B/s 的来源）。

**当前代码状态**：`third_party/xray-core/app/dispatcher/shaper.go` 是「同 goroutine 攒够 64 KB 再写」的版本（理论上正确），但**最后一次实测仍是 0 B/s**，尚未定位。

**下一步建议**：
1. 先用 `curl -v` 看客户端到底收到多少字节，判断是「没写出去」还是「写出去但被丢弃」；对比 `xray` 日志里的 `accepted` 与实际字节数。
2. 用最小复现（本地 python http server + 两个 xray 进程）替代 Cloudflare，排除外网因素（注意：Xray 的 freedom 默认 finalRules 会 block 回环地址，本地 HTTP server 需要改 outbound finalRules 或改用公网地址）。
3. 怀疑点：`buf.SplitSize` 的返回值顺序是 `(remaining, chunk)`（已修过一次），以及 `pending` 的缓冲区所有权在 `Close()` 时是否被释放两次。
4. 验证标准：**单线程 ≈ 设定值；4 条并发总和仍 ≈ 设定值**（这正是用户关心的「是不是只限单线程」）。

**安全阀**：限速**默认关闭**——面板侧写 `ratelimit.json` 需要 `XUI_RATELIMIT_ENABLE=1`；未开启时文件里是空 `users`，内核不会限速。**在 P0 修好前，生产环境不要开这个开关。**

#### P1：客户端页实时速度

客户端页**已有**「速度」列（`pages/clients/ClientsPage.tsx` 的 `key: 'speed'`，数据来自 `useClients()` 的 `clientSpeed`，由内核 stats 差分 + WebSocket 推送）。
待办：
- 在有真实流量的机器上确认它会跳字（测试机上无流量，一直显示 `—`）。
- 入站页展开的客户表目前**没有**速度列（只有累计流量），可考虑补一列。

#### P2：发布与分发

- 分支未推送；Actions 未启用；没有 tag → 一键安装还没真正跑通。
- 步骤：推 `feat/d3x-ui` → 仓库 Settings 启用 Actions → 打 tag `v3.11.0-d3.1` → 拿到 8 平台产物 → 服务器执行
  `bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh)`。
- 注意 `release.yml` 现在从 `third_party/xray-core` 编译内核，**不要再改回下载上游二进制**，否则限速补丁会静默失效。

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
| `internal/xray/process.go` | 给内核子进程注入 `XRAY_RATELIMIT_FILE` |
| `third_party/xray-core/app/dispatcher/ratelimit.go` | 旁路文件读取 + 令牌桶 |
| `third_party/xray-core/app/dispatcher/shaper.go` | 方向整形器（P0 攻坚对象） |
| `third_party/xray-core/app/dispatcher/default.go` | `Dispatch` / `WrapLink` 两处 hook |
| `patches/xray-ratelimit.patch` | 相对上游的补丁（升级内核时用） |
| `docs/d3x-xray-ratelimit.md` | 内核补丁原理 + 升级内核步骤 |
| `frontend/src/pages/inbounds/list/InboundClientsPanel.tsx` | 入站展开的客户表 |
| `frontend/src/pages/clients/ClientEditModal.tsx` | 内嵌完整客户编辑弹窗 |
