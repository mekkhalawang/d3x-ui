# D3X-UI

**D3X-UI** is an open-source Xray web panel for deploying, configuring, and monitoring a wide range of proxy protocols — from a single VPS to multi-node deployments. The project is a frozen secondary development of 3x-ui v3.11.0 and evolves independently, focused on multi-user internet access management.

> [!IMPORTANT]
> This project is intended for personal use only. Please do not use it for illegal purposes or in a production environment.

## Features

- **Multi-protocol inbounds** — VLESS, VMess, Trojan, Shadowsocks, WireGuard, AmneziaWG, TUIC v5, Hysteria2, MTProto, HTTP, SOCKS (Mixed), Dokodemo-door / Tunnel, and TUN.
- **Modern transports & security** — TCP (Raw), mKCP, WebSocket, gRPC, HTTPUpgrade, and XHTTP, secured with TLS, XTLS, and REALITY.
- **Per-client speed limits** — upload/download caps per user (Mbps in the UI), enforced by the bundled patched Xray-core; concurrent connections of one user share the same token bucket, so opening more streams cannot multiply the limit.
- **Argo (Cloudflare Tunnel) built in** — quick tunnels (random `*.trycloudflare.com` host) and named tunnels (Zero Trust token mode) are managed straight from the panel: `cloudflared` is downloaded and supervised automatically, crashed tunnels are restarted, and share links gain CDN variants (preferred Cloudflare IP as the dial address, tunnel domain as Host/SNI, ports 8443/8880) for every client.
- **One-click Argo node** — create a complete Argo node from the inbounds page in one shot: pick quick or named tunnel, enter the domain and token, leave the origin port empty for a random one; the inbound, client, tunnel binding, tunnel start and user links are all produced in a single step.
- **One-click self-signed certificate** — generate a self-signed certificate from the SNI in the inbound's security tab (CN + SAN = SNI), built for self-signed + arbitrary-domain setups. Hysteria2 supports "allow insecure", and share links carry `insecure=1` / Clash `skip-cert-verify` automatically.
- **Inbound-embedded client management** — expand an inbound row to manage its clients inline: enable switches, expiry, traffic, speed limits and delete, with the full add/edit form available without leaving the page.
- **AmneziaWG built in** — DPI-resistant WireGuard runs inside the panel on a userspace network stack, with no kernel module, DKMS, or extra packages to install.
- **Native TUIC v5 server** — an in-process Go QUIC server with Xray routing and per-client traffic accounting; BBR and New Reno are available server-side.
- **MTProto proxies** — per-client FakeTLS secrets, ad-tags, and quotas, applied live without dropping existing connections.
- **Fallbacks** — serve multiple protocols on a single port (e.g. VLESS and Trojan on 443) using Xray's fallback support.
- **Per-client management** — traffic quotas, expiry dates, IP limits with trusted-address exemptions, HWID device limits, scheduled renewal cycles, live online status, and one-click share links, QR codes, and subscriptions.
- **Traffic statistics** — per inbound, per client, and per outbound, with reset controls.
- **Multi-node support** — manage and scale across multiple servers from a single panel, including cloning inbounds onto other nodes.
- **Outbound & routing** — WARP, NordVPN, PIA, custom routing rules, load balancers with balancer-to-balancer fallback, and outbound proxy chaining. Bundled geosite and geoip categories are browsable straight from the rule editor.
- **Built-in subscription server** — raw, JSON, and Clash output, auto-selected from the client's User-Agent, plus [custom page templates](docs/custom-subscription-templates.md).
- **Telegram and Discord bots** for remote monitoring and management.
- **RESTful API** with scoped, optionally expiring tokens and an in-panel API reference.
- **Installable panel (PWA)** — pin D3X-UI to a desktop or phone home screen.
- **Flexible storage** — SQLite (default) or PostgreSQL.
- **14 UI languages** with dark and light themes.
- **Fail2ban integration** for enforcing per-client IP limits.

## Quick Start

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh)
```

To install a specific version, append its tag (e.g. `v3.11.0-d3.1`):

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh) v3.11.0-d3.1
```

To install the rolling **dev** build (latest per-commit pre-release from `main`, not a stable release), pass `dev-latest`:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh) dev-latest
```

During installation a random username, password, and access path are generated. After installation, run `d3x-ui` to open the management menu, where you can start/stop the service, view or reset your login credentials, manage SSL certificates, and more.

Every release asset is published with a `.sha256` sum next to it. Both `install.sh` and the updater verify the archive against that sum and abort on a mismatch.

### Unattended install

The installer also runs **non-interactively** for cloud-init. Set `XUI_NONINTERACTIVE=1` (or pipe with no TTY) and it installs end-to-end with zero prompts, generating random credentials and writing them to `/etc/d3x-ui/install-result.env`. See [`deploy/`](deploy/):

- [Cloud-init user-data](deploy/cloud-init/) — unattended install on any cloud (Hetzner/AWS/DO/Vultr/GCP/Azure/Oracle)
- [Hetzner Cloud notes](deploy/marketplace/hetzner/)

## Supported Platforms

**Operating systems:** Ubuntu, Debian, Armbian, Fedora, CentOS, RHEL, AlmaLinux, Rocky Linux, Oracle Linux, Amazon Linux, Virtuozzo, Arch, Manjaro, Parch, openSUSE (Tumbleweed / Leap), Alpine, and Windows.

**Architectures:** `amd64` · `386` · `arm64` (aarch64) · `armv7` · `armv6` · `armv5` · `s390x`.

## Database Options

- **SQLite** (default) — a single file at `/etc/d3x-ui/d3x-ui.db`. Zero setup, ideal for small and medium deployments.
- **PostgreSQL** — ideal for large deployments and centralized management.

At runtime the backend is selected via environment variables (the installer writes these to `/etc/default/d3x-ui` for you):

```bash
XUI_DB_TYPE=postgres
XUI_DB_DSN=postgres://xui:password@127.0.0.1:5432/xui?sslmode=disable
```

Migrating an existing SQLite install to PostgreSQL:

```bash
d3x-ui migrate-db --dsn "postgres://xui:password@127.0.0.1:5432/xui?sslmode=disable"
# then set XUI_DB_TYPE and XUI_DB_DSN in /etc/default/d3x-ui and restart:
systemctl restart d3x-ui
```

### Docker

The default `docker compose up -d` keeps using SQLite. To run with the bundled PostgreSQL service, uncomment the two `XUI_DB_*` env lines in `docker-compose.yml` and start with the matching profile. Images are published to `ghcr.io/mekkhalawang/d3x-ui`.

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `XUI_DB_TYPE` | Database backend: `sqlite` or `postgres` | `sqlite` |
| `XUI_DB_DSN` | PostgreSQL connection string (when `XUI_DB_TYPE=postgres`) | — |
| `XUI_DB_FOLDER` | Directory for the SQLite database file | `/etc/d3x-ui` |
| `XUI_INIT_WEB_BASE_PATH` | The initial URI path for the web panel | `/` |
| `XUI_ENABLE_FAIL2BAN` | Enable Fail2ban-based IP-limit enforcement | `true` |
| `XUI_LOG_LEVEL` | Log verbosity (`debug`, `info`, `warning`, `error`) | `info` |
| `XUI_DEBUG` | Enable debug mode | `false` |
| `XUI_RATELIMIT_ENABLE` | Turn on per-client speed limits (the panel writes the limit table the patched core enforces) | `false` |
| `XUI_CLOUDFLARED_PATH` | Use an existing `cloudflared` binary instead of the auto-downloaded one | — |
| `XUI_TUNNEL_HEALTH_MONITOR` | Enable the tunnel health monitor (probes a URL and restarts xray after repeated failures) | `false` |

The complete list is on the [environment variables reference](https://github.com/mekkhalawang/d3x-ui#readme/docs/reference/env-vars).

## License

GPL-3.0
