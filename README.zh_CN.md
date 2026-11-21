# D3X-UI

[English](README.md) | [简体中文](README.zh_CN.md)

**D3X-UI** 是一个开源的 Xray 网络面板，用于部署、配置和监控多种代理协议——从单台 VPS 到多节点部署。项目基于 3x-ui v3.11.0 冻结二次开发，独立演进，面向多用户上网管理场景。

> [!IMPORTANT]
> 本项目仅供个人学习使用，请勿用于非法用途或生产环境。

## 功能特性

- **多协议入站** — VLESS、VMess、Trojan、Shadowsocks、WireGuard、AmneziaWG、TUIC v5、Hysteria2、MTProto、HTTP、SOCKS (Mixed)、Dokodemo-door / Tunnel 和 TUN。
- **现代传输与安全** — TCP (Raw)、mKCP、WebSocket、gRPC、HTTPUpgrade、XHTTP，支持 TLS、XTLS、REALITY。
- **按客户端限速** — 每个用户的上/下行速率上限（界面按 Mbps 设置），由内置补丁版 Xray-core 执行；同一用户的多条并发连接共用一个令牌桶，开多条连接也无法突破限额。
- **内置 Argo（Cloudflare Tunnel）** — 临时隧道（随机 `*.trycloudflare.com` 域名）与固定隧道（Zero Trust Token 模式）全部在面板内管理：自动下载并守护 `cloudflared`、崩溃自动重启；分享链接自动生成 CDN 变体（优选 Cloudflare IP 作为连接地址、隧道域名作 Host/SNI、端口 8443/8880），覆盖每一个客户端。
- **一键 Argo 节点** — 入站页一键创建完整 Argo 节点：选临时/固定隧道、填域名与 Token、回源端口留空自动分配，创建入站、生成客户端、绑定隧道、启动并输出用户链接一步到位。
- **一键自签证书** — 入站安全设置中按 SNI 域名一键生成自签证书（CN+SAN=SNI），适配自签 + 任意域名的部署场景；Hysteria2 支持"允许不安全"，分享链接自动携带 `insecure=1` / Clash `skip-cert-verify`。
- **入站内嵌客户管理** — 入站行内展开客户表：启用开关、到期时间、流量、限速、删除，添加/编辑客户复用完整表单，无需跳转页面。
- **AmneziaWG 内置** — 抗 DPI 的 WireGuard 以内置用户态网络栈运行在面板内，无需内核模块、DKMS 或额外依赖。
- **原生 TUIC v5 服务** — 进程内 Go QUIC 服务，对接 Xray 路由与按客户端流量统计，服务端支持 BBR 与 New Reno。
- **MTProto 代理** — 按客户端的 FakeTLS 密钥、广告标签与配额，热更新不掉线。
- **Fallback（回落）** — 借助 Xray fallback 在单端口上服务多种协议（例如 443 端口同时跑 VLESS 和 Trojan）。
- **按客户端管理** — 流量配额、到期日期、IP 限制（受信任地址豁免）、HWID 设备数限制、定时续期、实时在线状态，一键分享链接、二维码与订阅。
- **流量统计** — 按入站、按客户端、按出站统计，支持重置。
- **多节点管理** — 从单一面板管理多台服务器，支持入站克隆到其他节点。
- **出站与路由** — WARP、NordVPN、PIA、自定义路由规则、负载均衡（支持 balancer 回退）、出站链式代理；内置 geosite / geoip 分类可在规则编辑器中浏览。
- **内置订阅服务** — raw、JSON、Clash 输出，按客户端 User-Agent 自动选择，支持[自定义订阅页面模板](docs/custom-subscription-templates.md)。
- **Telegram 与 Discord 机器人** 远程监控与管理。
- **RESTful API** — 支持作用域与过期时间的 API Token，面板内置 API 文档。
- **可安装面板（PWA）** — 可固定到桌面或手机主屏。
- **灵活存储** — SQLite（默认）或 PostgreSQL。
- **14 种界面语言**，暗色 / 亮色主题。
- **Fail2ban 集成**，用于按客户端 IP 限制的强制执行。

## 快速开始

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh)
```

安装指定版本，追加 tag（例如 `v3.11.0-d3.1`）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh) v3.11.0-d3.1
```

安装滚动 **dev** 构建（`main` 分支每次提交的最新预发布，非稳定版）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh) dev-latest
```

安装过程会生成随机的用户名、密码与访问路径。安装完成后运行 `d3x-ui` 打开管理菜单，可启停服务、查看或重置登录凭据、管理 SSL 证书等。

安装脚本的交互提示默认使用中文；设置 `XUI_LANG=en` 可切换为英文。安装过程中会询问是否自定义面板用户名和密码——回答 `y` 则自行指定（密码需输入两次确认），直接回车或回答 `N` 则继续使用随机生成的凭据。

每个发布产物均附带 `.sha256` 校验文件，`install.sh` 与更新器都会校验后再继续。

### 无人值守安装

安装器支持 **非交互** 运行（适用于 cloud-init）。设置 `XUI_NONINTERACTIVE=1`（或无 TTY 管道输入）即可零提示完成安装，随机凭据写入 `/etc/d3x-ui/install-result.env`。参见 [`deploy/`](deploy/)：

- [Cloud-init user-data](deploy/cloud-init/) — 在任意云上无人值守安装（Hetzner/AWS/DO/Vultr/GCP/Azure/Oracle）
- [Hetzner Cloud 说明](deploy/marketplace/hetzner/)

## 支持平台

**操作系统：** Ubuntu、Debian、Armbian、Fedora、CentOS、RHEL、AlmaLinux、Rocky Linux、Oracle Linux、Amazon Linux、Virtuozzo、Arch、Manjaro、Parch、openSUSE（Tumbleweed / Leap）、Alpine 与 Windows。

**架构：** `amd64` · `386` · `arm64` (aarch64) · `armv7` · `armv6` · `armv5` · `s390x`。

## 数据库选项

- **SQLite**（默认）— 单文件 `/etc/d3x-ui/d3x-ui.db`，零配置，适合中小规模部署。
- **PostgreSQL** — 适合大规模部署与集中管理。

运行时通过环境变量选择后端（安装程序会写入 `/etc/default/d3x-ui`）：

```bash
XUI_DB_TYPE=postgres
XUI_DB_DSN=postgres://xui:password@127.0.0.1:5432/xui?sslmode=disable
```

迁移已有 SQLite 数据到 PostgreSQL：

```bash
d3x-ui migrate-db --dsn "postgres://xui:password@127.0.0.1:5432/xui?sslmode=disable"
# 然后设置 XUI_DB_TYPE 与 XUI_DB_DSN 并重启：
systemctl restart d3x-ui
```

### Docker

默认 `docker compose up -d` 使用 SQLite；如需 PostgreSQL，取消注释 `docker-compose.yml` 中的 `XUI_DB_*` 两行并以对应 profile 启动。镜像发布于 `ghcr.io/mekkhalawang/d3x-ui`。

## 环境变量

| 变量 | 说明 | 默认值 |
|---|---|---|
| `XUI_DB_TYPE` | 数据库后端：`sqlite` 或 `postgres` | `sqlite` |
| `XUI_DB_DSN` | PostgreSQL 连接串（`XUI_DB_TYPE=postgres` 时） | — |
| `XUI_DB_FOLDER` | SQLite 数据库文件目录 | `/etc/d3x-ui` |
| `XUI_INIT_WEB_BASE_PATH` | Web 面板初始 URI 路径 | `/` |
| `XUI_ENABLE_FAIL2BAN` | 启用基于 Fail2ban 的 IP 限制执行 | `true` |
| `XUI_LOG_LEVEL` | 日志级别（`debug`、`info`、`warning`、`error`） | `info` |
| `XUI_DEBUG` | 启用调试模式 | `false` |
| `XUI_RATELIMIT_ENABLE` | 开启按客户端限速（面板写出限额表，由补丁版内核执行） | `false` |
| `XUI_CLOUDFLARED_PATH` | 使用已安装的 `cloudflared` 二进制，而不是自动下载 | — |
| `XUI_TUNNEL_HEALTH_MONITOR` | 启用隧道健康监控（探测某 URL，连续失败后重启 xray） | `false` |
| `XUI_LANG` | 安装脚本提示语言：`zh`（默认）或 `en`。不跟随系统 locale | `zh` |

完整列表参见[环境变量参考](https://github.com/mekkhalawang/d3x-ui#readme/docs/reference/env-vars)。

## 许可证

GPL-3.0
