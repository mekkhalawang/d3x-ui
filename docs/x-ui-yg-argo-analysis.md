# x-ui-yg Argo（Cloudflare Tunnel）集成机制调研

> 调研对象：https://github.com/yonggekkk/x-ui-yg （yonggekkk 出品，x-ui 精简修改版）
> 调研日期：2026-11-20
> 调研材料：仓库开源文件（install.sh 2938 行、config.json、version 等）、release 闭源面板二进制（strings 验证）、同作者 sing-box-yg 项目文档（交叉印证）
> 本地留档：`E:\D3X-UI\.tmp\x-ui-yg\`（install.sh 等原始文件 + 解包后的 x-ui 二进制）

---

## 一、调研结论摘要

1. **开源情况：部分开源。** 仓库中开源的是一键安装/管理脚本 `install.sh`（2938 行 bash）、Xray 出站模板 `config.json`、GitHub Actions 保活 `ssh.yml`、WARP+Psiphon 助手二进制 `xuiwpph_*`（闭源）。**面板本体 `x-ui` 二进制未开源**（README 明示"二进制文件未开源"），通过 release 包 `x-ui-linux-$cpu.tar.gz` 分发（install.sh:161）。
2. **技术路线：Argo 不在 Web 面板里，而在 SSH 一键脚本里。** 经对 release 面板二进制做字符串检查（`grep -a` 全量搜 `argo`/`cloudflared`/`trycloudflare`/`tunnel`/`jhsub` 等，命中数均为 0），面板二进制不含任何 Argo 逻辑——所谓"把 argo 融合进面板"实为"融合进 x-ui-yg 脚本生态"：Web 面板只负责入站/多用户管理（与原版 vaxilu x-ui 一致），Argo 隧道的启停、配置、订阅链接生成全部由 `install.sh` 的 SSH 文本菜单完成。
3. **双隧道模式：临时隧道（quick tunnel）+ 固定隧道（named tunnel / token 模式）可共存。** 临时隧道用 `cloudflared tunnel --url http://localhost:端口`，自动获得 `*.trycloudflare.com` 随机域名；固定隧道用 `cloudflared tunnel run --token`（Cloudflare Zero Trust 仪表盘托管的 remotely-managed tunnel），域名固定。**不用本地 config.yml / cert.pem / credentials-file**，固定隧道的 ingress 映射（域名→本地端口）在 Cloudflare 网页端配置。
4. **多用户：一条隧道 = 一个 WS 入站端口，多用户 = 该入站下的多个 clients**，共用同一域名与 path，按 uuid/password 区分。聚合订阅导出固定只取 `clients[0]`（每个入站第一个用户），多用户各自链接需在面板查看或手工替换——这是该实现的明显局限。
5. **CDN/优选 IP 有完整处理**：分享链接的"地址"填优选 IP/域名（默认 `www.visa.com.sg`，走 CF anycast 快速入口），`host`/`sni` 填 Argo 隧道域名（CF 按 Host 头路由到隧道），端口用 CF 标准端口 8880（ws 无 TLS）/8443（wss TLS）。
6. **可靠性偏弱（对 D3X-UI 是机会点）**：cloudflared 仅靠 crontab `@reboot` 开机拉起，无运行时崩溃自愈（守护脚本只盯 x-ui/xray 进程）；二进制无版本管理、无自动更新（`--no-autoupdate`）；固定隧道的回源端口与脚本记录端口靠用户手工保持一致。

---

## 二、架构图（文字版数据流）

```
                          （VPS，x-ui-yg 环境）
┌────────────────────────────────────────────────────────────────┐
│  SSH 一键脚本 install.sh（菜单 3→1→xuiargo）                    │
│    ├─ cloudflaredargo(): 下载 cloudflared → /usr/local/x-ui/    │
│    ├─ cfargo():      临时隧道  --url http://localhost:$port     │
│    ├─ cfargoym():    固定隧道  run --token $TOKEN               │
│    └─ sharesub_sbcl(): 读 bin/config.json 生成订阅/分享链接      │
│                                                                │
│  Web 面板 x-ui（闭源 fork，systemd 托管）                       │
│    └─ 管理 Xray 入站/多用户 clients                             │
│       运行时全量 xray 配置落盘 → /usr/local/x-ui/bin/config.json │
│                                                                │
│  cloudflared 进程 A（临时）          cloudflared 进程 B（固定）  │
│    --url http://localhost:WS端口      run --token（回源端口      │
│    pid→xuiargopid.log                 在 CF 仪表盘配置）        │
│    域名从 argo.log 抓取               pid→xuiargoympid.log      │
│                                                                │
│  Xray（由面板拉起）                                              │
│    └─ WS 入站（vmess/vless/trojan/ss-ws，关 TLS、header 留空）   │
│         ├─ client#1 (uuid1)  ←── 多用户共用此入站               │
│         ├─ client#2 (uuid2)                                    │
│         └─ ...                                                 │
└────────────────────────────────────────────────────────────────┘
        │ A: tunnel --url（出站连 CF）        │ B: run --token（出站连 CF）
        ▼                                     ▼
┌────────────────────────────────────────────────────────────────┐
│                 Cloudflare 边缘网络（CDN）                       │
│  临时入口：https://xxx.trycloudflare.com                         │
│  固定入口：https://自定义域名（Zero Trust 配置 hostname→service） │
│  客户端实际接入：优选 IP 域名:8880/8443（Host/SNI=隧道域名）      │
└────────────────────────────────────────────────────────────────┘
        ▲
        │  vmess/vless-ws over CF（ws://8880 或 wss://8443）
   客户端（订阅链接 / jhsub.txt / clmi.yaml / sbox.json）
```

关键点：**cloudflared 只出站连接 CF，不监听公网端口**；流量方向为 客户端 → CF 边缘（优选 IP 入口）→ 隧道 → cloudflared → `localhost:WS端口` → Xray 入站 → 按 clients 认证。

---

## 三、关键实现细节清单

以下行号均指向 `install.sh`（仓库 `yonggekkk/x-ui-yg:main`，本地留档 `E:\D3X-UI\.tmp\x-ui-yg\install.sh`）。

### 3.1 cloudflared 二进制怎么管理

**【源码证实】** `cloudflaredargo()`（install.sh:898-911）：

```bash
cloudflaredargo(){
if [ ! -e /usr/local/x-ui/cloudflared ]; then
case $(uname -m) in
aarch64) cpu=arm64;;
x86_64) cpu=amd64;;
esac
curl -L -o /usr/local/x-ui/cloudflared -# --retry 2 https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$cpu
chmod +x /usr/local/x-ui/cloudflared
fi
green "Argo版本：V$(/usr/local/x-ui/cloudflared version 2>/dev/null | awk '{print $3}')"
}
```

- **下载源**：官方 `github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-{amd64|arm64}`，落到 `/usr/local/x-ui/cloudflared`。
- **版本管理**：无。已存在即跳过下载（只判断文件存在），跟随 `latest`，运行时带 `--no-autoupdate` 禁用自更新。无校验和验证。
- **进程生命周期**：
  - 启动（临时，install.sh:950-951）：`/usr/local/x-ui/cloudflared tunnel --url http://localhost:$port --edge-ip-version auto --no-autoupdate --protocol http2 > /usr/local/x-ui/argo.log 2>&1 &`，PID 写入 `/usr/local/x-ui/xuiargopid.log`。
  - 启动（固定，install.sh:1010）：`nohup setsid /usr/local/x-ui/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token ${argotoken} >/dev/null 2>&1 & echo "$!" > /usr/local/x-ui/xuiargoympid.log`。
  - **守护/重启**：仅 crontab `@reboot sleep 10 && ...` 开机重拉（install.sh:969、1017，命令把 PID 写回 pid 文件）。另有 `goxui.sh` 每分钟自检（install.sh:653-663）**只重启 x-ui/xray，不管 cloudflared**——即运行期崩溃不会自动拉活。**【源码证实（cron 条目穷举）】**
  - 停止/卸载：`kill -15` pid 文件对应进程，删除 `argo.log`、pid 文件、port/token/domain 记录文件，清理 cron（install.sh:974-980、1024-1030）。
- **可共存**：临时与固定各用独立 pid 文件（`xuiargopid.log` / `xuiargoympid.log`）与独立端口记录，可同时运行（README"集成argo固定临时双隧道（可共存）"）。

### 3.2 Argo 隧道配置怎么生成

**【源码证实】** 不生成任何配置文件——没有 `config.yml`、没有 `cert.pem`/credentials、没有本地 named tunnel 定义。两种模式：

| | 临时隧道（quick） | 固定隧道（named, token 模式） |
|---|---|---|
| 命令 | `cloudflared tunnel --url http://localhost:$port ...`（L950） | `cloudflared tunnel ... run --token ${argotoken}`（L1010） |
| 域名 | 自动发 `*.trycloudflare.com`，从 `argo.log` 抓取（L953-954：`grep -a trycloudflare.com | awk 'NR==2...'`） | 用户输入，存 `/usr/local/x-ui/xuiargoym.log` |
| 凭据 | 无需 | 用户输入 token（Zero Trust 仪表盘生成），存 `/usr/local/x-ui/xuiargotoken.log` |
| 回源映射 | 命令行 `--url` 指定 | **在 Cloudflare 仪表盘配置**（L994 提示"请确保Cloudflare官网 --- Zero Trust --- Networks --- Tunnels已设置完成"） |
| 域名验证 | 重试 5 次：`curl -sL https://$domain -I` 命中 `404|400|503` 视为有效（L945-962） | 无脚本侧验证，仅 sleep 20（L1011） |
| 状态记录 | 端口→`xuiargoport.log` | 端口→`xuiargoymport.log`，域名/Token 各自 log |

即 **token 模式（remotely-managed tunnel）而非本地配置文件模式**；固定隧道的 hostname→localhost:端口 映射由用户在 CF 仪表盘的 Public Hostname 里配（典型配 `http://localhost:<WS端口>`）。**【源码证实脚本行为；"映射在仪表盘配"系基于 token 模式原理 + L994 提示的推断】**

命令行公共参数：`--edge-ip-version auto --no-autoupdate --protocol http2`（http2 传输协议，非 quic）。

### 3.3 UI 放在哪 / 用户怎么开启

**【源码证实】** 全部在 SSH 文本菜单，不在 Web 面板：

- 入口：`show_menu` 主菜单选 `3`（附加功能 `changeserv`，L725）→ 选 `1`（"设置Argo临时、固定隧道" `xuiargo`）→ 选 `1`（临时 `cfargo`）或 `2`（固定 `cfargoym`）。
- `xuiargo()`（L913-932）先打印三个前提（**【源码证实】** L915-919）：
  1. 节点传输协议必须是 **WS**；
  2. 节点 **TLS 必须关闭**；
  3. 请求头（host header）**留空不设**；
  4. 可用节点：vmess-ws、vless-ws、trojan-ws、shadowsocks-ws，推荐 vmess-ws。
- 用户操作：输入"Argo 监听的 WS 节点端口"（面板里已建好的 WS 入站端口）→（固定隧道再输 Token+域名）→ 脚本起 cloudflared 并回写 cron。
- 状态展示也在脚本主菜单（L2803-2866）：显示隧道运行状态、监听端口、协议、UUID/密码、path、临时/固定域名，并带错误反馈（"ws节点开启了tls，不支持Argo"、"面板尚未创建对应端口的ws节点"等）。
- **Web 面板二进制无任何 Argo UI**：strings 验证 `argo`/`cloudflared`/`tunnel`/`trycloudflare` 命中 0（仅 `cloudflare/circl` 加密库符号）；README 亦称面板设置与 vaxilu 原版保持一致。**【源码证实】**

### 3.4 多用户怎么走 Argo

**【源码证实】** 模型是"**一条隧道 ↔ 一个 WS 入站端口**"：

- 启动时用户手动指定一个 WS 入站端口（L941/L1000），cloudflared 回源该端口。
- **多用户 = 面板在该 WS 入站下建多个 clients**（x-ui 原生多客户端能力），所有用户共享同一隧道域名 + 同一 ws path，以各自 uuid（vmess/vless）或 password（trojan）区分。没有"一个用户一条隧道/一个域名"的分配机制。
- 固定隧道想路由多个入站，理论上可在 CF 仪表盘给同一 tunnel 配多条 Public Hostname（不同 hostname→不同 localhost 端口）；但脚本侧只记录/展示一个端口，聚合订阅也只认一个端口。**【前者是 CF 平台能力的推断，后者源码证实】**
- 订阅生成对用户凭据的取法（L2059，固定隧道同构 L2299）：

  ```bash
  uuid=$(jq -r --arg port "$(cat /usr/local/x-ui/xuiargoport.log ...)" \
    '.inbounds[] | select(.port == ($port | tonumber)) | .settings.clients[0].id' \
    /usr/local/x-ui/bin/config.json)
  ```

  **固定只取 `clients[0]`**（全部协议的订阅导出都如此：L1517/1581/1634/... 亦然）。即聚合订阅只带出第一个用户的凭据，其余用户的 Argo 链接需管理员在面板内查看对应 client 后手工把 server 换成 Argo 域名。**【源码证实；"需手工替换"是基于此局限的推断】**

### 3.5 隧道与 Xray 入站的端口绑定关系

**【源码证实】**

- **临时隧道**：命令行直接 `--url http://localhost:$port`（L950），`$port` 即 Xray 的 WS 入站端口。一对一硬绑定。
- **固定隧道**：脚本不下发回源端口到 cloudflared（token 模式无本地 ingress）；实际绑定发生在 **CF 仪表盘 Public Hostname 的 service 字段**（用户填 `http://localhost:<WS端口>`）。脚本里的 `xuiargoymport.log` 仅用于展示与订阅生成时反查节点信息。**【"绑定在仪表盘"为推断（依据 token 模式机制 + L994 提示），脚本侧行为源码证实】**
- **客户端侧端口与 VPS 端口无关**：分享链接用 CF 标准端口 **8880（无 TLS）/ 8443（TLS）**（L2174-2175、L2293-2294），VPS 不开公网端口（cloudflared 全部出站连接）。
- 校验联动（L2063、L2820-2831）：脚本会用 jq 反查该端口入站的 protocol / streamSettings.security，要求 protocol ∈ {vless,vmess}（订阅生成）或 {vless,vmess,trojan,ss}（状态展示）且 `security != "tls"`，否则报错提示关 TLS。

### 3.6 CDN / 优选 IP / 节点分享链接处理

**【源码证实】** 有完整处理，`xuicfadd()`（L1037-1067）+ `sharesub_sbcl()`（L1210 起）：

- **优选 IP 配置**：`/usr/local/x-ui/bin/xuicdnip_argo.txt` 存 Argo 节点优选 IP/域名（默认 `www.visa.com.sg`，推荐 www.visa.com.sg / www.wto.org / www.web.com 等大厂 CF 站点）；另有 `xuicdnip_ws.txt` 管非 Argo 主节点的优选 IP。原理：客户端把 `add` 解析到这些 CF anycast 入口以提速，Host/SNI 仍为隧道域名，CF 照常路由到隧道。
- **分享链接格式**（jhsub.txt 聚合订阅，L2174-2175、L2293-2294，固定隧道 L2414-2415、L2533 同构）：

  ```
  vless://$uuid@$cdnargo:8880?type=ws&security=none&path=$ws_path&host=$argolsym#vl-argo临时-8880
  vless://$uuid@$cdnargo:8443?type=ws&security=tls&path=$ws_path&host=$argolsym#vl-tls-argo临时-8443
  vmess://base64{"add":"$cdnargo","host":"$argolsym","id":"$uuid","net":"ws","path":"$ws_path","port":"8880"...}
  ```

  其中 `$cdnargo`=优选 IP 域名，`$argolsym`/`$argoym`=临时/固定隧道域名（作 Host/SNI），每种协议出 8880/8443 两条（无 TLS / TLS 各一）。
- **订阅产物**：`jhsub.txt`（聚合通用链接）、`clmi.yaml`（clash-meta）、`sbox.json`（sing-box），节点信息从 `/usr/local/x-ui/bin/config.json`（面板落盘的运行时 xray 全量配置，二进制 strings 证实含 `bin/config.json` 路径）用 jq 解析拼装。
- **分发渠道**：① 本地订阅服务（`ipsub()` L767-848：python http 服务挂 `/root/webxui/<token>/`，输出三个文件，端口/路径可配）；② Gitlab 推送（`sharesub()` L1162-1181）；③ 直接 cat 文件/二维码展示。
- **面板联动**：`version` 文件称"XUI面版指定节点的添加、变更、删除将自动同步IP订阅链接"——面板二进制对指定节点变更会自动同步本地订阅产物。**【文本证实；具体实现未开源，属推断（可能由面板回调脚本或直接重写产物）】**

### 3.7 其他佐证与边界

- `config.json`（仓库根）是 Xray **出站模板**（WARP wireguard/socks 出站、geoip 分流），与 Argo 无关。**【源码证实】**
- 同作者姊妹项目 **sing-box-yg** 的 DeepWiki 文档（"Temporary vs Fixed Tunnels"）描述了同一套模式（boot.log 抓 trycloudflare、ARGO_DOMAIN/ARGO_AUTH.log、`run --token`、13 端口覆盖），可交叉印证甬哥系脚本的 Argo 实现范式。**【外部资料佐证】**
- 面板二进制来源：`https://github.com/yonggekkk/x-ui-yg/releases/download/xui_yg/x-ui-linux-${cpu}.tar.gz`（install.sh:161），内含 `x-ui`（27MB Go 二进制，strings 显示含 "x-ui-yg"/"ygkkk" 标识）+ xray + geo 数据。**【源码+strings 证实】**

---

## 四、对 D3X-UI 的借鉴建议

D3X-UI 现状（3x-ui v3.11.0 二开）：Go 后端（`internal/xray`、`internal/sub`、`internal/web/controller`、`internal/database/model`、已有 `internal/tunnelmonitor`）+ React 前端（`frontend/src/pages/{inbounds,nodes,settings,sub,...}`）。建议**不要复刻 x-ui-yg 的"脚本+SSH 菜单"路线**，而是把同等能力原生集成进面板，同时保留它的两个精髓：① 双隧道（quick + named token）共存；② 分享链接 = 优选 IP 入口 + 隧道域名作 Host/SNI + CF 标准端口。

### 4.1 cloudflared 二进制与进程管理

- 新增 `internal/argo/`（或 `internal/service/argo_service.go`）：
  - 下载官方 release 到 `/usr/local/x-ui/bin/cloudflared`（按 GOARCH 选 amd64/arm64，**加 SHA256 校验、版本号记录、可升级**——弥补 x-ui-yg 无版本管理的短板）。
  - 进程 supervisor 用 Go goroutine 管理（`exec.Command` + 崩溃指数退避重启 + 状态事件进 eventbus），替代 crontab `@reboot`；面板重启/开机由现有服务生命周期统一拉起。
  - 解析临时隧道域名：不要 grep 文本 log（x-ui-yg 方式脆弱），优先解析 cloudflared 的 `--metrics` / JSON 日志或 `cloudflared tunnel info`；失败时复用其"curl 验证 404/400/503"思路做兜底。

### 4.2 配置存储

- 持久化到 DB（`internal/database/model`）：建议独立 `argo_tunnel` 表或 settings 键（`argo.temp.port`、`argo.temp.domain`、`argo.fixed.token`、`argo.fixed.domain`、`argo.fixed.origin_port`、`argo.cdn.preferred_ip`）。**支持多条 named tunnel（hostname→入站端口的映射表）**，直接超越 x-ui-yg 的"临时×1+固定×1、每条只绑一个端口"限制。
- token 模式照抄（`run --token`，免 cert.pem/credentials）；同时可选支持本地 config.yml 模式（`tunnel run --config`）给进阶用户做多 ingress，但默认走 token 降低门槛。

### 4.3 UI 放哪

- `frontend/src/pages/` 新增 **"Argo 隧道"** 页面（或 `settings` 下加 tab）：开关、绑定入站（下拉选择 WS 入站，联动校验"WS + 关 TLS + header 留空"）、临时/固定双卡、实时状态/域名/日志、重置与停止按钮。
- `inbounds`/`nodes` 页的节点分享弹窗：对 WS 入站自动生成 Argo 变体链接（add=优选 IP、host/sni=隧道域名、8880/8443），并显示每个 client 的专属链接（**遍历全部 clients，不要学 `clients[0]`**）。
- API：`internal/web/controller` 新增 argo controller（状态查询/启停/配置），错误提示沿用 x-ui-yg 的三条（TLS 开了、协议不对、入站不存在）。

### 4.4 多用户与订阅

- 模型：一个 tunnel ↔ 一个（或一组 hostname↔）WS 入站；多用户 = 入站多 clients，uuid/password 区分——与 x-ui-yg 一致，但订阅侧在 `internal/sub/`（如 `host_sub.go`/`build_urls`）为**每个 client** 生成带其 uuid 的 Argo 链接（vmess/vless/trojan/ss-ws），支持 clash/sing-box/聚合格式（D3X-UI 已有 clash_yaml/sbox 基础设施）。
- 固定隧道多入站：利用 named tunnel 多 Public Hostname（或本地 config.yml 多 ingress），面板里 hostname 与入站一一映射，避免 x-ui-yg"手动输端口 + CF 仪表盘另配"两处不一致的问题（**面板生成/校验 ingress 配置或至少展示一致的回源端口**）。

### 4.5 端口与 CDN 细节

- 客户端链接统一用 CF 标准端口 8880（ws）/8443（wss），可再补 2052/2082/2086/2095/80/8880/8080 与 2053/2083/2087/2096/8443/443 全套（sing-box-yg 的"13 端口全覆盖"做法）；`add` 字段默认 `www.visa.com.sg` 并允许用户自定义优选 IP（存 DB）。
- TLS 变体：wss 链接 `security=tls` 时 `sni`/`serverName`=隧道域名，`skip-cert-verify=false`（CF 证书有效，x-ui-yg 亦如此）。

### 4.6 落地文件清单（建议）

| 位置 | 改动 |
|---|---|
| `internal/argo/`（新） | cloudflared 下载/校验/进程 supervisor/域名解析 |
| `internal/database/model/model.go` 或新 model 文件 | argo 隧道配置持久化 |
| `internal/web/controller/`（新 argo_controller） | REST API：状态/启停/配置 |
| `internal/sub/host_sub.go` 等 URL 构造处 | Argo 链接生成（add=优选IP，host/sni=隧道域，8880/8443） |
| `frontend/src/pages/`（新 argo 页）+ `api/` + 路由/菜单 | Argo 管理 UI、入站分享弹窗的 Argo 链接 |
| `internal/eventbus` / 启动生命周期 | 面板启动时按 DB 配置拉起隧道、状态广播 |
| `internal/tunnelmonitor`（已有，待确认职责） | 可能可复用其监控/告警框架托管 cloudflared 健康检查 |

---

## 五、证实 / 推断标注汇总

| 结论 | 性质 | 依据 |
|---|---|---|
| 面板二进制闭源、argo 逻辑全在 install.sh | **源码证实** | README 声明 + 面板二进制 strings 零命中（argo/cloudflared/tunnel/jhsub 等） |
| cloudflared 下载路径/来源/chmod | **源码证实** | install.sh:898-911 |
| 临时隧道 `--url`、域名抓取、验证重试、@reboot cron | **源码证实** | install.sh:941-971 |
| 固定隧道 `run --token`、token/域名存 log、@reboot cron | **源码证实** | install.sh:987-1022 |
| 无 config.yml/cert.pem，token 模式 | **源码证实** | 全文无相关文件读写；命令行仅 `--token` |
| 固定隧道回源端口在 CF 仪表盘配置 | **推断** | token（remotely-managed）模式机制 + install.sh:994 提示文本 |
| cloudflared 运行期崩溃无自愈、仅开机重启 | **源码证实**（cron 穷举） | @reboot 条目外无 cloudflared 监控；goxui.sh 只管 x-ui/xray（L653-663） |
| UI 在 SSH 菜单（3→1→1/2），Web 面板无 Argo UI | **源码证实** | install.sh:725/913-932 + strings 零命中 |
| 一隧道一 WS 端口，多用户=入站多 clients | **源码证实** | install.sh:941/1000 + clients 机制 |
| 聚合订阅只导出 clients[0] | **源码证实** | install.sh:2059/2299 等 |
| 其余用户需手工换 uuid 拼链接 | **推断** | 基于 clients[0] 局限 |
| 链接 add=优选IP、host/sni=隧道域、8880/8443 | **源码证实** | install.sh:2174-2175/2293-2294/2414-2415/2533 |
| 优选 IP 文件 xuicdnip_argo.txt、默认 www.visa.com.sg | **源码证实** | install.sh:1037-1067/1211-1215 |
| 订阅产物 jhsub/clmi/sbox + 本地 webxui 或 Gitlab 分发 | **源码证实** | install.sh:1210-1482/767-848/1162-1181 |
| 面板"节点变更自动同步IP订阅" | **文本证实，实现推断** | version 文件；二进制闭源 |
| 面板落盘 bin/config.json 供脚本 jq 解析 | **源码证实** | 二进制 strings 含 `bin/config.json`；install.sh:1492 起读取 |
| 前提约束（WS/关TLS/空header） | **源码证实** | install.sh:915-919、2063/2820 校验逻辑 |
| sing-box-yg 同套 Argo 范式 | **外部资料佐证** | deepwiki.com/yonggekkk/sing-box-yg "Temporary vs Fixed Tunnels" |
