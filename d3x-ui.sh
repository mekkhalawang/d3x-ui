#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
plain='\033[0m'

# ---------------------------------------------------------------------------
# Localization: Chinese is the default for D3X-UI; set XUI_LANG=en for the
# original English wording. Mirrors the install.sh scheme on purpose.
# ---------------------------------------------------------------------------
case "${XUI_LANG:-zh}" in
    en | en_US | en_GB | en_US.* | en_GB.* | EN | EN_* | En | En_*) XUI_LANG_RESOLVED="en" ;;
    *) XUI_LANG_RESOLVED="zh" ;;
esac

# xui_zh <english-text> echoes the Chinese wording for a known key, or the
# English text itself when the key is unknown. A case statement is used on
# purpose: an associative-array lookup misses keys that contain parentheses.
xui_zh() {
    case "$1" in
        "ERROR: You must be root to run this script! \\n") printf '%s' "错误：必须以 root 身份运行本脚本！\\n" ;;
        "%s [Default %s]:") printf '%s' "%s（默认 %s）：" ;;
        "%s [y/n]:") printf '%s' "%s（y/n）：" ;;
        "Cancelled") printf '%s' "已取消" ;;
        "Cancelled.") printf '%s' "已取消。" ;;
        "Operation canceled.") printf '%s' "操作已取消。" ;;
        "Invalid option. Please select a valid number.\\n") printf '%s' "无效选项，请输入有效的数字。\\n" ;;
        "Choose an option:") printf '%s' "请选择一项：" ;;
        "Choose [1]:") printf '%s' "请选择［1］：" ;;
        "Enter your choice (1 or 2):") printf '%s' "请输入你的选择（1 或 2）：" ;;
        "Select an option (1 or 2):") printf '%s' "请选择一项（1 或 2）：" ;;
        "Please enter your selection [0-28]:") printf '%s' "请输入你的选择［0-28］：" ;;
        "Please enter the correct number [0-28]") printf '%s' "请输入正确的数字［0-28］" ;;
        "Please enter your server's public IPv4 address:") printf '%s' "请输入服务器的公网 IPv4 地址：" ;;
        "Invalid IPv4 address. Please try again.") printf '%s' "无效的 IPv4 地址，请重试。" ;;
        "Could not auto-detect server IP from any provider.") printf '%s' "无法从任何服务商自动检测服务器 IP。" ;;
        "Invalid IP address format! Please try again.") printf '%s' "IP 地址格式无效，请重试。" ;;
        "Could not find the running panel process to signal.") printf '%s' "找不到正在运行的面板进程。" ;;
        "Update is complete, Panel has automatically restarted") printf '%s' "更新完成，面板已自动重启" ;;
        "Dev update is complete, Panel has automatically restarted") printf '%s' "Dev 更新完成，面板已自动重启" ;;
        "No d3x-ui.sh published for the installed version (%s), using main") printf '%s' "当前安装版本（%s）没有对应的 d3x-ui.sh，已使用 main" ;;
        "Updating Menu") printf '%s' "正在更新菜单" ;;
        "Update successful. The panel has automatically restarted.") printf '%s' "更新成功，面板已自动重启。" ;;
        "Failed to update the menu.") printf '%s' "菜单更新失败。" ;;
        "Uninstalled Successfully.\\n") printf '%s' "卸载成功。\\n" ;;
        "Please set the login username [default is a random username]:") printf '%s' "请设置登录用户名（默认随机生成）：" ;;
        "Please set the login password [default is a random password]:") printf '%s' "请设置登录密码（默认随机生成）：" ;;
        "Do you want to disable currently configured two-factor authentication? (y/n):") printf '%s' "是否关闭当前配置的两步验证？（y/n）：" ;;
        "Two factor authentication has been disabled.") printf '%s' "两步验证已关闭。" ;;
        "Panel login username has been reset to:  %s") printf '%s' "面板登录用户名已重置为：%s" ;;
        "Panel login password has been reset to:  %s") printf '%s' "面板登录密码已重置为：%s" ;;
        "Please use the new login username and password to access the D3X-UI panel. Also remember them!") printf '%s' "请使用新的用户名和密码登录 D3X-UI 面板，并妥善保管！" ;;
        "Resetting Web Base Path") printf '%s' "正在重置访问路径" ;;
        "Are you sure you want to reset the web base path? (y/n):") printf '%s' "确定要重置访问路径吗？（y/n）：" ;;
        "Web base path has been reset to: %s") printf '%s' "访问路径已重置为：%s" ;;
        "Please use the new web base path to access the panel.") printf '%s' "请使用新的访问路径访问面板。" ;;
        "All panel settings have been reset to default.") printf '%s' "所有面板设置已重置为默认值。" ;;
        "get current settings error, please check logs") printf '%s' "读取当前设置失败，请查看日志" ;;
        "Database: PostgreSQL — %s") printf '%s' "数据库：PostgreSQL — %s" ;;
        "Database: SQLite (/etc/d3x-ui/d3x-ui.db)") printf '%s' "数据库：SQLite（/etc/d3x-ui/d3x-ui.db）" ;;
        "Panel installed, Please do not reinstall") printf '%s' "面板已安装，请勿重复安装" ;;
        "Please install the panel first") printf '%s' "请先安装面板" ;;
        "d3x-ui is not installed.") printf '%s' "d3x-ui 尚未安装。" ;;
        "Upgrade script succeeded, Please rerun the script") printf '%s' "脚本升级成功，请重新运行脚本" ;;
        "Failed to download script, Please check whether the machine can connect Github") printf '%s' "脚本下载失败，请检查机器能否连接 GitHub" ;;
        "Access URL: https://%s:%s%s") printf '%s' "访问地址：https://%s:%s%s" ;;
        "Access URL: http://%s:%s%s") printf '%s' "访问地址：http://%s:%s%s" ;;
        "The certificate also covers: %s") printf '%s' "证书还覆盖：%s" ;;
        "⚠ WARNING: No SSL certificate configured!") printf '%s' "⚠ 警告：尚未配置 SSL 证书！" ;;
        "You can get a Let's Encrypt certificate for your IP address (valid ~6 days, auto-renews).") printf '%s' "可以为服务器 IP 申请 Let's Encrypt 证书（有效期约 6 天，自动续期）。" ;;
        "Generate SSL certificate for IP now? [y/N]:") printf '%s' "现在为 IP 生成 SSL 证书吗？［y/N］：" ;;
        "IP certificate setup failed.") printf '%s' "IP 证书配置失败。" ;;
        "You can try again via main menu option 20 (SSL Certificate Management).") printf '%s' "可稍后通过主菜单选项 20（SSL 证书管理）重试。" ;;
        "For security, please configure SSL certificate using main menu option 20 (SSL Certificate Management)") printf '%s' "出于安全考虑，请通过主菜单选项 20（SSL 证书管理）配置 SSL 证书" ;;
        "The port is set, Please restart the panel now, and use the new port %s to access web panel") printf '%s' "端口已设置，请立即重启面板，并使用新端口 %s 访问" ;;
        "Panel is secure with SSL.") printf '%s' "面板已启用 SSL，安全状态正常。" ;;
        "\\nWarning: No Cert and Key found! The panel is not secure.") printf '%s' "\\n警告：未找到证书和私钥！面板当前不安全。" ;;
        "Panel is running, No need to start again, If you need to restart, please select restart") printf '%s' "面板正在运行，无需重复启动；如需重启请选择「重启」" ;;
        "Panel process is not running inside this container.") printf '%s' "容器内没有运行中的面板进程。" ;;
        "In Docker the panel is the container's main process. Restart the container to bring it back up:") printf '%s' "在 Docker 中面板是容器主进程，请重启容器以恢复：" ;;
        "d3x-ui Started Successfully") printf '%s' "d3x-ui 启动成功" ;;
        "panel Failed to start, Probably because it takes longer than two seconds to start, Please check the log information later") printf '%s' "面板启动失败，可能是启动耗时超过两秒，请稍后查看日志" ;;
        "Panel stopped, No need to stop again!") printf '%s' "面板已停止，无需重复停止！" ;;
        "In Docker the panel runs as the container's main process.") printf '%s' "在 Docker 中面板以容器主进程运行。" ;;
        "To stop it, stop the container from the host:") printf '%s' "要停止它，请在宿主机上停止容器：" ;;
        "d3x-ui and xray stopped successfully") printf '%s' "d3x-ui 和 xray 已停止" ;;
        "Panel stop failed, Probably because the stop time exceeds two seconds, Please check the log information later") printf '%s' "面板停止失败，可能是停止耗时超过两秒，请稍后查看日志" ;;
        "Restart signal sent to the panel and xray-core.") printf '%s' "已向面板和 xray-core 发送重启信号。" ;;
        "d3x-ui and xray Restarted successfully") printf '%s' "d3x-ui 和 xray 重启成功" ;;
        "Panel restart failed, Please check the log information later") printf '%s' "面板重启失败，请稍后查看日志" ;;
        "Panel restart failed, Probably because it takes longer than two seconds to start, Please check the log information later") printf '%s' "面板重启失败，可能是启动耗时超过两秒，请稍后查看日志" ;;
        "xray-core Restart signal sent successfully, Please check the log information to confirm whether xray restarted successfully") printf '%s' "已发送 xray-core 重启信号，请查看日志确认是否重启成功" ;;
        "Panel state: Running") printf '%s' "面板状态：运行中" ;;
        "Panel state: Not Running") printf '%s' "面板状态：未运行" ;;
        "Panel state: Not Installed") printf '%s' "面板状态：未安装" ;;
        "Start automatically: Managed by Docker") printf '%s' "开机自启：由 Docker 管理" ;;
        "Start automatically: Yes") printf '%s' "开机自启：是" ;;
        "Start automatically: No") printf '%s' "开机自启：否" ;;
        "xray state: Running") printf '%s' "xray 状态：运行中" ;;
        "xray state: Not Running") printf '%s' "xray 状态：未运行" ;;
        "mtproto inbound %s (%s): Running") printf '%s' "mtproto 入站 %s（%s）：运行中" ;;
        "mtproto inbound %s (%s): Not Running") printf '%s' "mtproto 入站 %s（%s）：未运行" ;;
        "Autostart is controlled by the Docker restart policy (e.g. 'restart: unless-stopped' in docker-compose.yml).") printf '%s' "开机自启由 Docker 重启策略控制（如 docker-compose.yml 中的 'restart: unless-stopped'）。" ;;
        "There is no service to enable inside the container.") printf '%s' "容器内没有可启用的系统服务。" ;;
        "d3x-ui Set to boot automatically on startup successfully") printf '%s' "d3x-ui 已设置开机自启" ;;
        "d3x-ui Failed to set Autostart") printf '%s' "d3x-ui 设置开机自启失败" ;;
        "Set 'restart: no' for the container on the host to disable autostart.") printf '%s' "请在宿主机上为容器设置 'restart: no' 以关闭自启。" ;;
        "d3x-ui Autostart Cancelled successfully") printf '%s' "d3x-ui 已取消开机自启" ;;
        "d3x-ui Failed to cancel autostart") printf '%s' "d3x-ui 取消开机自启失败" ;;
        "\\t1. Debug Log") printf '%s' "\\t1. 调试日志" ;;
        "\\t2. Clear All logs") printf '%s' "\\t2. 清空全部日志" ;;
        "\\t0. Back to Main Menu") printf '%s' "\\t0. 返回主菜单" ;;
        "\\t1. Enable BBR") printf '%s' "\\t1. 启用 BBR" ;;
        "\\t2. Disable BBR") printf '%s' "\\t2. 关闭 BBR" ;;
        "BBR is not currently enabled.") printf '%s' "BBR 当前未启用。" ;;
        "BBR has been replaced with CUBIC successfully.") printf '%s' "BBR 已成功替换为 CUBIC。" ;;
        "Failed to replace BBR with CUBIC. Please check your system configuration.") printf '%s' "BBR 替换为 CUBIC 失败，请检查系统配置。" ;;
        "BBR is already enabled!") printf '%s' "BBR 已经启用！" ;;
        "BBR has been enabled successfully.") printf '%s' "BBR 启用成功。" ;;
        "Failed to enable BBR. Please check your system configuration.") printf '%s' "BBR 启用失败，请检查系统配置。" ;;
        "\\t1. Install Firewall") printf '%s' "\\t1. 安装防火墙" ;;
        "\\t2. Port List [numbered]") printf '%s' "\\t2. 端口列表［编号］" ;;
        "\\t3. Open Ports") printf '%s' "\\t3. 开放端口" ;;
        "\\t4. Delete Ports from List") printf '%s' "\\t4. 从列表删除端口" ;;
        "\\t5. Enable Firewall") printf '%s' "\\t5. 启用防火墙" ;;
        "\\t6. Disable Firewall") printf '%s' "\\t6. 关闭防火墙" ;;
        "\\t7. Firewall Status") printf '%s' "\\t7. 防火墙状态" ;;
        "Enter the ports you want to open (e.g. 80,443,2053 or range 400-500):") printf '%s' "请输入要开放的端口（如 80,443,2053 或区间 400-500）：" ;;
        "Enter the rule numbers you want to delete (1, 2, etc.):") printf '%s' "请输入要删除的规则编号（1、2 等）：" ;;
        "Enter the ports you want to delete (e.g. 80,443,2053 or range 400-500):") printf '%s' "请输入要删除的端口（如 80,443,2053 或区间 400-500）：" ;;
        "update_geofiles: unknown dataset '%s'") printf '%s' "update_geofiles：未知数据集 '%s'" ;;
        "%s.dat: download failed") printf '%s' "%s.dat：下载失败" ;;
        "%s.dat: already up to date") printf '%s' "%s.dat：已是最新" ;;
        "%s.dat: downloaded file is empty") printf '%s' "%s.dat：下载的文件为空" ;;
        "%s.dat: failed to install") printf '%s' "%s.dat：安装失败" ;;
        "%s.dat: updated") printf '%s' "%s.dat：已更新" ;;
        "Some %s could not be updated. Check the errors above.") printf '%s' "部分 %s 更新失败，请查看上方错误信息。" ;;
        "%s have been updated successfully!") printf '%s' "%s 更新成功！" ;;
        "%s are already up to date, restart is not needed.") printf '%s' "%s 已是最新，无需重启。" ;;
        "\\t1. Loyalsoldier (geoip.dat, geosite.dat)") printf '%s' "\\t1. Loyalsoldier（geoip.dat、geosite.dat）" ;;
        "\\t2. chocolate4u (geoip_IR.dat, geosite_IR.dat)") printf '%s' "\\t2. chocolate4u（geoip_IR.dat、geosite_IR.dat）" ;;
        "\\t3. runetfreedom (geoip_RU.dat, geosite_RU.dat)") printf '%s' "\\t3. runetfreedom（geoip_RU.dat、geosite_RU.dat）" ;;
        "\\t4. All") printf '%s' "\\t4. 全部" ;;
        "acme.sh is already installed.") printf '%s' "acme.sh 已安装。" ;;
        "Installing acme.sh...") printf '%s' "正在安装 acme.sh……" ;;
        "Installation of acme.sh failed.") printf '%s' "acme.sh 安装失败。" ;;
        "Installation of acme.sh succeeded.") printf '%s' "acme.sh 安装成功。" ;;
        "acme.sh not found, installing...") printf '%s' "未找到 acme.sh，正在安装……" ;;
        "Failed to install acme.sh") printf '%s' "acme.sh 安装失败" ;;
        "install acme failed, please check logs") printf '%s' "acme 安装失败，请查看日志" ;;
        "Install acme failed, please check logs.") printf '%s' "acme 安装失败，请查看日志。" ;;
        "install socat failed, please check logs") printf '%s' "socat 安装失败，请查看日志" ;;
        "install socat succeed...") printf '%s' "socat 安装成功……" ;;
        "\\t1. Get SSL (Domain)") printf '%s' "\\t1. 申请 SSL（域名）" ;;
        "\\t2. Revoke & Remove") printf '%s' "\\t2. 吊销并删除" ;;
        "\\t3. Force Renew") printf '%s' "\\t3. 强制续期" ;;
        "\\t4. Show Existing Domains") printf '%s' "\\t4. 查看已有域名" ;;
        "\\t5. Set Cert paths for the panel") printf '%s' "\\t5. 为面板设置证书路径" ;;
        "\\t6. Get SSL for IP Address (6-day cert, auto-renews)") printf '%s' "\\t6. 为 IP 申请 SSL（6 天证书，自动续期）" ;;
        "Please enter a domain from the list to revoke and remove the certificate:") printf '%s' "请从列表中输入要吊销并删除证书的域名：" ;;
        "Certificate revoked and removed for domain: %s") printf '%s' "已吊销并删除域名证书：%s" ;;
        "Cleared panel certificate paths referencing %s; restarting panel.") printf '%s' "已清除引用 %s 的面板证书路径，正在重启面板。" ;;
        "Please enter a domain from the list to renew the SSL certificate:") printf '%s' "请从列表中输入要续期 SSL 证书的域名：" ;;
        "Certificate forcefully renewed for domain: %s") printf '%s' "已强制续期域名证书：%s" ;;
        "Domain: %s") printf '%s' "域名：%s" ;;
        "\\tCertificate Path: %s") printf '%s' "\\t证书路径：%s" ;;
        "\\tPrivate Key Path: %s") printf '%s' "\\t私钥路径：%s" ;;
        "Domain: %s - Certificate or Key missing.") printf '%s' "域名：%s —— 证书或私钥缺失。" ;;
        "Panel certificate (custom path): %s") printf '%s' "面板证书（自定义路径）：%s" ;;
        "\\tCovers: %s") printf '%s' "\\t覆盖范围：%s" ;;
        "\\t1. Use a certificate from /root/cert") printf '%s' "\\t1. 使用 /root/cert 中的证书" ;;
        "\\t2. Enter custom certificate file paths (e.g. certbot, /etc/letsencrypt/...)") printf '%s' "\\t2. 手动输入证书文件路径（如 certbot、/etc/letsencrypt/……）" ;;
        "Certificate file path (fullchain):") printf '%s' "证书文件路径（fullchain）：" ;;
        "Private key file path:") printf '%s' "私钥文件路径：" ;;
        "Please choose a domain to set the panel paths:") printf '%s' "请选择一个域名来设置面板路径：" ;;
        "Please enter your domain name:") printf '%s' "请输入你的域名：" ;;
        "Domain name cannot be empty. Please try again.") printf '%s' "域名不能为空，请重试。" ;;
        "Invalid domain format: %s. Please enter a valid domain name.") printf '%s' "域名格式无效：%s，请输入有效的域名。" ;;
        "Your domain is: %s, checking it...") printf '%s' "你的域名是：%s，正在检查……" ;;
        "Existing certificate found for %s, will reuse it.") printf '%s' "发现 %s 的已有证书，将直接复用。" ;;
        "Your domain is ready for issuing certificates now...") printf '%s' "你的域名现在可以签发证书了……" ;;
        "Issuing certificate failed, please check logs.") printf '%s' "证书签发失败，请查看日志。" ;;
        "Issuing certificate succeeded, installing certificates...") printf '%s' "证书签发成功，正在安装证书……" ;;
        "Using existing certificate, installing certificates...") printf '%s' "使用已有证书，正在安装证书……" ;;
        "Default --reloadcmd for ACME is: d3x-ui restart") printf '%s' "ACME 默认的 --reloadcmd 为：d3x-ui restart" ;;
        "This command will run on every certificate issue and renew.") printf '%s' "该命令会在每次签发和续期证书时执行。" ;;
        "Would you like to modify --reloadcmd for ACME? (y/n):") printf '%s' "是否修改 ACME 的 --reloadcmd？（y/n）：" ;;
        "\\n\\t1. Preset: systemctl reload nginx ; d3x-ui restart") printf '%s' "\\n\\t1. 预设：systemctl reload nginx ; d3x-ui restart" ;;
        "\\t2. Input your own command") printf '%s' "\\t2. 输入你自己的命令" ;;
        "\\t0. Keep default reloadcmd") printf '%s' "\\t0. 保持默认 reloadcmd" ;;
        "Reloadcmd is: systemctl reload nginx ; d3x-ui restart") printf '%s' "reloadcmd 为：systemctl reload nginx ; d3x-ui restart" ;;
        "It's recommended to put d3x-ui restart at the end, so it won't raise an error if other services fails") printf '%s' "建议把 d3x-ui restart 放在最后，这样其他服务失败时不会报错" ;;
        "Please enter your reloadcmd (example: systemctl reload nginx ; d3x-ui restart):") printf '%s' "请输入你的 reloadcmd（示例：systemctl reload nginx ; d3x-ui restart）：" ;;
        "Your reloadcmd is: %s") printf '%s' "你的 reloadcmd 为：%s" ;;
        "Keep default reloadcmd") printf '%s' "保持默认 reloadcmd" ;;
        "Installing certificate succeeded, enabling auto renew...") printf '%s' "证书安装成功，正在开启自动续期……" ;;
        "Installing certificate failed, exiting.") printf '%s' "证书安装失败，即将退出。" ;;
        "Auto renew failed, certificate details:") printf '%s' "自动续期失败，证书详情：" ;;
        "Auto renew succeeded, certificate details:") printf '%s' "自动续期成功，证书详情：" ;;
        "Panel paths set for domain: %s") printf '%s' "面板路径已设置为域名：%s" ;;
        "Panel paths set for IP: %s") printf '%s' "面板路径已设置为 IP：%s" ;;
        "- Certificate File: %s") printf '%s' "- 证书文件：%s" ;;
        "- Private Key File: %s") printf '%s' "- 私钥文件：%s" ;;
        "- Validity: ~6 days (auto-renews via acme.sh cron)") printf '%s' "- 有效期：约 6 天（通过 acme.sh 计划任务自动续期）" ;;
        "Panel will restart to apply SSL certificate...") printf '%s' "面板将重启以应用 SSL 证书……" ;;
        "Error: Certificate or private key file not found for domain: %s.") printf '%s' "错误：找不到域名 %s 的证书或私钥文件。" ;;
        "Error: Certificate or private key file not found for IP: %s.") printf '%s' "错误：找不到 IP %s 的证书或私钥文件。" ;;
        "Skipping panel path setting.") printf '%s' "已跳过面板路径设置。" ;;
        "Certificate files not found after installation") printf '%s' "安装后未找到证书文件" ;;
        "Certificate files installed successfully") printf '%s' "证书文件安装成功" ;;
        "Would you like to set this certificate for the panel? (y/n):") printf '%s' "是否将该证书设置给面板使用？（y/n）：" ;;
        "Let's Encrypt SSL Certificate for IP Address") printf '%s' "Let's Encrypt IP 地址 SSL 证书" ;;
        "This will obtain a certificate for your server's IP using the shortlived profile.") printf '%s' "将使用 shortlived 配置为服务器 IP 签发证书。" ;;
        "Certificate valid for ~6 days, auto-renews via acme.sh cron job.") printf '%s' "证书有效期约 6 天，通过 acme.sh 计划任务自动续期。" ;;
        "Port 80 must be open and accessible from the internet.") printf '%s' "80 端口必须开放且可从公网访问。" ;;
        "Starting automatic SSL certificate generation for server IP...") printf '%s' "正在为服务器 IP 自动生成 SSL 证书……" ;;
        "Using Let's Encrypt shortlived profile (~6 days validity, auto-renews)") printf '%s' "使用 Let's Encrypt shortlived 配置（约 6 天有效期，自动续期）" ;;
        "Server IP detected: %s") printf '%s' "检测到服务器 IP：%s" ;;
        "Issuing certificate for server IP: %s") printf '%s' "正在为服务器 IP 签发证书：%s" ;;
        "Do you have an IPv6 address to include? (leave empty to skip):") printf '%s' "是否有 IPv6 地址需要一并加入？（留空跳过）：" ;;
        "Including IPv6 address: %s") printf '%s' "包含 IPv6 地址：%s" ;;
        "Port to use for ACME HTTP-01 listener (default 80):") printf '%s' "ACME HTTP-01 监听端口（默认 80）：" ;;
        "Invalid port provided. Falling back to 80.") printf '%s' "端口无效，已回退为 80。" ;;
        "Invalid port provided.") printf '%s' "端口无效。" ;;
        "Using port %s to issue certificate for IP: %s") printf '%s' "使用端口 %s 为 IP 签发证书：%s" ;;
        "Reminder: Let's Encrypt still reaches port 80; forward external port 80 to %s for validation.") printf '%s' "提醒：Let's Encrypt 仍然访问 80 端口；请把外网 80 端口转发到 %s 以完成验证。" ;;
        "Port %s is currently in use.") printf '%s' "端口 %s 当前被占用。" ;;
        "Enter another port for acme.sh standalone listener (leave empty to abort):") printf '%s' "请输入 acme.sh 独立监听的另一个端口（留空中止）：" ;;
        "Port %s is busy; cannot proceed with issuance.") printf '%s' "端口 %s 被占用，无法继续签发。" ;;
        "Port %s is free and ready for standalone validation.") printf '%s' "端口 %s 空闲，可以进行独立验证。" ;;
        "Failed to issue certificate for IP: %s") printf '%s' "IP 证书签发失败：%s" ;;
        "Make sure port %s is open and the server is accessible from the internet") printf '%s' "请确保端口 %s 开放，且服务器可从公网访问" ;;
        "Certificate issued successfully for IP: %s") printf '%s' "IP 证书签发成功：%s" ;;
        "****** Instructions for Use ******") printf '%s' "****** 使用说明 ******" ;;
        "Follow the steps below to complete the process:") printf '%s' "按以下步骤完成操作：" ;;
        "1. A Cloudflare API Token (recommended, scoped to Zone:DNS:Edit) or the Global API Key + registered email.") printf '%s' "1. Cloudflare API Token（推荐，权限限定为 Zone:DNS:Edit）或 Global API Key + 注册邮箱。" ;;
        "2. The Domain Name.") printf '%s' "2. 域名。" ;;
        "3. Once the certificate is issued, you will be prompted to set the certificate for the panel (optional).") printf '%s' "3. 证书签发后，会提示是否设置给面板使用（可选）。" ;;
        "4. The script also supports automatic renewal of the SSL certificate after installation.") printf '%s' "4. 脚本还支持安装后的 SSL 证书自动续期。" ;;
        "Please set a domain name:") printf '%s' "请设置域名：" ;;
        "Input your domain here:") printf '%s' "在此输入你的域名：" ;;
        "Your domain name is set to: %s") printf '%s' "你的域名已设置为：%s" ;;
        "Are you using a Cloudflare API Token or Global API Key? (t/g) [Default t]:") printf '%s' "你使用的是 Cloudflare API Token 还是 Global API Key？（t/g）［默认 t］：" ;;
        "Please set the Global API Key:") printf '%s' "请设置 Global API Key：" ;;
        "Input your key here:") printf '%s' "在此输入你的 Key：" ;;
        "Please set up the registered email:") printf '%s' "请设置注册邮箱：" ;;
        "Input your email here:") printf '%s' "在此输入你的邮箱：" ;;
        "Please set the API Token:") printf '%s' "请设置 API Token：" ;;
        "Input your token here:") printf '%s' "在此输入你的 Token：" ;;
        "Default CA, Let'sEncrypt fail, script exiting...") printf '%s' "默认 CA（Let's Encrypt）签发失败，脚本退出……" ;;
        "Certificate issuance failed, script exiting...") printf '%s' "证书签发失败，脚本退出……" ;;
        "Certificate issued successfully, Installing...") printf '%s' "证书签发成功，正在安装……" ;;
        "Failed to create directory: %s") printf '%s' "目录创建失败：%s" ;;
        "Certificate installation failed, script exiting...") printf '%s' "证书安装失败，脚本退出……" ;;
        "Certificate installed successfully, Turning on automatic updates...") printf '%s' "证书安装成功，正在开启自动更新……" ;;
        "Auto update setup failed, script exiting...") printf '%s' "自动更新设置失败，脚本退出……" ;;
        "The certificate is installed and auto-renewal is turned on. Specific information is as follows:") printf '%s' "证书已安装并开启自动续期，详细信息如下：" ;;
        "\\n\\t1. Install Fail2ban and configure IP Limit") printf '%s' "\\n\\t1. 安装 Fail2ban 并配置 IP 限制" ;;
        "\\t2. Change Ban Duration") printf '%s' "\\t2. 修改封禁时长" ;;
        "\\t3. Unban Everyone") printf '%s' "\\t3. 解封所有人" ;;
        "\\t4. Ban Logs") printf '%s' "\\t4. 封禁日志" ;;
        "\\t5. Ban an IP Address") printf '%s' "\\t5. 封禁指定 IP" ;;
        "\\t6. Unban an IP Address") printf '%s' "\\t6. 解封指定 IP" ;;
        "\\t7. Real-Time Logs") printf '%s' "\\t7. 实时日志" ;;
        "\\t8. Service Status") printf '%s' "\\t8. 服务状态" ;;
        "\\t9. Service Restart") printf '%s' "\\t9. 重启服务" ;;
        "\\t10. Uninstall Fail2ban and IP Limit") printf '%s' "\\t10. 卸载 Fail2ban 与 IP 限制" ;;
        "\\t1. Only remove IP Limit configurations") printf '%s' "\\t1. 仅移除 IP 限制配置" ;;
        "\\t2. Uninstall Fail2ban and IP Limit") printf '%s' "\\t2. 卸载 Fail2ban 与 IP 限制" ;;
        "Please enter new Ban Duration in Minutes [default 30]:") printf '%s' "请输入新的封禁时长（分钟）［默认 30］：" ;;
        "%s is not a number! Please, try again.") printf '%s' "%s 不是数字，请重试。" ;;
        "All users Unbanned successfully.") printf '%s' "已成功解封所有用户。" ;;
        "Enter the IP address you want to ban:") printf '%s' "请输入要封禁的 IP 地址：" ;;
        "IP Address %s has been banned successfully.") printf '%s' "IP 地址 %s 已封禁成功。" ;;
        "Enter the IP address you want to unban:") printf '%s' "请输入要解封的 IP 地址：" ;;
        "IP Address %s has been unbanned successfully.") printf '%s' "IP 地址 %s 已解封成功。" ;;
        "XUI_ENABLE_FAIL2BAN=%s, skipping Fail2ban setup.\\n") printf '%s' "XUI_ENABLE_FAIL2BAN=%s，跳过 Fail2ban 配置。\\n" ;;
        "Fail2ban is not installed. Installing now...!\\n") printf '%s' "Fail2ban 未安装，正在安装……！\\n" ;;
        "Could not enable the EPEL repository; fail2ban is only available from EPEL on this distro.") printf '%s' "无法启用 EPEL 源；该发行版的 fail2ban 仅在 EPEL 中提供。" ;;
        "Unsupported operating system. Please check the script and install the necessary packages manually.\\n") printf '%s' "不支持的操作系统，请检查脚本并手动安装所需软件包。\\n" ;;
        "Unsupported operating system. Please uninstall Fail2ban manually.\\n") printf '%s' "不支持的操作系统，请手动卸载 Fail2ban。\\n" ;;
        "Fail2ban installation failed.\\n") printf '%s' "Fail2ban 安装失败。\\n" ;;
        "Fail2ban installed successfully!\\n") printf '%s' "Fail2ban 安装成功！\\n" ;;
        "Fail2ban is already installed.\\n") printf '%s' "Fail2ban 已安装。\\n" ;;
        "Configuring IP Limit...\\n") printf '%s' "正在配置 IP 限制……\\n" ;;
        "IP Limit installed and configured successfully!\\n") printf '%s' "IP 限制安装并配置成功！\\n" ;;
        "IP Limit removed successfully!\\n") printf '%s' "IP 限制已移除！\\n" ;;
        "Fail2ban and IP Limit removed successfully!\\n") printf '%s' "Fail2ban 与 IP 限制已移除！\\n" ;;
        "Checking ban logs...\\n") printf '%s' "正在检查封禁日志……\\n" ;;
        "Fail2ban service is not running!\\n") printf '%s' "Fail2ban 服务未运行！\\n" ;;
        "Recent system ban activities from fail2ban.log:") printf '%s' "fail2ban.log 中最近的封禁活动：" ;;
        "No recent system ban activities found") printf '%s' "未发现最近的封禁活动" ;;
        "3X-IPL ban log entries:") printf '%s' "3X-IPL 封禁日志记录：" ;;
        "No ban entries found") printf '%s' "未发现封禁记录" ;;
        "Ban log file is empty") printf '%s' "封禁日志文件为空" ;;
        "Ban log file not found at: %s") printf '%s' "找不到封禁日志文件：%s" ;;
        "\\nCurrent jail status:") printf '%s' "\\n当前 jail 状态：" ;;
        "Unable to get jail status") printf '%s' "无法获取 jail 状态" ;;
        "Ip Limit jail files created with a bantime of %s minutes.") printf '%s' "IP 限制 jail 文件已创建，封禁时长 %s 分钟。" ;;
        "Removing conflicts of [3x-ipl] in jail (%s)!\\n") printf '%s' "正在清除 jail（%s）中 [3x-ipl] 的冲突项！\\n" ;;
        "\\nCurrent SSH Port Forwarding Configuration:") printf '%s' "\\n当前 SSH 端口转发配置：" ;;
        "Standard SSH command:") printf '%s' "标准 SSH 命令：" ;;
        "\\nIf using SSH key:") printf '%s' "\\n如使用 SSH 密钥：" ;;
        "\\nAfter connecting, access the panel at:") printf '%s' "\\n连接后通过以下地址访问面板：" ;;
        "\\nChoose an option:") printf '%s' "\\n请选择一项：" ;;
        "1. Set listen IP") printf '%s' "1. 设置监听 IP" ;;
        "2. Clear listen IP") printf '%s' "2. 清除监听 IP" ;;
        "\\nNo listenIP configured. Choose an option:") printf '%s' "\\n尚未配置监听 IP，请选择：" ;;
        "1. Use default IP (127.0.0.1)") printf '%s' "1. 使用默认 IP（127.0.0.1）" ;;
        "2. Set a custom IP") printf '%s' "2. 设置自定义 IP" ;;
        "Enter custom IP to listen on:") printf '%s' "请输入要监听的自定义 IP：" ;;
        "listen IP has been set to %s.") printf '%s' "监听 IP 已设置为 %s。" ;;
        "\\nSSH Port Forwarding Configuration:") printf '%s' "\\nSSH 端口转发配置：" ;;
        "Current listen IP is already set to %s.") printf '%s' "当前监听 IP 已是 %s。" ;;
        "Listen IP has been cleared.") printf '%s' "监听 IP 已清除。" ;;
        "PostgreSQL does not appear to be installed on this system.") printf '%s' "系统上似乎未安装 PostgreSQL。" ;;
        "PostgreSQL is listening on port 5432:") printf '%s' "PostgreSQL 正在监听 5432 端口：" ;;
        "Nothing is listening on port 5432 - the database is not running.") printf '%s' "5432 端口无监听——数据库未在运行。" ;;
        "PostgreSQL stop signal sent.") printf '%s' "已发送 PostgreSQL 停止信号。" ;;
        "PostgreSQL set to start automatically on boot.") printf '%s' "PostgreSQL 已设置开机自启。" ;;
        "Failed to enable PostgreSQL autostart.") printf '%s' "PostgreSQL 开机自启设置失败。" ;;
        "No PostgreSQL log found.") printf '%s' "未找到 PostgreSQL 日志。" ;;
        "PostgreSQL is not installed. Use option 1 (Install PostgreSQL) in this menu first.") printf '%s' "PostgreSQL 未安装，请先使用本菜单选项 1（安装 PostgreSQL）。" ;;
        "This panel was using PostgreSQL.") printf '%s' "该面板此前使用 PostgreSQL。" ;;
        "WARNING: purging removes the PostgreSQL server and ALL of its databases on") printf '%s' "警告：清除操作会删除 PostgreSQL 服务器及这台机器上的全部数据库，" ;;
        "this machine, including any used by other applications. This cannot be undone.") printf '%s' "包括其他应用正在使用的数据库。此操作不可恢复。" ;;
        "Left PostgreSQL installed; its data was not removed.") printf '%s' "已保留 PostgreSQL 安装，数据未删除。" ;;
        "Unsupported distro for automatic PostgreSQL purge: %s. Remove it manually.") printf '%s' "不支持的发行版，无法自动清除 PostgreSQL：%s，请手动删除。" ;;
        "PostgreSQL has been purged.") printf '%s' "PostgreSQL 已清除。" ;;
        "PostgreSQL %s is not available for this system; installing the distribution's PostgreSQL instead.") printf '%s' "系统没有 PostgreSQL %s，改为安装发行版自带的 PostgreSQL。" ;;
        "Unsupported distro for automatic PostgreSQL install: %s") printf '%s' "不支持的发行版，无法自动安装 PostgreSQL：%s" ;;
        "Warning: could not update pg_hba.conf; PostgreSQL may reject the panel's TCP login (ident auth).") printf '%s' "警告：未能更新 pg_hba.conf；PostgreSQL 可能拒绝面板的 TCP 登录（ident 认证）。" ;;
        "Installing PostgreSQL client tools (pg_dump/pg_restore)...") printf '%s' "正在安装 PostgreSQL 客户端工具（pg_dump/pg_restore）……" ;;
        "Invalid PostgreSQL major version '%s' (expected a number like 17).") printf '%s' "PostgreSQL 主版本号 '%s' 无效（应为类似 17 的数字）。" ;;
        "PostgreSQL client tools are already installed (version %s).") printf '%s' "PostgreSQL 客户端工具已安装（版本 %s）。" ;;
        "Installed PostgreSQL client tools are version %s; version %s or newer is required.") printf '%s' "已安装的 PostgreSQL 客户端工具版本为 %s；需要 %s 或更新版本。" ;;
        "Note: packages installed inside the container are lost when the container is recreated.") printf '%s' "注意：容器内安装的软件包在容器重建后会丢失。" ;;
        "postgresql-client-%s is not in the distribution repositories; adding the official PostgreSQL apt repository...") printf '%s' "发行版仓库中没有 postgresql-client-%s；正在添加官方 PostgreSQL apt 源……" ;;
        "Could not determine the Enterprise Linux release; install the PostgreSQL %s client tools manually.") printf '%s' "无法确定 Enterprise Linux 版本；请手动安装 PostgreSQL %s 客户端工具。" ;;
        "postgresql%s is not in the enabled repositories; adding the official PostgreSQL yum repository...") printf '%s' "启用的仓库中没有 postgresql%s；正在添加官方 PostgreSQL yum 源……" ;;
        "Unsupported OS '%s'; install the PostgreSQL client tools manually.") printf '%s' "不支持的操作系统 '%s'；请手动安装 PostgreSQL 客户端工具。" ;;
        "pg_dump/pg_restore are still unavailable after installation.") printf '%s' "安装后仍无法使用 pg_dump/pg_restore。" ;;
        "PostgreSQL client tools are version %s after installation but %s or newer is required; install them manually.") printf '%s' "安装后的 PostgreSQL 客户端工具版本为 %s，但需要 %s 或更新版本；请手动安装。" ;;
        "PostgreSQL client tools are ready (version %s).") printf '%s' "PostgreSQL 客户端工具就绪（版本 %s）。" ;;
        "PostgreSQL already appears to be installed on this system.") printf '%s' "系统上似乎已安装 PostgreSQL。" ;;
        "Installing PostgreSQL server and creating a dedicated user/database...") printf '%s' "正在安装 PostgreSQL 并创建专用用户/数据库……" ;;
        "PostgreSQL installation failed.") printf '%s' "PostgreSQL 安装失败。" ;;
        "Could not install pg_dump/pg_restore (panel DB backup may be unavailable).") printf '%s' "未能安装 pg_dump/pg_restore（面板数据库备份可能不可用）。" ;;
        "PostgreSQL is installed and ready.") printf '%s' "PostgreSQL 已安装就绪。" ;;
        "Connection DSN: %s") printf '%s' "连接 DSN：%s" ;;
        "Use option 2 to migrate your SQLite data and switch the panel to PostgreSQL.") printf '%s' "使用选项 2 迁移 SQLite 数据并把面板切换到 PostgreSQL。" ;;
        "This copies your current SQLite data into a PostgreSQL database,") printf '%s' "此操作会把当前 SQLite 数据复制到 PostgreSQL 数据库，" ;;
        "then switches the panel to PostgreSQL and restarts it.") printf '%s' "然后把面板切换到 PostgreSQL 并重启。" ;;
        "Any existing panel tables in the destination will be cleared and overwritten.") printf '%s' "目标库中已有的面板表会被清空并覆盖。" ;;
        "A PostgreSQL database was created in this session:") printf '%s' "本次操作创建了一个 PostgreSQL 数据库：" ;;
        "\\t1. Install PostgreSQL locally and create a dedicated user/db (recommended)") printf '%s' "\\t1. 本地安装 PostgreSQL 并创建专用用户/数据库（推荐）" ;;
        "\\t2. Use an existing PostgreSQL server (enter DSN)") printf '%s' "\\t2. 使用已有的 PostgreSQL 服务器（输入 DSN）" ;;
        "Enter PostgreSQL DSN (postgres://user:pass@host:port/dbname?sslmode=disable):") printf '%s' "请输入 PostgreSQL DSN（postgres://user:pass@host:port/dbname?sslmode=disable）：" ;;
        "Installing PostgreSQL locally (this may take a moment)...") printf '%s' "正在本地安装 PostgreSQL（可能需要片刻）……" ;;
        "PostgreSQL installation failed. Aborting migration.") printf '%s' "PostgreSQL 安装失败，迁移中止。" ;;
        "Could not install pg_dump/pg_restore (in-panel DB backup/restore may be unavailable).") printf '%s' "未能安装 pg_dump/pg_restore（面板内数据库备份/恢复可能不可用）。" ;;
        "Stopping panel to take a consistent snapshot...") printf '%s' "正在停止面板以进行一致性快照……" ;;
        "Migrating data into PostgreSQL...") printf '%s' "正在把数据迁移到 PostgreSQL……" ;;
        "Migration failed. The panel was NOT switched to PostgreSQL.") printf '%s' "迁移失败，面板未切换到 PostgreSQL。" ;;
        "Wrote database settings to %s (XUI_DB_TYPE=postgres).") printf '%s' "数据库配置已写入 %s（XUI_DB_TYPE=postgres）。" ;;
        "Restarting panel on PostgreSQL...") printf '%s' "正在以 PostgreSQL 重启面板……" ;;
        "Migration complete. The panel is now running on PostgreSQL.") printf '%s' "迁移完成，面板现已运行在 PostgreSQL 上。" ;;
        "Panel did not come up. Check logs (main menu option 17). Your SQLite data is left intact.") printf '%s' "面板未启动。请查看日志（主菜单选项 17）。SQLite 数据未受影响。" ;;
        "\\t1. Install PostgreSQL (server + client + xui db)") printf '%s' "\\t1. 安装 PostgreSQL（服务端 + 客户端 + xui 数据库）" ;;
        "\\t2. Migrate SQLite -> PostgreSQL") printf '%s' "\\t2. 迁移 SQLite -> PostgreSQL" ;;
        "\\t3. Status (clusters & port 5432)") printf '%s' "\\t3. 状态（集群与 5432 端口）" ;;
        "\\t4. Start PostgreSQL") printf '%s' "\\t4. 启动 PostgreSQL" ;;
        "\\t5. Stop PostgreSQL") printf '%s' "\\t5. 停止 PostgreSQL" ;;
        "\\t6. Restart PostgreSQL") printf '%s' "\\t6. 重启 PostgreSQL" ;;
        "\\t7. Enable Autostart on boot") printf '%s' "\\t7. 设置开机自启" ;;
        "\\t8. View PostgreSQL Log") printf '%s' "\\t8. 查看 PostgreSQL 日志" ;;
        "\\t9. Convert SQLite .db <-> .dump") printf '%s' "\\t9. 转换 SQLite .db <-> .dump" ;;
        "\\t10. Install/Upgrade client tools (pg_dump/pg_restore)") printf '%s' "\\t10. 安装/升级客户端工具（pg_dump/pg_restore）" ;;
        "Required PostgreSQL major version (empty = any):") printf '%s' "所需 PostgreSQL 主版本号（留空为任意）：" ;;
        "d3x-ui binary not found at %s. Is the panel installed?") printf '%s' "在 %s 找不到 d3x-ui 二进制，面板安装了吗？" ;;
        "This d3x-ui build does not support .db <-> .dump conversion yet.") printf '%s' "当前 d3x-ui 版本尚不支持 .db <-> .dump 转换。" ;;
        "Update the panel first (d3x-ui update) to a version with 'migrate-db --dump/--restore'.") printf '%s' "请先更新面板（d3x-ui update）到支持 'migrate-db --dump/--restore' 的版本。" ;;
        "Input file not found: %s") printf '%s' "找不到输入文件：%s" ;;
        "Usage: d3x-ui migrateDB [file.db|file.dump] [output]") printf '%s' "用法：d3x-ui migrateDB [file.db|file.dump] [输出文件]" ;;
        "Dumping SQLite database to SQL text:") printf '%s' "正在把 SQLite 数据库导出为 SQL 文本：" ;;
        "%s -> %s") printf '%s' "%s -> %s" ;;
        "Done. Wrote %s.") printf '%s' "完成，已写出 %s。" ;;
        "Dump failed.") printf '%s' "导出失败。" ;;
        "Refusing to restore into the live database (%s) while d3x-ui is running.") printf '%s' "d3x-ui 运行期间拒绝恢复到在线数据库（%s）。" ;;
        "Stop the panel first (d3x-ui stop) or choose a different output path.") printf '%s' "请先停止面板（d3x-ui stop），或选择其他输出路径。" ;;
        "Rebuilding SQLite database from SQL text:") printf '%s' "正在从 SQL 文本重建 SQLite 数据库：" ;;
        "Done. Created %s.") printf '%s' "完成，已创建 %s。" ;;
        "Restore failed.") printf '%s' "恢复失败。" ;;
        "Convert between a SQLite .db and a portable .dump (direction auto-detected).") printf '%s' "在 SQLite .db 与可移植 .dump 之间转换（自动识别方向）。" ;;
        "Input file [%s]:") printf '%s' "输入文件［%s］：" ;;
        "Output file (leave empty to auto-name next to input):") printf '%s' "输出文件（留空则自动在输入旁命名）：" ;;
        "D3X-UI Panel Management Script") printf '%s' "D3X-UI 面板管理脚本" ;;
        "Exit Script") printf '%s' "退出脚本" ;;
        "Install") printf '%s' "安装" ;;
        "Update") printf '%s' "更新" ;;
        "Update to Dev Channel (latest commit)") printf '%s' "更新到 Dev 频道（最新提交）" ;;
        "Update Menu") printf '%s' "更新菜单" ;;
        "Legacy Version") printf '%s' "旧版版本" ;;
        "Uninstall") printf '%s' "卸载" ;;
        "Reset Username & Password") printf '%s' "重置用户名和密码" ;;
        "Reset Web Base Path") printf '%s' "重置访问路径" ;;
        "Reset Settings") printf '%s' "重置设置" ;;
        "Change Port") printf '%s' "修改端口" ;;
        "View Current Settings") printf '%s' "查看当前设置" ;;
        "Start") printf '%s' "启动" ;;
        "Stop") printf '%s' "停止" ;;
        "Restart") printf '%s' "重启" ;;
        "Restart Xray") printf '%s' "重启 Xray" ;;
        "Check Status") printf '%s' "查看状态" ;;
        "Logs Management") printf '%s' "日志管理" ;;
        "Enable Autostart") printf '%s' "启用开机自启" ;;
        "Disable Autostart") printf '%s' "关闭开机自启" ;;
        "SSL Certificate Management") printf '%s' "SSL 证书管理" ;;
        "Cloudflare SSL Certificate") printf '%s' "Cloudflare SSL 证书" ;;
        "IP Limit Management") printf '%s' "IP 限制管理" ;;
        "Firewall Management") printf '%s' "防火墙管理" ;;
        "SSH Port Forwarding Management") printf '%s' "SSH 端口转发管理" ;;
        "PostgreSQL Management") printf '%s' "PostgreSQL 管理" ;;
        "Enable BBR") printf '%s' "启用 BBR" ;;
        "Update Geo Files") printf '%s' "更新 Geo 文件" ;;
        "Speedtest by Ookla") printf '%s' "Ookla 测速" ;;
        "d3x-ui control menu usages (subcommands):") printf '%s' "d3x-ui 控制菜单用法（子命令）：" ;;
        "Admin Management Script") printf '%s' "管理脚本主菜单" ;;
        "Current Status") printf '%s' "当前状态" ;;
        "Current Settings") printf '%s' "当前设置" ;;
        "Enable Autostart on OS Startup") printf '%s' "设置系统开机自启" ;;
        "Disable Autostart on OS Startup") printf '%s' "取消系统开机自启" ;;
        "Check logs") printf '%s' "查看日志" ;;
        "Check Fail2ban ban logs") printf '%s' "查看 Fail2ban 封禁日志" ;;
        "Update to Dev channel (latest)") printf '%s' "更新到 Dev 频道（最新）" ;;
        "Update all geo files") printf '%s' "更新全部 geo 文件" ;;
        "Convert .db <-> .dump (SQLite)") printf '%s' "转换 .db <-> .dump（SQLite）" ;;
        "Upgrade pg_dump/pg_restore tools") printf '%s' "升级 pg_dump/pg_restore 工具" ;;
        "Legacy version") printf '%s' "旧版版本" ;;
        "Your input %s is invalid, will use default port 80.") printf '%s' "输入的 %s 无效，将使用默认端口 80。" ;;
        "Will use port: %s to issue certificates. Please make sure this port is open.") printf '%s' "将使用端口 %s 签发证书，请确保该端口开放。" ;;
        "Please choose which port to use (default is 80):") printf '%s' "请选择要使用的端口（默认 80）：" ;;
        "0. Back to Main Menu") printf '%s' "0. 返回主菜单" ;;
        "The certificate also covers:") printf '%s' "证书还覆盖：" ;;
        "firewalld was pulled in by fail2ban and has been disabled so it does not block your ports after a reboot.") printf '%s' "firewalld 是被 fail2ban 顺带安装的，已禁用，以免重启后拦截你的端口。" ;;
        *) printf '%s' "$1" ;;
    esac
}

# xui_tr <key> [args...]
# Returns the translated key. Each %s in the wording takes the next arg and
# leftover args are appended (the value after a label such as "Password: ").
xui_tr() {
    local key="$1"
    shift
    local out="$key"
    if [[ "$XUI_LANG_RESOLVED" == "zh" ]]; then
        out="$(xui_zh "$key")"
    fi
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

# Terminal display width of a string in columns (CJK = 2).
xui_width() {
    local LC_ALL=C
    local s="$1" w=0 i=0 b
    while (( i < ${#s} )); do
        printf -v b '%d' "'${s:i:1}"
        if (( b < 0x80 )); then w=$((w + 1)); i=$((i + 1))
        elif (( b < 0xC0 )); then w=$((w + 1)); i=$((i + 1))
        elif (( b < 0xE0 )); then w=$((w + 1)); i=$((i + 2))
        elif (( b < 0xF0 )); then w=$((w + 2)); i=$((i + 3))
        else w=$((w + 2)); i=$((i + 4)); fi
    done
    printf '%d' "$w"
}

# Width-aware box rows. The menu frame is 48 columns wide, the usage frame 66.
menu_title() {
    local t; t="$(xui_tr "$1")"
    printf '\u2502  %b%s%b%*s\u2502\n' "$green" "$t" "$plain" $((48 - 2 - $(xui_width "$t"))) ""
}
menu_line() {
    local t; t="$(xui_tr "$2")"
    printf '\u2502  %b%s.%b %s%*s\u2502\n' "$green" "$1" "$plain" "$t" $((44 - ${#1} - $(xui_width "$t"))) ""
}
usage_title() {
    local t; t="$(xui_tr "$1")"
    printf '\u2502  %b%s%b%*s\u2502\n' "$blue" "$t" "$plain" $((66 - 2 - $(xui_width "$t"))) ""
}
usage_line() {
    local t; t="$(xui_tr "$2")"
    printf '\u2502  %b%s%b%*s- %s%*s\u2502\n' "$blue" "$1" "$plain" $((29 - ${#1})) "" "$t" $((33 - $(xui_width "$t"))) ""
}

#Add some basic function here
function LOGD() {
    echo -e "${yellow}[DEG] $(xui_tr "$*") ${plain}"
}

function LOGE() {
    echo -e "${red}[ERR] $(xui_tr "$*") ${plain}"
}

function LOGI() {
    echo -e "${green}[INF] $(xui_tr "$*") ${plain}"
}

# Port helpers: detect listener and owning process (best effort)
is_port_in_use() {
    local port="$1"
    if command -v ss > /dev/null 2>&1; then
        ss -ltn 2> /dev/null | awk -v p=":${port}$" '$4 ~ p {exit 0} END {exit 1}'
        return
    fi
    if command -v netstat > /dev/null 2>&1; then
        netstat -lnt 2> /dev/null | awk -v p=":${port} " '$4 ~ p {exit 0} END {exit 1}'
        return
    fi
    if command -v lsof > /dev/null 2>&1; then
        lsof -nP -iTCP:${port} -sTCP:LISTEN > /dev/null 2>&1 && return 0
    fi
    return 1
}

# Simple helpers for domain/IP validation
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

# check root
[[ $EUID -ne 0 ]] && LOGE "ERROR: You must be root to run this script! \n" && exit 1

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

os_version=""
os_version=$(grep "^VERSION_ID" /etc/os-release | cut -d '=' -f2 | tr -d '"' | tr -d '.')

running_in_docker="false"
if [[ -f /.dockerenv ]] || [[ "${XUI_IN_DOCKER}" == "true" ]]; then
    running_in_docker="true"
fi

# Declare Variables
if [[ "${running_in_docker}" == "true" ]]; then
    xui_folder="${XUI_MAIN_FOLDER:=/app}"
else
    xui_folder="${XUI_MAIN_FOLDER:=/usr/local/d3x-ui}"
fi
xui_service="${XUI_SERVICE:=/etc/systemd/system}"
log_folder="${XUI_LOG_FOLDER:=/var/log/d3x-ui}"
mkdir -p "${log_folder}"
iplimit_log_path="${log_folder}/3xipl.log"
iplimit_banned_log_path="${log_folder}/3xipl-banned.log"

confirm() {
    if [[ $# -gt 1 ]]; then
        echo && read -rp "$(xui_tr '%s [Default %s]:' "$1" "$2")" temp
        if [[ "${temp}" == "" ]]; then
            temp=$2
        fi
    else
        read -rp "$(xui_tr '%s [y/n]:' "$1")" temp
    fi
    if [[ "${temp}" == "y" || "${temp}" == "Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Restart the panel, Attention: Restarting the panel will also restart xray" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Press enter to return to the main menu: ${plain}" && read -r temp
    show_menu
}

install() {
    bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/install.sh)
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    confirm "This function will update all d3x-ui components to the latest version, and the data will not be lost. Do you want to continue?" "y"
    if [[ $? != 0 ]]; then
        LOGE "Cancelled"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/update.sh)
    if [[ $? == 0 ]]; then
        LOGI "Update is complete, Panel has automatically restarted "
        before_show_menu
    fi
}

update_dev() {
    confirm "This will update d3x-ui to the latest DEV commit (the rolling 'dev-latest' build, not a stable release). Your data is preserved. Continue?" "y"
    if [[ $? != 0 ]]; then
        LOGE "Cancelled"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    # XUI_UPDATE_TAG tells update.sh to install the dev-latest pre-release
    # instead of the latest stable tag.
    XUI_UPDATE_TAG="dev-latest" bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/update.sh)
    if [[ $? == 0 ]]; then
        LOGI "Dev update is complete, Panel has automatically restarted "
        before_show_menu
    fi
}

replace_xui_script() {
    local url="$1"
    local use_if_modified_since="$2"
    local temp_file="/usr/bin/d3x-ui-temp.$$"

    rm -f "$temp_file"
    if [[ "$use_if_modified_since" == "true" ]]; then
        curl -fLRo "$temp_file" -z /usr/bin/d3x-ui "$url"
    else
        curl -fLRo "$temp_file" "$url"
    fi
    if [[ $? != 0 ]]; then
        rm -f "$temp_file"
        return 1
    fi

    if [[ ! -s "$temp_file" ]]; then
        rm -f "$temp_file"
        # -z above means "not modified since /usr/bin/d3x-ui" rather than a
        # real failure, so an empty download here is success, not an error.
        [[ "$use_if_modified_since" == "true" ]] && return 0
        return 1
    fi

    mv -f "$temp_file" /usr/bin/d3x-ui
    if [[ $? != 0 ]]; then
        rm -f "$temp_file"
        return 1
    fi
    # The move already landed the new script; a transient chmod failure here
    # shouldn't make callers think the whole replace failed.
    chmod +x /usr/bin/d3x-ui
    return 0
}

# The menu must match the installed panel, so update it from that release's
# tag; fall back to main only when no script is published for the version.
installed_script_url() {
    local ver
    ver=$("${xui_folder}/d3x-ui" -v 2> /dev/null | tr -d '[:space:]')
    if [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && curl -fsIL -o /dev/null "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/v${ver}/d3x-ui.sh"; then
        echo "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/v${ver}/d3x-ui.sh"
    else
        echo -e "${yellow}$(xui_tr 'No d3x-ui.sh published for the installed version (%s), using main' "${ver:-unknown}")${plain}" >&2
        echo "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/main/d3x-ui.sh"
    fi
}

update_menu() {
    echo -e "${yellow}$(xui_tr 'Updating Menu')${plain}"
    confirm "This function will update the menu to the latest changes." "y"
    if [[ $? != 0 ]]; then
        LOGE "Cancelled"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi

    if replace_xui_script "$(installed_script_url)" "false"; then
        chmod +x ${xui_folder}/d3x-ui.sh
        echo -e "${green}$(xui_tr 'Update successful. The panel has automatically restarted.')${plain}"
        exit 0
    else
        echo -e "${red}$(xui_tr 'Failed to update the menu.')${plain}"
        return 1
    fi
}

legacy_version() {
    echo -n "Enter the panel version (like 2.4.0):"
    read -r tag_version

    if [ -z "$tag_version" ]; then
        echo "Panel version cannot be empty. Exiting."
        exit 1
    fi
    # Use the entered panel version in the download link
    install_command="bash <(curl -Ls "https://raw.githubusercontent.com/mekkhalawang/d3x-ui/v$tag_version/install.sh") v$tag_version"

    echo "Downloading and installing panel version $tag_version..."
    eval $install_command
}

# Function to handle the deletion of the script file
delete_script() {
    rm "$0" # Remove the script file itself
    exit 1
}

xui_env_file_path() {
    case "${release}" in
        ubuntu | debian | armbian)
            echo "/etc/default/d3x-ui"
            ;;
        arch | manjaro | parch | alpine)
            echo "/etc/conf.d/d3x-ui"
            ;;
        *)
            echo "/etc/sysconfig/d3x-ui"
            ;;
    esac
}

uninstall() {
    confirm "Are you sure you want to uninstall the panel? xray will also uninstalled!" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi

    if [[ $release == "alpine" ]]; then
        rc-service d3x-ui stop
        rc-update del d3x-ui
        rm /etc/init.d/d3x-ui -f
    else
        systemctl stop d3x-ui
        systemctl disable d3x-ui
        rm ${xui_service}/d3x-ui.service -f
        # The sandbox drop-in generated by install.sh/update.sh lives beside the
        # unit; leaving it behind would keep an empty d3x-ui.service.d around and
        # silently re-apply on a later install of another unit of the same name.
        # Local drop-ins the operator added go with it, which is what an
        # uninstall is expected to do.
        rm -rf -- "${xui_service}/d3x-ui.service.d"
        systemctl daemon-reload
        systemctl reset-failed
    fi

    local panel_used_postgres="false"
    local db_env_file
    db_env_file="$(xui_env_file_path)"
    if [[ -r "$db_env_file" ]] && grep -q '^XUI_DB_TYPE=postgres' "$db_env_file"; then
        panel_used_postgres="true"
    fi

    rm /etc/d3x-ui/ -rf
    rm ${xui_folder}/ -rf
    rm -f "$db_env_file"

    if [[ "$panel_used_postgres" == "true" ]] && postgresql_installed; then
        purge_postgresql
    fi

    echo ""
    echo -e "$(xui_tr 'Uninstalled Successfully.\n')"
    echo "If you need to install this panel again, you can use below command:"
    echo -e "${green}bash <(curl -Ls https://raw.githubusercontent.com/mekkhalawang/d3x-ui/master/install.sh)${plain}"
    echo ""
    # Trap the SIGTERM signal
    trap delete_script SIGTERM
    delete_script
}

reset_user() {
    confirm "Are you sure to reset the username and password of the panel?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi

    read -rp "$(xui_tr 'Please set the login username [default is a random username]:')" config_account
    [[ -z $config_account ]] && config_account=$(gen_random_string 10)
    read -rp "$(xui_tr 'Please set the login password [default is a random password]:')" config_password
    [[ -z $config_password ]] && config_password=$(gen_random_string 18)

    read -rp "$(xui_tr 'Do you want to disable currently configured two-factor authentication? (y/n):')" twoFactorConfirm
    if [[ $twoFactorConfirm != "y" && $twoFactorConfirm != "Y" ]]; then
        ${xui_folder}/d3x-ui setting -username "${config_account}" -password "${config_password}" > /dev/null 2>&1
    else
        ${xui_folder}/d3x-ui setting -username "${config_account}" -password "${config_password}" -resetTwoFactor=true > /dev/null 2>&1
        echo -e "$(xui_tr 'Two factor authentication has been disabled.')"
    fi

    echo -e "${green}$(xui_tr 'Panel login username has been reset to:  %s' "${config_account}")${plain}"
    echo -e "${green}$(xui_tr 'Panel login password has been reset to:  %s' "${config_password}")${plain}"
    echo -e "${green}$(xui_tr 'Please use the new login username and password to access the D3X-UI panel. Also remember them!')${plain}"
    confirm_restart
}

gen_random_string() {
    local length="$1"
    openssl rand -base64 $((length * 2)) \
        | tr -dc 'a-zA-Z0-9' \
        | head -c "$length"
}

reset_webbasepath() {
    echo -e "${yellow}$(xui_tr 'Resetting Web Base Path')${plain}"

    read -rp "$(xui_tr 'Are you sure you want to reset the web base path? (y/n):')" confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        echo -e "${yellow}$(xui_tr 'Operation canceled.')${plain}"
        return
    fi

    config_webBasePath=$(gen_random_string 18)

    # Apply the new web base path setting
    ${xui_folder}/d3x-ui setting -webBasePath "${config_webBasePath}" > /dev/null 2>&1

    echo -e "${green}$(xui_tr 'Web base path has been reset to: %s' "${config_webBasePath}")${plain}"
    echo -e "${green}$(xui_tr 'Please use the new web base path to access the panel.')${plain}"
    restart
}

reset_config() {
    confirm "Are you sure you want to reset all panel settings, Account data will not be lost, Username and password will not change" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    ${xui_folder}/d3x-ui setting -reset
    echo -e "$(xui_tr 'All panel settings have been reset to default.')"
    restart
}

check_config() {
    local info=$(${xui_folder}/d3x-ui setting -show true)
    if [[ $? != 0 ]]; then
        LOGE "get current settings error, please check logs"
        show_menu
        return
    fi
    LOGI "${info}"

    local db_env_file
    db_env_file="$(xui_env_file_path)"
    if [[ -r "$db_env_file" ]] && grep -q '^XUI_DB_TYPE=postgres' "$db_env_file"; then
        local dsn
        dsn="$(grep -E '^XUI_DB_DSN=' "$db_env_file" | head -1 | cut -d= -f2-)"
        local dsn_safe
        dsn_safe="$(echo "$dsn" | sed -E 's|(://[^:/@]+:)[^@]+@|\1****@|')"
        echo -e "${green}$(xui_tr 'Database: PostgreSQL — %s' "${dsn_safe}")${plain}"
    else
        echo -e "${green}$(xui_tr 'Database: SQLite (/etc/d3x-ui/d3x-ui.db)')${plain}"
    fi

    local existing_webBasePath=$(echo "$info" | grep -Eo 'webBasePath: .+' | awk '{print $2}')
    local existing_port=$(echo "$info" | grep -Eo 'port: .+' | awk '{print $2}')
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
        echo -e "${yellow}$(xui_tr 'Could not auto-detect server IP from any provider.')${plain}"
        while [[ -z "$server_ip" ]]; do
            read -rp "$(xui_tr "Please enter your server's public IPv4 address:")" server_ip
            server_ip="${server_ip// /}"
            if [[ ! "$server_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo -e "${red}$(xui_tr 'Invalid IPv4 address. Please try again.')${plain}"
                server_ip=""
            fi
        done
    fi

    if [[ -n "$existing_cert" ]]; then
        local domain=$(basename "$(dirname "$existing_cert")")
        # The cert folder name is only the certificate's first domain. A
        # multidomain (SAN) certificate may be served under any name it covers,
        # so read the real names from the certificate itself (#5070).
        local cert_sans=""
        if [[ -f "$existing_cert" ]] && command -v openssl > /dev/null 2>&1; then
            cert_sans=$(openssl x509 -in "$existing_cert" -noout -ext subjectAltName 2> /dev/null \
                | grep -Eo 'DNS:[^,[:space:]]+' | cut -d: -f2)
            if [[ -n "$cert_sans" ]] && ! echo "$cert_sans" | grep -qx "$domain"; then
                domain=$(echo "$cert_sans" | head -n1)
            fi
        fi

        if [[ "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            echo -e "${green}$(xui_tr 'Access URL: https://%s:%s%s' "${domain}" "${existing_port}" "${existing_webBasePath}")${plain}"
        else
            echo -e "${green}$(xui_tr 'Access URL: https://%s:%s%s' "${server_ip}" "${existing_port}" "${existing_webBasePath}")${plain}"
        fi
        if [[ -n "$cert_sans" && $(echo "$cert_sans" | wc -l) -gt 1 ]]; then
            echo -e "${yellow}$(xui_tr 'The certificate also covers:')${plain} $(echo "$cert_sans" | grep -vx "$domain" | tr '\n' ' ')"
        fi
    else
        echo -e "${red}$(xui_tr '⚠ WARNING: No SSL certificate configured!')${plain}"
        echo -e "${yellow}$(xui_tr "You can get a Let's Encrypt certificate for your IP address (valid ~6 days, auto-renews).")${plain}"
        read -rp "$(xui_tr 'Generate SSL certificate for IP now? [y/N]:')" gen_ssl
        if [[ "$gen_ssl" == "y" || "$gen_ssl" == "Y" ]]; then
            stop 0 > /dev/null 2>&1
            ssl_cert_issue_for_ip
            if [[ $? -eq 0 ]]; then
                echo -e "${green}$(xui_tr 'Access URL: https://%s:%s%s' "${server_ip}" "${existing_port}" "${existing_webBasePath}")${plain}"
                # ssl_cert_issue_for_ip already restarts the panel, but ensure it's running
                start 0 > /dev/null 2>&1
            else
                LOGE "IP certificate setup failed."
                echo -e "${yellow}$(xui_tr 'You can try again via main menu option 20 (SSL Certificate Management).')${plain}"
                start 0 > /dev/null 2>&1
            fi
        else
            echo -e "${yellow}$(xui_tr 'Access URL: http://%s:%s%s' "${server_ip}" "${existing_port}" "${existing_webBasePath}")${plain}"
            echo -e "${yellow}$(xui_tr 'For security, please configure SSL certificate using main menu option 20 (SSL Certificate Management)')${plain}"
        fi
    fi
}

set_port() {
    echo -n "Enter port number[1-65535]: "
    read -r port
    if [[ -z "${port}" ]]; then
        LOGD "Cancelled"
        before_show_menu
    else
        ${xui_folder}/d3x-ui setting -port ${port}
        echo -e "${green}$(xui_tr 'The port is set, Please restart the panel now, and use the new port %s to access web panel' "${port}")${plain}"
        confirm_restart
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        LOGI "Panel is running, No need to start again, If you need to restart, please select restart"
    else
        if [[ "${running_in_docker}" == "true" ]]; then
            LOGE "Panel process is not running inside this container."
            LOGI "In Docker the panel is the container's main process. Restart the container to bring it back up:"
            LOGI "  docker restart <container_name>"
            if [[ $# == 0 ]]; then
                before_show_menu
            fi
            return 0
        fi
        if [[ $release == "alpine" ]]; then
            rc-service d3x-ui start
        else
            systemctl start d3x-ui
        fi
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            LOGI "d3x-ui Started Successfully"
        else
            LOGE "panel Failed to start, Probably because it takes longer than two seconds to start, Please check the log information later"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    check_status
    if [[ $? == 1 ]]; then
        echo ""
        LOGI "Panel stopped, No need to stop again!"
    else
        if [[ "${running_in_docker}" == "true" ]]; then
            LOGI "In Docker the panel runs as the container's main process."
            LOGI "To stop it, stop the container from the host:"
            LOGI "  docker stop <container_name>"
            if [[ $# == 0 ]]; then
                before_show_menu
            fi
            return 0
        fi
        if [[ $release == "alpine" ]]; then
            rc-service d3x-ui stop
        else
            systemctl stop d3x-ui
        fi
        sleep 2
        check_status
        if [[ $? == 1 ]]; then
            LOGI "d3x-ui and xray stopped successfully"
        else
            LOGE "Panel stop failed, Probably because the stop time exceeds two seconds, Please check the log information later"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    if [[ "${running_in_docker}" == "true" ]]; then
        if signal_xui HUP; then
            sleep 1
            signal_xui USR1
            LOGI "Restart signal sent to the panel and xray-core."
        else
            LOGE "Could not find the running panel process to signal."
        fi
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            LOGI "d3x-ui and xray Restarted successfully"
        else
            LOGE "Panel restart failed, Please check the log information later"
        fi
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    if [[ $release == "alpine" ]]; then
        rc-service d3x-ui restart
    else
        systemctl restart d3x-ui
    fi
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        LOGI "d3x-ui and xray Restarted successfully"
    else
        LOGE "Panel restart failed, Probably because it takes longer than two seconds to start, Please check the log information later"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart_xray() {
    if [[ "${running_in_docker}" == "true" ]]; then
        if signal_xui USR1; then
            LOGI "xray-core Restart signal sent successfully, Please check the log information to confirm whether xray restarted successfully"
        else
            LOGE "Could not find the running panel process to signal."
        fi
        sleep 2
        show_xray_status
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    if [[ $release == "alpine" ]]; then
        rc-service d3x-ui reload
    else
        systemctl reload d3x-ui
    fi
    LOGI "xray-core Restart signal sent successfully, Please check the log information to confirm whether xray restarted successfully"
    sleep 2
    show_xray_status
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    if [[ "${running_in_docker}" == "true" ]]; then
        show_status
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    if [[ $release == "alpine" ]]; then
        rc-service d3x-ui status
    else
        systemctl status d3x-ui -l
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    if [[ "${running_in_docker}" == "true" ]]; then
        LOGI "Autostart is controlled by the Docker restart policy (e.g. 'restart: unless-stopped' in docker-compose.yml)."
        LOGI "There is no service to enable inside the container."
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    if [[ $release == "alpine" ]]; then
        rc-update add d3x-ui default
    else
        systemctl enable d3x-ui
    fi
    if [[ $? == 0 ]]; then
        LOGI "d3x-ui Set to boot automatically on startup successfully"
    else
        LOGE "d3x-ui Failed to set Autostart"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    if [[ "${running_in_docker}" == "true" ]]; then
        LOGI "Autostart is controlled by the Docker restart policy (e.g. 'restart: unless-stopped' in docker-compose.yml)."
        LOGI "Set 'restart: no' for the container on the host to disable autostart."
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    if [[ $release == "alpine" ]]; then
        rc-update del d3x-ui
    else
        systemctl disable d3x-ui
    fi
    if [[ $? == 0 ]]; then
        LOGI "d3x-ui Autostart Cancelled successfully"
    else
        LOGE "d3x-ui Failed to cancel autostart"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    if [[ $release == "alpine" ]]; then
        echo -e "${green}$(xui_tr '\t1. Debug Log')${plain}"
        echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
        read -rp "$(xui_tr 'Choose an option:')" choice

        case "$choice" in
            0)
                show_menu
                ;;
            1)
                grep -F 'd3x-ui[' /var/log/messages
                if [[ $# == 0 ]]; then
                    before_show_menu
                fi
                ;;
            *)
                echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
                show_log
                ;;
        esac
    else
        echo -e "${green}$(xui_tr '\t1. Debug Log')${plain}"
        echo -e "${green}$(xui_tr '\t2. Clear All logs')${plain}"
        echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
        read -rp "$(xui_tr 'Choose an option:')" choice

        case "$choice" in
            0)
                show_menu
                ;;
            1)
                journalctl -u d3x-ui -e --no-pager -f -p debug
                if [[ $# == 0 ]]; then
                    before_show_menu
                fi
                ;;
            2)
                sudo journalctl --rotate
                sudo journalctl --vacuum-time=1s
                echo "All Logs cleared."
                restart
                ;;
            *)
                echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
                show_log
                ;;
        esac
    fi
}

bbr_menu() {
    echo -e "${green}$(xui_tr '\t1. Enable BBR')${plain}"
    echo -e "${green}$(xui_tr '\t2. Disable BBR')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" choice
    case "$choice" in
        0)
            show_menu
            ;;
        1)
            enable_bbr
            bbr_menu
            ;;
        2)
            disable_bbr
            bbr_menu
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            bbr_menu
            ;;
    esac
}

disable_bbr() {

    if [[ $(sysctl -n net.ipv4.tcp_congestion_control) != "bbr" ]] || [[ ! $(sysctl -n net.core.default_qdisc) =~ ^(fq|cake)$ ]]; then
        echo -e "${yellow}$(xui_tr 'BBR is not currently enabled.')${plain}"
        before_show_menu
    fi

    if [ -f "/etc/sysctl.d/99-bbr-d3x-ui.conf" ]; then
        old_settings=$(head -1 /etc/sysctl.d/99-bbr-d3x-ui.conf | tr -d '#')
        # sysctl -w already restores the live values, so no `sysctl --system`
        # afterwards — it would re-apply every sysctl file on the host and
        # surface unrelated errors from the distro's own defaults (see issue #5160)
        sysctl -w net.core.default_qdisc="${old_settings%:*}"
        sysctl -w net.ipv4.tcp_congestion_control="${old_settings#*:}"
        rm /etc/sysctl.d/99-bbr-d3x-ui.conf
    else
        # Replace BBR with CUBIC configurations
        if [ -f "/etc/sysctl.conf" ]; then
            sed -i 's/net.core.default_qdisc=fq/net.core.default_qdisc=pfifo_fast/' /etc/sysctl.conf
            sed -i 's/net.ipv4.tcp_congestion_control=bbr/net.ipv4.tcp_congestion_control=cubic/' /etc/sysctl.conf
            sysctl -p
        fi
    fi

    if [[ $(sysctl -n net.ipv4.tcp_congestion_control) != "bbr" ]]; then
        echo -e "${green}$(xui_tr 'BBR has been replaced with CUBIC successfully.')${plain}"
    else
        echo -e "${red}$(xui_tr 'Failed to replace BBR with CUBIC. Please check your system configuration.')${plain}"
    fi
}

enable_bbr() {
    if [[ $(sysctl -n net.ipv4.tcp_congestion_control) == "bbr" ]] && [[ $(sysctl -n net.core.default_qdisc) =~ ^(fq|cake)$ ]]; then
        echo -e "${green}$(xui_tr 'BBR is already enabled!')${plain}"
        before_show_menu
    fi

    # Enable BBR
    if [ -d "/etc/sysctl.d/" ]; then
        {
            echo "#$(sysctl -n net.core.default_qdisc):$(sysctl -n net.ipv4.tcp_congestion_control)"
            echo "net.core.default_qdisc = fq"
            echo "net.ipv4.tcp_congestion_control = bbr"
        } > "/etc/sysctl.d/99-bbr-d3x-ui.conf"
        if [ -f "/etc/sysctl.conf" ]; then
            # Backup old settings from sysctl.conf, if any
            sed -i 's/^net.core.default_qdisc/# &/' /etc/sysctl.conf
            sed -i 's/^net.ipv4.tcp_congestion_control/# &/' /etc/sysctl.conf
        fi
        # Apply only our config file; `sysctl --system` would re-apply every
        # sysctl file on the host and surface unrelated errors from the distro's
        # own defaults (see issue #5160)
        sysctl -p /etc/sysctl.d/99-bbr-d3x-ui.conf
    else
        sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
        sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
        echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" | tee -a /etc/sysctl.conf
        sysctl -p
    fi

    # Verify that BBR is enabled
    if [[ $(sysctl -n net.ipv4.tcp_congestion_control) == "bbr" ]]; then
        echo -e "${green}$(xui_tr 'BBR has been enabled successfully.')${plain}"
    else
        echo -e "${red}$(xui_tr 'Failed to enable BBR. Please check your system configuration.')${plain}"
    fi
}

update_shell() {
    if replace_xui_script "$(installed_script_url)" "true"; then
        LOGI "Upgrade script succeeded, Please rerun the script"
        before_show_menu
    else
        echo ""
        LOGE "Failed to download script, Please check whether the machine can connect Github"
        before_show_menu
    fi
}

xui_pid() {
    ps -ef 2> /dev/null | grep -F "${xui_folder}/d3x-ui" | grep -v grep | awk 'NR==1 {print $1}'
}

signal_xui() {
    local sig="$1" pid
    pid="$(xui_pid)"
    if [[ -z "${pid}" ]]; then
        return 1
    fi
    kill -"${sig}" "${pid}" 2> /dev/null
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ "${running_in_docker}" == "true" ]]; then
        if [[ ! -x "${xui_folder}/d3x-ui" ]]; then
            return 2
        fi
        if [[ -n "$(xui_pid)" ]]; then
            return 0
        else
            return 1
        fi
    fi
    if [[ $release == "alpine" ]]; then
        if [[ ! -f /etc/init.d/d3x-ui ]]; then
            return 2
        fi
        if [[ $(rc-service d3x-ui status | grep -F 'status: started' -c) == 1 ]]; then
            return 0
        else
            return 1
        fi
    else
        if [[ ! -f ${xui_service}/d3x-ui.service ]]; then
            return 2
        fi
        temp=$(systemctl show --property=SubState d3x-ui)
        temp=${temp#SubState=}
        if [[ "${temp}" == "running" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

check_enabled() {
    if [[ $release == "alpine" ]]; then
        if [[ $(rc-update show | grep -F 'd3x-ui' | grep default -c) == 1 ]]; then
            return 0
        else
            return 1
        fi
    else
        temp=$(systemctl is-enabled d3x-ui)
        if [[ "${temp}" == "enabled" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        LOGE "Panel installed, Please do not reinstall"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        LOGE "Please install the panel first"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
        0)
            echo -e "${green}$(xui_tr 'Panel state: Running')${plain}"
            show_enable_status
            ;;
        1)
            echo -e "${yellow}$(xui_tr 'Panel state: Not Running')${plain}"
            show_enable_status
            ;;
        2)
            echo -e "${red}$(xui_tr 'Panel state: Not Installed')${plain}"
            ;;
    esac
    show_xray_status
    show_mtproto_status
}

show_enable_status() {
    if [[ "${running_in_docker}" == "true" ]]; then
        echo -e "${green}$(xui_tr 'Start automatically: Managed by Docker')${plain}"
        return
    fi
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "${green}$(xui_tr 'Start automatically: Yes')${plain}"
    else
        echo -e "${red}$(xui_tr 'Start automatically: No')${plain}"
    fi
}

check_xray_status() {
    count=$(ps -ef | grep "xray-linux" | grep -v "grep" | wc -l)
    if [[ count -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

show_xray_status() {
    check_xray_status
    if [[ $? == 0 ]]; then
        echo -e "${green}$(xui_tr 'xray state: Running')${plain}"
    else
        echo -e "${red}$(xui_tr 'xray state: Not Running')${plain}"
    fi
}

# show_mtproto_status reports each mtproto inbound's mtg sidecar (one process per
# inbound, run outside xray). Silent when no mtproto inbound is configured.
show_mtproto_status() {
    local cfg_dir="${xui_folder}/bin/mtproto"
    local cfgs=()
    if [[ -d "${cfg_dir}" ]]; then
        for f in "${cfg_dir}"/mtg-*.toml; do
            [[ -e "$f" ]] && cfgs+=("$f")
        done
    fi
    [[ ${#cfgs[@]} -eq 0 ]] && return

    local running
    running=$(ps -ef | grep "mtg-linux" | grep -v "grep" | grep -oE 'mtg-[0-9]+\.toml')
    for f in "${cfgs[@]}"; do
        local name id bind
        name=$(basename "$f")
        id=$(echo "${name}" | sed -E 's/mtg-([0-9]+)\.toml/\1/')
        bind=$(grep -E '^[[:space:]]*bind-to' "$f" | head -1 | cut -d'"' -f2)
        if echo "${running}" | grep -qx "${name}"; then
            echo -e "${green}$(xui_tr 'mtproto inbound %s (%s): Running' "${id}" "${bind}")${plain}"
        else
            echo -e "${red}$(xui_tr 'mtproto inbound %s (%s): Not Running' "${id}" "${bind}")${plain}"
        fi
    done
}

firewall_menu() {
    echo -e "${green}$(xui_tr '\t1. Install Firewall')${plain}"
    echo -e "${green}$(xui_tr '\t2. Port List [numbered]')${plain}"
    echo -e "${green}$(xui_tr '\t3. Open Ports')${plain}"
    echo -e "${green}$(xui_tr '\t4. Delete Ports from List')${plain}"
    echo -e "${green}$(xui_tr '\t5. Enable Firewall')${plain}"
    echo -e "${green}$(xui_tr '\t6. Disable Firewall')${plain}"
    echo -e "${green}$(xui_tr '\t7. Firewall Status')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" choice
    case "$choice" in
        0)
            show_menu
            ;;
        1)
            install_firewall
            firewall_menu
            ;;
        2)
            ufw status numbered
            firewall_menu
            ;;
        3)
            open_ports
            firewall_menu
            ;;
        4)
            delete_ports
            firewall_menu
            ;;
        5)
            ufw enable
            firewall_menu
            ;;
        6)
            ufw disable
            firewall_menu
            ;;
        7)
            ufw status verbose
            firewall_menu
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            firewall_menu
            ;;
    esac
}

install_firewall() {
    if ! command -v ufw &> /dev/null; then
        echo "ufw firewall is not installed. Installing now..."
        apt-get update
        apt-get install -y ufw
    else
        echo "ufw firewall is already installed"
    fi

    # Check if the firewall is inactive
    if ufw status | grep -q "Status: active"; then
        echo "Firewall is already active"
    else
        echo "Activating firewall..."
        # Open the necessary ports
        ufw allow ssh
        ufw allow http
        ufw allow https
        ufw allow 2053/tcp #webPort
        ufw allow 2096/tcp #subport

        # Enable the firewall
        ufw --force enable
    fi
}

open_ports() {
    # Prompt the user to enter the ports they want to open
    read -rp "$(xui_tr 'Enter the ports you want to open (e.g. 80,443,2053 or range 400-500):')" ports

    # Check if the input is valid
    if ! [[ $ports =~ ^([0-9]+|[0-9]+-[0-9]+)(,([0-9]+|[0-9]+-[0-9]+))*$ ]]; then
        echo "Error: Invalid input. Please enter a comma-separated list of ports or a range of ports (e.g. 80,443,2053 or 400-500)." >&2
        exit 1
    fi

    # Open the specified ports using ufw
    IFS=',' read -ra PORT_LIST <<< "$ports"
    for port in "${PORT_LIST[@]}"; do
        if [[ $port == *-* ]]; then
            # Split the range into start and end ports
            start_port=$(echo $port | cut -d'-' -f1)
            end_port=$(echo $port | cut -d'-' -f2)
            # Open the port range
            ufw allow $start_port:$end_port/tcp
            ufw allow $start_port:$end_port/udp
        else
            # Open the single port
            ufw allow "$port"
        fi
    done

    # Confirm that the ports are opened
    echo "Opened the specified ports:"
    for port in "${PORT_LIST[@]}"; do
        if [[ $port == *-* ]]; then
            start_port=$(echo $port | cut -d'-' -f1)
            end_port=$(echo $port | cut -d'-' -f2)
            # Check if the port range has been successfully opened
            (ufw status | grep -q "$start_port:$end_port") && echo "$start_port-$end_port"
        else
            # Check if the individual port has been successfully opened
            (ufw status | grep -q "$port") && echo "$port"
        fi
    done
}

delete_ports() {
    # Display current rules with numbers
    echo "Current UFW rules:"
    ufw status numbered

    # Ask the user how they want to delete rules
    echo "Do you want to delete rules by:"
    echo "1) Rule numbers"
    echo "2) Ports"
    read -rp "$(xui_tr 'Enter your choice (1 or 2):')" choice

    if [[ $choice -eq 1 ]]; then
        # Deleting by rule numbers
        read -rp "$(xui_tr 'Enter the rule numbers you want to delete (1, 2, etc.):')" rule_numbers

        # Validate the input
        if ! [[ $rule_numbers =~ ^([0-9]+)(,[0-9]+)*$ ]]; then
            echo "Error: Invalid input. Please enter a comma-separated list of rule numbers." >&2
            exit 1
        fi

        # Split numbers into an array
        IFS=',' read -ra RULE_NUMBERS <<< "$rule_numbers"
        for rule_number in "${RULE_NUMBERS[@]}"; do
            # Delete the rule by number
            ufw delete "$rule_number" || echo "Failed to delete rule number $rule_number"
        done

        echo "Selected rules have been deleted."

    elif [[ $choice -eq 2 ]]; then
        # Deleting by ports
        read -rp "$(xui_tr 'Enter the ports you want to delete (e.g. 80,443,2053 or range 400-500):')" ports

        # Validate the input
        if ! [[ $ports =~ ^([0-9]+|[0-9]+-[0-9]+)(,([0-9]+|[0-9]+-[0-9]+))*$ ]]; then
            echo "Error: Invalid input. Please enter a comma-separated list of ports or a range of ports (e.g. 80,443,2053 or 400-500)." >&2
            exit 1
        fi

        # Split ports into an array
        IFS=',' read -ra PORT_LIST <<< "$ports"
        for port in "${PORT_LIST[@]}"; do
            if [[ $port == *-* ]]; then
                # Split the port range
                start_port=$(echo $port | cut -d'-' -f1)
                end_port=$(echo $port | cut -d'-' -f2)
                # Delete the port range
                ufw delete allow $start_port:$end_port/tcp
                ufw delete allow $start_port:$end_port/udp
            else
                # Delete a single port
                ufw delete allow "$port"
            fi
        done

        # Confirmation of deletion
        echo "Deleted the specified ports:"
        for port in "${PORT_LIST[@]}"; do
            if [[ $port == *-* ]]; then
                start_port=$(echo $port | cut -d'-' -f1)
                end_port=$(echo $port | cut -d'-' -f2)
                # Check if the port range has been deleted
                (ufw status | grep -q "$start_port:$end_port") || echo "$start_port-$end_port"
            else
                # Check if the individual port has been deleted
                (ufw status | grep -q "$port") || echo "$port"
            fi
        done
    else
        echo "${red}Error:${plain} Invalid choice. Please enter 1 or 2." >&2
        exit 1
    fi
}

update_all_geofiles() {
    local failed=0
    update_geofiles "main" || failed=1
    update_geofiles "IR" || failed=1
    update_geofiles "RU" || failed=1
    return $failed
}

update_geofiles() {
    case "${1}" in
        "main")
            dat_files=(geoip geosite)
            dat_source="Loyalsoldier/v2ray-rules-dat"
            ;;
        "IR")
            dat_files=(geoip_IR geosite_IR)
            dat_source="chocolate4u/Iran-v2ray-rules"
            ;;
        "RU")
            dat_files=(geoip_RU geosite_RU)
            dat_source="runetfreedom/russia-v2ray-rules-dat"
            ;;
        *)
            echo -e "${red}$(xui_tr "update_geofiles: unknown dataset '%s'" "${1}")${plain}"
            return 1
            ;;
    esac
    local failed=0 http_code
    for dat in "${dat_files[@]}"; do
        # Remove suffix for remote filename (e.g., geoip_IR -> geoip)
        remote_file="${dat%%_*}"
        local dest="${xui_folder}/bin/${dat}.dat"
        local temp_file="${dest}.tmp.$$"
        rm -f "$temp_file"
        # -z (against the live file, not the temp file) skips the download
        # (server answers 304) when the local copy is already current.
        http_code=$(curl -sSfLRo "$temp_file" -z "$dest" -w '%{http_code}' \
            https://github.com/${dat_source}/releases/latest/download/${remote_file}.dat)
        if [[ $? -ne 0 ]]; then
            echo -e "${red}$(xui_tr '%s.dat: download failed' "${dat}")${plain}"
            rm -f "$temp_file"
            failed=1
        elif [[ "$http_code" == "304" ]]; then
            echo -e "$(xui_tr '%s.dat: already up to date' "${dat}")"
            rm -f "$temp_file"
        elif [[ ! -s "$temp_file" ]]; then
            echo -e "${red}$(xui_tr '%s.dat: downloaded file is empty' "${dat}")${plain}"
            rm -f "$temp_file"
            failed=1
        else
            mv -f "$temp_file" "$dest"
            if [[ $? -ne 0 ]]; then
                echo -e "${red}$(xui_tr '%s.dat: failed to install' "${dat}")${plain}"
                rm -f "$temp_file"
                failed=1
            else
                echo -e "${green}$(xui_tr '%s.dat: updated' "${dat}")${plain}"
                geo_updated=1
            fi
        fi
    done
    return $failed
}

run_geo_update() {
    local name="$1"
    shift
    geo_updated=0
    "$@"
    if [[ $? -ne 0 ]]; then
        echo -e "${red}$(xui_tr 'Some %s could not be updated. Check the errors above.' "${name}")${plain}"
    elif [[ $geo_updated -eq 1 ]]; then
        echo -e "${green}$(xui_tr '%s have been updated successfully!' "${name}")${plain}"
        restart
    else
        echo -e "${green}$(xui_tr '%s are already up to date, restart is not needed.' "${name}")${plain}"
    fi
}

update_geo() {
    echo -e "${green}$(xui_tr '\t1. Loyalsoldier (geoip.dat, geosite.dat)')${plain}"
    echo -e "${green}$(xui_tr '\t2. chocolate4u (geoip_IR.dat, geosite_IR.dat)')${plain}"
    echo -e "${green}$(xui_tr '\t3. runetfreedom (geoip_RU.dat, geosite_RU.dat)')${plain}"
    echo -e "${green}$(xui_tr '\t4. All')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" choice

    case "$choice" in
        0)
            show_menu
            ;;
        1)
            run_geo_update "Loyalsoldier datasets" update_geofiles "main"
            ;;
        2)
            run_geo_update "chocolate4u datasets" update_geofiles "IR"
            ;;
        3)
            run_geo_update "runetfreedom datasets" update_geofiles "RU"
            ;;
        4)
            run_geo_update "geo files" update_all_geofiles
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            update_geo
            ;;
    esac

    before_show_menu
}

install_acme() {
    # Check if acme.sh is already installed
    if command -v ~/.acme.sh/acme.sh &> /dev/null; then
        LOGI "acme.sh is already installed."
        return 0
    fi

    LOGI "Installing acme.sh..."
    cd ~ || return 1 # Ensure you can change to the home directory

    curl -s https://get.acme.sh | sh
    if [ $? -ne 0 ]; then
        LOGE "Installation of acme.sh failed."
        return 1
    else
        LOGI "Installation of acme.sh succeeded."
    fi

    return 0
}

ssl_cert_issue_main() {
    echo -e "${green}$(xui_tr '\t1. Get SSL (Domain)')${plain}"
    echo -e "${green}$(xui_tr '\t2. Revoke & Remove')${plain}"
    echo -e "${green}$(xui_tr '\t3. Force Renew')${plain}"
    echo -e "${green}$(xui_tr '\t4. Show Existing Domains')${plain}"
    echo -e "${green}$(xui_tr '\t5. Set Cert paths for the panel')${plain}"
    echo -e "${green}$(xui_tr '\t6. Get SSL for IP Address (6-day cert, auto-renews)')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"

    read -rp "$(xui_tr 'Choose an option:')" choice
    case "$choice" in
        0)
            show_menu
            ;;
        1)
            ssl_cert_issue
            ssl_cert_issue_main
            ;;
        2)
            local domains=$(find /root/cert/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2> /dev/null)
            if [ -z "$domains" ]; then
                echo "No certificates found to revoke."
            else
                echo "Existing domains:"
                echo "$domains"
                read -rp "$(xui_tr 'Please enter a domain from the list to revoke and remove the certificate:')" domain
                if echo "$domains" | grep -qw "$domain"; then
                    # The IP-cert flow (option 6) stores files under /root/cert/ip, but acme.sh
                    # tracks the cert under the actual IP address(es). Resolve those so renewal
                    # state is torn down too; otherwise the acme.sh cron re-creates the deleted cert.
                    local acme_ids="${domain}"
                    if [[ "${domain}" == "ip" ]]; then
                        acme_ids=$(~/.acme.sh/acme.sh --list 2> /dev/null | awk 'NR>1 {print $1}' | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$|:')
                    fi
                    for id in ${acme_ids}; do
                        # Best-effort revoke at the CA, then drop acme.sh renewal tracking.
                        ~/.acme.sh/acme.sh --revoke -d "${id}" 2> /dev/null
                        ~/.acme.sh/acme.sh --remove -d "${id}" 2> /dev/null
                        # --remove leaves the cert files on disk, so delete the state dirs (RSA + ECC).
                        rm -rf ~/.acme.sh/"${id}" ~/.acme.sh/"${id}_ecc"
                    done
                    # Delete the local certificate files for this domain.
                    rm -rf "/root/cert/${domain}"
                    LOGI "$(xui_tr 'Certificate revoked and removed for domain: %s' "${domain}")"

                    # If the panel currently serves this domain's cert, clear the stored paths
                    # so it stops loading the now-deleted files, then restart.
                    local existing_cert=$(${xui_folder}/d3x-ui setting -getCert true | grep 'cert:' | awk -F': ' '{print $2}' | tr -d '[:space:]')
                    if [[ "${existing_cert}" == "/root/cert/${domain}/"* ]]; then
                        ${xui_folder}/d3x-ui cert -reset
                        LOGI "$(xui_tr 'Cleared panel certificate paths referencing %s; restarting panel.' "${domain}")"
                        restart
                    fi
                else
                    echo "Invalid domain entered."
                fi
            fi
            ssl_cert_issue_main
            ;;
        3)
            local domains=$(find /root/cert/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2> /dev/null)
            if [ -z "$domains" ]; then
                echo "No certificates found to renew."
            else
                echo "Existing domains:"
                echo "$domains"
                read -rp "$(xui_tr 'Please enter a domain from the list to renew the SSL certificate:')" domain
                if echo "$domains" | grep -qw "$domain"; then
                    ~/.acme.sh/acme.sh --renew -d ${domain} --force
                    LOGI "$(xui_tr 'Certificate forcefully renewed for domain: %s' "$domain")"
                else
                    echo "Invalid domain entered."
                fi
            fi
            ssl_cert_issue_main
            ;;
        4)
            local domains=$(find /root/cert/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2> /dev/null)
            if [ -z "$domains" ]; then
                echo "No certificates found under /root/cert."
            else
                echo "Existing domains and their paths:"
                for domain in $domains; do
                    local cert_path="/root/cert/${domain}/fullchain.pem"
                    local key_path="/root/cert/${domain}/privkey.pem"
                    if [[ -f "${cert_path}" && -f "${key_path}" ]]; then
                        echo -e "$(xui_tr 'Domain: %s' "${domain}")"
                        echo -e "$(xui_tr '\tCertificate Path: %s' "${cert_path}")"
                        echo -e "$(xui_tr '\tPrivate Key Path: %s' "${key_path}")"
                    else
                        echo -e "$(xui_tr 'Domain: %s - Certificate or Key missing.' "${domain}")"
                    fi
                done
            fi
            # The panel's configured certificate may live outside /root/cert
            # (e.g. certbot under /etc/letsencrypt) — show it too (#5070).
            local panel_cert=$(${xui_folder}/d3x-ui setting -getCert true | grep 'cert:' | awk -F': ' '{print $2}' | tr -d '[:space:]')
            if [[ -n "${panel_cert}" && "${panel_cert}" != /root/cert/* ]]; then
                echo -e "$(xui_tr 'Panel certificate (custom path): %s' "${panel_cert}")"
                if [[ -f "${panel_cert}" ]] && command -v openssl > /dev/null 2>&1; then
                    local panel_sans=$(openssl x509 -in "${panel_cert}" -noout -ext subjectAltName 2> /dev/null \
                        | grep -Eo 'DNS:[^,[:space:]]+' | cut -d: -f2 | tr '\n' ' ')
                    [[ -n "${panel_sans}" ]] && echo -e "$(xui_tr '\tCovers: %s' "${panel_sans}")"
                fi
            fi
            ssl_cert_issue_main
            ;;
        5)
            echo -e "${green}$(xui_tr '\t1. Use a certificate from /root/cert')${plain}"
            echo -e "${green}$(xui_tr '\t2. Enter custom certificate file paths (e.g. certbot, /etc/letsencrypt/...)')${plain}"
            read -rp "$(xui_tr 'Choose an option:')" pathChoice
            if [[ "$pathChoice" == "2" ]]; then
                read -rp "$(xui_tr 'Certificate file path (fullchain):')" webCertFile
                read -rp "$(xui_tr 'Private key file path:')" webKeyFile
                if [[ -f "${webCertFile}" && -f "${webKeyFile}" ]]; then
                    ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile"
                    echo "Panel certificate paths set:"
                    echo "  - Certificate File: $webCertFile"
                    echo "  - Private Key File: $webKeyFile"
                    restart
                else
                    echo "Certificate or private key file not found."
                fi
                ssl_cert_issue_main
                return
            fi
            local domains=$(find /root/cert/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2> /dev/null)
            if [ -z "$domains" ]; then
                echo "No certificates found."
            else
                echo "Available domains:"
                echo "$domains"
                read -rp "$(xui_tr 'Please choose a domain to set the panel paths:')" domain

                if echo "$domains" | grep -qw "$domain"; then
                    local webCertFile="/root/cert/${domain}/fullchain.pem"
                    local webKeyFile="/root/cert/${domain}/privkey.pem"

                    if [[ -f "${webCertFile}" && -f "${webKeyFile}" ]]; then
                        ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile"
                        echo "Panel paths set for domain: $domain"
                        echo "  - Certificate File: $webCertFile"
                        echo "  - Private Key File: $webKeyFile"
                        # Register the acme.sh install-cert hook so auto-renewal copies the
                        # renewed cert to these paths and reloads the panel. Without it acme.sh
                        # renews but never updates /root/cert, silently serving a stale cert.
                        if command -v ~/.acme.sh/acme.sh &> /dev/null && ~/.acme.sh/acme.sh --list 2> /dev/null | awk '{print $1}' | grep -Fxq "${domain}"; then
                            ~/.acme.sh/acme.sh --installcert --force -d "${domain}" \
                                --key-file "${webKeyFile}" \
                                --fullchain-file "${webCertFile}" \
                                --reloadcmd "d3x-ui restart" 2>&1 || true
                            echo "Registered acme.sh auto-renewal hook for ${domain}."
                        fi
                        restart
                    else
                        echo "Certificate or private key not found for domain: $domain."
                    fi
                else
                    echo "Invalid domain entered."
                fi
            fi
            ssl_cert_issue_main
            ;;
        6)
            echo -e "${yellow}$(xui_tr "Let's Encrypt SSL Certificate for IP Address")${plain}"
            echo -e "$(xui_tr "This will obtain a certificate for your server's IP using the shortlived profile.")"
            echo -e "${yellow}$(xui_tr 'Certificate valid for ~6 days, auto-renews via acme.sh cron job.')${plain}"
            echo -e "${yellow}$(xui_tr 'Port 80 must be open and accessible from the internet.')${plain}"
            confirm "Do you want to proceed?" "y"
            if [[ $? == 0 ]]; then
                ssl_cert_issue_for_ip
            fi
            ssl_cert_issue_main
            ;;

        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            ssl_cert_issue_main
            ;;
    esac
}

ssl_cert_issue_for_ip() {
    LOGI "Starting automatic SSL certificate generation for server IP..."
    LOGI "Using Let's Encrypt shortlived profile (~6 days validity, auto-renews)"

    local existing_webBasePath=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'webBasePath: .+' | awk '{print $2}')
    local existing_port=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'port: .+' | awk '{print $2}')

    # Get server IP
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

    if [[ -n "$server_ip" ]]; then
        LOGI "$(xui_tr 'Server IP detected: %s' "${server_ip}")"
        if ! confirm "Is ${server_ip} the correct incoming public IPv4 address for this server?" "y"; then
            server_ip=""
        fi
    else
        LOGI "Could not auto-detect server IP from any provider."
    fi

    while [[ -z "$server_ip" ]]; do
        read -rp "$(xui_tr "Please enter your server's public IPv4 address:")" server_ip
        server_ip="${server_ip// /}"
        if [[ ! "$server_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            LOGE "Invalid IPv4 address. Please try again."
            server_ip=""
        fi
    done

    LOGI "$(xui_tr 'Issuing certificate for server IP: %s' "${server_ip}")"

    # Ask for optional IPv6
    local ipv6_addr=""
    read -rp "$(xui_tr 'Do you have an IPv6 address to include? (leave empty to skip):')" ipv6_addr
    ipv6_addr="${ipv6_addr// /}" # Trim whitespace

    # check for acme.sh first
    if ! command -v ~/.acme.sh/acme.sh &> /dev/null; then
        LOGI "acme.sh not found, installing..."
        install_acme
        if [ $? -ne 0 ]; then
            LOGE "Failed to install acme.sh"
            return 1
        fi
    fi

    # install socat
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get update > /dev/null 2>&1 && apt-get install socat -y > /dev/null 2>&1
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
            dnf makecache -y > /dev/null 2>&1 && dnf -y install socat > /dev/null 2>&1
            ;;
        centos)
            if [[ "${VERSION_ID}" =~ ^7 ]]; then
                yum makecache -y > /dev/null 2>&1 && yum -y install socat > /dev/null 2>&1
            else
                dnf makecache -y > /dev/null 2>&1 && dnf -y install socat > /dev/null 2>&1
            fi
            ;;
        arch | manjaro | parch)
            pacman -Sy --noconfirm socat > /dev/null 2>&1
            ;;
        opensuse-tumbleweed | opensuse-leap)
            zypper refresh > /dev/null 2>&1 && zypper -q install -y socat > /dev/null 2>&1
            ;;
        alpine)
            apk add socat curl openssl > /dev/null 2>&1
            ;;
        *)
            LOGW "Unsupported OS for automatic socat installation"
            ;;
    esac

    # Create certificate directory
    certPath="/root/cert/ip"
    mkdir -p "$certPath"

    # Build domain arguments
    local domain_args="-d ${server_ip}"
    if [[ -n "$ipv6_addr" ]] && is_ipv6 "$ipv6_addr"; then
        domain_args="${domain_args} -d ${ipv6_addr}"
        LOGI "$(xui_tr 'Including IPv6 address: %s' "${ipv6_addr}")"
    fi

    # Choose port for HTTP-01 listener (default 80, allow override)
    local WebPort=""
    read -rp "$(xui_tr 'Port to use for ACME HTTP-01 listener (default 80):')" WebPort
    WebPort="${WebPort:-80}"
    if ! [[ "${WebPort}" =~ ^[0-9]+$ ]] || ((WebPort < 1 || WebPort > 65535)); then
        LOGE "Invalid port provided. Falling back to 80."
        WebPort=80
    fi
    LOGI "$(xui_tr 'Using port %s to issue certificate for IP: %s' "${WebPort}" "${server_ip}")"
    if [[ "${WebPort}" -ne 80 ]]; then
        LOGI "$(xui_tr "Reminder: Let's Encrypt still reaches port 80; forward external port 80 to %s for validation." "${WebPort}")"
    fi

    while true; do
        if is_port_in_use "${WebPort}"; then
            LOGI "$(xui_tr 'Port %s is currently in use.' "${WebPort}")"

            local alt_port=""
            read -rp "$(xui_tr 'Enter another port for acme.sh standalone listener (leave empty to abort):')" alt_port
            alt_port="${alt_port// /}"
            if [[ -z "${alt_port}" ]]; then
                LOGE "$(xui_tr 'Port %s is busy; cannot proceed with issuance.' "${WebPort}")"
                return 1
            fi
            if ! [[ "${alt_port}" =~ ^[0-9]+$ ]] || ((alt_port < 1 || alt_port > 65535)); then
                LOGE "Invalid port provided."
                return 1
            fi
            WebPort="${alt_port}"
            continue
        else
            LOGI "$(xui_tr 'Port %s is free and ready for standalone validation.' "${WebPort}")"
            break
        fi
    done

    # Reload command - restarts panel after renewal
    local reloadCmd="systemctl restart d3x-ui 2>/dev/null || rc-service d3x-ui restart 2>/dev/null"

    # issue the certificate for IP with shortlived profile
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --force
    ~/.acme.sh/acme.sh --issue \
        ${domain_args} \
        --standalone \
        --server letsencrypt \
        --certificate-profile shortlived \
        --days 6 \
        --httpport ${WebPort} \
        --force

    if [ $? -ne 0 ]; then
        LOGE "$(xui_tr 'Failed to issue certificate for IP: %s' "${server_ip}")"
        LOGE "$(xui_tr 'Make sure port %s is open and the server is accessible from the internet' "${WebPort}")"
        # Cleanup acme.sh data for both IPv4 and IPv6 if specified
        rm -rf ~/.acme.sh/${server_ip} ~/.acme.sh/${server_ip}_ecc 2> /dev/null
        [[ -n "$ipv6_addr" ]] && rm -rf ~/.acme.sh/${ipv6_addr} ~/.acme.sh/${ipv6_addr}_ecc 2> /dev/null
        rm -rf ${certPath} 2> /dev/null
        return 1
    else
        LOGI "$(xui_tr 'Certificate issued successfully for IP: %s' "${server_ip}")"
    fi

    # Install the certificate
    # Note: acme.sh may report "Reload error" and exit non-zero if reloadcmd fails,
    # but the cert files are still installed. We check for files instead of exit code.
    ~/.acme.sh/acme.sh --installcert --force -d ${server_ip} \
        --key-file "${certPath}/privkey.pem" \
        --fullchain-file "${certPath}/fullchain.pem" \
        --reloadcmd "${reloadCmd}" 2>&1 || true

    # Verify certificate files exist (don't rely on exit code - reloadcmd failure causes non-zero)
    if [[ ! -f "${certPath}/fullchain.pem" || ! -f "${certPath}/privkey.pem" ]]; then
        LOGE "Certificate files not found after installation"
        # Cleanup acme.sh data for both IPv4 and IPv6 if specified
        rm -rf ~/.acme.sh/${server_ip} ~/.acme.sh/${server_ip}_ecc 2> /dev/null
        [[ -n "$ipv6_addr" ]] && rm -rf ~/.acme.sh/${ipv6_addr} ~/.acme.sh/${ipv6_addr}_ecc 2> /dev/null
        rm -rf ${certPath} 2> /dev/null
        return 1
    fi

    LOGI "Certificate files installed successfully"

    # enable auto-renew
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade > /dev/null 2>&1
    chmod 600 $certPath/privkey.pem 2> /dev/null
    chmod 644 $certPath/fullchain.pem 2> /dev/null

    # Prompt user to set panel paths after successful certificate installation
    local webCertFile="${certPath}/fullchain.pem"
    local webKeyFile="${certPath}/privkey.pem"

    read -rp "$(xui_tr 'Would you like to set this certificate for the panel? (y/n):')" setPanel
    if [[ "$setPanel" == "y" || "$setPanel" == "Y" ]]; then
        if [[ -f "$webCertFile" && -f "$webKeyFile" ]]; then
            ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile"
            LOGI "$(xui_tr 'Panel paths set for IP: %s' "$server_ip")"
            LOGI "$(xui_tr '- Certificate File: %s' "$webCertFile")"
            LOGI "$(xui_tr '- Private Key File: %s' "$webKeyFile")"
            LOGI "  - Validity: ~6 days (auto-renews via acme.sh cron)"
            echo -e "${green}$(xui_tr 'Access URL: https://%s:%s%s' "${server_ip}" "${existing_port}" "${existing_webBasePath}")${plain}"
            LOGI "Panel will restart to apply SSL certificate..."
            restart
        else
            LOGE "$(xui_tr 'Error: Certificate or private key file not found for IP: %s.' "$server_ip")"
            return 1
        fi
    else
        LOGI "Skipping panel path setting."
    fi

    return 0
}

ssl_cert_issue() {
    local existing_webBasePath=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'webBasePath: .+' | awk '{print $2}')
    local existing_port=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'port: .+' | awk '{print $2}')
    # check for acme.sh first
    if ! command -v ~/.acme.sh/acme.sh &> /dev/null; then
        echo "acme.sh could not be found. we will install it"
        install_acme
        if [ $? -ne 0 ]; then
            LOGE "install acme failed, please check logs"
            exit 1
        fi
    fi

    # install socat
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get update > /dev/null 2>&1 && apt-get install socat -y > /dev/null 2>&1
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
            dnf makecache -y > /dev/null 2>&1 && dnf -y install socat > /dev/null 2>&1
            ;;
        centos)
            if [[ "${VERSION_ID}" =~ ^7 ]]; then
                yum makecache -y > /dev/null 2>&1 && yum -y install socat > /dev/null 2>&1
            else
                dnf makecache -y > /dev/null 2>&1 && dnf -y install socat > /dev/null 2>&1
            fi
            ;;
        arch | manjaro | parch)
            pacman -Sy --noconfirm socat > /dev/null 2>&1
            ;;
        opensuse-tumbleweed | opensuse-leap)
            zypper refresh > /dev/null 2>&1 && zypper -q install -y socat > /dev/null 2>&1
            ;;
        alpine)
            apk add socat curl openssl > /dev/null 2>&1
            ;;
        *)
            LOGW "Unsupported OS for automatic socat installation"
            ;;
    esac
    if [ $? -ne 0 ]; then
        LOGE "install socat failed, please check logs"
        exit 1
    else
        LOGI "install socat succeed..."
    fi

    # get the domain here, and we need to verify it
    local domain=""
    while true; do
        read -rp "$(xui_tr 'Please enter your domain name:')" domain
        domain="${domain// /}" # Trim whitespace

        if [[ -z "$domain" ]]; then
            LOGE "Domain name cannot be empty. Please try again."
            continue
        fi

        if ! is_domain "$domain"; then
            LOGE "$(xui_tr 'Invalid domain format: %s. Please enter a valid domain name.' "${domain}")"
            continue
        fi

        break
    done
    LOGD "$(xui_tr 'Your domain is: %s, checking it...' "${domain}")"
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
            LOGI "$(xui_tr 'Existing certificate found for %s, will reuse it.' "${domain}")"
            [[ -n "${certInfo}" ]] && LOGI "${certInfo}"
        else
            LOGW "Found incomplete acme.sh state for ${domain} (no valid certificate files); cleaning it up and re-issuing."
            rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc
        fi
    fi
    if [[ ${cert_exists} -eq 0 ]]; then
        LOGI "Your domain is ready for issuing certificates now..."
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
    read -rp "$(xui_tr 'Please choose which port to use (default is 80):')" WebPort
    if [[ -z ${WebPort} ]]; then
        WebPort=80
    elif [[ ! ${WebPort} =~ ^[1-9][0-9]*$ || ${WebPort} -gt 65535 ]]; then
        LOGE "$(xui_tr 'Your input %s is invalid, will use default port 80.' "${WebPort}")"
        WebPort=80
    fi
    LOGI "$(xui_tr 'Will use port: %s to issue certificates. Please make sure this port is open.' "${WebPort}")"

    if [[ ${cert_exists} -eq 0 ]]; then
        # issue the certificate
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --force
        ~/.acme.sh/acme.sh --issue -d ${domain} $(acme_listen_flag) --standalone --httpport ${WebPort} --force
        if [ $? -ne 0 ]; then
            LOGE "Issuing certificate failed, please check logs."
            rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc
            exit 1
        else
            LOGE "Issuing certificate succeeded, installing certificates..."
        fi
    else
        LOGI "Using existing certificate, installing certificates..."
    fi

    reloadCmd="d3x-ui restart"

    LOGI "${yellow}$(xui_tr 'Default --reloadcmd for ACME is: d3x-ui restart')${yellow}"
    LOGI "This command will run on every certificate issue and renew."
    read -rp "$(xui_tr 'Would you like to modify --reloadcmd for ACME? (y/n):')" setReloadcmd
    if [[ "$setReloadcmd" == "y" || "$setReloadcmd" == "Y" ]]; then
        echo -e "${green}$(xui_tr '\n\t1. Preset: systemctl reload nginx ; d3x-ui restart')${plain}"
        echo -e "${green}$(xui_tr '\t2. Input your own command')${plain}"
        echo -e "${green}$(xui_tr '\t0. Keep default reloadcmd')${plain}"
        read -rp "$(xui_tr 'Choose an option:')" choice
        case "$choice" in
            1)
                LOGI "Reloadcmd is: systemctl reload nginx ; d3x-ui restart"
                reloadCmd="systemctl reload nginx ; d3x-ui restart"
                ;;
            2)
                LOGD "It's recommended to put d3x-ui restart at the end, so it won't raise an error if other services fails"
                read -rp "$(xui_tr 'Please enter your reloadcmd (example: systemctl reload nginx ; d3x-ui restart):')" reloadCmd
                LOGI "$(xui_tr 'Your reloadcmd is: %s' "${reloadCmd}")"
                ;;
            *)
                LOGI "Keep default reloadcmd"
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
        LOGI "Installing certificate succeeded, enabling auto renew..."
    else
        LOGE "Installing certificate failed, exiting."
        if [[ ${cert_exists} -eq 0 ]]; then
            rm -rf ~/.acme.sh/${domain} ~/.acme.sh/${domain}_ecc
        fi
        exit 1
    fi

    # enable auto-renew
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade
    if [ $? -ne 0 ]; then
        LOGE "Auto renew failed, certificate details:"
        ls -lah cert/*
        chmod 600 $certPath/privkey.pem
        chmod 644 $certPath/fullchain.pem
        exit 1
    else
        LOGI "Auto renew succeeded, certificate details:"
        ls -lah cert/*
        chmod 600 $certPath/privkey.pem
        chmod 644 $certPath/fullchain.pem
    fi

    # Prompt user to set panel paths after successful certificate installation
    read -rp "$(xui_tr 'Would you like to set this certificate for the panel? (y/n):')" setPanel
    if [[ "$setPanel" == "y" || "$setPanel" == "Y" ]]; then
        local webCertFile="/root/cert/${domain}/fullchain.pem"
        local webKeyFile="/root/cert/${domain}/privkey.pem"

        if [[ -f "$webCertFile" && -f "$webKeyFile" ]]; then
            ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile"
            LOGI "$(xui_tr 'Panel paths set for domain: %s' "$domain")"
            LOGI "$(xui_tr '- Certificate File: %s' "$webCertFile")"
            LOGI "$(xui_tr '- Private Key File: %s' "$webKeyFile")"
            echo -e "${green}$(xui_tr 'Access URL: https://%s:%s%s' "${domain}" "${existing_port}" "${existing_webBasePath}")${plain}"
            restart
        else
            LOGE "$(xui_tr 'Error: Certificate or private key file not found for domain: %s.' "$domain")"
        fi
    else
        LOGI "Skipping panel path setting."
    fi
}

ssl_cert_issue_CF() {
    local existing_webBasePath=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'webBasePath: .+' | awk '{print $2}')
    local existing_port=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'port: .+' | awk '{print $2}')
    LOGI "****** Instructions for Use ******"
    LOGI "Follow the steps below to complete the process:"
    LOGI "1. A Cloudflare API Token (recommended, scoped to Zone:DNS:Edit) or the Global API Key + registered email."
    LOGI "2. The Domain Name."
    LOGI "3. Once the certificate is issued, you will be prompted to set the certificate for the panel (optional)."
    LOGI "4. The script also supports automatic renewal of the SSL certificate after installation."

    confirm "Do you confirm the information and wish to proceed? [y/n]" "y"

    if [ $? -eq 0 ]; then
        # Check for acme.sh first
        if ! command -v ~/.acme.sh/acme.sh &> /dev/null; then
            echo "acme.sh could not be found. We will install it."
            install_acme
            if [ $? -ne 0 ]; then
                LOGE "Install acme failed, please check logs."
                exit 1
            fi
        fi

        CF_Domain=""

        LOGD "Please set a domain name:"
        read -rp "$(xui_tr 'Input your domain here:')" CF_Domain
        LOGD "$(xui_tr 'Your domain name is set to: %s' "${CF_Domain}")"

        # Cloudflare API credentials: an API Token (recommended, scoped to a
        # single zone) or the account-wide Global API Key. acme.sh reads
        # CF_Token for tokens, or CF_Key + CF_Email for the Global Key.
        CF_KeyType=""
        read -rp "$(xui_tr 'Are you using a Cloudflare API Token or Global API Key? (t/g) [Default t]:')" CF_KeyType
        CF_KeyType=${CF_KeyType:-t}

        if [[ "$CF_KeyType" == "g" || "$CF_KeyType" == "G" ]]; then
            CF_GlobalKey=""
            CF_AccountEmail=""
            LOGD "Please set the Global API Key:"
            read -rp "$(xui_tr 'Input your key here:')" CF_GlobalKey
            LOGD "Please set up the registered email:"
            read -rp "$(xui_tr 'Input your email here:')" CF_AccountEmail
            export CF_Key="${CF_GlobalKey}"
            export CF_Email="${CF_AccountEmail}"
        else
            CF_ApiToken=""
            LOGD "Please set the API Token:"
            read -rp "$(xui_tr 'Input your token here:')" CF_ApiToken
            export CF_Token="${CF_ApiToken}"
        fi

        # Set the default CA to Let's Encrypt
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --force
        if [ $? -ne 0 ]; then
            LOGE "Default CA, Let'sEncrypt fail, script exiting..."
            exit 1
        fi

        # Issue the certificate using Cloudflare DNS
        ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CF_Domain} -d *.${CF_Domain} --log --force
        if [ $? -ne 0 ]; then
            LOGE "Certificate issuance failed, script exiting..."
            exit 1
        else
            LOGI "Certificate issued successfully, Installing..."
        fi

        # Install the certificate
        certPath="/root/cert/${CF_Domain}"
        if [ -d "$certPath" ]; then
            rm -rf ${certPath}
        fi

        mkdir -p ${certPath}
        if [ $? -ne 0 ]; then
            LOGE "$(xui_tr 'Failed to create directory: %s' "${certPath}")"
            exit 1
        fi

        reloadCmd="d3x-ui restart"

        LOGI "${yellow}$(xui_tr 'Default --reloadcmd for ACME is: d3x-ui restart')${yellow}"
        LOGI "This command will run on every certificate issue and renew."
        read -rp "$(xui_tr 'Would you like to modify --reloadcmd for ACME? (y/n):')" setReloadcmd
        if [[ "$setReloadcmd" == "y" || "$setReloadcmd" == "Y" ]]; then
            echo -e "${green}$(xui_tr '\n\t1. Preset: systemctl reload nginx ; d3x-ui restart')${plain}"
            echo -e "${green}$(xui_tr '\t2. Input your own command')${plain}"
            echo -e "${green}$(xui_tr '\t0. Keep default reloadcmd')${plain}"
            read -rp "$(xui_tr 'Choose an option:')" choice
            case "$choice" in
                1)
                    LOGI "Reloadcmd is: systemctl reload nginx ; d3x-ui restart"
                    reloadCmd="systemctl reload nginx ; d3x-ui restart"
                    ;;
                2)
                    LOGD "It's recommended to put d3x-ui restart at the end, so it won't raise an error if other services fails"
                    read -rp "$(xui_tr 'Please enter your reloadcmd (example: systemctl reload nginx ; d3x-ui restart):')" reloadCmd
                    LOGI "$(xui_tr 'Your reloadcmd is: %s' "${reloadCmd}")"
                    ;;
                *)
                    LOGI "Keep default reloadcmd"
                    ;;
            esac
        fi
        ~/.acme.sh/acme.sh --installcert --force -d ${CF_Domain} -d *.${CF_Domain} \
            --key-file ${certPath}/privkey.pem \
            --fullchain-file ${certPath}/fullchain.pem --reloadcmd "${reloadCmd}"

        if [ $? -ne 0 ]; then
            LOGE "Certificate installation failed, script exiting..."
            exit 1
        else
            LOGI "Certificate installed successfully, Turning on automatic updates..."
        fi

        # Enable auto-update
        ~/.acme.sh/acme.sh --upgrade --auto-upgrade
        if [ $? -ne 0 ]; then
            LOGE "Auto update setup failed, script exiting..."
            exit 1
        else
            LOGI "The certificate is installed and auto-renewal is turned on. Specific information is as follows:"
            ls -lah ${certPath}/*
            chmod 600 ${certPath}/privkey.pem
            chmod 644 ${certPath}/fullchain.pem
        fi

        # Prompt user to set panel paths after successful certificate installation
        read -rp "$(xui_tr 'Would you like to set this certificate for the panel? (y/n):')" setPanel
        if [[ "$setPanel" == "y" || "$setPanel" == "Y" ]]; then
            local webCertFile="${certPath}/fullchain.pem"
            local webKeyFile="${certPath}/privkey.pem"

            if [[ -f "$webCertFile" && -f "$webKeyFile" ]]; then
                ${xui_folder}/d3x-ui cert -webCert "$webCertFile" -webCertKey "$webKeyFile"
                LOGI "$(xui_tr 'Panel paths set for domain: %s' "$CF_Domain")"
                LOGI "$(xui_tr '- Certificate File: %s' "$webCertFile")"
                LOGI "$(xui_tr '- Private Key File: %s' "$webKeyFile")"
                echo -e "${green}$(xui_tr 'Access URL: https://%s:%s%s' "${CF_Domain}" "${existing_port}" "${existing_webBasePath}")${plain}"
                restart
            else
                LOGE "$(xui_tr 'Error: Certificate or private key file not found for domain: %s.' "$CF_Domain")"
            fi
        else
            LOGI "Skipping panel path setting."
        fi
    else
        show_menu
    fi
}

run_speedtest() {
    # Check if Speedtest is already installed
    if ! command -v speedtest &> /dev/null; then
        # If not installed, determine installation method
        if command -v snap &> /dev/null; then
            # Use snap to install Speedtest
            echo "Installing Speedtest using snap..."
            snap install speedtest
        else
            # Fallback to using package managers
            local pkg_manager=""
            local speedtest_install_script=""

            if command -v dnf &> /dev/null; then
                pkg_manager="dnf"
                speedtest_install_script="https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh"
            elif command -v yum &> /dev/null; then
                pkg_manager="yum"
                speedtest_install_script="https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh"
            elif command -v apt-get &> /dev/null; then
                pkg_manager="apt-get"
                speedtest_install_script="https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh"
            elif command -v apt &> /dev/null; then
                pkg_manager="apt"
                speedtest_install_script="https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh"
            fi

            if [[ -z $pkg_manager ]]; then
                echo "Error: Package manager not found. You may need to install Speedtest manually."
                return 1
            else
                echo "Installing Speedtest using $pkg_manager..."
                curl -s $speedtest_install_script | bash
                $pkg_manager install -y speedtest
            fi
        fi
    fi

    speedtest
}

ip_validation() {
    ipv6_regex="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"
    ipv4_regex="^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]?|0)\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]?|0)$"
}

iplimit_main() {
    echo -e "${green}$(xui_tr '\n\t1. Install Fail2ban and configure IP Limit')${plain}"
    echo -e "${green}$(xui_tr '\t2. Change Ban Duration')${plain}"
    echo -e "${green}$(xui_tr '\t3. Unban Everyone')${plain}"
    echo -e "${green}$(xui_tr '\t4. Ban Logs')${plain}"
    echo -e "${green}$(xui_tr '\t5. Ban an IP Address')${plain}"
    echo -e "${green}$(xui_tr '\t6. Unban an IP Address')${plain}"
    echo -e "${green}$(xui_tr '\t7. Real-Time Logs')${plain}"
    echo -e "${green}$(xui_tr '\t8. Service Status')${plain}"
    echo -e "${green}$(xui_tr '\t9. Service Restart')${plain}"
    echo -e "${green}$(xui_tr '\t10. Uninstall Fail2ban and IP Limit')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" choice
    case "$choice" in
        0)
            show_menu
            ;;
        1)
            confirm "Proceed with installation of Fail2ban & IP Limit?" "y"
            if [[ $? == 0 ]]; then
                install_iplimit
            else
                iplimit_main
            fi
            ;;
        2)
            read -rp "$(xui_tr 'Please enter new Ban Duration in Minutes [default 30]:')" NUM
            if [[ $NUM =~ ^[0-9]+$ ]]; then
                create_iplimit_jails ${NUM}
                if [[ $release == "alpine" ]]; then
                    rc-service fail2ban restart
                else
                    systemctl restart fail2ban
                fi
            else
                echo -e "${red}$(xui_tr '%s is not a number! Please, try again.' "${NUM}")${plain}"
            fi
            iplimit_main
            ;;
        3)
            confirm "Proceed with Unbanning everyone from IP Limit jail?" "y"
            if [[ $? == 0 ]]; then
                fail2ban-client reload --restart --unban 3x-ipl
                truncate -s 0 "${iplimit_banned_log_path}"
                echo -e "${green}$(xui_tr 'All users Unbanned successfully.')${plain}"
                iplimit_main
            else
                echo -e "${yellow}$(xui_tr 'Cancelled.')${plain}"
            fi
            iplimit_main
            ;;
        4)
            show_banlog
            iplimit_main
            ;;
        5)
            read -rp "$(xui_tr 'Enter the IP address you want to ban:')" ban_ip
            ip_validation
            if [[ $ban_ip =~ $ipv4_regex || $ban_ip =~ $ipv6_regex ]]; then
                fail2ban-client set 3x-ipl banip "$ban_ip"
                echo -e "${green}$(xui_tr 'IP Address %s has been banned successfully.' "${ban_ip}")${plain}"
            else
                echo -e "${red}$(xui_tr 'Invalid IP address format! Please try again.')${plain}"
            fi
            iplimit_main
            ;;
        6)
            read -rp "$(xui_tr 'Enter the IP address you want to unban:')" unban_ip
            ip_validation
            if [[ $unban_ip =~ $ipv4_regex || $unban_ip =~ $ipv6_regex ]]; then
                fail2ban-client set 3x-ipl unbanip "$unban_ip"
                echo -e "${green}$(xui_tr 'IP Address %s has been unbanned successfully.' "${unban_ip}")${plain}"
            else
                echo -e "${red}$(xui_tr 'Invalid IP address format! Please try again.')${plain}"
            fi
            iplimit_main
            ;;
        7)
            tail -f /var/log/fail2ban.log
            iplimit_main
            ;;
        8)
            service fail2ban status
            iplimit_main
            ;;
        9)
            if [[ $release == "alpine" ]]; then
                rc-service fail2ban restart
            else
                systemctl restart fail2ban
            fi
            iplimit_main
            ;;
        10)
            remove_iplimit
            iplimit_main
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            iplimit_main
            ;;
    esac
}

setup_fail2ban_iplimit() {
    # Honor the same toggle the panel uses (isFail2BanEnabled): enabled when the
    # var is unset or exactly "true"; any other explicit value means the operator
    # opted out, so do nothing rather than install a fail2ban the panel ignores.
    if [[ -n "${XUI_ENABLE_FAIL2BAN+x}" && "${XUI_ENABLE_FAIL2BAN}" != "true" ]]; then
        echo -e "${yellow}$(xui_tr 'XUI_ENABLE_FAIL2BAN=%s, skipping Fail2ban setup.\n' "${XUI_ENABLE_FAIL2BAN}")${plain}"
        return 0
    fi

    if ! command -v fail2ban-client &> /dev/null; then
        echo -e "${green}$(xui_tr 'Fail2ban is not installed. Installing now...!\n')${plain}"

        # Install fail2ban together with nftables. Recent fail2ban packages
        # default to `banaction = nftables-multiport` in /etc/fail2ban/jail.conf,
        # but the `nftables` package isn't pulled in as a dependency on most
        # minimal server images (Debian 12+, Ubuntu 24+, fresh RHEL-family).
        # Without `nft` in PATH the default sshd jail fails to ban with
        #   stderr: '/bin/sh: 1: nft: not found'
        # even though our own 3x-ipl jail uses iptables. Bundling the binary
        # at install time prevents that confusing log spam for new installs.
        case "${release}" in
            ubuntu)
                apt-get update
                if [[ "${os_version}" -ge 2400 ]]; then
                    apt-get install python3-pip -y
                    python3 -m pip install pyasynchat --break-system-packages
                fi
                apt-get install fail2ban nftables -y
                ;;
            debian)
                apt-get update
                if [ "$os_version" -ge 12 ]; then
                    apt-get install -y python3-systemd
                fi
                apt-get install -y fail2ban nftables
                ;;
            armbian)
                apt-get update && apt-get install fail2ban nftables -y
                ;;
            fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
                if [[ "${release}" != "fedora" ]] && ! dnf repolist enabled 2> /dev/null | grep -qiw epel; then
                    dnf install -y epel-release \
                        || dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm" \
                        || echo -e "${yellow}$(xui_tr 'Could not enable the EPEL repository; fail2ban is only available from EPEL on this distro.')${plain}"
                fi
                dnf makecache -y && dnf -y install fail2ban nftables
                ;;
            centos)
                if [[ "${VERSION_ID}" =~ ^7 ]]; then
                    yum makecache -y && yum install epel-release -y
                    # On EL7 fail2ban pulls in firewalld, which is enabled on the
                    # next boot and blocks every panel/inbound port. The IP Limit
                    # jail uses raw iptables, so a firewalld that was not there
                    # before is not needed: keep it from starting on reboot.
                    rpm -q firewalld &> /dev/null && had_firewalld=1 || had_firewalld=0
                    yum -y install fail2ban nftables
                    if [[ "${had_firewalld}" == "0" ]] && rpm -q firewalld &> /dev/null; then
                        systemctl disable firewalld 2> /dev/null
                        echo -e "${yellow}$(xui_tr 'firewalld was pulled in by fail2ban and has been disabled so it does not block your ports after a reboot.')${plain}\n"
                    fi
                else
                    dnf makecache -y && dnf -y install fail2ban nftables
                fi
                ;;
            arch | manjaro | parch)
                pacman -Sy --noconfirm fail2ban nftables
                ;;
            alpine)
                apk add fail2ban nftables
                ;;
            *)
                echo -e "${red}$(xui_tr 'Unsupported operating system. Please check the script and install the necessary packages manually.\n')${plain}"
                return 1
                ;;
        esac

        if ! command -v fail2ban-client &> /dev/null; then
            echo -e "${red}$(xui_tr 'Fail2ban installation failed.\n')${plain}"
            return 1
        fi

        echo -e "${green}$(xui_tr 'Fail2ban installed successfully!\n')${plain}"
    else
        echo -e "${yellow}$(xui_tr 'Fail2ban is already installed.\n')${plain}"
    fi

    echo -e "${green}$(xui_tr 'Configuring IP Limit...\n')${plain}"

    # make sure there's no conflict for jail files
    iplimit_remove_conflicts

    # Check if log file exists
    if ! test -f "${iplimit_banned_log_path}"; then
        touch ${iplimit_banned_log_path}
    fi

    # Check if service log file exists so fail2ban won't return error
    if ! test -f "${iplimit_log_path}"; then
        touch ${iplimit_log_path}
    fi

    # Create the iplimit jail files
    # we didn't pass the bantime here to use the default value
    create_iplimit_jails

    # Launching fail2ban
    if [[ $release == "alpine" ]]; then
        if [[ $(rc-service fail2ban status | grep -F 'status: started' -c) == 0 ]]; then
            rc-service fail2ban start
        else
            rc-service fail2ban restart
        fi
        rc-update add fail2ban
    else
        if ! systemctl is-active --quiet fail2ban; then
            systemctl start fail2ban
        else
            systemctl restart fail2ban
        fi
        systemctl enable fail2ban
    fi

    echo -e "${green}$(xui_tr 'IP Limit installed and configured successfully!\n')${plain}"
    return 0
}

# install_iplimit is the interactive (menu) entry point: it runs the shared
# setup and then returns to the menu. The non-interactive installer path uses
# setup_fail2ban_iplimit directly via `d3x-ui setup-fail2ban`.
install_iplimit() {
    setup_fail2ban_iplimit
    before_show_menu
}

remove_iplimit() {
    echo -e "${green}$(xui_tr '\t1. Only remove IP Limit configurations')${plain}"
    echo -e "${green}$(xui_tr '\t2. Uninstall Fail2ban and IP Limit')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" num
    case "$num" in
        1)
            rm -f /etc/fail2ban/filter.d/3x-ipl.conf
            rm -f /etc/fail2ban/action.d/3x-ipl.conf
            rm -f /etc/fail2ban/jail.d/3x-ipl.conf
            if [[ $release == "alpine" ]]; then
                rc-service fail2ban restart
            else
                systemctl restart fail2ban
            fi
            echo -e "${green}$(xui_tr 'IP Limit removed successfully!\n')${plain}"
            before_show_menu
            ;;
        2)
            rm -rf /etc/fail2ban
            if [[ $release == "alpine" ]]; then
                rc-service fail2ban stop
            else
                systemctl stop fail2ban
            fi
            case "${release}" in
                ubuntu | debian | armbian)
                    apt-get remove -y fail2ban
                    apt-get purge -y fail2ban -y
                    apt-get autoremove -y
                    ;;
                fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
                    dnf remove fail2ban -y
                    dnf autoremove -y
                    ;;
                centos)
                    if [[ "${VERSION_ID}" =~ ^7 ]]; then
                        yum remove fail2ban -y
                        yum autoremove -y
                    else
                        dnf remove fail2ban -y
                        dnf autoremove -y
                    fi
                    ;;
                arch | manjaro | parch)
                    pacman -Rns --noconfirm fail2ban
                    ;;
                alpine)
                    apk del fail2ban
                    ;;
                *)
                    echo -e "${red}$(xui_tr 'Unsupported operating system. Please uninstall Fail2ban manually.\n')${plain}"
                    exit 1
                    ;;
            esac
            echo -e "${green}$(xui_tr 'Fail2ban and IP Limit removed successfully!\n')${plain}"
            before_show_menu
            ;;
        0)
            show_menu
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            remove_iplimit
            ;;
    esac
}

show_banlog() {
    local system_log="/var/log/fail2ban.log"

    echo -e "${green}$(xui_tr 'Checking ban logs...\n')${plain}"

    if [[ $release == "alpine" ]]; then
        if [[ $(rc-service fail2ban status | grep -F 'status: started' -c) == 0 ]]; then
            echo -e "${red}$(xui_tr 'Fail2ban service is not running!\n')${plain}"
            return 1
        fi
    else
        if ! systemctl is-active --quiet fail2ban; then
            echo -e "${red}$(xui_tr 'Fail2ban service is not running!\n')${plain}"
            return 1
        fi
    fi

    if [[ -f "$system_log" ]]; then
        echo -e "${green}$(xui_tr 'Recent system ban activities from fail2ban.log:')${plain}"
        grep "3x-ipl" "$system_log" | grep -E "Ban|Unban" | tail -n 10 || echo -e "${yellow}$(xui_tr 'No recent system ban activities found')${plain}"
        echo ""
    fi

    if [[ -f "${iplimit_banned_log_path}" ]]; then
        echo -e "${green}$(xui_tr '3X-IPL ban log entries:')${plain}"
        if [[ -s "${iplimit_banned_log_path}" ]]; then
            grep -v "INIT" "${iplimit_banned_log_path}" | tail -n 10 || echo -e "${yellow}$(xui_tr 'No ban entries found')${plain}"
        else
            echo -e "${yellow}$(xui_tr 'Ban log file is empty')${plain}"
        fi
    else
        echo -e "${red}$(xui_tr 'Ban log file not found at: %s' "${iplimit_banned_log_path}")${plain}"
    fi

    echo -e "${green}$(xui_tr '\nCurrent jail status:')${plain}"
    fail2ban-client status 3x-ipl || echo -e "${yellow}$(xui_tr 'Unable to get jail status')${plain}"
}

create_iplimit_jails() {
    # Use default bantime if not passed => 30 minutes
    local bantime="${1:-30}"

    # Uncomment 'allowipv6 = auto' in fail2ban.conf
    sed -i 's/#allowipv6 = auto/allowipv6 = auto/g' /etc/fail2ban/fail2ban.conf

    # Debian 12+ / Ubuntu 22.04+ log sshd to the journal only; a jail.d override
    # survives package upgrades. Only the stock 'backend = auto' is overridden.
    if [[ ( "${release}" == "debian" && ${os_version} -ge 12 ) || ( "${release}" == "ubuntu" && ${os_version} -ge 2200 ) ]] &&
        sed -n '0,/action =/p' /etc/fail2ban/jail.conf | grep -q '^backend = auto'; then
        cat << EOF > /etc/fail2ban/jail.d/3x-ipl-backend.conf
[DEFAULT]
backend = systemd
EOF
    fi

    cat << EOF > /etc/fail2ban/jail.d/3x-ipl.conf
[3x-ipl]
enabled=true
backend=auto
filter=3x-ipl
action=3x-ipl
logpath=${iplimit_log_path}
maxretry=1
findtime=32
bantime=${bantime}m
EOF

    cat << EOF > /etc/fail2ban/filter.d/3x-ipl.conf
[Definition]
datepattern = ^%%Y/%%m/%%d %%H:%%M:%%S
failregex   = \[LIMIT_IP\]\s*Email\s*=\s*<F-USER>.+</F-USER>\s*\|\|\s*Disconnecting OLD IP\s*=\s*<ADDR>\s*\|\|\s*Timestamp\s*=\s*\d+
ignoreregex =
EOF

    # Ports to exempt from the ban so an over-limit proxy client can never lock
    # the administrator out of SSH or the panel. The ban still covers every other
    # TCP and UDP port (including all Xray inbounds, e.g. UDP-based Hysteria2), so
    # IP-limit keeps working for inbounds added later without regenerating these files.
    local ssh_ports
    ssh_ports=$(grep -oP '^[[:space:]]*Port[[:space:]]+\K[0-9]+' /etc/ssh/sshd_config 2>/dev/null | paste -sd, -)
    [[ -z "${ssh_ports}" ]] && ssh_ports="22"
    local panel_port
    panel_port=$(${xui_folder}/d3x-ui setting -show true 2>/dev/null | grep -Eo 'port: .+' | awk '{print $2}')
    local exempt_ports="${ssh_ports}"
    [[ -n "${panel_port}" ]] && exempt_ports="${exempt_ports},${panel_port}"

    cat << EOF > /etc/fail2ban/action.d/3x-ipl.conf
[INCLUDES]
before = iptables-allports.conf

[Definition]
actionstart = <iptables> -N f2b-<name>
              <iptables> -A f2b-<name> -j <returntype>
              <iptables> -I <chain> -j f2b-<name>

actionstop = <iptables> -D <chain> -j f2b-<name>
             <actionflush>
             <iptables> -X f2b-<name>

actioncheck = <iptables> -n -L <chain> | grep -q 'f2b-<name>[ \t]'

actionban = <iptables> -I f2b-<name> 1 -s <ip> -p tcp -m multiport ! --dports <exemptports> -j <blocktype>
            <iptables> -I f2b-<name> 1 -s <ip> -p udp -m multiport ! --dports <exemptports> -j <blocktype>
            echo "\$(date +"%%Y/%%m/%%d %%H:%%M:%%S")   BAN   [Email] = <F-USER> [IP] = <ip> banned for <bantime> seconds." >> ${iplimit_banned_log_path}

actionunban = <iptables> -D f2b-<name> -s <ip> -p tcp -m multiport ! --dports <exemptports> -j <blocktype>
              <iptables> -D f2b-<name> -s <ip> -p udp -m multiport ! --dports <exemptports> -j <blocktype>
              echo "\$(date +"%%Y/%%m/%%d %%H:%%M:%%S")   UNBAN   [Email] = <F-USER> [IP] = <ip> unbanned." >> ${iplimit_banned_log_path}

[Init]
name = default
chain = INPUT
exemptports = ${exempt_ports}
EOF

    echo -e "${green}$(xui_tr 'Ip Limit jail files created with a bantime of %s minutes.' "${bantime}")${plain}"
}

iplimit_remove_conflicts() {
    local jail_files=(
        /etc/fail2ban/jail.conf
        /etc/fail2ban/jail.local
    )

    for file in "${jail_files[@]}"; do
        # Check for [3x-ipl] config in jail file then remove it
        if test -f "${file}" && grep -qw '3x-ipl' ${file}; then
            sed -i "/\[3x-ipl\]/,/^$/d" ${file}
            echo -e "${yellow}$(xui_tr 'Removing conflicts of [3x-ipl] in jail (%s)!\n' "${file}")${plain}"
        fi
    done
}

SSH_port_forwarding() {
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
        echo -e "${yellow}$(xui_tr 'Could not auto-detect server IP from any provider.')${plain}"
        while [[ -z "$server_ip" ]]; do
            read -rp "$(xui_tr "Please enter your server's public IPv4 address:")" server_ip
            server_ip="${server_ip// /}"
            if [[ ! "$server_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo -e "${red}$(xui_tr 'Invalid IPv4 address. Please try again.')${plain}"
                server_ip=""
            fi
        done
    fi

    local existing_webBasePath=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'webBasePath: .+' | awk '{print $2}')
    local existing_port=$(${xui_folder}/d3x-ui setting -show true | grep -Eo 'port: .+' | awk '{print $2}')
    local existing_listenIP=$(${xui_folder}/d3x-ui setting -getListen true | grep -Eo 'listenIP: .+' | awk '{print $2}')
    local existing_cert=$(${xui_folder}/d3x-ui setting -getCert true | grep -Eo 'cert: .+' | awk '{print $2}')
    local existing_key=$(${xui_folder}/d3x-ui setting -getCert true | grep -Eo 'key: .+' | awk '{print $2}')

    local config_listenIP=""
    local listen_choice=""

    if [[ -n "$existing_cert" && -n "$existing_key" ]]; then
        echo -e "${green}$(xui_tr 'Panel is secure with SSL.')${plain}"
        before_show_menu
    fi
    if [[ -z "$existing_cert" && -z "$existing_key" && (-z "$existing_listenIP" || "$existing_listenIP" == "0.0.0.0") ]]; then
        echo -e "${red}$(xui_tr '\nWarning: No Cert and Key found! The panel is not secure.')${plain}"
        echo "Please obtain a certificate or set up SSH port forwarding."
    fi

    if [[ -n "$existing_listenIP" && "$existing_listenIP" != "0.0.0.0" && (-z "$existing_cert" && -z "$existing_key") ]]; then
        echo -e "${green}$(xui_tr '\nCurrent SSH Port Forwarding Configuration:')${plain}"
        echo -e "$(xui_tr 'Standard SSH command:')"
        echo -e "${yellow}ssh -L 2222:${existing_listenIP}:${existing_port} root@${server_ip}${plain}"
        echo -e "$(xui_tr '\nIf using SSH key:')"
        echo -e "${yellow}ssh -i <sshkeypath> -L 2222:${existing_listenIP}:${existing_port} root@${server_ip}${plain}"
        echo -e "$(xui_tr '\nAfter connecting, access the panel at:')"
        echo -e "${yellow}http://localhost:2222${existing_webBasePath}${plain}"
    fi

    echo -e "$(xui_tr '\nChoose an option:')"
    echo -e "${green}$(xui_tr '1. Set listen IP')${plain}"
    echo -e "${green}$(xui_tr '2. Clear listen IP')${plain}"
    echo -e "${green}$(xui_tr '0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" num

    case "$num" in
        1)
            if [[ -z "$existing_listenIP" || "$existing_listenIP" == "0.0.0.0" ]]; then
                echo -e "$(xui_tr '\nNo listenIP configured. Choose an option:')"
                echo -e "$(xui_tr '1. Use default IP (127.0.0.1)')"
                echo -e "$(xui_tr '2. Set a custom IP')"
                read -rp "$(xui_tr 'Select an option (1 or 2):')" listen_choice

                config_listenIP="127.0.0.1"
                [[ "$listen_choice" == "2" ]] && read -rp "$(xui_tr 'Enter custom IP to listen on:')" config_listenIP

                ${xui_folder}/d3x-ui setting -listenIP "${config_listenIP}" > /dev/null 2>&1
                echo -e "${green}$(xui_tr 'listen IP has been set to %s.' "${config_listenIP}")${plain}"
                echo -e "${green}$(xui_tr '\nSSH Port Forwarding Configuration:')${plain}"
                echo -e "$(xui_tr 'Standard SSH command:')"
                echo -e "${yellow}ssh -L 2222:${config_listenIP}:${existing_port} root@${server_ip}${plain}"
                echo -e "$(xui_tr '\nIf using SSH key:')"
                echo -e "${yellow}ssh -i <sshkeypath> -L 2222:${config_listenIP}:${existing_port} root@${server_ip}${plain}"
                echo -e "$(xui_tr '\nAfter connecting, access the panel at:')"
                echo -e "${yellow}http://localhost:2222${existing_webBasePath}${plain}"
                restart
            else
                config_listenIP="${existing_listenIP}"
                echo -e "${green}$(xui_tr 'Current listen IP is already set to %s.' "${config_listenIP}")${plain}"
            fi
            ;;
        2)
            ${xui_folder}/d3x-ui setting -listenIP 0.0.0.0 > /dev/null 2>&1
            echo -e "${green}$(xui_tr 'Listen IP has been cleared.')${plain}"
            restart
            ;;
        0)
            show_menu
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            SSH_port_forwarding
            ;;
    esac
}

# PostgreSQL service management (for panels configured with XUI_DB_TYPE=postgres).

postgresql_installed() {
    command -v pg_lsclusters > /dev/null 2>&1 || command -v psql > /dev/null 2>&1 || command -v postgres > /dev/null 2>&1
}

# Prints "VER CLUSTER" of the first configured cluster on Debian-style installs (e.g. "16 main").
pg_cluster_info() {
    if command -v pg_lsclusters > /dev/null 2>&1; then
        pg_lsclusters 2> /dev/null | awk '$1 ~ /^[0-9]+$/ {print $1, $2; exit}'
    fi
}

# Resolves the systemd unit used to manage the PostgreSQL server.
pg_systemd_unit() {
    local info ver cluster
    info="$(pg_cluster_info)"
    if [[ -n "$info" ]]; then
        ver="${info%% *}"
        cluster="${info##* }"
        echo "postgresql@${ver}-${cluster}"
    elif [[ -f "/usr/lib/systemd/system/postgresql-${PG_TARGET_MAJOR}.service" ]]; then
        echo "postgresql-${PG_TARGET_MAJOR}"
    else
        echo "postgresql"
    fi
}

postgresql_status() {
    if ! postgresql_installed; then
        LOGE "PostgreSQL does not appear to be installed on this system."
        return 1
    fi
    if command -v pg_lsclusters > /dev/null 2>&1; then
        pg_lsclusters
    else
        systemctl status "$(pg_systemd_unit)" --no-pager
    fi
    echo ""
    if command -v ss > /dev/null 2>&1; then
        local listening
        listening=$(ss -ltnp 2> /dev/null | grep ':5432')
        if [[ -n "$listening" ]]; then
            echo -e "${green}$(xui_tr 'PostgreSQL is listening on port 5432:')${plain}"
            echo "$listening"
        else
            echo -e "${red}$(xui_tr 'Nothing is listening on port 5432 - the database is not running.')${plain}"
        fi
    fi
}

postgresql_start() {
    pg_require_installed || return 1
    if [[ $release == "alpine" ]]; then
        rc-service postgresql start
    else
        systemctl start "$(pg_systemd_unit)"
    fi
    sleep 1
    postgresql_status
}

postgresql_stop() {
    pg_require_installed || return 1
    if [[ $release == "alpine" ]]; then
        rc-service postgresql stop
    else
        systemctl stop "$(pg_systemd_unit)"
    fi
    LOGI "PostgreSQL stop signal sent."
}

postgresql_restart() {
    pg_require_installed || return 1
    if [[ $release == "alpine" ]]; then
        rc-service postgresql restart
    else
        systemctl restart "$(pg_systemd_unit)"
    fi
    sleep 1
    postgresql_status
}

postgresql_enable() {
    pg_require_installed || return 1
    if [[ $release == "alpine" ]]; then
        rc-update add postgresql default
    else
        systemctl enable "$(pg_systemd_unit)"
    fi
    if [[ $? == 0 ]]; then
        LOGI "PostgreSQL set to start automatically on boot."
    else
        LOGE "Failed to enable PostgreSQL autostart."
    fi
}

postgresql_log() {
    pg_require_installed || return 1
    local info ver cluster logfile
    info="$(pg_cluster_info)"
    if [[ -n "$info" ]]; then
        ver="${info%% *}"
        cluster="${info##* }"
        logfile="/var/log/postgresql/postgresql-${ver}-${cluster}.log"
    fi
    if [[ -n "$logfile" && -f "$logfile" ]]; then
        tail -n 40 "$logfile"
    elif command -v journalctl > /dev/null 2>&1; then
        journalctl -u "$(pg_systemd_unit)" -n 40 --no-pager
    else
        LOGE "No PostgreSQL log found."
    fi
}

pg_require_installed() {
    if ! postgresql_installed; then
        LOGE "PostgreSQL is not installed. Use option 1 (Install PostgreSQL) in this menu first."
        return 1
    fi
}

# Completely removes the PostgreSQL server and ALL of its databases from the system.
# Gated behind an explicit confirmation because this is system-wide and irreversible:
# any other application sharing this PostgreSQL instance loses its data too. Mirrors the
# package names used by pg_install_local() so the right packages are removed per distro.
purge_postgresql() {
    echo ""
    echo -e "${yellow}$(xui_tr 'This panel was using PostgreSQL.')${plain}"
    echo -e "${red}$(xui_tr 'WARNING: purging removes the PostgreSQL server and ALL of its databases on')${plain}"
    echo -e "$(xui_tr 'this machine, including any used by other applications. This cannot be undone.')"
    confirm "Also purge PostgreSQL and delete all of its data?" "n"
    if [[ $? != 0 ]]; then
        LOGI "Left PostgreSQL installed; its data was not removed."
        return 0
    fi

    if [[ $release == "alpine" ]]; then
        rc-service postgresql stop 2> /dev/null
        rc-update del postgresql 2> /dev/null
    else
        systemctl stop "$(pg_systemd_unit)" 2> /dev/null
        systemctl disable "$(pg_systemd_unit)" 2> /dev/null
    fi

    local pgdg_pkgs=()
    command -v rpm > /dev/null 2>&1 && mapfile -t pgdg_pkgs < <(rpm -qa --qf '%{NAME}\n' "postgresql${PG_TARGET_MAJOR}*")
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get -y --purge remove 'postgresql*'
            apt-get -y autoremove --purge
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol)
            dnf remove -y postgresql postgresql-server postgresql-contrib "${pgdg_pkgs[@]}"
            ;;
        centos)
            if [[ "${VERSION_ID}" =~ ^7 ]]; then
                yum remove -y postgresql postgresql-server postgresql-contrib
            else
                dnf remove -y postgresql postgresql-server postgresql-contrib "${pgdg_pkgs[@]}"
            fi
            ;;
        arch | manjaro | parch)
            pacman -Rns --noconfirm postgresql
            ;;
        opensuse-tumbleweed | opensuse-leap)
            zypper -q remove -y postgresql postgresql-server postgresql-contrib
            ;;
        alpine)
            apk del postgresql postgresql-contrib postgresql-client
            ;;
        *)
            LOGE "$(xui_tr 'Unsupported distro for automatic PostgreSQL purge: %s. Remove it manually.' "${release}")"
            return 1
            ;;
    esac

    rm -rf /var/lib/postgresql /var/lib/pgsql /var/lib/postgres /etc/postgresql
    LOGI "PostgreSQL has been purged."
}

# RHEL-family initdb writes pg_hba.conf host rules with ident auth, which
# compares the OS username against the Postgres role and always rejects the
# randomly generated panel role over TCP (#5806). Prepend password-auth rules
# scoped to the panel database; first match wins, and md5 also accepts
# scram-sha-256-stored verifiers, so this works on every supported distro.
# Mirrors pg_ensure_hba_password_auth() from install.sh.
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
    echo -e "${yellow}$(xui_tr "PostgreSQL %s is not available for this system; installing the distribution's PostgreSQL instead." "${PG_TARGET_MAJOR}")${plain}" >&2
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
    echo -e "${yellow}$(xui_tr "PostgreSQL %s is not available for this system; installing the distribution's PostgreSQL instead." "${PG_TARGET_MAJOR}")${plain}" >&2
    return 1
}

# Installs a local PostgreSQL server and creates a dedicated xui user/database.
# Progress goes to stderr; on success the connection DSN is printed to stdout so
# callers can capture it. Mirrors install_postgres_local() from install.sh, so the
# panel can be set up without re-running the remote install script.
pg_install_local() {
    local pg_user pg_pass pg_db pg_host pg_port
    pg_pass=$(gen_random_string 24)
    pg_db="xui"
    pg_host="127.0.0.1"
    pg_port="5432"

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
            echo -e "${red}$(xui_tr 'Unsupported distro for automatic PostgreSQL install: %s' "${release}")${plain}" >&2
            return 1
            ;;
    esac

    if [[ "${release}" != "alpine" ]]; then
        systemctl enable --now "${pg_service}" >&2 || return 1
    fi

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

    sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${pg_user}'" 2> /dev/null \
        | grep -q 1 \
        || sudo -u postgres psql -c "CREATE USER \"${pg_user}\" WITH PASSWORD '${pg_pass}';" >&2 || return 1

    sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${pg_db}'" 2> /dev/null \
        | grep -q 1 \
        || sudo -u postgres psql -c "CREATE DATABASE \"${pg_db}\" OWNER \"${pg_user}\";" >&2 || return 1

    sudo -u postgres psql -c "ALTER USER \"${pg_user}\" WITH PASSWORD '${pg_pass}';" >&2 || return 1

    pg_ensure_hba_password_auth "${pg_db}" \
        || echo -e "${yellow}$(xui_tr "Warning: could not update pg_hba.conf; PostgreSQL may reject the panel's TCP login (ident auth).")${plain}" >&2

    local pg_pass_enc
    pg_pass_enc=$(printf '%s' "${pg_pass}" | sed -e 's/%/%25/g' -e 's/:/%3A/g' -e 's/@/%40/g' -e 's|/|%2F|g' -e 's/?/%3F/g' -e 's/#/%23/g')

    echo "postgres://${pg_user}:${pg_pass_enc}@${pg_host}:${pg_port}/${pg_db}?sslmode=disable"
    return 0
}

# Installs the PostgreSQL client tools (pg_dump/pg_restore) used by in-panel backup.
pg_ensure_client() {
    if command -v pg_dump > /dev/null 2>&1 && command -v pg_restore > /dev/null 2>&1; then
        return 0
    fi
    echo -e "${yellow}$(xui_tr 'Installing PostgreSQL client tools (pg_dump/pg_restore)...')${plain}" >&2
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

# Prints the major version of the installed pg_restore, or nothing when absent.
pg_client_major() {
    command -v pg_restore > /dev/null 2>&1 || return 1
    pg_restore --version 2> /dev/null | grep -oE '[0-9]+' | head -n 1
}

# Installs or upgrades the PostgreSQL client tools (pg_dump/pg_restore) so their
# major version is at least $1 (e.g. 17); with no argument any installed version
# is accepted. Falls back to the official PostgreSQL package repository when the
# distribution one is too old. Restoring a panel backup made by a newer pg_dump
# needs this:   d3x-ui pgclient <major>
pg_upgrade_client() {
    local want="$1" have
    if [[ -n "$want" && ! "$want" =~ ^[0-9]+$ ]]; then
        LOGE "$(xui_tr "Invalid PostgreSQL major version '%s' (expected a number like 17)." "${want}")"
        return 1
    fi
    have=$(pg_client_major)
    if [[ -n "$have" ]]; then
        if [[ -z "$want" || "$have" -ge "$want" ]]; then
            LOGI "$(xui_tr 'PostgreSQL client tools are already installed (version %s).' "${have}")"
            return 0
        fi
        LOGI "$(xui_tr 'Installed PostgreSQL client tools are version %s; version %s or newer is required.' "${have}" "${want}")"
    fi
    if [[ "${running_in_docker}" == "true" ]]; then
        LOGI "Note: packages installed inside the container are lost when the container is recreated."
    fi
    case "${release}" in
        ubuntu | debian | armbian)
            apt-get update >&2 || return 1
            if [[ -z "$want" ]]; then
                apt-get install -y -q postgresql-client >&2 || return 1
            elif ! apt-get install -y -q "postgresql-client-${want}" >&2; then
                LOGI "$(xui_tr 'postgresql-client-%s is not in the distribution repositories; adding the official PostgreSQL apt repository...' "${want}")"
                apt-get install -y -q postgresql-common ca-certificates gnupg >&2 || return 1
                /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y >&2 || return 1
                apt-get install -y -q "postgresql-client-${want}" >&2 || return 1
            fi
            ;;
        fedora | amzn | virtuozzo | rhel | almalinux | rocky | ol | centos)
            local pkg_mgr="dnf"
            command -v dnf > /dev/null 2>&1 || pkg_mgr="yum"
            if [[ -z "$want" ]]; then
                "$pkg_mgr" install -y -q postgresql >&2 || return 1
            elif ! "$pkg_mgr" install -y -q "postgresql${want}" >&2; then
                local elver
                elver=$(rpm -E %rhel 2> /dev/null)
                if [[ ! "$elver" =~ ^[0-9]+$ ]]; then
                    LOGE "$(xui_tr 'Could not determine the Enterprise Linux release; install the PostgreSQL %s client tools manually.' "${want}")"
                    return 1
                fi
                LOGI "$(xui_tr 'postgresql%s is not in the enabled repositories; adding the official PostgreSQL yum repository...' "${want}")"
                "$pkg_mgr" install -y "https://download.postgresql.org/pub/repos/yum/reporpms/EL-${elver}-$(uname -m)/pgdg-redhat-repo-latest.noarch.rpm" >&2 || return 1
                if [[ "$pkg_mgr" == "dnf" ]]; then
                    dnf -qy module disable postgresql >&2 || true
                fi
                "$pkg_mgr" install -y -q "postgresql${want}" >&2 || return 1
            fi
            ;;
        arch | manjaro | parch)
            pacman -Sy --noconfirm postgresql >&2 || return 1
            ;;
        opensuse-tumbleweed | opensuse-leap)
            if [[ -z "$want" ]] || ! zypper -q install -y "postgresql${want}" >&2; then
                zypper -q install -y postgresql >&2 || return 1
            fi
            ;;
        alpine)
            if [[ -z "$want" ]] || ! apk add --no-cache "postgresql${want}-client" >&2; then
                apk add --no-cache postgresql-client >&2 || return 1
            fi
            ;;
        *)
            LOGE "$(xui_tr "Unsupported OS '%s'; install the PostgreSQL client tools manually." "${release}")"
            return 1
            ;;
    esac
    hash -r 2> /dev/null
    have=$(pg_client_major)
    if [[ -n "$want" && ( -z "$have" || "$have" -lt "$want" ) && -x "/usr/pgsql-${want}/bin/pg_restore" ]]; then
        ln -sf "/usr/pgsql-${want}/bin/pg_dump" /usr/local/bin/pg_dump
        ln -sf "/usr/pgsql-${want}/bin/pg_restore" /usr/local/bin/pg_restore
        hash -r 2> /dev/null
        have=$(pg_client_major)
    fi
    if [[ -z "$have" ]]; then
        LOGE "pg_dump/pg_restore are still unavailable after installation."
        return 1
    fi
    if [[ -n "$want" && "$have" -lt "$want" ]]; then
        LOGE "$(xui_tr 'PostgreSQL client tools are version %s after installation but %s or newer is required; install them manually.' "${have}" "${want}")"
        return 1
    fi
    LOGI "$(xui_tr 'PostgreSQL client tools are ready (version %s).' "${have}")"
    return 0
}

# Writes XUI_DB_TYPE/XUI_DB_DSN into the service env file, preserving other entries.
pg_write_env() {
    local dsn="$1" envfile
    envfile="$(xui_env_file_path)"
    install -d -m 755 "$(dirname "$envfile")"
    touch "$envfile"
    sed -i '/^XUI_DB_TYPE=/d; /^XUI_DB_DSN=/d' "$envfile"
    {
        echo "XUI_DB_TYPE=postgres"
        echo "XUI_DB_DSN=${dsn}"
    } >> "$envfile"
    chmod 600 "$envfile"
}

pg_install_server_action() {
    if postgresql_installed; then
        LOGI "PostgreSQL already appears to be installed on this system."
        confirm "Run setup anyway (ensures the xui database/user exist)?" "n" || return 0
    fi
    LOGI "Installing PostgreSQL server and creating a dedicated user/database..."
    local dsn
    dsn=$(pg_install_local)
    if [[ $? -ne 0 || -z "$dsn" ]]; then
        LOGE "PostgreSQL installation failed."
        return 1
    fi
    PG_LAST_DSN="$dsn"
    pg_ensure_client || LOGE "Could not install pg_dump/pg_restore (panel DB backup may be unavailable)."
    echo ""
    LOGI "PostgreSQL is installed and ready."
    echo -e "${green}$(xui_tr 'Connection DSN: %s' "${dsn}")${plain}"
    echo -e "${yellow}$(xui_tr 'Use option 2 to migrate your SQLite data and switch the panel to PostgreSQL.')${plain}"
}

# Copies the current SQLite data into PostgreSQL, then switches the panel over.
migrate_to_postgres() {
    if [[ ! -x "${xui_folder}/d3x-ui" ]]; then
        LOGE "d3x-ui is not installed."
        return 1
    fi
    echo ""
    echo -e "${yellow}$(xui_tr 'This copies your current SQLite data into a PostgreSQL database,')${plain}"
    echo -e "${yellow}$(xui_tr 'then switches the panel to PostgreSQL and restarts it.')${plain}"
    echo -e "${red}$(xui_tr 'Any existing panel tables in the destination will be cleared and overwritten.')${plain}"
    confirm "Continue?" "n" || return 0

    local dsn="" pg_mode
    if [[ -n "$PG_LAST_DSN" ]]; then
        echo -e "$(xui_tr 'A PostgreSQL database was created in this session:')"
        echo -e "  ${green}${PG_LAST_DSN}${plain}"
        confirm "Migrate into this database?" "y" && dsn="$PG_LAST_DSN"
    fi

    if [[ -z "$dsn" ]]; then
        echo ""
        echo -e "${green}$(xui_tr '\t1. Install PostgreSQL locally and create a dedicated user/db (recommended)')${plain}"
        echo -e "${green}$(xui_tr '\t2. Use an existing PostgreSQL server (enter DSN)')${plain}"
        read -rp "$(xui_tr 'Choose [1]:')" pg_mode
        pg_mode="${pg_mode:-1}"
        if [[ "$pg_mode" == "2" ]]; then
            while [[ -z "$dsn" ]]; do
                read -rp "$(xui_tr 'Enter PostgreSQL DSN (postgres://user:pass@host:port/dbname?sslmode=disable):')" dsn
                dsn="${dsn// /}"
            done
        else
            LOGI "Installing PostgreSQL locally (this may take a moment)..."
            dsn=$(pg_install_local)
            if [[ $? -ne 0 || -z "$dsn" ]]; then
                LOGE "PostgreSQL installation failed. Aborting migration."
                return 1
            fi
            PG_LAST_DSN="$dsn"
        fi
    fi

    pg_ensure_client || LOGE "Could not install pg_dump/pg_restore (in-panel DB backup/restore may be unavailable)."

    LOGI "Stopping panel to take a consistent snapshot..."
    stop 0 > /dev/null 2>&1

    echo ""
    LOGI "Migrating data into PostgreSQL..."
    if ! ${xui_folder}/d3x-ui migrate-db --dsn "$dsn"; then
        LOGE "Migration failed. The panel was NOT switched to PostgreSQL."
        start 0 > /dev/null 2>&1
        return 1
    fi

    pg_write_env "$dsn"
    LOGI "$(xui_tr 'Wrote database settings to %s (XUI_DB_TYPE=postgres).' "$(xui_env_file_path)")"
    LOGI "Restarting panel on PostgreSQL..."
    restart 0
    sleep 1
    if check_status; then
        LOGI "Migration complete. The panel is now running on PostgreSQL."
    else
        LOGE "Panel did not come up. Check logs (main menu option 17). Your SQLite data is left intact."
    fi
}

postgresql_menu() {
    echo -e "${green}$(xui_tr '\t1. Install PostgreSQL (server + client + xui db)')${plain}"
    echo -e "${green}$(xui_tr '\t2. Migrate SQLite -> PostgreSQL')${plain}"
    echo -e "${green}$(xui_tr '\t3. Status (clusters & port 5432)')${plain}"
    echo -e "${green}$(xui_tr '\t4. Start PostgreSQL')${plain}"
    echo -e "${green}$(xui_tr '\t5. Stop PostgreSQL')${plain}"
    echo -e "${green}$(xui_tr '\t6. Restart PostgreSQL')${plain}"
    echo -e "${green}$(xui_tr '\t7. Enable Autostart on boot')${plain}"
    echo -e "${green}$(xui_tr '\t8. View PostgreSQL Log')${plain}"
    echo -e "${green}$(xui_tr '\t9. Convert SQLite .db <-> .dump')${plain}"
    echo -e "${green}$(xui_tr '\t10. Install/Upgrade client tools (pg_dump/pg_restore)')${plain}"
    echo -e "${green}$(xui_tr '\t0. Back to Main Menu')${plain}"
    read -rp "$(xui_tr 'Choose an option:')" choice
    case "$choice" in
        0)
            show_menu
            ;;
        1)
            pg_install_server_action
            postgresql_menu
            ;;
        2)
            migrate_to_postgres
            postgresql_menu
            ;;
        3)
            postgresql_status
            postgresql_menu
            ;;
        4)
            postgresql_start
            postgresql_menu
            ;;
        5)
            postgresql_stop
            postgresql_menu
            ;;
        6)
            postgresql_restart
            postgresql_menu
            ;;
        7)
            postgresql_enable
            postgresql_menu
            ;;
        8)
            postgresql_log
            postgresql_menu
            ;;
        9)
            migrate_db_prompt
            postgresql_menu
            ;;
        10)
            read -rp "$(xui_tr 'Required PostgreSQL major version (empty = any):')" pg_client_ver
            pg_upgrade_client "$pg_client_ver"
            postgresql_menu
            ;;
        *)
            echo -e "${red}$(xui_tr 'Invalid option. Please select a valid number.\n')${plain}"
            postgresql_menu
            ;;
    esac
}

# Convert between the panel's SQLite database and a portable .dump (SQL text)
# file using the bundled d3x-ui binary. With no arguments it dumps the installed
# panel database; an optional second argument overrides the output path.
#   d3x-ui migrateDB [file.db|file.dump] [output]
migrate_db() {
    local input="$1" output="$2"
    local default_db="/etc/d3x-ui/d3x-ui.db"
    local bin="${xui_folder}/d3x-ui"

    [[ -z "$input" ]] && input="$default_db"

    if [[ ! -x "$bin" ]]; then
        LOGE "$(xui_tr 'd3x-ui binary not found at %s. Is the panel installed?' "${bin}")"
        return 1
    fi

    if ! "$bin" migrate-db -h 2>&1 | grep -q -- '-dump'; then
        LOGE "This d3x-ui build does not support .db <-> .dump conversion yet."
        LOGE "Update the panel first (d3x-ui update) to a version with 'migrate-db --dump/--restore'."
        return 1
    fi

    if [[ ! -f "$input" ]]; then
        LOGE "$(xui_tr 'Input file not found: %s' "${input}")"
        echo -e "${green}$(xui_tr 'Usage: d3x-ui migrateDB [file.db|file.dump] [output]')${plain}"
        return 1
    fi

    local mode
    case "$input" in
        *.db | *.sqlite | *.sqlite3)
            mode="dump"
            ;;
        *.dump | *.sql)
            mode="restore"
            ;;
        *)
            if head -c 16 "$input" | grep -q "SQLite format 3"; then
                mode="dump"
            else
                mode="restore"
            fi
            ;;
    esac

    if [[ "$mode" == "dump" ]]; then
        [[ -z "$output" ]] && output="${input%.*}.dump"
        if [[ -f "$output" ]]; then
            confirm "Output ${output} already exists and will be overwritten. Continue?" "n" || return 0
        fi
        LOGI "Dumping SQLite database to SQL text:"
        echo -e "${green}$(xui_tr '%s -> %s' "${input}" "${output}")${plain}"
        if "$bin" migrate-db --src "$input" --dump "$output"; then
            LOGI "$(xui_tr 'Done. Wrote %s.' "${output}")"
        else
            LOGE "Dump failed."
            return 1
        fi
    else
        [[ -z "$output" ]] && output="${input%.*}.db"
        if [[ "$output" == "$default_db" ]] && check_status > /dev/null 2>&1; then
            LOGE "$(xui_tr 'Refusing to restore into the live database (%s) while d3x-ui is running.' "${default_db}")"
            LOGE "Stop the panel first (d3x-ui stop) or choose a different output path."
            return 1
        fi
        if [[ -f "$output" ]]; then
            confirm "Output ${output} already exists and will be overwritten. Continue?" "n" || return 0
            rm -f "$output"
        fi
        LOGI "Rebuilding SQLite database from SQL text:"
        echo -e "${green}$(xui_tr '%s -> %s' "${input}" "${output}")${plain}"
        if "$bin" migrate-db --restore "$input" --out "$output"; then
            LOGI "$(xui_tr 'Done. Created %s.' "${output}")"
        else
            LOGE "Restore failed."
            rm -f "$output"
            return 1
        fi
    fi
}

# Interactive wrapper around migrate_db for the menu: prompts for the paths and
# lets migrate_db auto-detect the direction.
migrate_db_prompt() {
    local default_db="/etc/d3x-ui/d3x-ui.db"
    local input output
    echo -e "${green}$(xui_tr 'Convert between a SQLite .db and a portable .dump (direction auto-detected).')${plain}"
    read -rp "$(xui_tr 'Input file [%s]:' "${default_db}")" input
    input="${input:-$default_db}"
    read -rp "$(xui_tr 'Output file (leave empty to auto-name next to input):')" output
    migrate_db "$input" "$output"
}

show_usage() {
    echo "┌──────────────────────────────────────────────────────────────────┐"
    usage_title "d3x-ui control menu usages (subcommands):"
    echo "│                                                                  │"
    usage_line "d3x-ui" "Admin Management Script"
    usage_line "d3x-ui start" "Start"
    usage_line "d3x-ui stop" "Stop"
    usage_line "d3x-ui restart" "Restart"
    usage_line "d3x-ui restart-xray" "Restart Xray"
    usage_line "d3x-ui status" "Current Status"
    usage_line "d3x-ui settings" "Current Settings"
    usage_line "d3x-ui enable" "Enable Autostart on OS Startup"
    usage_line "d3x-ui disable" "Disable Autostart on OS Startup"
    usage_line "d3x-ui log" "Check logs"
    usage_line "d3x-ui banlog" "Check Fail2ban ban logs"
    usage_line "d3x-ui update" "Update"
    usage_line "d3x-ui update-dev" "Update to Dev channel (latest)"
    usage_line "d3x-ui update-all-geofiles" "Update all geo files"
    usage_line "d3x-ui migrateDB [file]" "Convert .db <-> .dump (SQLite)"
    usage_line "d3x-ui pgclient [ver]" "Upgrade pg_dump/pg_restore tools"
    usage_line "d3x-ui legacy" "Legacy version"
    usage_line "d3x-ui install" "Install"
    usage_line "d3x-ui uninstall" "Uninstall"
    echo "└──────────────────────────────────────────────────────────────────┘"
}

show_menu() {
    echo
    echo "╔────────────────────────────────────────────────╗"
    menu_title "D3X-UI Panel Management Script"
    menu_line "0" "Exit Script"
    echo "│────────────────────────────────────────────────│"
    menu_line "1" "Install"
    menu_line "2" "Update"
    menu_line "3" "Update to Dev Channel (latest commit)"
    menu_line "4" "Update Menu"
    menu_line "5" "Legacy Version"
    menu_line "6" "Uninstall"
    echo "│────────────────────────────────────────────────│"
    menu_line "7" "Reset Username & Password"
    menu_line "8" "Reset Web Base Path"
    menu_line "9" "Reset Settings"
    menu_line "10" "Change Port"
    menu_line "11" "View Current Settings"
    echo "│────────────────────────────────────────────────│"
    menu_line "12" "Start"
    menu_line "13" "Stop"
    menu_line "14" "Restart"
    menu_line "15" "Restart Xray"
    menu_line "16" "Check Status"
    menu_line "17" "Logs Management"
    echo "│────────────────────────────────────────────────│"
    menu_line "18" "Enable Autostart"
    menu_line "19" "Disable Autostart"
    echo "│────────────────────────────────────────────────│"
    menu_line "20" "SSL Certificate Management"
    menu_line "21" "Cloudflare SSL Certificate"
    menu_line "22" "IP Limit Management"
    menu_line "23" "Firewall Management"
    menu_line "24" "SSH Port Forwarding Management"
    menu_line "25" "PostgreSQL Management"
    echo "│────────────────────────────────────────────────│"
    menu_line "26" "Enable BBR"
    menu_line "27" "Update Geo Files"
    menu_line "28" "Speedtest by Ookla"
    echo "╚────────────────────────────────────────────────╝"
    show_status
    echo && read -rp "$(xui_tr 'Please enter your selection [0-28]:') " num

    case "${num}" in
        0)
            exit 0
            ;;
        1)
            check_uninstall && install
            ;;
        2)
            check_install && update
            ;;
        3)
            check_install && update_dev
            ;;
        4)
            check_install && update_menu
            ;;
        5)
            check_install && legacy_version
            ;;
        6)
            check_install && uninstall
            ;;
        7)
            check_install && reset_user
            ;;
        8)
            check_install && reset_webbasepath
            ;;
        9)
            check_install && reset_config
            ;;
        10)
            check_install && set_port
            ;;
        11)
            check_install && check_config
            ;;
        12)
            check_install && start
            ;;
        13)
            check_install && stop
            ;;
        14)
            check_install && restart
            ;;
        15)
            check_install && restart_xray
            ;;
        16)
            check_install && status
            ;;
        17)
            check_install && show_log
            ;;
        18)
            check_install && enable
            ;;
        19)
            check_install && disable
            ;;
        20)
            ssl_cert_issue_main
            ;;
        21)
            ssl_cert_issue_CF
            ;;
        22)
            iplimit_main
            ;;
        23)
            firewall_menu
            ;;
        24)
            SSH_port_forwarding
            ;;
        25)
            postgresql_menu
            ;;
        26)
            bbr_menu
            ;;
        27)
            update_geo
            ;;
        28)
            run_speedtest
            ;;
        *)
            LOGE "Please enter the correct number [0-28]"
            ;;
    esac
}

if [[ $# -gt 0 ]]; then
    case $1 in
        "start")
            check_install 0 && start 0
            ;;
        "stop")
            check_install 0 && stop 0
            ;;
        "restart")
            check_install 0 && restart 0
            ;;
        "restart-xray")
            check_install 0 && restart_xray 0
            ;;
        "status")
            check_install 0 && status 0
            ;;
        "settings")
            check_install 0 && check_config 0
            ;;
        "enable")
            check_install 0 && enable 0
            ;;
        "disable")
            check_install 0 && disable 0
            ;;
        "log")
            check_install 0 && show_log 0
            ;;
        "banlog")
            check_install 0 && show_banlog 0
            ;;
        "setup-fail2ban")
            setup_fail2ban_iplimit
            ;;
        "update")
            check_install 0 && update 0
            ;;
        "update-dev")
            check_install 0 && update_dev 0
            ;;
        "legacy")
            check_install 0 && legacy_version 0
            ;;
        "install")
            check_uninstall 0 && install 0
            ;;
        "uninstall")
            check_install 0 && uninstall 0
            ;;
        "update-all-geofiles")
            geo_updated=0
            if check_install 0 && update_all_geofiles 0; then
                [[ $geo_updated -eq 0 ]] || restart 0
            fi
            ;;
        "migrateDB")
            migrate_db "$2" "$3"
            ;;
        "pgclient")
            pg_upgrade_client "$2"
            ;;
        *) show_usage ;;
    esac
else
    show_menu
fi
