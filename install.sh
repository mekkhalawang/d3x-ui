#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
plain='\033[0m'

# ---------------------------------------------------------------------------
# Localization
#
# The interactive prompts and the normal install output are bilingual. Chinese
# is the default for D3X-UI; set XUI_LANG=en for the original English wording.
#
# The default deliberately does NOT follow the system locale: most overseas
# cloud images ship LANG=en_US.UTF-8, so locale sniffing would silently drop
# the user back to English and defeat the Chinese-first install experience.
# The language is therefore an explicit opt-in (XUI_LANG=en) rather than an
# automatic one.
#
# xui_tr <english-text> [printf-args...] echoes the localized wording. The
# lookup key is the English string itself, so an unknown key silently falls
# back to English rather than printing an empty prompt.
# ---------------------------------------------------------------------------
case "${XUI_LANG:-zh}" in
    en | en_US | en_GB | en_US.* | en_GB.* | EN | EN_* | En | En_*) XUI_LANG_RESOLVED="en" ;;
    *) XUI_LANG_RESOLVED="zh" ;;
esac

# xui_zh <english-text> echoes the Chinese wording for a known key, or the
# English text itself when the key is unknown. A case statement is used on
# purpose: an associative-array lookup misses keys that contain
# parentheses, because bash re-parses the subscript as an expression.
xui_zh() {
    case "$1" in
        "Would you like to customize the Panel Port settings? (If not, a random port will be applied) [y/N]: ") printf '%s' "是否自定义面板端口设置？（不自定义则随机分配端口）[y/N]: " ;;
        "Please set up the panel port: ") printf '%s' "请设置面板端口: " ;;
        "Would you like to set a custom panel username and password? (If not, random ones will be applied) [y/N]: ") printf '%s' "是否自定义面板用户名和密码？（不自定义则随机生成）[y/N]: " ;;
        "Please enter the panel username: ") printf '%s' "请输入面板用户名: " ;;
        "Please enter the panel password: ") printf '%s' "请输入面板密码: " ;;
        "Please re-enter the panel password to confirm: ") printf '%s' "请再次输入面板密码以确认: " ;;
        "Port to use for ACME HTTP-01 listener (default 80): ") printf '%s' "ACME HTTP-01 验证使用的端口（默认 80）: " ;;
        "Enter another port for acme.sh standalone listener (leave empty to abort): ") printf '%s' "请输入 acme.sh 独立监听使用的其他端口（留空则中止）: " ;;
        "Please enter your domain name: ") printf '%s' "请输入你的域名: " ;;
        "Please choose which port to use (default is 80): ") printf '%s' "请选择要使用的端口（默认 80）: " ;;
        "Would you like to modify --reloadcmd for ACME? (y/n): ") printf '%s' "是否为 ACME 修改 --reloadcmd？(y/n): " ;;
        "Choose an option: ") printf '%s' "请选择一个选项: " ;;
        "Please enter your custom reloadcmd: ") printf '%s' "请输入自定义 reloadcmd: " ;;
        "Would you like to set this certificate for the panel? (y/n): ") printf '%s' "是否将该证书设置为面板证书？(y/n): " ;;
        "Choose an option (default 2 for IP): ") printf '%s' "请选择一个选项（IP 证书默认选 2）: " ;;
        "Let's Encrypt for Domain (90-day validity, auto-renews)") printf '%s' "Let's Encrypt 域名证书（90 天有效，自动续期）" ;;
        "Let's Encrypt for IP Address (6-day validity, auto-renews)") printf '%s' "Let's Encrypt IP 证书（6 天有效，自动续期）" ;;
        "Self-signed Certificate for IP (no port 80 needed, no renewal)") printf '%s' "自签 IP 证书（无需 80 端口，无需续期）" ;;
        "Custom SSL Certificate (Path to existing files)") printf '%s' "使用已有 SSL 证书（指定文件路径）" ;;
        "Skip SSL (advanced — behind reverse proxy / SSH tunnel only)") printf '%s' "跳过 SSL（高级选项——仅用于反向代理 / SSH 隧道）" ;;
        "Options 1 & 2 require port 80 open. Option 3 needs no port and no renewal. Option 4 requires manual paths.") printf '%s' "选项 1、2 需要开放 80 端口；选项 3 无需端口、无需续期；选项 4 需要手动指定路径。" ;;
        "Option 5 serves the panel over plain HTTP — only safe behind nginx/Caddy or an SSH tunnel.") printf '%s' "选项 5 会以纯 HTTP 提供面板服务——仅在 nginx/Caddy 反向代理或 SSH 隧道之后使用。" ;;
        "Enter the IP address for the self-signed certificate (press Enter to use %s): ") printf '%s' "请输入自签证书使用的 IP 地址（回车使用 %s）: " ;;
        "Is %s the correct incoming public IPv4 address for this server? [Default y]: ") printf '%s' "%s 是本服务器正确的入站公网 IPv4 地址吗？[默认 y]: " ;;
        "Please enter your server's public IPv4 address: ") printf '%s' "请输入你的服务器公网 IPv4 地址: " ;;
        "Do you have an IPv6 address to include? (leave empty to skip): ") printf '%s' "是否需要包含 IPv6 地址？（留空则跳过）: " ;;
        "Please enter domain name certificate issued for: ") printf '%s' "请输入证书签发对应的域名: " ;;
        "Input certificate path (keywords: .crt / fullchain): ") printf '%s' "输入证书路径（关键字：.crt / fullchain）: " ;;
        "Input private key path (keywords: .key / privatekey): ") printf '%s' "输入私钥路径（关键字：.key / privatekey）: " ;;
        "Bind the panel to 127.0.0.1 only? (recommended — forces SSH tunnel / reverse-proxy access) [y/N]: ") printf '%s' "是否只将面板绑定到 127.0.0.1？（推荐——强制通过 SSH 隧道或反向代理访问）[y/N]: " ;;
        "Enter PostgreSQL DSN (postgres://user:pass@host:port/dbname?sslmode=disable): ") printf '%s' "请输入 PostgreSQL DSN（postgres://user:pass@host:port/dbname?sslmode=disable）: " ;;
        "Choose [1]: ") printf '%s' "请选择 [1]: " ;;
        "Please answer yes or no (Enter defaults to No).") printf '%s' "请回答 yes 或 no（直接回车默认为 No）。" ;;
        "Invalid port. Enter a number between 1 and 65535.") printf '%s' "端口无效，请输入 1 到 65535 之间的数字。" ;;
        "Username cannot be empty. Please try again.") printf '%s' "用户名不能为空，请重新输入。" ;;
        "Username cannot be longer than 256 characters. Please try again.") printf '%s' "用户名不能超过 256 个字符，请重新输入。" ;;
        "Password cannot be empty. Please try again.") printf '%s' "密码不能为空，请重新输入。" ;;
        "The passwords do not match. Please try again.") printf '%s' "两次输入的密码不一致，请重新输入。" ;;
        "Invalid IPv4 address. Please try again.") printf '%s' "IPv4 地址无效，请重新输入。" ;;
        "Database Selection") printf '%s' "数据库选择" ;;
        "SSL Certificate Setup (RECOMMENDED)") printf '%s' "SSL 证书配置（推荐）" ;;
        "Panel Installation Complete!") printf '%s' "面板安装完成！" ;;
        "PostgreSQL Credentials") printf '%s' "PostgreSQL 凭据" ;;
        "Generated new random login credentials:") printf '%s' "已生成新的登录凭据:" ;;
        "New WebBasePath: ") printf '%s' "新的 WebBasePath: " ;;
        "Default credentials detected. Security update required...") printf '%s' "检测到仍在使用默认凭据，需要进行安全更新..." ;;
        "Username:    ") printf '%s' "用户名:     " ;;
        "Password:    ") printf '%s' "密码:       " ;;
        "Port:        ") printf '%s' "端口:       " ;;
        "WebBasePath: ") printf '%s' "访问路径:   " ;;
        "Database:    ") printf '%s' "数据库:     " ;;
        "Access URL:  ") printf '%s' "访问地址:   " ;;
        "API Token:   ") printf '%s' "API 令牌:   " ;;
        "⚠ IMPORTANT: Save these credentials securely!") printf '%s' "⚠ 重要：请妥善保存以上凭据！" ;;
        "⚠ SSL Certificate: Enabled and configured") printf '%s' "⚠ SSL 证书：已启用并配置完成" ;;
        "⚠ SSL Certificate: Skipped — panel is HTTP-only. Use a reverse proxy or SSH tunnel.") printf '%s' "⚠ SSL 证书：已跳过——面板仅支持 HTTP，请使用反向代理或 SSH 隧道。" ;;
        "Would you like to customize the panel settings (port, username, password, access path)? (If not, random values will be applied) [Y/n]: ") printf '%s' "是否自定义面板设置（端口、用户名、密码、访问路径）？（不自定义则随机生成）[Y/n]: " ;;
        "Would you like to set a custom panel access path? (If not, a random one will be applied) [y/N]: ") printf '%s' "是否自定义面板访问路径？（不自定义则随机生成）[y/N]: " ;;
        "Please enter the panel access path (letters and digits only): ") printf '%s' "请输入面板访问路径（仅限字母、数字、连字符和下划线）: " ;;
        "The access path cannot be empty. Please try again.") printf '%s' "访问路径不能为空，请重新输入。" ;;
        "The access path may only contain letters, digits, hyphens and underscores. Please try again.") printf '%s' "访问路径只能包含字母、数字、连字符和下划线，请重新输入。" ;;
        "The access path must be at least 6 characters long. Please try again.") printf '%s' "访问路径至少需要 6 个字符，请重新输入。" ;;
        "The access path cannot be longer than 64 characters. Please try again.") printf '%s' "访问路径不能超过 64 个字符，请重新输入。" ;;
        "Please answer yes or no (Enter defaults to Yes).") printf '%s' "请回答 yes 或 no（直接回车默认为 Yes）。" ;;
        "  %ssudo -u postgres psql -d %s%s      (as the postgres superuser)") printf '%s' "  %ssudo -u postgres psql -d %s%s      （以 postgres 超级用户身份）" ;;
        "  %s%s://%s:%s/%s%s → Backup & Restore") printf '%s' "  %s%s://%s:%s/%s%s → 备份与恢复" ;;
        "  1) Install PostgreSQL locally and create a dedicated user/db (recommended)") printf '%s' "  1) 本地安装 PostgreSQL 并创建专用用户/数据库（推荐）" ;;
        "  1) Retry local install") printf '%s' "  1) 重试本地安装" ;;
        "  1) SQLite     (default — recommended for < 500 clients)") printf '%s' "  1) SQLite     （默认——适合 500 个客户端以内）" ;;
        "  2) Enter an external DSN instead") printf '%s' "  2) 改为输入外部 DSN" ;;
        "  2) PostgreSQL (recommended for high client counts / many nodes)") printf '%s' "  2) PostgreSQL （适合客户端数量多 / 多节点场景）" ;;
        "  2) Use an existing PostgreSQL server (enter DSN)") printf '%s' "  2) 使用已有的 PostgreSQL 服务器（输入 DSN）" ;;
        "  3) Abort install") printf '%s' "  3) 中止安装" ;;
        "  4) Fall back to SQLite") printf '%s' "  4) 回退到 SQLite" ;;
        "  Back Up downloads a pg_dump .dump file; Restore reloads it via pg_restore.") printf '%s' "  「备份」会下载 pg_dump 生成的 .dump 文件；「恢复」通过 pg_restore 重新载入。" ;;
        "  Cert: ") printf '%s' "  证书: " ;;
        "  Cert: %s/fullchain.pem") printf '%s' "  证书: %s/fullchain.pem" ;;
        "  If using an SSH key:") printf '%s' "  如果使用 SSH 密钥:" ;;
        "  Key:  ") printf '%s' "  私钥: " ;;
        "  Key:  %s/privkey.pem") printf '%s' "  私钥: %s/privkey.pem" ;;
        "  Standard SSH command:") printf '%s' "  标准 SSH 命令:" ;;
        "  Then open in your browser:") printf '%s' "  然后在浏览器中打开:" ;;
        "  • A reverse proxy (nginx, Caddy, Traefik) terminates TLS for you, or") printf '%s' "  • 由反向代理（nginx、Caddy、Traefik）为你终止 TLS，或" ;;
        "  • You access the panel exclusively via SSH tunnel") printf '%s' "  • 你只通过 SSH 隧道访问面板" ;;
        "%s is not available for %s (HTTP %s)") printf '%s' "%s 对 %s 不可用（HTTP %s）" ;;
        "Access URL:  %s://%s:%s/") printf '%s' "访问地址:  %s://%s:%s/" ;;
        "Access URL: https://%s:%s/") printf '%s' "访问地址: https://%s:%s/" ;;
        "Alternative: point a reverse proxy (nginx/Caddy) at 127.0.0.1:%s and let it terminate TLS.") printf '%s' "另一种方式：让反向代理（nginx/Caddy）指向 127.0.0.1:%s 并由它终止 TLS。" ;;
        "Auto renew setup had issues, certificate details:") printf '%s' "自动续期配置存在问题，证书详情:" ;;
        "Auto renew succeeded, certificate details:") printf '%s' "自动续期配置成功，证书详情:" ;;
        "Beginning to install d3x-ui ") printf '%s' "开始安装 d3x-ui " ;;
        "Certificate File: ") printf '%s' "证书文件: " ;;
        "Certificate files are at:") printf '%s' "证书文件位于:" ;;
        "Certificate files installed successfully") printf '%s' "证书文件安装成功" ;;
        "Certificate files not found") printf '%s' "未找到证书文件" ;;
        "Certificate files not found after installation") printf '%s' "安装后未找到证书文件" ;;
        "Certificate files were not created") printf '%s' "证书文件未能创建" ;;
        "Certificate issued successfully, installing...") printf '%s' "证书签发成功，正在安装..." ;;
        "Certificate paths configured successfully") printf '%s' "证书路径配置成功" ;;
        "Certificate paths set for the panel") printf '%s' "已为面板设置证书路径" ;;
        "Certificate valid for ~6 days, auto-renews via acme.sh cron job.") printf '%s' "证书有效期约 6 天，通过 acme.sh 定时任务自动续期。" ;;
        "Checksum mismatch for $(basename \"%s\"): expected %s, got ") printf '%s' "\$(basename \"%s\") 校验不匹配：期望 %s，实际为 " ;;
        "Checksum verified: ") printf '%s' "校验通过: " ;;
        "Choose SSL certificate setup method:") printf '%s' "请选择 SSL 证书配置方式:" ;;
        "Could not auto-detect server IP from any provider.") printf '%s' "无法从任何服务自动检测到服务器 IP。" ;;
        "Could not back up bin/ -- custom files there will not be preserved across this update") printf '%s' "无法备份 bin/ ——其中的自定义文件在本次更新后不会保留" ;;
        "Default --reloadcmd for ACME is: %ssystemctl restart d3x-ui || rc-service d3x-ui restart") printf '%s' "ACME 默认的 --reloadcmd 为: %ssystemctl restart d3x-ui || rc-service d3x-ui restart" ;;
        "Default listener is port 80. If you choose another port, ensure external port 80 forwards to it.") printf '%s' "默认监听端口为 80。如果选择其他端口，请确保外部 80 端口转发到该端口。" ;;
        "Domain name cannot be empty. Please try again.") printf '%s' "域名不能为空，请重新输入。" ;;
        "Download d3x-ui %s failed, please check if the version exists ") printf '%s' "下载 d3x-ui %s 失败，请检查该版本是否存在 " ;;
        "Downloaded d3x-ui release archive is empty") printf '%s' "下载的 d3x-ui 发布包为空" ;;
        "Downloaded d3x-ui.rc is empty") printf '%s' "下载的 d3x-ui.rc 为空" ;;
        "Downloaded d3x-ui.sh is empty") printf '%s' "下载的 d3x-ui.sh 为空" ;;
        "Downloading d3x-ui failed, please be sure that your server can access GitHub ") printf '%s' "下载 d3x-ui 失败，请确认服务器可以访问 GitHub " ;;
        "Error: Certificate or private key file not found for domain: %s.") printf '%s' "错误：未找到域名 %s 对应的证书或私钥文件。" ;;
        "Error: File does not exist! Try again.") printf '%s' "错误：文件不存在！请重试。" ;;
        "Error: File exists but is not readable (check permissions)!") printf '%s' "错误：文件存在但不可读（请检查权限）！" ;;
        "Error: File is empty!") printf '%s' "错误：文件为空！" ;;
        "Existing certificate found for %s, will reuse it.") printf '%s' "已找到 %s 的现有证书，将直接复用。" ;;
        "Extracted d3x-ui archive is missing the d3x-ui binary -- the previous installation has already been removed, so the panel will not start until this is fixed; try running the installer again") printf '%s' "解压后的 d3x-ui 压缩包中缺少 d3x-ui 可执行文件——旧版本已被移除，需修复后面板才能启动，请重新运行安装脚本" ;;
        "Fail2ban setup complete.") printf '%s' "Fail2ban 配置完成。" ;;
        "Failed to create temporary credentials file.") printf '%s' "创建临时凭据文件失败。" ;;
        "Failed to download d3x-ui.rc") printf '%s' "下载 d3x-ui.rc 失败" ;;
        "Failed to download the checksum for $(basename \"%s\") (HTTP %s)") printf '%s' "下载 \$(basename \"%s\") 的校验文件失败（HTTP %s）" ;;
        "Failed to extract the d3x-ui release archive -- the previous installation has already been removed, so the panel will not start until this is fixed; try running the installer again") printf '%s' "解压 d3x-ui 发布包失败——旧版本已被移除，需修复后面板才能启动，请重新运行安装脚本" ;;
        "Failed to fetch d3x-ui version, it may be due to GitHub API restrictions, please try it later") printf '%s' "获取 d3x-ui 版本失败，可能是 GitHub API 限制，请稍后重试" ;;
        "Failed to generate the self-signed certificate") printf '%s' "生成自签证书失败" ;;
        "Failed to install acme.sh") printf '%s' "安装 acme.sh 失败" ;;
        "Failed to install acme.sh, skipping SSL setup") printf '%s' "安装 acme.sh 失败，已跳过 SSL 配置" ;;
        "Failed to install certificate") printf '%s' "安装证书失败" ;;
        "Failed to install d3x-ui.rc") printf '%s' "安装 d3x-ui.rc 失败" ;;
        "Failed to install d3x-ui.service file") printf '%s' "安装 d3x-ui.service 文件失败" ;;
        "Failed to install d3x-ui.service from GitHub (%s) -- the release tarball did not ship one either") printf '%s' "无法从 GitHub 安装 d3x-ui.service（%s）——发布包中也没有该文件" ;;
        "Failed to install d3x-ui.sh") printf '%s' "安装 d3x-ui.sh 失败" ;;
        "Failed to issue IP certificate") printf '%s' "签发 IP 证书失败" ;;
        "Failed to issue certificate for ") printf '%s' "为以下域名签发证书失败: " ;;
        "Found d3x-ui.service in extracted files, installing...") printf '%s' "在解压文件中找到 d3x-ui.service，正在安装..." ;;
        "Found d3x-ui.service.arch in extracted files, installing...") printf '%s' "在解压文件中找到 d3x-ui.service.arch，正在安装..." ;;
        "Found d3x-ui.service.debian in extracted files, installing...") printf '%s' "在解压文件中找到 d3x-ui.service.debian，正在安装..." ;;
        "Found d3x-ui.service.rhel in extracted files, installing...") printf '%s' "在解压文件中找到 d3x-ui.service.rhel，正在安装..." ;;
        "Found incomplete acme.sh state for %s (no valid certificate files); cleaning it up and re-issuing.") printf '%s' "发现 %s 的 acme.sh 状态不完整（没有有效的证书文件），将清理后重新签发。" ;;
        "Generating the key pair...") printf '%s' "正在生成密钥对..." ;;
        "Got d3x-ui latest version: %s, beginning the installation...") printf '%s' "获取到 d3x-ui 最新版本：%s，开始安装..." ;;
        "IP certificate installed and configured successfully!") printf '%s' "IP 证书安装并配置成功！" ;;
        "IPv4 address is required") printf '%s' "必须提供 IPv4 地址" ;;
        "Including IPv6 address: ") printf '%s' "包含 IPv6 地址: " ;;
        "Install a release that ships it, or 'dev' for the rolling build. Your existing installation has not been touched.") printf '%s' "请安装包含该文件的发布版本，或使用 'dev' 安装滚动构建版。当前安装未被改动。" ;;
        "Install aborted.") printf '%s' "安装已中止。" ;;
        "Installing PostgreSQL locally (non-interactive)...") printf '%s' "正在本地安装 PostgreSQL（非交互模式）..." ;;
        "Installing PostgreSQL — this may take a moment...") printf '%s' "正在安装 PostgreSQL——这可能需要一点时间..." ;;
        "Installing acme.sh for SSL certificate management...") printf '%s' "正在安装 acme.sh 用于 SSL 证书管理..." ;;
        "Installing certificate failed, exiting.") printf '%s' "安装证书失败，退出。" ;;
        "Installing certificate succeeded, enabling auto renew...") printf '%s' "安装证书成功，正在启用自动续期..." ;;
        "Installing the rolling dev build (tag: dev-latest). This is a per-commit pre-release, not a stable version.") printf '%s' "正在安装滚动 dev 构建（tag: dev-latest）。这是每次提交都会更新的预发布版本，不是稳定版。" ;;
        "Invalid IPv4 address: ") printf '%s' "无效的 IPv4 地址: " ;;
        "Invalid domain format: %s. Please enter a valid domain name.") printf '%s' "域名格式无效: %s，请输入合法的域名。" ;;
        "Invalid option. Skipping SSL setup.") printf '%s' "无效选项，已跳过 SSL 配置。" ;;
        "Invalid port provided.") printf '%s' "提供的端口无效。" ;;
        "Invalid port provided. Falling back to 80.") printf '%s' "提供的端口无效，回退到 80。" ;;
        "Issuing IP certificate for %s...") printf '%s' "正在为 %s 签发 IP 证书..." ;;
        "Issuing SSL certificate for %s...") printf '%s' "正在为 %s 签发 SSL 证书..." ;;
        "Issuing certificate failed, please check logs.") printf '%s' "签发证书失败，请查看日志。" ;;
        "Issuing certificate succeeded, installing certificates...") printf '%s' "签发证书成功，正在安装证书..." ;;
        "It's recommended to put d3x-ui restart at the end") printf '%s' "建议把 d3x-ui restart 放在最后" ;;
        "Keeping default reloadcmd") printf '%s' "保持默认 reloadcmd" ;;
        "Let's Encrypt now supports both domains and IP addresses!") printf '%s' "Let's Encrypt 现已同时支持域名和 IP 地址！" ;;
        "Login credentials and cookies will travel as plain HTTP.") printf '%s' "登录凭据与 Cookie 将以明文 HTTP 传输。" ;;
        "No checksum published for this release, skipping verification") printf '%s' "该发布版本未提供校验文件，跳过校验" ;;
        "Note: IP certificates are valid for ~6 days and will auto-renew.") printf '%s' "注意：IP 证书有效期约 6 天，到期会自动续期。" ;;
        "Note: Port 80 must be open and accessible from the internet") printf '%s' "注意：80 端口必须开放且可从公网访问" ;;
        "Note: You are responsible for renewing these files externally.") printf '%s' "注意：这些文件的续期需要你自行处理。" ;;
        "Note: systemd %s ignores part of the hardening in d3x-ui.service; the panel still starts.") printf '%s' "注意：systemd %s 会忽略 d3x-ui.service 中的部分加固项，但面板仍可正常启动。" ;;
        "Only safe when:") printf '%s' "仅在以下情况安全:" ;;
        "Panel will listen on all interfaces over plain HTTP. Make sure something else is terminating TLS in front of it.") printf '%s' "面板将以明文 HTTP 监听所有网卡，请确保前置有其他组件终止 TLS。" ;;
        "Panel will restart to apply SSL certificate...") printf '%s' "面板将重启以应用 SSL 证书..." ;;
        "Please ensure port %s is reachable (or forwarded from external port 80)") printf '%s' "请确保端口 %s 可访问（或已从外部 80 端口转发）" ;;
        "Please ensure port 80 is open and try again later with: d3x-ui") printf '%s' "请确保 80 端口已开放，稍后可用 d3x-ui 重试" ;;
        "Please use a newer version (at least v2.3.5). Exiting installation.") printf '%s' "请使用更新的版本（至少 v2.3.5），安装已退出。" ;;
        "Port %s is busy; cannot proceed in non-interactive mode.") printf '%s' "端口 %s 被占用；非交互模式下无法继续。" ;;
        "Port %s is busy; cannot proceed.") printf '%s' "端口 %s 被占用；无法继续。" ;;
        "Port %s is free and ready for standalone validation.") printf '%s' "端口 %s 空闲，可用于独立验证。" ;;
        "Port %s is in use.") printf '%s' "端口 %s 已被占用。" ;;
        "PostgreSQL backup & restore is built into the panel:") printf '%s' "面板内置 PostgreSQL 备份与恢复:" ;;
        "PostgreSQL installation failed in non-interactive mode; aborting.") printf '%s' "非交互模式下 PostgreSQL 安装失败，中止安装。" ;;
        "PostgreSQL installation failed.") printf '%s' "PostgreSQL 安装失败。" ;;
        "Private Key File: ") printf '%s' "私钥文件: " ;;
        "Reloadcmd is: ") printf '%s' "Reloadcmd 为: " ;;
        "Reloadcmd is: systemctl reload nginx ; systemctl restart d3x-ui") printf '%s' "Reloadcmd 为: systemctl reload nginx ; systemctl restart d3x-ui" ;;
        "Reminder: Let's Encrypt still connects on port 80; forward external port 80 to %s.") printf '%s' "提醒：Let's Encrypt 仍通过 80 端口连接，请将外部 80 端口转发到 %s。" ;;
        "Restored custom file(s) in bin/ not shipped by this release: ") printf '%s' "已恢复本发布未包含的 bin/ 自定义文件: " ;;
        "Running...") printf '%s' "正在运行..." ;;
        "SSH Port Forwarding — open the panel from your local machine via:") printf '%s' "SSH 端口转发——在本地机器上通过以下方式打开面板:" ;;
        "SSL certificate already configured. No action needed.") printf '%s' "SSL 证书已配置，无需操作。" ;;
        "SSL certificate installed and configured successfully!") printf '%s' "SSL 证书安装并配置成功！" ;;
        "SSL certificate setup failed for domain mode.") printf '%s' "域名模式的 SSL 证书配置失败。" ;;
        "SSL is strongly recommended. Skip only if a reverse proxy") printf '%s' "强烈建议启用 SSL。仅当反向代理" ;;
        "SSL setup may have completed, but domain extraction failed") printf '%s' "SSL 配置可能已完成，但域名提取失败" ;;
        "Self-signed certificate installed and configured successfully!") printf '%s' "自签证书安装并配置成功！" ;;
        "Service files not found in tar.gz, downloading from GitHub...") printf '%s' "tar.gz 中未找到服务文件，正在从 GitHub 下载..." ;;
        "Set XUI_DB_DSN to use an existing server, or XUI_DB_TYPE=sqlite.") printf '%s' "如需使用已有服务器请设置 XUI_DB_DSN，或设置 XUI_DB_TYPE=sqlite。" ;;
        "Setting certificate paths for the panel...") printf '%s' "正在为面板设置证书路径..." ;;
        "Setting up Fail2ban for the IP Limit feature...") printf '%s' "正在为 IP 限制功能配置 Fail2ban..." ;;
        "Setting up Let's Encrypt IP certificate (shortlived profile)...") printf '%s' "正在配置 Let's Encrypt IP 证书（短期证书配置）..." ;;
        "Setting up SSL certificate...") printf '%s' "正在配置 SSL 证书..." ;;
        "Setting up self-signed certificate for %s...") printf '%s' "正在为 %s 生成自签证书..." ;;
        "Setting up systemd unit...") printf '%s' "正在配置 systemd 服务单元..." ;;
        "Skipping panel path setting.") printf '%s' "已跳过面板路径设置。" ;;
        "Stopping panel temporarily...") printf '%s' "正在临时停止面板..." ;;
        "This command will run on every certificate issue and renew.") printf '%s' "该命令会在每次签发和续期证书时执行。" ;;
        "Username, Password, and WebBasePath are properly set.") printf '%s' "用户名、密码与访问路径均已正确设置。" ;;
        "Using Let's Encrypt for IP certificate (shortlived profile)...") printf '%s' "正在使用 Let's Encrypt 签发 IP 证书（短期证书配置）..." ;;
        "Using Let's Encrypt for domain certificate...") printf '%s' "正在使用 Let's Encrypt 签发域名证书..." ;;
        "Using a self-signed certificate for the panel IP...") printf '%s' "正在为面板 IP 使用自签证书..." ;;
        "Using custom existing certificate...") printf '%s' "正在使用已有的自定义证书..." ;;
        "Using existing certificate, installing certificates...") printf '%s' "使用现有证书，正在安装证书..." ;;
        "Using port %s for standalone validation.") printf '%s' "使用端口 %s 进行独立验证。" ;;
        "Valid for 10 years — no renewal needed.") printf '%s' "有效期 10 年——无需续期。" ;;
        "Warning: Could not set certificate paths automatically") printf '%s' "警告：无法自动设置证书路径" ;;
        "Warning: could not refresh %s/d3x-ui.service.d/10-xui-sandbox.conf.") printf '%s' "警告：无法刷新 %s/d3x-ui.service.d/10-xui-sandbox.conf。" ;;
        "WebBasePath is missing or set to root. Generating a new one...") printf '%s' "访问路径缺失或被设为根路径，正在生成新的..." ;;
        "Will use port: %s to issue certificates. Please make sure this port is open.") printf '%s' "将使用端口: %s 签发证书，请确保该端口已开放。" ;;
        "XUI_ENABLE_FAIL2BAN=%s, skipping Fail2ban auto-setup.") printf '%s' "XUI_ENABLE_FAIL2BAN=%s，已跳过 Fail2ban 自动配置。" ;;
        "XUI_SSL_MODE=domain requires a valid XUI_DOMAIN (got: '%s').") printf '%s' "XUI_SSL_MODE=domain 需要一个有效的 XUI_DOMAIN（当前为: '%s'）。" ;;
        "Your browser will warn that the certificate is not trusted; click 'Advanced' to continue.") printf '%s' "浏览器会提示证书不受信任，点击「高级」→「继续访问」即可。" ;;
        "Your domain is ready for issuing certificates now...") printf '%s' "你的域名已就绪，正在签发证书..." ;;
        "Your domain is: %s, checking it...") printf '%s' "你的域名是: %s，正在检查..." ;;
        "Your input %s is invalid, will use default port 80.") printf '%s' "你输入的 %s 无效，将使用默认端口 80。" ;;
        "acme.sh installed successfully") printf '%s' "acme.sh 安装成功" ;;
        "acme.sh will automatically renew and reload d3x-ui before expiry.") printf '%s' "acme.sh 会在到期前自动续期并重载 d3x-ui。" ;;
        "%sd3x-ui %s%s installation finished, it is running now...") printf '%s' "%sd3x-ui %s%s 安装完成，服务已启动..." ;;
        "d3x-ui CLI not found; skipping Fail2ban auto-setup.") printf '%s' "未找到 d3x-ui CLI，已跳过 Fail2ban 自动配置。" ;;
        "openssl is required to generate a self-signed certificate") printf '%s' "生成自签证书需要 openssl" ;;
        "or SSH tunnel handles TLS for you.") printf '%s' "或 SSH 隧道已为你处理 TLS 时才可跳过。" ;;
        "⚠ Panel will be installed WITHOUT SSL/TLS.") printf '%s' "⚠ 面板将不启用 SSL/TLS 安装。" ;;
        "⚠ Save the password — it is not stored anywhere else in plain text.") printf '%s' "⚠ 请保存密码——它不会以明文形式保存在其他地方。" ;;
        "⚠ The panel reads these credentials from %s.") printf '%s' "⚠ 面板从 %s 读取这些凭据。" ;;
        "✓ Custom certificate paths applied.") printf '%s' "✓ 已应用自定义证书路径。" ;;
        "✓ Let's Encrypt IP certificate configured successfully") printf '%s' "✓ Let's Encrypt IP 证书配置成功" ;;
        "✓ Panel bound to 127.0.0.1 only. It is now unreachable from the public internet.") printf '%s' "✓ 面板已仅绑定 127.0.0.1，公网无法访问。" ;;
        "✓ SSL certificate configured successfully with domain: ") printf '%s' "✓ 已成功配置域名 SSL 证书: " ;;
        "✓ SSL setup skipped.") printf '%s' "✓ 已跳过 SSL 配置。" ;;
        "✓ Self-signed certificate configured successfully") printf '%s' "✓ 自签证书配置成功" ;;
        "✗ IP certificate setup failed. Please check port 80 is open.") printf '%s' "✗ IP 证书配置失败，请检查 80 端口是否已开放。" ;;
        "✗ Self-signed certificate setup failed.") printf '%s' "✗ 自签证书配置失败。" ;;
        "Added d3x-ui.db to /etc/.gitignore for etckeeper") printf '%s' "已为 etckeeper 把 d3x-ui.db 加入 /etc/.gitignore" ;;
        "Connect from this server:") printf '%s' "在本服务器上连接:" ;;
        "Created /etc/.gitignore and added d3x-ui.db for etckeeper") printf '%s' "已创建 /etc/.gitignore 并为 etckeeper 加入 d3x-ui.db" ;;
        "Fail2ban setup did not finish; IP Limit stays disabled until you run 'd3x-ui' and open the IP Limit menu. Continuing.") printf '%s' "Fail2ban 配置未完成；在运行 'd3x-ui' 并打开 IP 限制菜单之前，IP 限制保持禁用。继续安装。" ;;
        "Failed to download d3x-ui.sh") printf '%s' "下载 d3x-ui.sh 失败" ;;
        "If XUI_DB_FOLDER or XUI_LOG_FOLDER points outside /etc/d3x-ui and /var/log/d3x-ui, the panel may not be able to write to it under ProtectSystem=full.") printf '%s' "如果 XUI_DB_FOLDER 或 XUI_LOG_FOLDER 指向 /etc/d3x-ui 与 /var/log/d3x-ui 之外的位置，在 ProtectSystem=full 下面板可能无法写入。" ;;
        "Install result written to %s (mode 600).") printf '%s' "安装结果已写入 %s（权限 600）。" ;;
        "This d3x-ui.sh predates 'd3x-ui setup-fail2ban'; skipping Fail2ban auto-setup.") printf '%s' "此 d3x-ui.sh 早于 'd3x-ui setup-fail2ban'，已跳过 Fail2ban 自动配置。" ;;
        "Unknown XUI_SSL_MODE='%s', defaulting to none (HTTP).") printf '%s' "未知的 XUI_SSL_MODE='%s'，已回退为 none（HTTP）。" ;;
        "Checksum mismatch for %s: expected %s, got %s") printf '%s' "%s 校验不匹配：期望 %s，实际为 %s" ;;
        "Failed to download the checksum for %s (HTTP %s)") printf '%s' "下载 %s 的校验文件失败（HTTP %s）" ;;
        "\n%s\t1.%s Preset: systemctl reload nginx ; systemctl restart d3x-ui") printf '%s' "\n%s\t1.%s 预设：systemctl reload nginx ; systemctl restart d3x-ui" ;;
        "%s\t2.%s Input your own command") printf '%s' "%s\t2.%s 输入你自己的命令" ;;
        "%s\t0.%s Keep default reloadcmd") printf '%s' "%s\t0.%s 保持默认 reloadcmd" ;;
        "DB Name:    ") printf '%s' "数据库名:  " ;;
        "Username:   ") printf '%s' "用户名:    " ;;
        "Password:   ") printf '%s' "密码:      " ;;
        "Host:       ") printf '%s' "主机:      " ;;
        "Port:       ") printf '%s' "端口:      " ;;
        "DSN:        ") printf '%s' "DSN:       " ;;
        "Env file:   ") printf '%s' "环境文件:  " ;;
        "Username: ") printf '%s' "用户名: " ;;
        "Password: ") printf '%s' "密码:   " ;;
        *) printf '%s' "$1" ;;
    esac
}

xui_tr() {
    local key="$1"
    shift
    local out="$key"
    if [[ "$XUI_LANG_RESOLVED" == "zh" ]]; then
        out="$(xui_zh "$key")"
    fi
    # Substitute the args one by one: each %s in the template takes the next
    # arg, and any args left over are appended at the end (the value after a
    # label such as "Password: "). The template is never used as a printf
    # format string, so a literal % in a translation or in a value is safe,
    # and surplus args cannot make printf re-run the format.
    local res="" rest="$out" suffix="" a ph='%s'
    for a in "$@"; do
        if [[ "$rest" == *"$ph"* ]]; then
            res+="${rest%%"$ph"*}$a"
            rest="${rest#*"$ph"}"
        else
            suffix+="$a"
        fi
    done
    printf '%s' "$res$rest$suffix"
}

# version_at_least <version> <minimum>
# Returns 0 when <version> is greater than or equal to <minimum>. The
# comparison is done field by field on the numeric parts, so a suffix such as
# "-d3.3" is ignored the way a release manager would expect. `sort -V` is not
# used: it orders "1.0.0" below "2.3.5", which is wrong for a fork whose own
# release train starts at 1.0.0.
version_at_least() {
    local version="${1#v}" minimum="${2#v}"
    local -a vf mf
    IFS='.-' read -r -a vf <<< "$version"
    IFS='.-' read -r -a mf <<< "$minimum"

    local i=0
    while (( i < ${#mf[@]} || i < ${#vf[@]} )); do
        local v="${vf[i]:-0}" m="${mf[i]:-0}"
        # Only the leading numeric fields are compared; a non-numeric field
        # ends the comparison.
        [[ "$v" =~ ^[0-9]+$ ]] || v=0
        [[ "$m" =~ ^[0-9]+$ ]] || m=0
        ((10#$v > 10#$m)) && return 0
        ((10#$v < 10#$m)) && return 1
        i=$((i + 1))
    done
    return 0
}

# Terminal display width of a string in columns. Wide (CJK / fullwidth)
# characters occupy two columns, everything else one. The string is walked
# byte by byte under LC_ALL=C so the result does not depend on the locale
# the installer happens to run under.
xui_width() {
    local LC_ALL=C
    local s="$1" w=0 i=0 b
    while (( i < ${#s} )); do
        printf -v b '%d' "'${s:i:1}"
        if (( b < 0x80 )); then
            w=$((w + 1)); i=$((i + 1))
        elif (( b < 0xC0 )); then
            w=$((w + 1)); i=$((i + 1))
        elif (( b < 0xE0 )); then
            w=$((w + 1)); i=$((i + 2))
        elif (( b < 0xF0 )); then
            w=$((w + 2)); i=$((i + 3))
        else
            w=$((w + 2)); i=$((i + 4))
        fi
    done
    printf '%d' "$w"
}

# xui_box_title <english-title>
# Prints a section header padded to the width of the surrounding "═══" rule.
# The English original is left-padded by five spaces; the Chinese wording is
# padded by the same amount measured in display columns so both languages
# line up inside the same frame.
xui_box_title() {
    local title
    title="$(xui_tr "$1")"
    local used
    used=$(($(xui_width "$title") + 5))
    local pad=$((43 - used))
    (( pad < 1 )) && pad=1
    printf '     %s%*s' "$title" "$pad" ""
}

xui_folder="${XUI_MAIN_FOLDER:=/usr/local/d3x-ui}"
xui_service="${XUI_SERVICE:=/etc/systemd/system}"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    exit 1
fi
echo "The OS release is: $release"

arch() {
    case "$(uname -m)" in
        x86_64 | x64 | amd64) echo 'amd64' ;;
        i*86 | x86) echo '386' ;;
        armv8* | armv8 | arm64 | aarch64) echo 'arm64' ;;
        armv7* | armv7 | arm) echo 'armv7' ;;
        armv6* | armv6) echo 'armv6' ;;
        armv5* | armv5) echo 'armv5' ;;
        s390x) echo 's390x' ;;
        *) echo -e "${green}Unsupported CPU architecture! ${plain}" && rm -f "$(realpath "$0")" && exit 1 ;;
    esac
}

echo "Arch: $(arch)"

# Non-interactive mode: triggered explicitly via XUI_NONINTERACTIVE=1, or
# implicitly when stdin is not a TTY (e.g. `curl ... | bash`, cloud-init).
# In this mode every prompt below is replaced by an env var or a sane default.
if [[ "${XUI_NONINTERACTIVE:-0}" == "1" ]] || [[ ! -t 0 ]]; then
    NONINTERACTIVE=1
else
    NONINTERACTIVE=0
fi
export NONINTERACTIVE

# Simple helpers
is_ipv4() {
    [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && return 0 || return 1
}
is_ipv6() {
    [[ "$1" =~ : ]] && return 0 || return 1
}
is_ip() {
    is_ipv4 "$1" || is_ipv6 "$1"
}
is_domain() {
    [[ "$1" =~ ^([A-Za-z0-9](-*[A-Za-z0-9])*\.)+(xn--[a-z0-9]{2,}|[A-Za-z]{2,})$ ]] && return 0 || return 1
}

# acme.sh's standalone server binds IPv4 by default; --listen-v6 makes it
# v6-only, which breaks HTTP-01 validation when the domain's A record points
# at this host's IPv4 (#4994). Only force IPv6 when the host has no global
# IPv4 address at all.
acme_listen_flag() {
    if ip -4 addr show scope global 2> /dev/null | grep -q "inet "; then
        echo ""
    else
        echo "--listen-v6"
    fi
}

# Port helpers
is_port_in_use() {
    local port="$1"
    if command -v ss > /dev/null 2>&1; then
        ss -ltn 2> /dev/null | awk -v p=":${port}$" '$4 ~ p {found = 1} END {exit !found}'
        return
    fi
    if command -v netstat > /dev/null 2>&1; then
        netstat -lnt 2> /dev/null | awk -v p=":${port}$" '$4 ~ p {found = 1} END {exit !found}'
        return
    fi
    if command -v lsof > /dev/null 2>&1; then
        lsof -nP -iTCP:${port} -sTCP:LISTEN > /dev/null 2>&1 && return 0
    fi
    return 1
}

normalize_panel_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || return 1
    # Strip leading zeros before bounding the length and doing arithmetic:
    # Bash and the Go flag parser otherwise interpret leading zeros as octal.
    port="${port#"${port%%[!0]*}"}"
    [[ -n "$port" && ${#port} -le 5 ]] || return 1
    ((10#$port <= 65535)) || return 1
    printf '%s\n' "$port"
}

# Print only the selected decimal port to stdout; prompts/notices use stderr.
# When $1 is "yes" the y/N question is skipped and the port is always asked
# for, which is how the combined panel-settings question drives it.
select_panel_port() {
    local force="${1:-no}"
    local confirm=n port attempt
    if [[ "$force" == "random" ]]; then
        confirm=n
    elif [[ "$NONINTERACTIVE" == 1 ]]; then
        [[ -z "${XUI_PANEL_PORT+x}" ]] || confirm=y
    elif [[ "$force" == "yes" ]]; then
        confirm=y
    else
        while true; do
            if ! IFS= read -rp "$(xui_tr 'Would you like to customize the Panel Port settings? (If not, a random port will be applied) [y/N]: ')" confirm; then
                echo 'Cannot read the panel port confirmation; aborting.' >&2
                return 1
            fi
            confirm="${confirm#"${confirm%%[![:space:]]*}"}"
            confirm="${confirm%"${confirm##*[![:space:]]}"}"
            case "${confirm,,}" in
                y | yes) break ;;
                n | no | '') confirm=n; break ;;
                *) echo "$(xui_tr 'Please answer yes or no (Enter defaults to No).')" >&2 ;;
            esac
        done
    fi

    if [[ "$confirm" == n ]]; then
        for ((attempt = 0; attempt < 100; attempt++)); do
            if ! port=$(shuf -i 1024-62000 -n 1); then
                echo 'Failed to generate a random panel port.' >&2
                return 1
            fi
            if port=$(normalize_panel_port "$port") && ! is_port_in_use "$port"; then
                echo "Generated random port: $port" >&2
                printf '%s\n' "$port"
                return 0
            fi
        done
        echo 'Could not find an available random panel port; aborting.' >&2
        return 1
    fi

    while true; do
        if [[ "$NONINTERACTIVE" == 1 ]]; then
            port="$XUI_PANEL_PORT"
        elif ! read -rp "$(xui_tr 'Please set up the panel port: ')" port; then
            echo 'Cannot read the custom panel port; aborting.' >&2
            return 1
        fi
        if ! port=$(normalize_panel_port "$port"); then
            echo "$(xui_tr 'Invalid port. Enter a number between 1 and 65535.')" >&2
        elif is_port_in_use "$port"; then
            echo "Port $port is already in use. Choose another panel port." >&2
        else
            echo "Your Panel Port is: $port" >&2
            printf '%s\n' "$port"
            return 0
        fi
        [[ "$NONINTERACTIVE" != 1 ]] || return 1
    done
}

# select_credentials resolves the panel login username/password.
# Nothing is printed; the caller reads SELECTED_USERNAME / SELECTED_PASSWORD.
# Priority: XUI_USERNAME / XUI_PASSWORD win outright and never trigger a prompt
# (they are how non-interactive installs pin credentials). Otherwise an
# interactive install asks once whether to type custom credentials; declining
# (or any non-interactive run) falls back to random values, which is exactly
# what the previous behaviour always did.
#
# When $1 is "yes" the y/N question is skipped and the values are always
# asked for. That is how the combined panel-settings question drives it: the
# operator already said "customize", so asking "do you want to customize?"
# again for each field would only add noise.
#
# $1 = "random" skips the question and goes straight to the random values.
select_credentials() {
    local force="${1:-no}"
    local confirm=n username password password_confirm
    SELECTED_USERNAME=""
    SELECTED_PASSWORD=""

    if [[ -n "${XUI_USERNAME:-}" || -n "${XUI_PASSWORD:-}" ]]; then
        SELECTED_USERNAME="${XUI_USERNAME:-$(gen_random_string 10)}"
        SELECTED_PASSWORD="${XUI_PASSWORD:-$(gen_random_string 10)}"
        return 0
    fi

    if [[ "$force" == "random" ]]; then
        SELECTED_USERNAME="$(gen_random_string 10)"
        SELECTED_PASSWORD="$(gen_random_string 10)"
        return 0
    fi

    if [[ "$force" != "yes" && "$NONINTERACTIVE" != 1 ]]; then
        while true; do
            if ! IFS= read -rp "$(xui_tr 'Would you like to set a custom panel username and password? (If not, random ones will be applied) [y/N]: ')" confirm; then
                echo 'Cannot read the credential confirmation; aborting.' >&2
                return 1
            fi
            confirm="${confirm#"${confirm%%[![:space:]]*}"}"
            confirm="${confirm%"${confirm##*[![:space:]]}"}"
            case "${confirm,,}" in
                y | yes) break ;;
                n | no | '') confirm=n; break ;;
                *) echo "$(xui_tr 'Please answer yes or no (Enter defaults to No).')" >&2 ;;
            esac
        done
    fi

    if [[ "$confirm" == y || "$force" == "yes" ]]; then
        while true; do
            if ! IFS= read -rp "$(xui_tr 'Please enter the panel username: ')" username; then                echo 'Cannot read the username; aborting.' >&2
                return 1
            fi
            username="${username#"${username%%[![:space:]]*}"}"
            username="${username%"${username##*[![:space:]]}"}"
            if [[ -z "$username" ]]; then
                echo "$(xui_tr 'Username cannot be empty. Please try again.')" >&2
            elif (( ${#username} > 256 )); then
                echo "$(xui_tr 'Username cannot be longer than 256 characters. Please try again.')" >&2
            else
                break
            fi
        done

        while true; do
            if ! IFS= read -rsp "$(xui_tr 'Please enter the panel password: ')" password; then
                echo 'Cannot read the password; aborting.' >&2
                return 1
            fi
            echo >&2
            if [[ -z "$password" ]]; then
                echo "$(xui_tr 'Password cannot be empty. Please try again.')" >&2
                continue
            fi
            if ! IFS= read -rsp "$(xui_tr 'Please re-enter the panel password to confirm: ')" password_confirm; then
                echo 'Cannot read the password confirmation; aborting.' >&2
                return 1
            fi
            echo >&2
            if [[ "$password" != "$password_confirm" ]]; then
                echo "$(xui_tr 'The passwords do not match. Please try again.')" >&2
                continue
            fi
            break
        done
    else
        username="$(gen_random_string 10)"
        password="$(gen_random_string 10)"
    fi

    SELECTED_USERNAME="$username"
    SELECTED_PASSWORD="$password"
    return 0
}

# select_web_base_path resolves the panel's URI path (the "token" segment that
# hides the panel behind an unguessable URL).
# Nothing is printed; the caller reads SELECTED_WEB_BASE_PATH.
# XUI_WEB_BASE_PATH pins the value for unattended installs. Otherwise the
# operator is asked whether to choose it; declining keeps the random 18
# character path. When $1 is "yes" the y/N question is skipped and the path
# is always asked for.
#
# The path is validated strictly: it is pasted into a URL and joined with the
# panel's own routes, so only URL-safe characters are allowed and the result
# must not collide with the reserved roots.
select_web_base_path() {
    local force="${1:-no}"
    local confirm=n path
    SELECTED_WEB_BASE_PATH=""

    if [[ -n "${XUI_WEB_BASE_PATH:-}" ]]; then
        SELECTED_WEB_BASE_PATH="${XUI_WEB_BASE_PATH}"
        return 0
    fi

    if [[ "$force" == "random" ]]; then
        SELECTED_WEB_BASE_PATH="$(gen_random_string 18)"
        return 0
    fi

    if [[ "$NONINTERACTIVE" != 1 && "$force" != "yes" ]]; then
        while true; do
            if ! IFS= read -rp "$(xui_tr 'Would you like to set a custom panel access path? (If not, a random one will be applied) [y/N]: ')" confirm; then
                echo 'Cannot read the access path confirmation; aborting.' >&2
                return 1
            fi
            confirm="${confirm#"${confirm%%[![:space:]]*}"}"
            confirm="${confirm%"${confirm##*[![:space:]]}"}"
            case "${confirm,,}" in
                y | yes) break ;;
                n | no | '') confirm=n; break ;;
                *) echo "$(xui_tr 'Please answer yes or no (Enter defaults to No).')" >&2 ;;
            esac
        done
    fi

    if [[ "$confirm" == y || "$force" == "yes" ]]; then
        while true; do
            if ! IFS= read -rp "$(xui_tr 'Please enter the panel access path (letters and digits only): ')" path; then
                echo 'Cannot read the access path; aborting.' >&2
                return 1
            fi
            path="${path#"${path%%[![:space:]]*}"}"
            path="${path%"${path##*[![:space:]]}"}"
            # A leading or trailing slash would produce a doubled separator
            # once the panel normalizes the path.
            path="${path#/}"
            path="${path%/}"
            if [[ -z "$path" ]]; then
                echo "$(xui_tr 'The access path cannot be empty. Please try again.')" >&2
            elif [[ ! "$path" =~ ^[A-Za-z0-9_-]+$ ]]; then
                echo "$(xui_tr 'The access path may only contain letters, digits, hyphens and underscores. Please try again.')" >&2
            elif (( ${#path} < 6 )); then
                echo "$(xui_tr 'The access path must be at least 6 characters long. Please try again.')" >&2
            elif (( ${#path} > 64 )); then
                echo "$(xui_tr 'The access path cannot be longer than 64 characters. Please try again.')" >&2
            else
                break
            fi
        done
        SELECTED_WEB_BASE_PATH="$path"
    else
        SELECTED_WEB_BASE_PATH="$(gen_random_string 18)"
    fi

    return 0
}

# select_panel_settings resolves the three panel settings a first-time
# operator may want to control: the panel port, the login credentials and the
# URI path the panel is served under.
#
# A single question covers all three: "customize the panel settings?". The
# default is yes, because an operator who just started the installer usually
# wants the panel on a predictable port with credentials they chose. Answering
# no leaves all three random, which is what the installer has always done.
# Answering yes asks for each value in turn.
#
# Nothing is printed; the caller reads SELECTED_PORT / SELECTED_USERNAME /
# SELECTED_PASSWORD / SELECTED_WEB_BASE_PATH.
select_panel_settings() {
    local confirm=y

    SELECTED_PORT=""
    SELECTED_USERNAME=""
    SELECTED_PASSWORD=""
    SELECTED_WEB_BASE_PATH=""

    # An unattended install never prompts; the environment variables and the
    # random fallbacks decide every value.
    if [[ "$NONINTERACTIVE" == 1 ]]; then
        SELECTED_PORT="$(select_panel_port)"
        select_credentials || return 1
        SELECTED_USERNAME="$SELECTED_USERNAME"
        SELECTED_PASSWORD="$SELECTED_PASSWORD"
        select_web_base_path || return 1
        return 0
    fi

    while true; do
        if ! IFS= read -rp "$(xui_tr 'Would you like to customize the panel settings (port, username, password, access path)? (If not, random values will be applied) [Y/n]: ')" confirm; then
            echo 'Cannot read the panel settings confirmation; aborting.' >&2
            return 1
        fi
        confirm="${confirm#"${confirm%%[![:space:]]*}"}"
        confirm="${confirm%"${confirm##*[![:space:]]}"}"
        case "${confirm,,}" in
            y | yes | '') confirm=y; break ;;
            n | no) confirm=n; break ;;
            *) echo "$(xui_tr 'Please answer yes or no (Enter defaults to Yes).')" >&2 ;;
        esac
    done

    if [[ "$confirm" == n ]]; then
        SELECTED_PORT="$(select_panel_port "random")"
        select_credentials "random" || return 1
        select_web_base_path "random" || return 1
        return 0
    fi

    SELECTED_PORT="$(select_panel_port "yes")" || return 1
    select_credentials "yes" || return 1
    select_web_base_path "yes" || return 1
    return 0
}

install_base() {
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get update && apt-get install -y -q cron curl tar tzdata socat ca-certificates openssl
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
            dnf makecache -y && dnf install -y -q cronie curl tar tzdata socat ca-certificates openssl
            ;;
        centos)
            if [[ "${VERSION_ID}" =~ ^7 ]]; then
                yum makecache -y && yum install -y cronie curl tar tzdata socat ca-certificates openssl
            else
                dnf makecache -y && dnf install -y -q cronie curl tar tzdata socat ca-certificates openssl
            fi
            ;;
        arch | manjaro | parch)
            pacman -Sy --noconfirm cronie curl tar tzdata socat ca-certificates openssl
            ;;
        opensuse-tumbleweed | opensuse-leap)
            zypper refresh && zypper -q install -y cron curl tar timezone socat ca-certificates openssl
            ;;
        alpine)
            apk update && apk add dcron curl tar tzdata socat ca-certificates openssl
            ;;
        *)
            apt-get update && apt-get install -y -q cron curl tar tzdata socat ca-certificates openssl
            ;;
    esac
}

gen_random_string() {
    local length="$1"
    openssl rand -base64 $((length * 2)) \
        | tr -dc 'a-zA-Z0-9' \
        | head -c "$length"
}

# prompt_or_default VARNAME "prompt text" "default" [ENV_NAME]
# Interactive: read into VARNAME. Non-interactive: VARNAME = ${ENV_NAME:-default}.
# ENV_NAME defaults to VARNAME when omitted. The prompt text is looked up in
# the translation table (xui_tr), so callers keep passing the English wording
# and each prompt renders in the active language.
prompt_or_default() {
    local __var="$1" __prompt="$2" __default="$3" __env="${4:-$1}"
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        printf -v "$__var" '%s' "${!__env:-$__default}"
    else
        # shellcheck disable=SC2229
        read -rp "$(xui_tr "$__prompt")" "$__var"
    fi
}

# write_install_result <user> <pass> <port> <webpath> <scheme> <host> <token> <dbtype>
# Persists a parseable, root-only credentials file consumed by cloud-init/MOTD.
# Values are written with printf '%q' so a pinned password/username containing
# spaces, quotes, $(...) or backticks is shell-escaped and the file stays safely
# source-able (consumers do '. install-result.env'). For the alphanumeric random
# values gen_random_string emits, %q is a no-op. This is a DIFFERENT file from the
# Postgres env file (/etc/default/d3x-ui).
write_install_result() {
    local u="$1" p="$2" port="$3" wbp="$4" scheme="$5" host="$6" token="$7" dbtype="$8"
    local result_file="/etc/d3x-ui/install-result.env"
    local url_host="${host:-SERVER_IP_UNKNOWN}"
    install -d -m 700 /etc/d3x-ui 2> /dev/null
    local prev_umask
    prev_umask=$(umask)
    umask 077
    if ! {
        printf 'XUI_USERNAME=%q\n' "$u"
        printf 'XUI_PASSWORD=%q\n' "$p"
        printf 'XUI_PANEL_PORT=%q\n' "$port"
        printf 'XUI_WEB_BASE_PATH=%q\n' "$wbp"
        printf 'XUI_ACCESS_URL=%q\n' "${scheme}://${url_host}:${port}/${wbp}"
        printf 'XUI_API_TOKEN=%q\n' "$token"
        printf 'XUI_DB_TYPE=%q\n' "$dbtype"
    } > "$result_file"; then
        umask "$prev_umask"
        echo -e "${yellow}Warning: failed to write ${result_file}.${plain}" >&2
        return 1
    fi
    umask "$prev_umask"
    chmod 600 "$result_file" 2> /dev/null
    chown root:root "$result_file" 2> /dev/null || true
    echo -e "${green}$(xui_tr 'Install result written to %s (mode 600).' "${result_file}")${plain}"
}

# RHEL-family initdb writes pg_hba.conf host rules with ident auth, which
# compares the OS username against the Postgres role and always rejects the
# randomly generated panel role over TCP (#5806). Prepend password-auth rules
# scoped to the panel database; first match wins, and md5 also accepts
# scram-sha-256-stored verifiers, so this works on every supported distro.
pg_ensure_hba_password_auth() {
    local pg_db="$1"
    local hba_file
    hba_file=$(sudo -u postgres psql -tAc 'SHOW hba_file' 2> /dev/null | tr -d '[:space:]')
    [[ -n "${hba_file}" && -f "${hba_file}" ]] || return 0
    grep -Eq "^host[[:space:]]+${pg_db}[[:space:]]" "${hba_file}" && return 0
    local tmp
    tmp=$(mktemp) || return 1
    {
        echo "# Added by d3x-ui: allow password logins for the panel database."
        echo "host    ${pg_db}    all    127.0.0.1/32    md5"
        echo "host    ${pg_db}    all    ::1/128         md5"
        cat "${hba_file}"
    } > "${tmp}" || {
        rm -f "${tmp}"
        return 1
    }
    cat "${tmp}" > "${hba_file}" || {
        rm -f "${tmp}"
        return 1
    }
    rm -f "${tmp}"
    sudo -u postgres psql -tAc 'SELECT pg_reload_conf()' > /dev/null 2>&1 || true
}

# New installs get this PostgreSQL major from the official PGDG repository; distros or
# CPU architectures PGDG does not build for fall back to the distribution's own package.
PG_TARGET_MAJOR=18

pg_has_debian_cluster() {
    command -v pg_lsclusters > /dev/null 2>&1 && [[ -n "$(pg_lsclusters -h 2> /dev/null)" ]]
}

# Installs postgresql-${PG_TARGET_MAJOR} from apt.postgresql.org. On failure it removes the
# repository it added, so an unsupported release cannot break later `apt-get update` runs.
pg_apt_install_pgdg_server() {
    local list added_lists=()
    for list in /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.sources; do
        [[ -e "${list}" ]] || added_lists+=("${list}")
    done
    if apt-get install -y -q postgresql-common ca-certificates gnupg >&2 \
        && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y >&2 \
        && apt-get install -y -q "postgresql-${PG_TARGET_MAJOR}" >&2; then
        return 0
    fi
    for list in "${added_lists[@]}"; do
        rm -f "${list}"
    done
    apt-get update >&2 || true
    echo -e "${yellow}PostgreSQL ${PG_TARGET_MAJOR} is not available for this system; installing the distribution's PostgreSQL instead.${plain}" >&2
    return 1
}

# Installs postgresql${PG_TARGET_MAJOR}-server from the PGDG yum repository (EL 8+ only); on
# failure it undoes the repository and module changes it made. The caller runs initdb.
pg_el_install_pgdg_server() {
    local elver
    elver=$(rpm -E %rhel 2> /dev/null)
    [[ "${elver}" =~ ^[0-9]+$ && "${elver}" -ge 8 ]] && command -v dnf > /dev/null 2>&1 || return 1
    [[ -f /var/lib/pgsql/data/PG_VERSION ]] && return 1
    local added_repo=false
    if ! rpm -q pgdg-redhat-repo > /dev/null 2>&1; then
        if dnf install -y -q "https://download.postgresql.org/pub/repos/yum/reporpms/EL-${elver}-$(uname -m)/pgdg-redhat-repo-latest.noarch.rpm" >&2; then
            added_repo=true
            dnf -qy module disable postgresql > /dev/null 2>&1 || true
        fi
    fi
    if rpm -q pgdg-redhat-repo > /dev/null 2>&1 \
        && dnf install -y -q "postgresql${PG_TARGET_MAJOR}-server" "postgresql${PG_TARGET_MAJOR}-contrib" >&2; then
        return 0
    fi
    if [[ "${added_repo}" == "true" ]]; then
        dnf -qy module reset postgresql > /dev/null 2>&1 || true
        dnf remove -y -q pgdg-redhat-repo >&2 || true
    fi
    echo -e "${yellow}PostgreSQL ${PG_TARGET_MAJOR} is not available for this system; installing the distribution's PostgreSQL instead.${plain}" >&2
    return 1
}

install_postgres_local() {
    local pg_user pg_pass
    pg_pass=$(gen_random_string 24)
    local pg_db="xui"
    local pg_host="127.0.0.1"
    local pg_port="5432"

    local pg_service="postgresql"
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get update >&2 || return 1
            if pg_has_debian_cluster || ! pg_apt_install_pgdg_server; then
                apt-get install -y -q postgresql >&2 || return 1
            fi
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol | centos)
            if [[ "${release}" != "fedora" && "${release}" != "amzn" ]] && pg_el_install_pgdg_server; then
                pg_service="postgresql-${PG_TARGET_MAJOR}"
                [[ -f "/var/lib/pgsql/${PG_TARGET_MAJOR}/data/PG_VERSION" ]] \
                    || "/usr/pgsql-${PG_TARGET_MAJOR}/bin/postgresql-${PG_TARGET_MAJOR}-setup" initdb >&2 || return 1
            else
                if [[ "${release}" == "centos" && "${VERSION_ID}" =~ ^7 ]]; then
                    yum install -y postgresql-server postgresql-contrib >&2 || return 1
                else
                    dnf install -y -q postgresql-server postgresql-contrib >&2 || return 1
                fi
                [[ -d /var/lib/pgsql/data && -f /var/lib/pgsql/data/PG_VERSION ]] || postgresql-setup --initdb >&2 || return 1
            fi
            ;;
        arch | manjaro | parch)
            pacman -Sy --noconfirm postgresql >&2 || return 1
            if [[ ! -f /var/lib/postgres/data/PG_VERSION ]]; then
                sudo -u postgres initdb -D /var/lib/postgres/data >&2 || return 1
            fi
            ;;
        opensuse-tumbleweed | opensuse-leap)
            zypper -q install -y postgresql-server postgresql-contrib >&2 || return 1
            if [[ ! -f /var/lib/pgsql/data/PG_VERSION ]]; then
                install -d -o postgres -g postgres -m 700 /var/lib/pgsql/data >&2 || return 1
                su - postgres -c "initdb -D /var/lib/pgsql/data" >&2 || return 1
            fi
            ;;
        alpine)
            apk add --no-cache postgresql postgresql-contrib >&2 || return 1
            if [[ ! -f /var/lib/postgresql/data/PG_VERSION ]]; then
                /etc/init.d/postgresql setup >&2 || return 1
            fi
            rc-update add postgresql default >&2 2> /dev/null || true
            rc-service postgresql start >&2 || return 1
            ;;
        *)
            echo -e "${red}Unsupported distro for automatic PostgreSQL install: ${release}${plain}" >&2
            return 1
            ;;
    esac

    if [[ "${release}" != "alpine" ]]; then
        systemctl enable --now "${pg_service}" >&2 || return 1
    fi

    # Wait briefly for the server to accept connections.
    local i
    for i in 1 2 3 4 5; do
        sudo -u postgres psql -tAc 'SELECT 1' > /dev/null 2>&1 && break
        sleep 1
    done

    local existing_owner=""
    existing_owner=$(sudo -u postgres psql -tAc \
        "SELECT pg_catalog.pg_get_userbyid(datdba) FROM pg_database WHERE datname='${pg_db}'" 2> /dev/null \
        | tr -d '[:space:]')
    if [[ -n "${existing_owner}" && "${existing_owner}" != "postgres" ]]; then
        pg_user="${existing_owner}"
    else
        pg_user=$(gen_random_string 8)
    fi

    # Idempotent role/db creation. Identifiers are double-quoted because a
    # random username may start with a digit, which Postgres rejects unquoted.
    sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${pg_user}'" 2> /dev/null \
        | grep -q 1 \
        || sudo -u postgres psql -c "CREATE USER \"${pg_user}\" WITH PASSWORD '${pg_pass}';" >&2 || return 1

    sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${pg_db}'" 2> /dev/null \
        | grep -q 1 \
        || sudo -u postgres psql -c "CREATE DATABASE \"${pg_db}\" OWNER \"${pg_user}\";" >&2 || return 1

    sudo -u postgres psql -c "ALTER USER \"${pg_user}\" WITH PASSWORD '${pg_pass}';" >&2 || return 1

    pg_ensure_hba_password_auth "${pg_db}" \
        || echo -e "${yellow}Warning: could not update pg_hba.conf; PostgreSQL may reject the panel's TCP login (ident auth).${plain}" >&2

    local pg_pass_enc
    pg_pass_enc=$(printf '%s' "${pg_pass}" | sed -e 's/%/%25/g' -e 's/:/%3A/g' -e 's/@/%40/g' -e 's|/|%2F|g' -e 's/?/%3F/g' -e 's/#/%23/g')

    if [[ -n "${PG_CRED_FILE:-}" ]]; then
        local prev_umask
        prev_umask=$(umask)
        umask 077
        if ! cat > "${PG_CRED_FILE}" << EOF; then
PG_USER=${pg_user}
PG_PASS=${pg_pass}
PG_HOST=${pg_host}
PG_PORT=${pg_port}
PG_DB=${pg_db}
EOF
            umask "${prev_umask}"
            echo -e "${red}Failed to write PostgreSQL credentials to ${PG_CRED_FILE}${plain}" >&2
            return 1
        fi
        umask "${prev_umask}"
    fi

    echo "postgres://${pg_user}:${pg_pass_enc}@${pg_host}:${pg_port}/${pg_db}?sslmode=disable"
    return 0
}

ensure_pg_client() {
    if command -v pg_dump > /dev/null 2>&1 && command -v pg_restore > /dev/null 2>&1; then
        return 0
    fi
    echo -e "${yellow}Installing PostgreSQL client tools (pg_dump/pg_restore) for in-panel backup...${plain}" >&2
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get update >&2 && apt-get install -y -q postgresql-client >&2 || return 1
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
            dnf install -y -q postgresql >&2 || return 1
            ;;
        centos)
            if [[ "${VERSION_ID}" =~ ^7 ]]; then
                yum install -y postgresql >&2 || return 1
            else
                dnf install -y -q postgresql >&2 || return 1
            fi
            ;;
        arch | manjaro | parch)
            pacman -Sy --noconfirm postgresql >&2 || return 1
            ;;
        opensuse-tumbleweed | opensuse-leap)
            zypper -q install -y postgresql >&2 || return 1
            ;;
        alpine)
            apk add --no-cache postgresql-client >&2 || return 1
            ;;
        *)
            return 1
            ;;
    esac
    command -v pg_dump > /dev/null 2>&1 && command -v pg_restore > /dev/null 2>&1
}

install_acme() {
    echo -e "${green}$(xui_tr 'Installing acme.sh for SSL certificate management...')${plain}"
    cd ~ || return 1
    curl -s https://get.acme.sh | sh > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${red}$(xui_tr 'Failed to install acme.sh')${plain}"
        return 1
    else
        echo -e "${green}$(xui_tr 'acme.sh installed successfully')${plain}"
    fi
    return 0
}

setup_ssl_certificate() {
    local domain="$1"
    local server_ip="$2"
    local existing_port="$3"
    local existing_webBasePath="$4"

    echo -e "${green}$(xui_tr 'Setting up SSL certificate...')${plain}"

    # Check if acme.sh is installed
    if ! command -v ~/.acme.sh/acme.sh &> /dev/null; then
        install_acme
        if [ $? -ne 0 ]; then
            echo -e "${yellow}$(xui_tr 'Failed to install acme.sh, skipping SSL setup')${plain}"
            return 1
        fi
    fi

    # Create certificate directory
    local certPath="/root/cert/${domain}"
    mkdir -p "$certPath"

    # Issue certificate
    echo -e "${green}$(xui_tr 'Issuing SSL certificate for %s...' "${domain}")${plain}"
    echo -e "${yellow}$(xui_tr 'Note: Port 80 must be open and accessible from the internet')${plain}"

    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --force > /dev/null 2>&1
    ~/.acme.sh/acme.sh --issue -d ${domain} $(acme_listen_flag) --standalone --httpport 80 --force

    if [ $? -ne 0 ]; then
        echo -e "${yellow}$(xui_tr 'Failed to issue certificate for ' "${domain}")${plain}"
        echo -e "${yellow}$(xui_tr 'Please ensure port 80 is open and try again later with: d3x-ui')${plain}"
        rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc 2> /dev/null
        rm -rf "$certPath" 2> /dev/null
        return 1
    fi

    # Install certificate
    ~/.acme.sh/acme.sh --installcert --force -d ${domain} \
        --key-file /root/cert/${domain}/privkey.pem \
        --fullchain-file /root/cert/${domain}/fullchain.pem \
        --reloadcmd "systemctl restart d3x-ui" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "${yellow}$(xui_tr 'Failed to install certificate')${plain}"
        return 1
    fi

    # Enable auto-renew
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade > /dev/null 2>&1
    # Secure permissions: private key readable only by owner
    chmod 600 $certPath/privkey.pem 2> /dev/null
    chmod 644 $certPath/fullchain.pem 2> /dev/null

    # Set certificate for panel
    local webCertFile="/root/cert/${domain}/fullchain.pem"
    local webKeyFile="/root/cert/${domain}/privkey.pem"

    if [[ -f "$webCertFile" && -f "$webKeyFile" ]]; then
        ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile" > /dev/null 2>&1
        echo -e "${green}$(xui_tr 'SSL certificate installed and configured successfully!')${plain}"
        return 0
    else
        echo -e "${yellow}$(xui_tr 'Certificate files not found')${plain}"
        return 1
    fi
}

# Generate a self-signed certificate for an IP address and configure the panel
# to use it. Unlike the Let's Encrypt paths this needs no port 80, no ACME
# account and no renewal, so it works on a locked-down VPS. The browser will
# show a warning because the certificate is not signed by a public CA; the
# client can accept it explicitly.
setup_self_signed_certificate() {
    local ipv4="$1"

    echo -e "${green}$(xui_tr 'Setting up self-signed certificate for %s...' "${ipv4}")${plain}"

    if [[ -z "$ipv4" ]]; then
        echo -e "${red}$(xui_tr 'IPv4 address is required')${plain}"
        return 1
    fi

    if ! is_ipv4 "$ipv4"; then
        echo -e "${red}$(xui_tr 'Invalid IPv4 address: ' "$ipv4")${plain}"
        return 1
    fi

    if ! command -v openssl > /dev/null 2>&1; then
        echo -e "${red}$(xui_tr 'openssl is required to generate a self-signed certificate')${plain}"
        return 1
    fi

    # Keep the certificate beside the other panel certificates. The name is
    # suffixed with the IP so a second install for a different address does
    # not overwrite the first one.
    local certDir="/root/cert/selfsigned-${ipv4}"
    mkdir -p "$certDir"

    local certFile="${certDir}/fullchain.pem"
    local keyFile="${certDir}/privkey.pem"

    # The SAN must carry the IP address: browsers and TLS clients ignore a
    # certificate whose CN is an IP unless the IP also appears in
    # subjectAltName, so a cert without it fails the hostname check.
    local confFile="${certDir}/openssl.cnf"
    cat > "$confFile" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = req_distinguished_name
x509_extensions = v3_req

[req_distinguished_name]
CN = ${ipv4}

[v3_req]
subjectAltName = IP:${ipv4}
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

    echo -e "${green}$(xui_tr 'Generating the key pair...')${plain}"
    if ! openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout "$keyFile" -out "$certFile" -config "$confFile" 2> /dev/null; then
        echo -e "${red}$(xui_tr 'Failed to generate the self-signed certificate')${plain}"
        rm -rf "$certDir" 2> /dev/null
        return 1
    fi
    rm -f "$confFile"

    if [[ ! -s "$certFile" || ! -s "$keyFile" ]]; then
        echo -e "${red}$(xui_tr 'Certificate files were not created')${plain}"
        rm -rf "$certDir" 2> /dev/null
        return 1
    fi

    # Secure permissions: private key readable only by owner
    chmod 600 "$keyFile" 2> /dev/null
    chmod 644 "$certFile" 2> /dev/null

    # Configure panel to use the certificate
    echo -e "${green}$(xui_tr 'Setting certificate paths for the panel...')${plain}"
    ${xui_folder}/d3x-ui cert -webCert "$certFile" -webCertKey "$keyFile"

    if [ $? -ne 0 ]; then
        echo -e "${yellow}$(xui_tr 'Warning: Could not set certificate paths automatically')${plain}"
        echo -e "${yellow}$(xui_tr 'Certificate files are at:')${plain}"
        echo -e "$(xui_tr '  Cert: ' "${certFile}")"
        echo -e "$(xui_tr '  Key:  ' "${keyFile}")"
    else
        echo -e "${green}$(xui_tr 'Certificate paths configured successfully')${plain}"
    fi

    echo -e "${green}$(xui_tr 'Self-signed certificate installed and configured successfully!')${plain}"
    echo -e "${green}$(xui_tr 'Valid for 10 years — no renewal needed.')${plain}"
    echo -e "${yellow}$(xui_tr "Your browser will warn that the certificate is not trusted; click 'Advanced' to continue.")${plain}"
    return 0
}

# Issue Let's Encrypt IP certificate with shortlived profile (~6 days validity)
# Requires acme.sh and port 80 open for HTTP-01 challenge
setup_ip_certificate() {
    local ipv4="$1"
    local ipv6="$2" # optional

    echo -e "${green}$(xui_tr "Setting up Let's Encrypt IP certificate (shortlived profile)...")${plain}"
    echo -e "${yellow}$(xui_tr 'Note: IP certificates are valid for ~6 days and will auto-renew.')${plain}"
    echo -e "${yellow}$(xui_tr 'Default listener is port 80. If you choose another port, ensure external port 80 forwards to it.')${plain}"

    # Check for acme.sh
    if ! command -v ~/.acme.sh/acme.sh &> /dev/null; then
        install_acme
        if [ $? -ne 0 ]; then
            echo -e "${red}$(xui_tr 'Failed to install acme.sh')${plain}"
            return 1
        fi
    fi

    # Validate IP address
    if [[ -z "$ipv4" ]]; then
        echo -e "${red}$(xui_tr 'IPv4 address is required')${plain}"
        return 1
    fi

    if ! is_ipv4 "$ipv4"; then
        echo -e "${red}$(xui_tr 'Invalid IPv4 address: ' "$ipv4")${plain}"
        return 1
    fi

    # Create certificate directory
    local certDir="/root/cert/ip"
    mkdir -p "$certDir"

    # Build domain arguments
    local domain_args="-d ${ipv4}"
    if [[ -n "$ipv6" ]] && is_ipv6 "$ipv6"; then
        domain_args="${domain_args} -d ${ipv6}"
        echo -e "${green}$(xui_tr 'Including IPv6 address: ' "${ipv6}")${plain}"
    fi

    # Set reload command for auto-renewal (add || true so it doesn't fail during first install)
    local reloadCmd="systemctl restart d3x-ui 2>/dev/null || rc-service d3x-ui restart 2>/dev/null || true"

    # Choose port for HTTP-01 listener (default 80, prompt override)
    local WebPort=""
    prompt_or_default WebPort "Port to use for ACME HTTP-01 listener (default 80): " "80" XUI_ACME_HTTP_PORT
    WebPort="${WebPort:-80}"
    if ! [[ "${WebPort}" =~ ^[0-9]+$ ]] || ((WebPort < 1 || WebPort > 65535)); then
        echo -e "${red}$(xui_tr 'Invalid port provided. Falling back to 80.')${plain}"
        WebPort=80
    fi
    echo -e "${green}$(xui_tr 'Using port %s for standalone validation.' "${WebPort}")${plain}"
    if [[ "${WebPort}" -ne 80 ]]; then
        echo -e "${yellow}$(xui_tr "Reminder: Let's Encrypt still connects on port 80; forward external port 80 to %s." "${WebPort}")${plain}"
    fi

    # Ensure chosen port is available
    while true; do
        if is_port_in_use "${WebPort}"; then
            echo -e "${yellow}$(xui_tr 'Port %s is in use.' "${WebPort}")${plain}"

            local alt_port=""
            if [[ "$NONINTERACTIVE" == "1" ]]; then
                echo -e "${red}$(xui_tr 'Port %s is busy; cannot proceed in non-interactive mode.' "${WebPort}")${plain}"
                return 1
            fi
            read -rp "$(xui_tr 'Enter another port for acme.sh standalone listener (leave empty to abort): ')" alt_port
            alt_port="${alt_port// /}"
            if [[ -z "${alt_port}" ]]; then
                echo -e "${red}$(xui_tr 'Port %s is busy; cannot proceed.' "${WebPort}")${plain}"
                return 1
            fi
            if ! [[ "${alt_port}" =~ ^[0-9]+$ ]] || ((alt_port < 1 || alt_port > 65535)); then
                echo -e "${red}$(xui_tr 'Invalid port provided.')${plain}"
                return 1
            fi
            WebPort="${alt_port}"
            continue
        else
            echo -e "${green}$(xui_tr 'Port %s is free and ready for standalone validation.' "${WebPort}")${plain}"
            break
        fi
    done

    # Issue certificate with shortlived profile
    echo -e "${green}$(xui_tr 'Issuing IP certificate for %s...' "${ipv4}")${plain}"
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --force > /dev/null 2>&1
    [[ -n "${XUI_ACME_EMAIL:-}" ]] && ~/.acme.sh/acme.sh --register-account -m "${XUI_ACME_EMAIL}" > /dev/null 2>&1

    ~/.acme.sh/acme.sh --issue \
        ${domain_args} \
        --standalone \
        --server letsencrypt \
        --certificate-profile shortlived \
        --days 6 \
        --httpport ${WebPort} \
        --force

    if [ $? -ne 0 ]; then
        echo -e "${red}$(xui_tr 'Failed to issue IP certificate')${plain}"
        echo -e "${yellow}$(xui_tr 'Please ensure port %s is reachable (or forwarded from external port 80)' "${WebPort}")${plain}"
        # Cleanup acme.sh data for both IPv4 and IPv6 if specified
        rm -rf ~/.acme.sh/${ipv4} ~/.acme.sh/${ipv4}_ecc 2> /dev/null
        [[ -n "$ipv6" ]] && rm -rf ~/.acme.sh/${ipv6} ~/.acme.sh/${ipv6}_ecc 2> /dev/null
        rm -rf ${certDir} 2> /dev/null
        return 1
    fi

    echo -e "${green}$(xui_tr 'Certificate issued successfully, installing...')${plain}"

    # Install certificate
    # Note: acme.sh may report "Reload error" and exit non-zero if reloadcmd fails,
    # but the cert files are still installed. We check for files instead of exit code.
    ~/.acme.sh/acme.sh --installcert --force -d ${ipv4} \
        --key-file "${certDir}/privkey.pem" \
        --fullchain-file "${certDir}/fullchain.pem" \
        --reloadcmd "${reloadCmd}" 2>&1 || true

    # Verify certificate files exist (don't rely on exit code - reloadcmd failure causes non-zero)
    if [[ ! -f "${certDir}/fullchain.pem" || ! -f "${certDir}/privkey.pem" ]]; then
        echo -e "${red}$(xui_tr 'Certificate files not found after installation')${plain}"
        # Cleanup acme.sh data for both IPv4 and IPv6 if specified
        rm -rf ~/.acme.sh/${ipv4} ~/.acme.sh/${ipv4}_ecc 2> /dev/null
        [[ -n "$ipv6" ]] && rm -rf ~/.acme.sh/${ipv6} ~/.acme.sh/${ipv6}_ecc 2> /dev/null
        rm -rf ${certDir} 2> /dev/null
        return 1
    fi

    echo -e "${green}$(xui_tr 'Certificate files installed successfully')${plain}"

    # Enable auto-upgrade for acme.sh (ensures cron job runs)
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade > /dev/null 2>&1

    # Secure permissions: private key readable only by owner
    chmod 600 ${certDir}/privkey.pem 2> /dev/null
    chmod 644 ${certDir}/fullchain.pem 2> /dev/null

    # Configure panel to use the certificate
    echo -e "${green}$(xui_tr 'Setting certificate paths for the panel...')${plain}"
    ${xui_folder}/d3x-ui cert -webCert "${certDir}/fullchain.pem" -webCertKey "${certDir}/privkey.pem"

    if [ $? -ne 0 ]; then
        echo -e "${yellow}$(xui_tr 'Warning: Could not set certificate paths automatically')${plain}"
        echo -e "${yellow}$(xui_tr 'Certificate files are at:')${plain}"
        echo -e "$(xui_tr '  Cert: %s/fullchain.pem' "${certDir}")"
        echo -e "$(xui_tr '  Key:  %s/privkey.pem' "${certDir}")"
    else
        echo -e "${green}$(xui_tr 'Certificate paths configured successfully')${plain}"
    fi

    echo -e "${green}$(xui_tr 'IP certificate installed and configured successfully!')${plain}"
    echo -e "${green}$(xui_tr 'Certificate valid for ~6 days, auto-renews via acme.sh cron job.')${plain}"
    echo -e "${yellow}$(xui_tr 'acme.sh will automatically renew and reload d3x-ui before expiry.')${plain}"
    return 0
}

# Comprehensive manual SSL certificate issuance via acme.sh
ssl_cert_issue() {
    local existing_webBasePath=$(${xui_folder}/d3x-ui setting -show true | grep 'webBasePath:' | awk -F': ' '{print $2}' | tr -d '[:space:]' | sed 's#^/##')
    local existing_port=$(${xui_folder}/d3x-ui setting -show true | grep 'port:' | awk -F': ' '{print $2}' | tr -d '[:space:]')

    # check for acme.sh first
    if ! command -v ~/.acme.sh/acme.sh &> /dev/null; then
        echo "acme.sh could not be found. Installing now..."
        cd ~ || return 1
        curl -s https://get.acme.sh | sh
        if [ $? -ne 0 ]; then
            echo -e "${red}$(xui_tr 'Failed to install acme.sh')${plain}"
            return 1
        else
            echo -e "${green}$(xui_tr 'acme.sh installed successfully')${plain}"
        fi
    fi

    # get the domain here, and we need to verify it
    local domain=""
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        domain="${XUI_DOMAIN// /}"
        if [[ -z "$domain" ]] || ! is_domain "$domain"; then
            echo -e "${red}$(xui_tr "XUI_SSL_MODE=domain requires a valid XUI_DOMAIN (got: '%s')." "${XUI_DOMAIN:-}")${plain}"
            return 1
        fi
    else
        while true; do
            read -rp "$(xui_tr 'Please enter your domain name: ')" domain
            domain="${domain// /}" # Trim whitespace

            if [[ -z "$domain" ]]; then
                echo -e "${red}$(xui_tr 'Domain name cannot be empty. Please try again.')${plain}"
                continue
            fi

            if ! is_domain "$domain"; then
                echo -e "${red}$(xui_tr 'Invalid domain format: %s. Please enter a valid domain name.' "${domain}")${plain}"
                continue
            fi

            break
        done
    fi
    echo -e "${green}$(xui_tr 'Your domain is: %s, checking it...' "${domain}")${plain}"
    SSL_ISSUED_DOMAIN="${domain}"

    # detect existing certificate and reuse it only if its files are actually
    # present and non-empty. acme.sh stores ECC certs under ${domain}_ecc and RSA
    # certs under ${domain}; a failed issuance can leave a domain entry in --list
    # with no usable cert files, which must not be reused (it produces a 0-byte
    # fullchain.pem). Broken partial state is cleaned up so issuance can proceed.
    local cert_exists=0
    if ~/.acme.sh/acme.sh --list 2> /dev/null | awk '{print $1}' | grep -Fxq "${domain}"; then
        local acmeCertDir=""
        if [[ -s ~/.acme.sh/${domain}_ecc/fullchain.cer && -s ~/.acme.sh/${domain}_ecc/${domain}.key ]]; then
            acmeCertDir=~/.acme.sh/${domain}_ecc
        elif [[ -s ~/.acme.sh/${domain}/fullchain.cer && -s ~/.acme.sh/${domain}/${domain}.key ]]; then
            acmeCertDir=~/.acme.sh/${domain}
        fi
        if [[ -n "${acmeCertDir}" ]]; then
            cert_exists=1
            local certInfo=$(~/.acme.sh/acme.sh --list 2> /dev/null | grep -F "${domain}")
            echo -e "${yellow}$(xui_tr 'Existing certificate found for %s, will reuse it.' "${domain}")${plain}"
            [[ -n "${certInfo}" ]] && echo "$certInfo"
        else
            echo -e "${yellow}$(xui_tr 'Found incomplete acme.sh state for %s (no valid certificate files); cleaning it up and re-issuing.' "${domain}")${plain}"
            rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc
        fi
    fi
    if [[ ${cert_exists} -eq 0 ]]; then
        echo -e "${green}$(xui_tr 'Your domain is ready for issuing certificates now...')${plain}"
    fi

    # create a directory for the certificate
    certPath="/root/cert/${domain}"
    if [ ! -d "$certPath" ]; then
        mkdir -p "$certPath"
    else
        rm -rf "$certPath"
        mkdir -p "$certPath"
    fi

    # get the port number for the standalone server
    local WebPort=80
    prompt_or_default WebPort "Please choose which port to use (default is 80): " "80" XUI_ACME_HTTP_PORT
    if [[ -z ${WebPort} ]]; then
        WebPort=80
    elif [[ ! ${WebPort} =~ ^[1-9][0-9]*$ || ${WebPort} -gt 65535 ]]; then
        echo -e "${yellow}$(xui_tr 'Your input %s is invalid, will use default port 80.' "${WebPort}")${plain}"
        WebPort=80
    fi
    echo -e "${green}$(xui_tr 'Will use port: %s to issue certificates. Please make sure this port is open.' "${WebPort}")${plain}"

    # Stop panel temporarily
    echo -e "${yellow}$(xui_tr 'Stopping panel temporarily...')${plain}"
    systemctl stop d3x-ui 2> /dev/null || rc-service d3x-ui stop 2> /dev/null

    if [[ ${cert_exists} -eq 0 ]]; then
        # issue the certificate
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --force
        [[ -n "${XUI_ACME_EMAIL:-}" ]] && ~/.acme.sh/acme.sh --register-account -m "${XUI_ACME_EMAIL}" > /dev/null 2>&1
        ~/.acme.sh/acme.sh --issue -d ${domain} $(acme_listen_flag) --standalone --httpport ${WebPort} --force
        if [ $? -ne 0 ]; then
            echo -e "${red}$(xui_tr 'Issuing certificate failed, please check logs.')${plain}"
            rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc
            systemctl start d3x-ui 2> /dev/null || rc-service d3x-ui start 2> /dev/null
            return 1
        else
            echo -e "${green}$(xui_tr 'Issuing certificate succeeded, installing certificates...')${plain}"
        fi
    else
        echo -e "${green}$(xui_tr 'Using existing certificate, installing certificates...')${plain}"
    fi

    # Setup reload command
    reloadCmd="systemctl restart d3x-ui || rc-service d3x-ui restart"
    echo -e "${green}$(xui_tr 'Default --reloadcmd for ACME is: %ssystemctl restart d3x-ui || rc-service d3x-ui restart' "${yellow}")${plain}"
    echo -e "${green}$(xui_tr 'This command will run on every certificate issue and renew.')${plain}"
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        setReloadcmd="n"
    else
        read -rp "$(xui_tr 'Would you like to modify --reloadcmd for ACME? (y/n): ')" setReloadcmd
    fi
    if [[ "$setReloadcmd" == "y" || "$setReloadcmd" == "Y" ]]; then
        echo -e "$(xui_tr '\n%s\t1.%s Preset: systemctl reload nginx ; systemctl restart d3x-ui' "${green}" "${plain}")"
        echo -e "$(xui_tr '%s\t2.%s Input your own command' "${green}" "${plain}")"
        echo -e "$(xui_tr '%s\t0.%s Keep default reloadcmd' "${green}" "${plain}")"
        read -rp "$(xui_tr 'Choose an option: ')" choice
        case "$choice" in
            1)
                echo -e "${green}$(xui_tr 'Reloadcmd is: systemctl reload nginx ; systemctl restart d3x-ui')${plain}"
                reloadCmd="systemctl reload nginx ; systemctl restart d3x-ui"
                ;;
            2)
                echo -e "${yellow}$(xui_tr "It's recommended to put d3x-ui restart at the end")${plain}"
                read -rp "$(xui_tr 'Please enter your custom reloadcmd: ')" reloadCmd
                echo -e "${green}$(xui_tr 'Reloadcmd is: ' "${reloadCmd}")${plain}"
                ;;
            *)
                echo -e "${green}$(xui_tr 'Keeping default reloadcmd')${plain}"
                ;;
        esac
    fi

    # install the certificate
    local installOutput=""
    installOutput=$(~/.acme.sh/acme.sh --installcert --force -d ${domain} \
        --key-file /root/cert/${domain}/privkey.pem \
        --fullchain-file /root/cert/${domain}/fullchain.pem --reloadcmd "${reloadCmd}" 2>&1)
    local installRc=$?
    echo "${installOutput}"

    local installWroteFiles=0
    if echo "${installOutput}" | grep -q "Installing key to:" && echo "${installOutput}" | grep -q "Installing full chain to:"; then
        installWroteFiles=1
    fi

    if [[ -f "/root/cert/${domain}/privkey.pem" && -f "/root/cert/${domain}/fullchain.pem" && (${installRc} -eq 0 || ${installWroteFiles} -eq 1) ]]; then
        echo -e "${green}$(xui_tr 'Installing certificate succeeded, enabling auto renew...')${plain}"
    else
        echo -e "${red}$(xui_tr 'Installing certificate failed, exiting.')${plain}"
        if [[ ${cert_exists} -eq 0 ]]; then
            rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc
        fi
        systemctl start d3x-ui 2> /dev/null || rc-service d3x-ui start 2> /dev/null
        return 1
    fi

    # enable auto-renew
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade
    if [ $? -ne 0 ]; then
        echo -e "${yellow}$(xui_tr 'Auto renew setup had issues, certificate details:')${plain}"
        ls -lah /root/cert/${domain}/
        # Secure permissions: private key readable only by owner
        chmod 600 $certPath/privkey.pem 2> /dev/null
        chmod 644 $certPath/fullchain.pem 2> /dev/null
    else
        echo -e "${green}$(xui_tr 'Auto renew succeeded, certificate details:')${plain}"
        ls -lah /root/cert/${domain}/
        # Secure permissions: private key readable only by owner
        chmod 600 $certPath/privkey.pem 2> /dev/null
        chmod 644 $certPath/fullchain.pem 2> /dev/null
    fi

    # start panel
    systemctl start d3x-ui 2> /dev/null || rc-service d3x-ui start 2> /dev/null

    # Prompt user to set panel paths after successful certificate installation
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        setPanel="y"
    else
        read -rp "$(xui_tr 'Would you like to set this certificate for the panel? (y/n): ')" setPanel
    fi
    if [[ "$setPanel" == "y" || "$setPanel" == "Y" ]]; then
        local webCertFile="/root/cert/${domain}/fullchain.pem"
        local webKeyFile="/root/cert/${domain}/privkey.pem"

        if [[ -f "$webCertFile" && -f "$webKeyFile" ]]; then
            ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile"
            echo -e "${green}$(xui_tr 'Certificate paths set for the panel')${plain}"
            echo -e "${green}$(xui_tr 'Certificate File: ' "$webCertFile")${plain}"
            echo -e "${green}$(xui_tr 'Private Key File: ' "$webKeyFile")${plain}"
            echo ""
            echo -e "${green}$(xui_tr 'Access URL: https://%s:%s/' "${domain}" "${existing_port}" "${existing_webBasePath}")${plain}"
            echo -e "${yellow}$(xui_tr 'Panel will restart to apply SSL certificate...')${plain}"
            systemctl restart d3x-ui 2> /dev/null || rc-service d3x-ui restart 2> /dev/null
        else
            echo -e "${red}$(xui_tr 'Error: Certificate or private key file not found for domain: %s.' "$domain")${plain}"
        fi
    else
        echo -e "${yellow}$(xui_tr 'Skipping panel path setting.')${plain}"
    fi

    return 0
}

# Reusable interactive SSL setup (domain or IP)
# Sets global `SSL_HOST` to the chosen domain/IP for Access URL usage
prompt_and_setup_ssl() {
    local panel_port="$1"
    local web_base_path="$2"
    local server_ip="$3"

    local ssl_choice=""
    SSL_SCHEME="https"

    echo -e "${yellow}$(xui_tr 'Choose SSL certificate setup method:')${plain}"
    echo -e "${green}1.${plain} $(xui_tr "Let's Encrypt for Domain (90-day validity, auto-renews)")"
    echo -e "${green}2.${plain} $(xui_tr "Let's Encrypt for IP Address (6-day validity, auto-renews)")"
    echo -e "${green}3.${plain} $(xui_tr "Self-signed Certificate for IP (no port 80 needed, no renewal)")"
    echo -e "${green}4.${plain} $(xui_tr "Custom SSL Certificate (Path to existing files)")"
    echo -e "${green}5.${plain} $(xui_tr "Skip SSL (advanced — behind reverse proxy / SSH tunnel only)")"
    echo -e "${blue}Note:${plain} $(xui_tr "Options 1 & 2 require port 80 open. Option 3 needs no port and no renewal. Option 4 requires manual paths.")"
    echo -e "${blue}Note:${plain} $(xui_tr "Option 5 serves the panel over plain HTTP — only safe behind nginx/Caddy or an SSH tunnel.")"
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        case "${XUI_SSL_MODE:-none}" in
            domain) ssl_choice="1" ;;
            ip) ssl_choice="2" ;;
            selfsigned | self_signed | self-sign) ssl_choice="3" ;;
            custom) ssl_choice="4" ;;
            none | "") ssl_choice="5" ;;
            *)
                echo -e "${yellow}$(xui_tr "Unknown XUI_SSL_MODE='%s', defaulting to none (HTTP)." "${XUI_SSL_MODE}")${plain}"
                ssl_choice="5"
                ;;
        esac
    else
        read -rp "$(xui_tr 'Choose an option (default 2 for IP): ')" ssl_choice
        ssl_choice="${ssl_choice// /}" # Trim whitespace

        # Default to 2 (IP cert) if input is empty or invalid (not 1, 3, 4 or 5)
        if [[ "$ssl_choice" != "1" && "$ssl_choice" != "3" && "$ssl_choice" != "4" && "$ssl_choice" != "5" ]]; then
            ssl_choice="2"
        fi
    fi

    case "$ssl_choice" in
        1)
            # User chose Let's Encrypt domain option
            echo -e "${green}$(xui_tr "Using Let's Encrypt for domain certificate...")${plain}"
            if ssl_cert_issue; then
                local cert_domain="${SSL_ISSUED_DOMAIN}"
                if [[ -z "${cert_domain}" ]]; then
                    cert_domain=$(~/.acme.sh/acme.sh --list 2> /dev/null | tail -1 | awk '{print $1}')
                fi

                if [[ -n "${cert_domain}" ]]; then
                    SSL_HOST="${cert_domain}"
                    echo -e "${green}$(xui_tr '✓ SSL certificate configured successfully with domain: ' "${cert_domain}")${plain}"
                else
                    echo -e "${yellow}$(xui_tr 'SSL setup may have completed, but domain extraction failed')${plain}"
                    SSL_HOST="${server_ip}"
                fi
            else
                echo -e "${red}$(xui_tr 'SSL certificate setup failed for domain mode.')${plain}"
                SSL_HOST="${server_ip}"
            fi
            ;;
        2)
            # User chose Let's Encrypt IP certificate option
            echo -e "${green}$(xui_tr "Using Let's Encrypt for IP certificate (shortlived profile)...")${plain}"

            # Confirm the auto-detected IP before issuing for it: with asymmetric
            # routing / multi-WAN the echo services can return a transit address.
            if [[ "$NONINTERACTIVE" != "1" ]]; then
                local ip_confirm=""
                read -rp "$(xui_tr 'Is %s the correct incoming public IPv4 address for this server? [Default y]: ' "$server_ip")" ip_confirm
                if [[ -n "$ip_confirm" && "$ip_confirm" != "y" && "$ip_confirm" != "Y" ]]; then
                    server_ip=""
                    while [[ -z "$server_ip" ]]; do
                        read -rp "$(xui_tr "Please enter your server's public IPv4 address: ")" server_ip
                        server_ip="${server_ip// /}"
                        if [[ ! "$server_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                            echo -e "${red}$(xui_tr 'Invalid IPv4 address. Please try again.')${plain}"
                            server_ip=""
                        fi
                    done
                fi
            fi

            # Ask for optional IPv6
            local ipv6_addr=""
            prompt_or_default ipv6_addr "Do you have an IPv6 address to include? (leave empty to skip): " "" XUI_SSL_IPV6
            ipv6_addr="${ipv6_addr// /}" # Trim whitespace

            # Stop panel if running (port 80 needed)
            if [[ $release == "alpine" ]]; then
                rc-service d3x-ui stop > /dev/null 2>&1
            else
                systemctl stop d3x-ui > /dev/null 2>&1
            fi

            setup_ip_certificate "${server_ip}" "${ipv6_addr}"
            if [ $? -eq 0 ]; then
                SSL_HOST="${server_ip}"
                echo -e "${green}$(xui_tr "✓ Let's Encrypt IP certificate configured successfully")${plain}"
            else
                echo -e "${red}$(xui_tr '✗ IP certificate setup failed. Please check port 80 is open.')${plain}"
                SSL_HOST="${server_ip}"
            fi
            ;;
        3)
            # User chose the self-signed certificate option
            echo -e "${green}$(xui_tr 'Using a self-signed certificate for the panel IP...')${plain}"

            # The auto-detected public IP is the default; the operator can
            # override it when the panel is reached through a different
            # address (NAT, a CDN, an IPv6-only host, ...).
            local self_signed_ip=""
            if [[ "$NONINTERACTIVE" == "1" ]]; then
                self_signed_ip="${XUI_SSL_IP:-${server_ip}}"
            else
                while true; do
                    read -rp "$(xui_tr 'Enter the IP address for the self-signed certificate (press Enter to use %s): ' "$server_ip")" self_signed_ip
                    self_signed_ip="${self_signed_ip// /}" # Trim whitespace
                    if [[ -z "$self_signed_ip" ]]; then
                        self_signed_ip="${server_ip}"
                        break
                    fi
                    if ! is_ipv4 "$self_signed_ip"; then
                        echo -e "${red}$(xui_tr 'Invalid IPv4 address. Please try again.')${plain}"
                        self_signed_ip=""
                    else
                        break
                    fi
                done
            fi

            if setup_self_signed_certificate "$self_signed_ip"; then
                SSL_HOST="${self_signed_ip}"
                echo -e "${green}$(xui_tr '✓ Self-signed certificate configured successfully')${plain}"
            else
                echo -e "${red}$(xui_tr '✗ Self-signed certificate setup failed.')${plain}"
                SSL_HOST="${server_ip}"
            fi

            # The panel reads the certificate at startup, so it has to be
            # restarted to pick the new one up. On a fresh install the service
            # is not running yet and the restart is a no-op.
            systemctl restart d3x-ui > /dev/null 2>&1 || rc-service d3x-ui restart > /dev/null 2>&1
            ;;
        4)
            # User chose Custom Paths (User Provided) option
            echo -e "${green}$(xui_tr 'Using custom existing certificate...')${plain}"
            local custom_cert=""
            local custom_key=""
            local custom_domain=""

            # 3.1 Request Domain to compose Panel URL later
            read -rp "$(xui_tr 'Please enter domain name certificate issued for: ')" custom_domain
            custom_domain="${custom_domain// /}" # Remove spaces

            # 3.2 Loop for Certificate Path
            while true; do
                read -rp "$(xui_tr 'Input certificate path (keywords: .crt / fullchain): ')" custom_cert
                # Strip quotes if present
                custom_cert=$(echo "$custom_cert" | tr -d '"' | tr -d "'")

                if [[ -f "$custom_cert" && -r "$custom_cert" && -s "$custom_cert" ]]; then
                    break
                elif [[ ! -f "$custom_cert" ]]; then
                    echo -e "${red}$(xui_tr 'Error: File does not exist! Try again.')${plain}"
                elif [[ ! -r "$custom_cert" ]]; then
                    echo -e "${red}$(xui_tr 'Error: File exists but is not readable (check permissions)!')${plain}"
                else
                    echo -e "${red}$(xui_tr 'Error: File is empty!')${plain}"
                fi
            done

            # 3.3 Loop for Private Key Path
            while true; do
                read -rp "$(xui_tr 'Input private key path (keywords: .key / privatekey): ')" custom_key
                # Strip quotes if present
                custom_key=$(echo "$custom_key" | tr -d '"' | tr -d "'")

                if [[ -f "$custom_key" && -r "$custom_key" && -s "$custom_key" ]]; then
                    break
                elif [[ ! -f "$custom_key" ]]; then
                    echo -e "${red}$(xui_tr 'Error: File does not exist! Try again.')${plain}"
                elif [[ ! -r "$custom_key" ]]; then
                    echo -e "${red}$(xui_tr 'Error: File exists but is not readable (check permissions)!')${plain}"
                else
                    echo -e "${red}$(xui_tr 'Error: File is empty!')${plain}"
                fi
            done

            # 3.4 Apply Settings via d3x-ui binary
            ${xui_folder}/d3x-ui cert -webCert "$custom_cert" -webCertKey "$custom_key" > /dev/null 2>&1

            # Set SSL_HOST for composing Panel URL
            if [[ -n "$custom_domain" ]]; then
                SSL_HOST="$custom_domain"
            else
                SSL_HOST="${server_ip}"
            fi

            echo -e "${green}$(xui_tr '✓ Custom certificate paths applied.')${plain}"
            echo -e "${yellow}$(xui_tr 'Note: You are responsible for renewing these files externally.')${plain}"

            systemctl restart d3x-ui > /dev/null 2>&1 || rc-service d3x-ui restart > /dev/null 2>&1
            ;;
        5)
            echo ""
            echo -e "${red}$(xui_tr '⚠ Panel will be installed WITHOUT SSL/TLS.')${plain}"
            echo -e "${yellow}$(xui_tr 'Login credentials and cookies will travel as plain HTTP.')${plain}"
            echo -e "${yellow}$(xui_tr 'Only safe when:')${plain}"
            echo -e "${yellow}$(xui_tr '  • A reverse proxy (nginx, Caddy, Traefik) terminates TLS for you, or')${plain}"
            echo -e "${yellow}$(xui_tr '  • You access the panel exclusively via SSH tunnel')${plain}"
            echo ""

            SSL_SCHEME="http"
            SSL_HOST="${server_ip}"

            local bind_local=""
            if [[ "$NONINTERACTIVE" == "1" ]]; then
                # Cloud images must stay reachable on their public interface.
                bind_local="n"
            else
                read -rp "$(xui_tr 'Bind the panel to 127.0.0.1 only? (recommended — forces SSH tunnel / reverse-proxy access) [y/N]: ')" bind_local
            fi
            if [[ "$bind_local" == "y" || "$bind_local" == "Y" ]]; then
                ${xui_folder}/d3x-ui setting -listenIP "127.0.0.1" > /dev/null 2>&1
                SSL_HOST="127.0.0.1"
                echo -e "${green}$(xui_tr '✓ Panel bound to 127.0.0.1 only. It is now unreachable from the public internet.')${plain}"
                echo ""
                echo -e "${green}$(xui_tr 'SSH Port Forwarding — open the panel from your local machine via:')${plain}"
                echo -e "$(xui_tr '  Standard SSH command:')"
                echo -e "  ${yellow}ssh -L 2222:127.0.0.1:${panel_port} root@${server_ip}${plain}"
                echo -e "$(xui_tr '  If using an SSH key:')"
                echo -e "  ${yellow}ssh -i <sshkeypath> -L 2222:127.0.0.1:${panel_port} root@${server_ip}${plain}"
                echo -e "$(xui_tr '  Then open in your browser:')"
                echo -e "  ${yellow}http://localhost:2222/${web_base_path}${plain}"
                echo ""
                echo -e "${yellow}$(xui_tr 'Alternative: point a reverse proxy (nginx/Caddy) at 127.0.0.1:%s and let it terminate TLS.' "${panel_port}")${plain}"
            else
                echo -e "${yellow}$(xui_tr 'Panel will listen on all interfaces over plain HTTP. Make sure something else is terminating TLS in front of it.')${plain}"
            fi

            systemctl restart d3x-ui > /dev/null 2>&1 || rc-service d3x-ui restart > /dev/null 2>&1
            echo -e "${green}$(xui_tr '✓ SSL setup skipped.')${plain}"
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Skipping SSL setup.')${plain}"
            SSL_HOST="${server_ip}"
            ;;
    esac
}

config_after_install() {
    local settings existing_webBasePath
    if ! settings=$("${xui_folder}/d3x-ui" setting -show true) ||
        ! existing_webBasePath=$(printf '%s\n' "$settings" | awk '
            /^get .* failed, error info:/ { failed = 1 }
            /^hasDefaultCredential: (true|false)$/ { credentials++ }
            /^port: [0-9]+$/ { ports++ }
            /^webBasePath:/ { paths++; sub(/^webBasePath: ?/, ""); path = $0 }
            END {
                if (failed || credentials != 1 || ports != 1 || paths != 1 || (path != "" && path !~ /^\//)) exit 1
                print path
            }'); then
        echo -e "${red}Unable to read webBasePath; leaving existing settings unchanged.${plain}" >&2
        return 1
    fi
    existing_webBasePath=${existing_webBasePath#/}
    local existing_hasDefaultCredential=$(printf '%s\n' "$settings" | awk '/^hasDefaultCredential: / {print $2}')
    local existing_port=$(printf '%s\n' "$settings" | awk '/^port: / {print $2}')
    # Properly detect empty cert by checking if cert: line exists and has content after it
    local existing_cert=$(${xui_folder}/d3x-ui setting -getCert true | grep 'cert:' | awk -F': ' '{print $2}' | tr -d '[:space:]')
    local URL_lists=(
        "https://api4.ipify.org"
        "https://ipv4.icanhazip.com"
        "https://v4.api.ipinfo.io/ip"
        "https://ipv4.myexternalip.com/raw"
        "https://4.ident.me"
        "https://check-host.net/ip"
    )
    local server_ip=""
    for ip_address in "${URL_lists[@]}"; do
        local response=$(curl -s -w "\n%{http_code}" --max-time 3 "${ip_address}" 2> /dev/null)
        local http_code=$(echo "$response" | tail -n1)
        local ip_result=$(echo "$response" | head -n-1 | tr -d '[:space:]"')
        if [[ "${http_code}" == "200" && "${ip_result}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            server_ip="${ip_result}"
            break
        fi
    done

    if [[ -z "$server_ip" ]]; then
        if [[ "$NONINTERACTIVE" == "1" ]]; then
            # Panel binds 0.0.0.0 regardless; the IP is only used to compose the
            # displayed access URL. Fall back to XUI_SERVER_IP or leave blank.
            server_ip="${XUI_SERVER_IP:-}"
        else
            echo -e "${yellow}$(xui_tr 'Could not auto-detect server IP from any provider.')${plain}"
            while [[ -z "$server_ip" ]]; do
                read -rp "$(xui_tr "Please enter your server's public IPv4 address: ")" server_ip
                server_ip="${server_ip// /}"
                if [[ ! "$server_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo -e "${red}$(xui_tr 'Invalid IPv4 address. Please try again.')${plain}"
                    server_ip=""
                fi
            done
        fi
    fi

    if [[ -z "$existing_webBasePath" ]]; then
        if [[ "$existing_hasDefaultCredential" == "true" ]]; then
            local config_webBasePath=""
            local config_username=""
            local config_password=""
            local config_port=""

            local db_label="SQLite (/etc/d3x-ui/d3x-ui.db)"
            echo ""
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${green}$(xui_box_title 'Database Selection')${plain}"
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "$(xui_tr '  1) SQLite     (default — recommended for < 500 clients)')"
            echo -e "$(xui_tr '  2) PostgreSQL (recommended for high client counts / many nodes)')"
            if [[ "$NONINTERACTIVE" == "1" ]]; then
                if [[ "${XUI_DB_TYPE:-sqlite}" == "postgres" ]]; then
                    db_choice="2"
                else
                    db_choice="1"
                fi
            else
                read -rp "$(xui_tr 'Choose [1]: ')" db_choice
                db_choice="${db_choice:-1}"
            fi
            if [[ "$db_choice" == "2" ]]; then
                local xui_env_file
                case "${release}" in
                    ubuntu | debian | armbian)
                        xui_env_file="/etc/default/d3x-ui"
                        ;;
                    arch | manjaro | parch | alpine)
                        xui_env_file="/etc/conf.d/d3x-ui"
                        ;;
                    *)
                        xui_env_file="/etc/sysconfig/d3x-ui"
                        ;;
                esac

                local xui_dsn=""
                local pg_mode=""
                local pg_local_installed=0
                while [[ -z "$xui_dsn" ]]; do
                    if [[ "$NONINTERACTIVE" == "1" ]]; then
                        if [[ -n "${XUI_DB_DSN:-}" ]]; then
                            xui_dsn="${XUI_DB_DSN}"
                            db_label="PostgreSQL (external)"
                            break
                        fi
                        echo -e "${yellow}$(xui_tr 'Installing PostgreSQL locally (non-interactive)...')${plain}"
                        local pg_cred_file
                        pg_cred_file=$(mktemp 2> /dev/null) || pg_cred_file=$(mktemp -t d3x-ui-pg-creds.XXXXXXXX)
                        if [[ -n "${pg_cred_file}" ]] && xui_dsn=$(PG_CRED_FILE="${pg_cred_file}" install_postgres_local); then
                            pg_local_installed=1
                            if [[ -r "${pg_cred_file}" ]]; then
                                # shellcheck disable=SC1090
                                source "${pg_cred_file}"
                            fi
                            rm -f "${pg_cred_file}"
                            db_label="PostgreSQL (${PG_USER}@${PG_HOST}:${PG_PORT}/${PG_DB})"
                            break
                        fi
                        rm -f "${pg_cred_file}"
                        echo -e "${red}$(xui_tr 'PostgreSQL installation failed in non-interactive mode; aborting.')${plain}"
                        echo -e "${yellow}$(xui_tr 'Set XUI_DB_DSN to use an existing server, or XUI_DB_TYPE=sqlite.')${plain}"
                        exit 1
                    fi
                    echo ""
                    echo -e "$(xui_tr '  1) Install PostgreSQL locally and create a dedicated user/db (recommended)')"
                    echo -e "$(xui_tr '  2) Use an existing PostgreSQL server (enter DSN)')"
                    read -rp "$(xui_tr 'Choose [1]: ')" pg_mode
                    pg_mode="${pg_mode:-1}"
                    if [[ "$pg_mode" == "2" ]]; then
                        while [[ -z "$xui_dsn" ]]; do
                            read -rp "$(xui_tr 'Enter PostgreSQL DSN (postgres://user:pass@host:port/dbname?sslmode=disable): ')" xui_dsn
                            xui_dsn="${xui_dsn// /}"
                        done
                        db_label="PostgreSQL (external)"
                    else
                        echo -e "${yellow}$(xui_tr 'Installing PostgreSQL — this may take a moment...')${plain}"
                        local pg_cred_file
                        pg_cred_file=$(mktemp 2> /dev/null) || pg_cred_file=$(mktemp -t d3x-ui-pg-creds.XXXXXXXX)
                        if [[ -z "${pg_cred_file}" ]]; then
                            echo -e "${red}$(xui_tr 'Failed to create temporary credentials file.')${plain}"
                            xui_dsn=""
                            continue
                        fi
                        if xui_dsn=$(PG_CRED_FILE="${pg_cred_file}" install_postgres_local); then
                            pg_local_installed=1
                            if [[ -r "${pg_cred_file}" ]]; then
                                # shellcheck disable=SC1090
                                source "${pg_cred_file}"
                            fi
                            rm -f "${pg_cred_file}"
                            db_label="PostgreSQL (${PG_USER}@${PG_HOST}:${PG_PORT}/${PG_DB})"
                        else
                            rm -f "${pg_cred_file}"
                            echo ""
                            echo -e "${red}$(xui_tr 'PostgreSQL installation failed.')${plain}"
                            echo -e "$(xui_tr '  1) Retry local install')"
                            echo -e "$(xui_tr '  2) Enter an external DSN instead')"
                            echo -e "$(xui_tr '  3) Abort install')"
                            echo -e "$(xui_tr '  4) Fall back to SQLite')"
                            read -rp "$(xui_tr 'Choose [1]: ')" pg_fail
                            pg_fail="${pg_fail:-1}"
                            case "$pg_fail" in
                                2) pg_mode="2" ;;
                                3)
                                    echo -e "${red}$(xui_tr 'Install aborted.')${plain}"
                                    exit 1
                                    ;;
                                4)
                                    db_choice="1"
                                    xui_dsn=""
                                    break
                                    ;;
                                *) xui_dsn="" ;;
                            esac
                        fi
                    fi
                done
                if [[ -n "$xui_dsn" ]]; then
                    install -d -m 755 "$(dirname "$xui_env_file")"
                    umask 077
                    cat > "$xui_env_file" << EOF
XUI_DB_TYPE=postgres
XUI_DB_DSN=${xui_dsn}
EOF
                    chmod 600 "$xui_env_file"
                    umask 022
                    export XUI_DB_TYPE=postgres
                    export XUI_DB_DSN="${xui_dsn}"
                    ensure_pg_client || echo -e "${yellow}⚠ Could not install pg_dump/pg_restore. In-panel database backup/restore will be unavailable until you install the postgresql-client package.${plain}"
                fi
            fi

            select_panel_settings || exit 1
            config_port="$SELECTED_PORT"
            config_username="$SELECTED_USERNAME"
            config_password="$SELECTED_PASSWORD"
            config_webBasePath="$SELECTED_WEB_BASE_PATH"

            local settings_output settings_status=0
            settings_output=$("${xui_folder}/d3x-ui" setting -username "${config_username}" -password "${config_password}" -port "${config_port}" -webBasePath "${config_webBasePath}" 2>&1) || settings_status=$?
            printf '%s\n' "$settings_output"
            # Released CLIs may print a settings/database error and still exit 0.
            # Require all three existing success messages before claiming success.
            if [[ "$settings_status" != 0 ]] ||
                ! grep -Fxq "Port set successfully: ${config_port}" <<< "$settings_output" ||
                ! grep -Fxq 'Username and password updated successfully' <<< "$settings_output" ||
                ! grep -Fxq 'Base URI path set successfully' <<< "$settings_output"; then
                echo 'Failed to configure panel settings; installation aborted.' >&2
                exit 1
            fi

            echo ""
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${green}$(xui_box_title 'SSL Certificate Setup (RECOMMENDED)')${plain}"
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${yellow}$(xui_tr 'SSL is strongly recommended. Skip only if a reverse proxy')${plain}"
            echo -e "${yellow}$(xui_tr 'or SSH tunnel handles TLS for you.')${plain}"
            echo -e "${yellow}$(xui_tr "Let's Encrypt now supports both domains and IP addresses!")${plain}"
            echo ""

            prompt_and_setup_ssl "${config_port}" "${config_webBasePath}" "${server_ip}"

            # Retrieve the API token for display
            local config_apiToken=$(${xui_folder}/d3x-ui setting -getApiToken | grep -Eo 'apiToken: .+' | awk '{print $2}')

            # Display final credentials and access information
            echo ""
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${green}$(xui_box_title 'Panel Installation Complete!')${plain}"
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${green}$(xui_tr 'Username:    ')${config_username}${plain}"
            echo -e "${green}$(xui_tr 'Password:    ')${config_password}${plain}"
            echo -e "${green}$(xui_tr 'Port:        ')${config_port}${plain}"
            echo -e "${green}$(xui_tr 'WebBasePath: ')${config_webBasePath}${plain}"
            echo -e "${green}$(xui_tr 'Database:    ')${db_label}${plain}"
            echo -e "${green}$(xui_tr 'Access URL:  ')${SSL_SCHEME}://${SSL_HOST}:${config_port}/${config_webBasePath}${plain}"
            echo -e "${green}$(xui_tr 'API Token:   ')${config_apiToken}${plain}"
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${yellow}$(xui_tr '⚠ IMPORTANT: Save these credentials securely!')${plain}"
            if [[ "$SSL_SCHEME" == "https" ]]; then
                echo -e "${yellow}$(xui_tr '⚠ SSL Certificate: Enabled and configured')${plain}"
            else
                echo -e "${yellow}$(xui_tr '⚠ SSL Certificate: Skipped — panel is HTTP-only. Use a reverse proxy or SSH tunnel.')${plain}"
            fi

            if [[ "$db_choice" == "2" ]]; then
                echo ""
                echo -e "${green}$(xui_tr 'PostgreSQL backup & restore is built into the panel:')${plain}"
                echo -e "$(xui_tr '  %s%s://%s:%s/%s%s → Backup & Restore' "${blue}" "${SSL_SCHEME}" "${SSL_HOST}" "${config_port}" "${config_webBasePath}" "${plain}")"
                echo -e "${yellow}$(xui_tr '  Back Up downloads a pg_dump .dump file; Restore reloads it via pg_restore.')${plain}"
            fi

            if [[ "$db_choice" == "2" && "$pg_local_installed" == "1" ]]; then
                echo ""
                echo -e "${green}═══════════════════════════════════════════${plain}"
                echo -e "${green}$(xui_box_title 'PostgreSQL Credentials')${plain}"
                echo -e "${green}═══════════════════════════════════════════${plain}"
                echo -e "${green}$(xui_tr 'DB Name:    ' "${PG_DB}")${plain}"
                echo -e "${green}$(xui_tr 'Username:   ' "${PG_USER}")${plain}"
                echo -e "${green}$(xui_tr 'Password:   ' "${PG_PASS}")${plain}"
                echo -e "${green}$(xui_tr 'Host:       ' "${PG_HOST}")${plain}"
                echo -e "${green}$(xui_tr 'Port:       ' "${PG_PORT}")${plain}"
                echo -e "${green}$(xui_tr 'DSN:        ' "${xui_dsn}")${plain}"
                echo -e "${green}$(xui_tr 'Env file:   ' "${xui_env_file}")${plain}"
                echo -e "${green}-------------------------------------------${plain}"
                echo -e "${green}$(xui_tr 'Connect from this server:')${plain}"
                echo -e "$(xui_tr '  %ssudo -u postgres psql -d %s%s      (as the postgres superuser)' "${blue}" "${PG_DB}" "${plain}")"
                echo -e "  ${blue}PGPASSWORD='${PG_PASS}' psql -h ${PG_HOST} -p ${PG_PORT} -U ${PG_USER} -d ${PG_DB}${plain}"
                echo -e "${green}═══════════════════════════════════════════${plain}"
                echo -e "${yellow}$(xui_tr '⚠ The panel reads these credentials from %s.' "${xui_env_file}")${plain}"
                echo -e "${yellow}$(xui_tr '⚠ Save the password — it is not stored anywhere else in plain text.')${plain}"
                unset PG_USER PG_PASS PG_HOST PG_PORT PG_DB
            fi

            # Persist a machine-parseable credentials file for cloud-init / MOTD.
            : "${SSL_SCHEME:=https}"
            : "${SSL_HOST:=${server_ip}}"
            local db_type_out="sqlite"
            [[ "$db_choice" == "2" ]] && db_type_out="postgres"
            write_install_result "${config_username}" "${config_password}" "${config_port}" \
                "${config_webBasePath}" "${SSL_SCHEME}" "${SSL_HOST}" "${config_apiToken}" "${db_type_out}"
        else
            local config_webBasePath=""
            echo -e "${yellow}$(xui_tr 'WebBasePath is missing or set to root. Generating a new one...')${plain}"
            select_web_base_path || exit 1
            config_webBasePath="$SELECTED_WEB_BASE_PATH"
            ${xui_folder}/d3x-ui setting -webBasePath "${config_webBasePath}"
            echo -e "${green}$(xui_tr 'New WebBasePath: ')${config_webBasePath}${plain}"

            # If the panel is already installed but no certificate is configured, prompt for SSL now
            if [[ -z "${existing_cert}" ]]; then
                echo ""
                echo -e "${green}═══════════════════════════════════════════${plain}"
                echo -e "${green}$(xui_box_title 'SSL Certificate Setup (RECOMMENDED)')${plain}"
                echo -e "${green}═══════════════════════════════════════════${plain}"
                echo -e "${yellow}$(xui_tr "Let's Encrypt now supports both domains and IP addresses!")${plain}"
                echo ""
                prompt_and_setup_ssl "${existing_port}" "${config_webBasePath}" "${server_ip}"
                echo -e "${green}$(xui_tr 'Access URL:  %s://%s:%s/' "${SSL_SCHEME}" "${SSL_HOST}" "${existing_port}" "${config_webBasePath}")${plain}"
            else
                # If a cert already exists, just show the access URL
                echo -e "${green}$(xui_tr 'Access URL: https://%s:%s/' "${server_ip}" "${existing_port}" "${config_webBasePath}")${plain}"
            fi
        fi
    else
        if [[ "$existing_hasDefaultCredential" == "true" ]]; then
            select_credentials || exit 1
            local config_username="$SELECTED_USERNAME"
            local config_password="$SELECTED_PASSWORD"

            echo -e "${yellow}$(xui_tr 'Default credentials detected. Security update required...')${plain}"
            ${xui_folder}/d3x-ui setting -username "${config_username}" -password "${config_password}"
            echo -e "$(xui_tr 'Generated new random login credentials:')"
            echo -e "###############################################"
            echo -e "${green}$(xui_tr 'Username: ' "${config_username}")${plain}"
            echo -e "${green}$(xui_tr 'Password: ' "${config_password}")${plain}"
            echo -e "###############################################"

            # The access path of an existing panel can still be replaced here;
            # a fresh random one is generated when the operator declines.
            local config_webBasePath="$existing_webBasePath"
            select_web_base_path || exit 1
            if [[ "$SELECTED_WEB_BASE_PATH" != "$existing_webBasePath" ]]; then
                ${xui_folder}/d3x-ui setting -webBasePath "${SELECTED_WEB_BASE_PATH}"
                config_webBasePath="$SELECTED_WEB_BASE_PATH"
                echo -e "${green}$(xui_tr 'New WebBasePath: ')${config_webBasePath}${plain}"
            fi

            # Persist a machine-parseable credentials file for cloud-init / MOTD.
            local config_apiToken
            config_apiToken=$(${xui_folder}/d3x-ui setting -getApiToken | grep -Eo 'apiToken: .+' | awk '{print $2}')
            : "${SSL_SCHEME:=https}"
            : "${SSL_HOST:=${server_ip}}"
            write_install_result "${config_username}" "${config_password}" "${existing_port}" \
                "${config_webBasePath}" "${SSL_SCHEME}" "${SSL_HOST}" "${config_apiToken}" "${XUI_DB_TYPE:-sqlite}"
        else
            echo -e "${green}$(xui_tr 'Username, Password, and WebBasePath are properly set.')${plain}"
        fi

        # Existing install: if no cert configured, prompt user for SSL setup
        # Properly detect empty cert by checking if cert: line exists and has content after it
        existing_cert=$(${xui_folder}/d3x-ui setting -getCert true | grep 'cert:' | awk -F': ' '{print $2}' | tr -d '[:space:]')
        if [[ -z "$existing_cert" ]]; then
            echo ""
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${green}$(xui_box_title 'SSL Certificate Setup (RECOMMENDED)')${plain}"
            echo -e "${green}═══════════════════════════════════════════${plain}"
            echo -e "${yellow}$(xui_tr "Let's Encrypt now supports both domains and IP addresses!")${plain}"
            echo ""
            prompt_and_setup_ssl "${existing_port}" "${existing_webBasePath}" "${server_ip}"
            echo -e "${green}$(xui_tr 'Access URL:  %s://%s:%s/' "${SSL_SCHEME}" "${SSL_HOST}" "${existing_port}" "${existing_webBasePath}")${plain}"
        else
            echo -e "${green}$(xui_tr 'SSL certificate already configured. No action needed.')${plain}"
        fi
    fi

    ${xui_folder}/d3x-ui migrate
}

# setup_fail2ban auto-installs and configures fail2ban for the IP Limit feature
# by invoking the freshly installed d3x-ui CLI. IP Limit is load-bearing on
# fail2ban (without it the panel disables the limitIp field and zeroes existing
# limits), so a fresh install should make it work out of the box, just like the
# Docker image already does. Non-fatal by design: a fail2ban failure must never
# abort the panel install.
setup_fail2ban() {
    if [[ -n "${XUI_ENABLE_FAIL2BAN+x}" && "${XUI_ENABLE_FAIL2BAN}" != "true" ]]; then
        echo -e "${yellow}$(xui_tr 'XUI_ENABLE_FAIL2BAN=%s, skipping Fail2ban auto-setup.' "${XUI_ENABLE_FAIL2BAN}")${plain}"
        return 0
    fi

    if [[ ! -x /usr/bin/d3x-ui ]]; then
        echo -e "${yellow}$(xui_tr 'd3x-ui CLI not found; skipping Fail2ban auto-setup.')${plain}"
        return 0
    fi

    # Scripts older than v3.4.0 have no setup-fail2ban and exit 0 from the
    # usage banner, which would read as success here.
    if ! grep -q '"setup-fail2ban")' /usr/bin/d3x-ui; then
        echo -e "${yellow}$(xui_tr "This d3x-ui.sh predates 'd3x-ui setup-fail2ban'; skipping Fail2ban auto-setup.")${plain}"
        return 0
    fi

    echo -e "${green}$(xui_tr 'Setting up Fail2ban for the IP Limit feature...')${plain}"
    if /usr/bin/d3x-ui setup-fail2ban; then
        echo -e "${green}$(xui_tr 'Fail2ban setup complete.')${plain}"
    else
        echo -e "${yellow}$(xui_tr "Fail2ban setup did not finish; IP Limit stays disabled until you run 'd3x-ui' and open the IP Limit menu. Continuing.")${plain}"
    fi
    return 0
}

# Major version of the local systemd, 0 when it cannot be determined. The
# SystemCallFilter=@system-service group only exists from systemd 239 on (other
# @-named groups exist since 231); on older versions an unknown group is not
# ignored safely, the filter stays in force and leaves a whitelist the panel
# cannot run under.
_xui_systemd_major_version() {
    local version=""
    if command -v systemctl > /dev/null 2>&1; then
        version="$(systemctl --version 2>/dev/null | awk 'NR == 1 {print $2}')"
    fi
    if [[ ! "$version" =~ ^[0-9]+$ ]]; then
        echo 0
        return 0
    fi
    echo "$version"
}

# The shipped units list hardening that older systemd does not know: the
# directive is logged and ignored at load time rather than rejected, so the
# panel still starts, only without that protection. Each entry is the systemd
# release that introduced the directive (systemd.exec(5)); everything else in
# the unit predates the oldest systemd install.sh supports (CentOS 7 has 219).
# SystemCallFilter= is listed because the drop-in only writes it from 239 on.
_xui_warn_unsupported_hardening() {
    local version entry missing=""
    version="$(_xui_systemd_major_version)"
    [[ "$version" -gt 0 ]] || return 0
    for entry in RestrictRealtime:231 ReadWritePaths:231 ProtectKernelTunables:232 \
        ProtectKernelModules:232 RestrictNamespaces:233 LockPersonality:235 \
        SystemCallFilter:239 ProtectHostname:242 RestrictSUIDSGID:242 \
        ProtectKernelLogs:244 ProtectClock:245; do
        if [[ "$version" -lt "${entry##*:}" ]]; then
            missing="${missing:+$missing, }${entry%%:*} (${entry##*:})"
        fi
    done
    [[ -n "$missing" ]] || return 0
    echo -e "${yellow}$(xui_tr 'Note: systemd %s ignores part of the hardening in d3x-ui.service; the panel still starts.' "${version}")${plain}"
    echo "      Not applied, needs a newer systemd: ${missing}."
    if [[ "$version" -lt 231 ]]; then
        echo "      The panel's folders stay writable through ReadWriteDirectories=, the alias this script installs."
    fi
    echo "      The rest of the hardening is in force. Upgrade systemd to apply the above."
    return 0
}

# ProtectSystem=full makes /usr, /boot, /efi and /etc read-only. ProtectSystem=
# strict would make the whole hierarchy read-only (only the kernel API
# filesystems stay as they are), and that would break the panel's own use of
# /tmp. The panel's stores are configurable (XUI_DB_FOLDER, XUI_LOG_FOLDER,
# XUI_BIN_FOLDER), and XUI_MAIN_FOLDER is the folder install.sh/update.sh place
# the files in -- the unit's WorkingDirectory on a stock install, and what a
# relative XUI_BIN_FOLDER is resolved against. So a hard-coded list in the unit
# either misses a relocated store -- the panel then cannot write its own SQLite
# database and sits in a Restart=on-failure loop -- or forces the operator to
# edit a file that every install/update overwrites from the release tarball.
# install.sh and update.sh therefore regenerate the drop-in from the folders
# actually in use, and the unit's own ReadWritePaths only carry the
# plain-install defaults. A relocated store means re-running install or update:
# the drop-in is only written here.
_xui_service_write_paths_dropin() {
    # $1 is the env file to resolve the XUI_* folders from; callers pass nothing
    # and get the OS-specific path the unit itself uses.
    local env_file="${1:-}"
    local dropin_dir dropin temp_file
    local db_folder log_folder bin_folder main_folder
    local path line="" whitespace_paths="" seen_paths="" escaped_path

    if [[ -z "$env_file" ]]; then
        case "${release}" in
            ubuntu | debian | armbian)
                env_file="/etc/default/d3x-ui"
                ;;
            arch | manjaro | parch | alpine)
                env_file="/etc/conf.d/d3x-ui"
                ;;
            *)
                env_file="/etc/sysconfig/d3x-ui"
                ;;
        esac
    fi
    if [[ -r "$env_file" ]]; then
        set -a
        # shellcheck disable=SC1090
        source "$env_file"
        set +a
    fi

    # XUI_* wins over the script's own default: the unit hands that same env
    # file to the panel through EnvironmentFile=, so these are the folders it
    # will actually use.
    main_folder="${XUI_MAIN_FOLDER:-${xui_folder}}"
    db_folder="${XUI_DB_FOLDER:-/etc/d3x-ui}"
    log_folder="${XUI_LOG_FOLDER:-/var/log/d3x-ui}"
    # An empty XUI_BIN_FOLDER resolves to "bin" relative to the panel's working
    # directory, which the unit sets to the main folder.
    bin_folder="${XUI_BIN_FOLDER:-bin}"
    if [[ "$bin_folder" != /* ]]; then
        bin_folder="${main_folder%/}/${bin_folder#./}"
    fi

    for path in "$db_folder" "$log_folder" "$bin_folder" "$main_folder"; do
        [[ "$path" == /* ]] || continue
        # ReadWritePaths= is a whitespace-separated list, and a folder whose
        # name contains whitespace cannot be written into it without relying on
        # quoting. A wrong entry makes systemd reject the whole drop-in and the
        # panel would not start, so leave such a folder out and say so instead.
        if [[ "$path" != "${path//[[:space:]]/}" ]]; then
            whitespace_paths="${whitespace_paths:+$whitespace_paths }$path"
            continue
        fi
        case " $seen_paths " in
            *" $path "*) continue ;;
        esac
        seen_paths="${seen_paths}${seen_paths:+ }$path"
        # systemd expands %-specifiers in unit files, so a folder name carrying
        # a literal % has to be written as %%, or the entry stops naming the
        # folder systemd is meant to keep writable.
        escaped_path="${path//%/%%}"
        line="${line} -${escaped_path}"
    done
    if [[ -n "$whitespace_paths" ]]; then
        echo "Warning: these folders contain whitespace and were left out of" >&2
        echo "         10-xui-sandbox.conf: $whitespace_paths" >&2
        echo "         The panel cannot write to them under the unit's sandbox." >&2
    fi
    line="${line# }"
    [[ -n "$line" ]] || return 1

    dropin_dir="${xui_service}/d3x-ui.service.d"
    dropin="${dropin_dir}/10-xui-sandbox.conf"
    temp_file="${dropin}.tmp.$$"

    mkdir -p "$dropin_dir" || return 1
    cat > "$temp_file" << EOF
# Regenerated by install.sh/update.sh on every install and update: edits here
# are lost, and the list only reflects the XUI_* variables read from
# ${env_file} at that moment. Re-run install/update after moving a store.
# It lists the folders the panel writes to. Put local additions in their own
# drop-in, for example 20-d3x-ui-local.conf, which nothing here touches.
[Service]
ReadWritePaths=${line}
ReadWriteDirectories=${line}
EOF
    if [[ "$(_xui_systemd_major_version)" -ge 239 ]]; then
        cat >> "$temp_file" << 'EOF'
# @system-service needs systemd >= 239; on older versions the unknown group
# would leave the panel with a filter it cannot start under (d3x-ui.service.*).
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
EOF
    fi
    if [[ ! -s "$temp_file" ]]; then
        rm -f "$temp_file"
        return 1
    fi
    chmod 644 "$temp_file"
    mv -f "$temp_file" "$dropin" || { rm -f "$temp_file"; return 1; }
    if command -v systemctl > /dev/null 2>&1; then
        systemctl daemon-reload > /dev/null 2>&1 || true
    fi
    return 0
}

# Lands a systemd unit file at ${xui_service}/d3x-ui.service via a temp file +
# atomic mv, so a failed cp/curl or an interrupted mv never leaves a
# truncated unit file at the live path -- systemd would then fail to parse
# it on the next daemon-reload/start. Same pattern already used for
# /usr/bin/d3x-ui elsewhere in this script. source_is_url picks cp (from a
# file already extracted from the release tarball) vs curl (GitHub fallback).
_install_xui_service_unit() {
    local source="$1"
    local source_is_url="$2"
    local dest="${xui_service}/d3x-ui.service"
    local temp_file="${dest}.tmp.$$"

    rm -f "$temp_file"
    if [[ "$source_is_url" == "true" ]]; then
        curl -fLRo "$temp_file" "$source" > /dev/null 2>&1
    else
        cp -f "$source" "$temp_file" > /dev/null 2>&1
    fi
    if [[ $? -ne 0 ]]; then
        rm -f "$temp_file"
        return 1
    fi
    if [[ ! -s "$temp_file" ]]; then
        rm -f "$temp_file"
        return 1
    fi
    mv -f "$temp_file" "$dest"
    if [[ $? -ne 0 ]]; then
        rm -f "$temp_file"
        return 1
    fi
    if ! _xui_service_write_paths_dropin; then
        echo -e "${yellow}$(xui_tr 'Warning: could not refresh %s/d3x-ui.service.d/10-xui-sandbox.conf.' "${xui_service}")${plain}"
        echo -e "${yellow}$(xui_tr 'If XUI_DB_FOLDER or XUI_LOG_FOLDER points outside /etc/d3x-ui and /var/log/d3x-ui, the panel may not be able to write to it under ProtectSystem=full.')${plain}"
    fi
    _xui_warn_unsupported_hardening
    return 0
}

# resolve_latest_tag prints the latest stable release tag. It prefers the web
# releases/latest redirect, which is not subject to the unauthenticated API's
# 60 req/h-per-IP limit that trips shared CI/CGNAT addresses (the install then
# fails with "Failed to fetch d3x-ui version"), and falls back to the API.
resolve_latest_tag() {
    local url tag
    url=$(curl -sSLI -o /dev/null -w '%{url_effective}' --retry 5 --retry-delay 3 --connect-timeout 15 --max-time 60 "https://github.com/mekkhalawang/d3x-ui/releases/latest" 2>/dev/null)
    tag=${url##*/tag/}
    if [[ "$tag" != "$url" && -n "$tag" && "$tag" != "latest" ]]; then
        echo "$tag"
        return 0
    fi
    curl -Ls --retry 5 --retry-delay 3 --connect-timeout 15 --max-time 60 "https://api.github.com/repos/mekkhalawang/d3x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Releases publish <asset>.sha256 next to each archive. A mismatch or a failed
# sidecar download aborts the install; only a 404 (releases predating the
# sidecar) is tolerated with a warning.
verify_release_checksum() {
    local url="$1" file="$2" sums="$2.sha256" code expected actual
    rm -f "${sums}"
    code=$(curl -sL --retry 3 --retry-delay 3 --connect-timeout 15 --max-time 60 -o "${sums}" -w '%{http_code}' "${url}.sha256")
    if [[ "${code}" == "404" ]]; then
        rm -f "${sums}"
        echo -e "${yellow}$(xui_tr 'No checksum published for this release, skipping verification')${plain}"
        return 0
    fi
    if [[ "${code}" != "200" ]]; then
        rm -f "${sums}" "${file}"
        echo -e "${red}$(xui_tr 'Failed to download the checksum for %s (HTTP %s)' "$(basename "${file}")" "${code}")${plain}"
        exit 1
    fi
    expected=$(awk 'NR == 1 {print $1}' "${sums}")
    actual=$(sha256sum "${file}" | awk '{print $1}')
    rm -f "${sums}"
    if [[ ! "${expected}" =~ ^[0-9a-f]{64}$ || "${expected}" != "${actual}" ]]; then
        rm -f "${file}"
        # The file name is interpolated outside the lookup key: the key carries
        # the printf placeholders, so a %s inside it would be consumed as one.
        echo -e "${red}$(xui_tr 'Checksum mismatch for %s: expected %s, got %s' "$(basename "${file}")" "${expected:-<none>}" "${actual}")${plain}"
        exit 1
    fi
    echo -e "${green}$(xui_tr 'Checksum verified: ' "${actual}")${plain}"
}

# Older tags predate some of these files (d3x-ui.rc arrived in v2.8.4). Serving
# main's copy against an old binary is the mismatch this pinning exists to
# prevent, so probe before anything is stopped or removed and refuse the tag.
require_repo_files() {
    local ref="$1" name status
    shift
    [[ "${ref}" == "main" ]] && return 0
    for name in "$@"; do
        status=$(curl -sIL --retry 3 --connect-timeout 15 -o /dev/null -w '%{http_code}' "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/${ref}/${name}")
        if [[ "${status}" != "200" ]]; then
            echo -e "${red}$(xui_tr '%s is not available for %s (HTTP %s)' "${name}" "${ref}" "${status}")${plain}"
            echo -e "${red}$(xui_tr "Install a release that ships it, or 'dev' for the rolling build. Your existing installation has not been touched.")${plain}"
            exit 1
        fi
    done
}

install_d3x-ui() {
    cd ${xui_folder%/d3x-ui}/

    # Download resources
    if [ $# == 0 ]; then
        tag_version=$(resolve_latest_tag)
        if [[ ! -n "$tag_version" ]]; then
            echo -e "${red}$(xui_tr 'Failed to fetch d3x-ui version, it may be due to GitHub API restrictions, please try it later')${plain}"
            exit 1
        fi
        echo -e "$(xui_tr 'Got d3x-ui latest version: %s, beginning the installation...' "${tag_version}")"
        curl -fLR --retry 5 --retry-delay 3 --connect-timeout 15 --speed-limit 1 --speed-time 300 -o ${xui_folder}-linux-$(arch).tar.gz https://github.com/mekkhalawang/d3x-ui/releases/download/${tag_version}/d3x-ui-linux-$(arch).tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}$(xui_tr 'Downloading d3x-ui failed, please be sure that your server can access GitHub ')${plain}"
            exit 1
        fi
        if [[ ! -s ${xui_folder}-linux-$(arch).tar.gz ]]; then
            rm ${xui_folder}-linux-$(arch).tar.gz -f
            echo -e "${red}$(xui_tr 'Downloaded d3x-ui release archive is empty')${plain}"
            exit 1
        fi
        verify_release_checksum "https://github.com/mekkhalawang/d3x-ui/releases/download/${tag_version}/d3x-ui-linux-$(arch).tar.gz" "${xui_folder}-linux-$(arch).tar.gz"
    else
        tag_version=$1
        # The rolling dev channel ships under a fixed, non-semver tag that is
        # force-moved to the latest main commit on every push. Accept `dev` as a
        # convenient alias and skip the numeric floor check for it.
        if [[ "$tag_version" == "dev" || "$tag_version" == "dev-latest" ]]; then
            tag_version="dev-latest"
            echo -e "${yellow}$(xui_tr 'Installing the rolling dev build (tag: dev-latest). This is a per-commit pre-release, not a stable version.')${plain}"
        else
            tag_version_numeric=${tag_version#v}
            # The floor applies to the upstream line, which this fork tracks
            # with a 3.11.0-dX.Y suffix. D3X-UI's own 1.x line is a separate
            # release train that starts below the upstream number, so it is
            # exempt: the floor exists to reject an archive that predates the
            # d3x-ui.sh / service files the installer relies on, and the 1.x
            # releases ship all of them.
            if [[ "$tag_version_numeric" != 1.* ]] && ! version_at_least "$tag_version_numeric" "2.3.5"; then
                echo -e "${red}$(xui_tr 'Please use a newer version (at least v2.3.5). Exiting installation.')${plain}"
                exit 1
            fi
        fi

        url="https://github.com/mekkhalawang/d3x-ui/releases/download/${tag_version}/d3x-ui-linux-$(arch).tar.gz"
        echo -e "$(xui_tr 'Beginning to install d3x-ui ' "${tag_version}")"
        curl -fLR --retry 5 --retry-delay 3 --connect-timeout 15 --speed-limit 1 --speed-time 300 -o ${xui_folder}-linux-$(arch).tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}$(xui_tr 'Download d3x-ui %s failed, please check if the version exists ' "${tag_version}")${plain}"
            exit 1
        fi
        if [[ ! -s ${xui_folder}-linux-$(arch).tar.gz ]]; then
            rm ${xui_folder}-linux-$(arch).tar.gz -f
            echo -e "${red}$(xui_tr 'Downloaded d3x-ui release archive is empty')${plain}"
            exit 1
        fi
        verify_release_checksum "${url}" "${xui_folder}-linux-$(arch).tar.gz"
    fi
    # d3x-ui.sh, d3x-ui.rc and the unit files must come from the same release as
    # the binary; only the rolling dev build tracks main.
    local script_ref="${tag_version}"
    if [[ "${tag_version}" == "dev-latest" ]]; then
        script_ref="main"
    fi
    # The unit files are only fetched when the release tarball lacks them, so
    # they are checked at that point instead of here.
    local required_files=("d3x-ui.sh")
    [[ $release == "alpine" ]] && required_files+=("d3x-ui.rc")
    require_repo_files "${script_ref}" "${required_files[@]}"
    local xui_script_temp="/usr/bin/d3x-ui-temp.$$"
    rm -f "${xui_script_temp}"
    curl -fLRo "${xui_script_temp}" "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/${script_ref}/d3x-ui.sh"
    if [[ $? -ne 0 ]]; then
        rm -f "${xui_script_temp}"
        echo -e "${red}$(xui_tr 'Failed to download d3x-ui.sh')${plain}"
        exit 1
    fi
    if [[ ! -s "${xui_script_temp}" ]]; then
        rm -f "${xui_script_temp}"
        echo -e "${red}$(xui_tr 'Downloaded d3x-ui.sh is empty')${plain}"
        exit 1
    fi

    # Stop d3x-ui service and remove old resources
    local custom_bin_backup=""
    if [[ -e ${xui_folder}/ ]]; then
        if [[ $release == "alpine" ]]; then
            rc-service d3x-ui stop
        else
            systemctl stop d3x-ui
        fi
        # Kill any leftover mtg (MTProto) sidecars. d3x-ui runs them outside its own
        # lifecycle, so on Linux a stale one can survive the stop and keep holding
        # an inbound port with an outdated secret, silently breaking new clients.
        # The freshly installed panel respawns a clean mtg per inbound on start.
        pkill -f 'mtg-linux-[^ ]* run ' > /dev/null 2>&1 || true
        pkill -f 'tuic-server.*-c .*bin/tuic/tuic_[0-9]+\.json' > /dev/null 2>&1 || true

        # bin/ is about to be wiped wholesale by the tar extraction below. The
        # release only ships known assets (xray/mtg binaries, the bundled
        # geoip*/geosite*.dat sets) -- anything else in bin/ was placed there
        # by the admin (e.g. a hand-added custom geoip/geosite file referenced
        # from a routing rule via "ext:<file>:<code>") and would otherwise be
        # silently deleted on every update, breaking Xray at next start with
        # "failed to open <file>: no such file or directory" for any routing
        # rule that references it. Moved aside rather than copied: a rename
        # on the same filesystem is atomic (no truncated file if disk space
        # runs out mid-copy, unlike `cp`) and keeps the snapshot under
        # /usr/local rather than a separate, possibly small/tmpfs $TMPDIR.
        if [[ -d "${xui_folder}/bin" ]]; then
            custom_bin_backup="${xui_folder%/d3x-ui}/d3x-ui-bin-backup.$$"
            rm -rf "${custom_bin_backup}"
            if ! mv "${xui_folder}/bin" "${custom_bin_backup}"; then
                custom_bin_backup=""
                echo -e "${yellow}$(xui_tr 'Could not back up bin/ -- custom files there will not be preserved across this update')${plain}"
            fi
        fi
        # Sole cleanup path for the backup from here on -- covers both the
        # two `exit 1`s below (extraction/binary-missing failures) and an
        # interrupted update (Ctrl-C, signal) before the restore runs.
        # Cleared once the restore below finishes normally.
        trap '[[ -n "${custom_bin_backup}" ]] && rm -rf "${custom_bin_backup}"' EXIT INT TERM
        rm ${xui_folder}/ -rf
    fi

    # Extract resources and set permissions
    tar zxvf d3x-ui-linux-$(arch).tar.gz
    if [[ $? -ne 0 ]]; then
        rm d3x-ui-linux-$(arch).tar.gz -f
        rm -f "${xui_script_temp}"
        echo -e "${red}$(xui_tr 'Failed to extract the d3x-ui release archive -- the previous installation has already been removed, so the panel will not start until this is fixed; try running the installer again')${plain}"
        exit 1
    fi
    rm d3x-ui-linux-$(arch).tar.gz -f

    cd d3x-ui
    if [[ $? -ne 0 || ! -s d3x-ui ]]; then
        rm -f "${xui_script_temp}"
        echo -e "${red}$(xui_tr 'Extracted d3x-ui archive is missing the d3x-ui binary -- the previous installation has already been removed, so the panel will not start until this is fixed; try running the installer again')${plain}"
        exit 1
    fi
    chmod +x d3x-ui
    chmod +x d3x-ui.sh

    # Check the system's architecture and rename the file accordingly.
    # The panel binary maps GOARCH=arm to "arm32" (internal/xray/process.go),
    # so the Xray binary must be named xray-linux-arm32; mtg keeps plain "arm".
    if [[ $(arch) == "armv5" || $(arch) == "armv6" || $(arch) == "armv7" ]]; then
        mv bin/xray-linux-$(arch) bin/xray-linux-arm32
        chmod +x bin/xray-linux-arm32
        if [[ -f bin/mtg-linux-$(arch) ]]; then
            mv bin/mtg-linux-$(arch) bin/mtg-linux-arm
            chmod +x bin/mtg-linux-arm
        fi
    fi
    chmod +x d3x-ui bin/xray-linux-$(arch)
    if [[ -f bin/mtg-linux-arm ]]; then
        chmod +x bin/mtg-linux-arm
    elif [[ -f bin/mtg-linux-$(arch) ]]; then
        chmod +x bin/mtg-linux-$(arch)
    fi

    # Restore anything from the old bin/ that the fresh release doesn't ship
    # (custom geoip/geosite files, or anything else an admin hand-placed
    # there) -- never overwrites a same-named file the new release provides,
    # so bundled assets (geoip.dat, geoip_RU.dat, ...) still get the fresh
    # per-release copy. Runs after the arch-rename above so xray-linux-arm32/
    # mtg-linux-arm already exist under their final names there and aren't
    # mistaken for custom files needing a restore. Skips paths the panel
    # itself regenerates at runtime (config.json, mtproto/*.toml -- see
    # internal/xray/process.go, internal/mtproto/manager.go): those aren't
    # admin-placed, and restoring a stale one only resurrects dead state (an
    # orphaned mtg config for a since-deleted inbound) or the wrong
    # directory permissions.
    if [[ -n "${custom_bin_backup}" ]]; then
        local restored_custom_bin=()
        while IFS= read -r -d '' f; do
            local rel="${f#"${custom_bin_backup}"/}"
            case "${rel}" in
                config.json | mtproto | mtproto/* | tuic | tuic/* | tuic-server | tuic-server-*) continue ;;
            esac
            if [[ ! -e "bin/${rel}" ]]; then
                mkdir -p "bin/$(dirname "${rel}")"
                cp -a "${f}" "bin/${rel}"
                restored_custom_bin+=("${rel}")
            fi
        done < <(find "${custom_bin_backup}" \( -type f -o -type l \) -print0)
        rm -rf "${custom_bin_backup}"
        custom_bin_backup=""
        if [[ ${#restored_custom_bin[@]} -gt 0 ]]; then
            echo -e "${green}$(xui_tr 'Restored custom file(s) in bin/ not shipped by this release: ' "${restored_custom_bin[*]}")${plain}"
        fi
    fi
    trap - EXIT INT TERM

    rm -f bin/tuic-server bin/tuic-server-* > /dev/null 2>&1 || true
    rm -rf bin/tuic > /dev/null 2>&1 || true

    # Update d3x-ui cli and se set permission
    mv -f "${xui_script_temp}" /usr/bin/d3x-ui
    if [[ $? -ne 0 ]]; then
        rm -f "${xui_script_temp}"
        echo -e "${red}$(xui_tr 'Failed to install d3x-ui.sh')${plain}"
        exit 1
    fi
    chmod +x /usr/bin/d3x-ui
    mkdir -p /var/log/d3x-ui
    config_after_install

    # Etckeeper compatibility
    if [ -d "/etc/.git" ]; then
        if [ -f "/etc/.gitignore" ]; then
            if ! grep -q "d3x-ui/d3x-ui.db" "/etc/.gitignore"; then
                echo "" >> "/etc/.gitignore"
                echo "d3x-ui/d3x-ui.db" >> "/etc/.gitignore"
                echo -e "${green}$(xui_tr 'Added d3x-ui.db to /etc/.gitignore for etckeeper')${plain}"
            fi
        else
            echo "d3x-ui/d3x-ui.db" > "/etc/.gitignore"
            echo -e "${green}$(xui_tr 'Created /etc/.gitignore and added d3x-ui.db for etckeeper')${plain}"
        fi
    fi

    if [[ $release == "alpine" ]]; then
        xui_rc_temp="/etc/init.d/d3x-ui.tmp.$$"
        rm -f "${xui_rc_temp}"
        curl -fLRo "${xui_rc_temp}" "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/${script_ref}/d3x-ui.rc"
        if [[ $? -ne 0 ]]; then
            rm -f "${xui_rc_temp}"
            echo -e "${red}$(xui_tr 'Failed to download d3x-ui.rc')${plain}"
            exit 1
        fi
        if [[ ! -s "${xui_rc_temp}" ]]; then
            rm -f "${xui_rc_temp}"
            echo -e "${red}$(xui_tr 'Downloaded d3x-ui.rc is empty')${plain}"
            exit 1
        fi
        mv -f "${xui_rc_temp}" /etc/init.d/d3x-ui
        if [[ $? -ne 0 ]]; then
            rm -f "${xui_rc_temp}"
            echo -e "${red}$(xui_tr 'Failed to install d3x-ui.rc')${plain}"
            exit 1
        fi
        chmod +x /etc/init.d/d3x-ui
        rc-update add d3x-ui
        rc-service d3x-ui start
    else
        # Install systemd service file
        service_installed=false

        if [ -f "d3x-ui.service" ]; then
            echo -e "${green}$(xui_tr 'Found d3x-ui.service in extracted files, installing...')${plain}"
            if _install_xui_service_unit "d3x-ui.service" "false"; then
                service_installed=true
            fi
        fi

        if [ "$service_installed" = false ]; then
            case "${release}" in
                ubuntu | debian | armbian)
                    if [ -f "d3x-ui.service.debian" ]; then
                        echo -e "${green}$(xui_tr 'Found d3x-ui.service.debian in extracted files, installing...')${plain}"
                        if _install_xui_service_unit "d3x-ui.service.debian" "false"; then
                            service_installed=true
                        fi
                    fi
                    ;;
                arch | manjaro | parch)
                    if [ -f "d3x-ui.service.arch" ]; then
                        echo -e "${green}$(xui_tr 'Found d3x-ui.service.arch in extracted files, installing...')${plain}"
                        if _install_xui_service_unit "d3x-ui.service.arch" "false"; then
                            service_installed=true
                        fi
                    fi
                    ;;
                *)
                    if [ -f "d3x-ui.service.rhel" ]; then
                        echo -e "${green}$(xui_tr 'Found d3x-ui.service.rhel in extracted files, installing...')${plain}"
                        if _install_xui_service_unit "d3x-ui.service.rhel" "false"; then
                            service_installed=true
                        fi
                    fi
                    ;;
            esac
        fi

        # If service file not found in tar.gz, download from GitHub
        if [ "$service_installed" = false ]; then
            echo -e "${yellow}$(xui_tr 'Service files not found in tar.gz, downloading from GitHub...')${plain}"
            case "${release}" in
                ubuntu | debian | armbian)
                    service_unit_url="https://raw.githubusercontent.com/mekkhalawang/d3x-ui/${script_ref}/d3x-ui.service.debian"
                    ;;
                arch | manjaro | parch)
                    service_unit_url="https://raw.githubusercontent.com/mekkhalawang/d3x-ui/${script_ref}/d3x-ui.service.arch"
                    ;;
                *)
                    service_unit_url="https://raw.githubusercontent.com/mekkhalawang/d3x-ui/${script_ref}/d3x-ui.service.rhel"
                    ;;
            esac

            if ! _install_xui_service_unit "$service_unit_url" "true"; then
                echo -e "${red}$(xui_tr 'Failed to install d3x-ui.service from GitHub (%s) -- the release tarball did not ship one either' "${script_ref}")${plain}"
                exit 1
            fi
            service_installed=true
        fi

        if [ "$service_installed" = true ]; then
            echo -e "${green}$(xui_tr 'Setting up systemd unit...')${plain}"
            chown root:root ${xui_service}/d3x-ui.service > /dev/null 2>&1
            chmod 644 ${xui_service}/d3x-ui.service > /dev/null 2>&1
            systemctl daemon-reload
            systemctl enable d3x-ui
            systemctl start d3x-ui
        else
            echo -e "${red}$(xui_tr 'Failed to install d3x-ui.service file')${plain}"
            exit 1
        fi
    fi

    # IP Limit relies on fail2ban; install + configure it now so the feature
    # works out of the box (no-op when XUI_ENABLE_FAIL2BAN=false). Never fatal.
    setup_fail2ban

    echo -e "$(xui_tr '%sd3x-ui %s%s installation finished, it is running now...' "${green}" "${tag_version}" "${plain}")"
    echo -e ""
    echo -e "┌───────────────────────────────────────────────────────┐
│  ${blue}d3x-ui control menu usages (subcommands):${plain}              │
│                                                       │
│  ${blue}d3x-ui${plain}              - Admin Management Script          │
│  ${blue}d3x-ui start${plain}        - Start                            │
│  ${blue}d3x-ui stop${plain}         - Stop                             │
│  ${blue}d3x-ui restart${plain}      - Restart                          │
│  ${blue}d3x-ui status${plain}       - Current Status                   │
│  ${blue}d3x-ui settings${plain}     - Current Settings                 │
│  ${blue}d3x-ui enable${plain}       - Enable Autostart on OS Startup   │
│  ${blue}d3x-ui disable${plain}      - Disable Autostart on OS Startup  │
│  ${blue}d3x-ui log${plain}          - Check logs                       │
│  ${blue}d3x-ui banlog${plain}       - Check Fail2ban ban logs          │
│  ${blue}d3x-ui update${plain}       - Update                           │
│  ${blue}d3x-ui legacy${plain}       - Legacy version                   │
│  ${blue}d3x-ui install${plain}      - Install                          │
│  ${blue}d3x-ui uninstall${plain}    - Uninstall                        │
└───────────────────────────────────────────────────────┘"
}

echo -e "${green}$(xui_tr 'Running...')${plain}"
install_base
install_d3x-ui $1
