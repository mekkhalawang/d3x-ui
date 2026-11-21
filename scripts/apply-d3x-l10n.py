#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Apply Chinese localization to d3x-ui.sh.

- inserts the language resolution + xui_zh/xui_tr/xui_width block
- hooks LOGD/LOGE/LOGI so literal messages translate automatically
- wraps echo -e / read -rp strings in xui_tr, rewriting ${var} to %s args
- rebuilds the show_menu / show_usage boxes with width-aware helpers
Pure command lines (ssh/docker/URLs) stay English. Reports keys missing
from the translation table and lines it could not parse.
"""
import re, sys, io

REPO = "E:/D3X-UI/repo"
SRC = f"{REPO}/d3x-ui.sh"
exec(io.open(f"{REPO}/scripts/d3x-l10n-zh.py", encoding="utf-8").read(), TABLE := {})
TABLE = TABLE["TABLE"]

src = io.open(SRC, encoding="utf-8").read()
lines = src.splitlines(keepends=False)

COLOR = re.compile(r"\$\{(?:green|red|yellow|blue|plain)\}")
VAR = re.compile(r"\$(?:\{[^}]+\}|[A-Za-z_][A-Za-z0-9_]*|[0-9])")
STR = re.compile(r'^(?P<pre>.*?)(?P<cmd>LOGI|LOGE|LOGD|echo -e|read -rp)(?P<sp>\s+")(?P<s>(?:[^"\\]|\\.)*)(?P<post>".*)$')

def unescape_dq(s):
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s) and s[i + 1] in '"\\$`':
            out.append(s[i + 1]); i += 2
        else:
            out.append(c); i += 1
    return "".join(out)

def quote_key(k):
    if "'" not in k:
        return "'" + k + "'"
    if '"' not in k and "$" not in k and "`" not in k:
        return '"' + k + '"'
    return '"' + k.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$') + '"'

needed = {}   # exact runtime key -> translation (may alias a stripped dict entry)
manual = []
skipped = []
changed = 0

def lookup(exact):
    if exact in TABLE:
        return TABLE[exact]
    st = exact.strip()
    if st in TABLE:
        return TABLE[st]
    return None

def transform_line(ln):
    global changed
    if "$*" in ln or "xui_tr" in ln or "menu_line" in ln or "usage_line" in ln or "menu_title" in ln or "usage_title" in ln:
        return ln                       # helpers / already-localized lines
    m = STR.match(ln)
    if not m:
        if re.search(r'\b(LOGI|LOGE|LOGD|echo -e|read -rp)\b', ln):
            manual.append(ln)
        return ln
    s_raw = m.group("s")
    s = unescape_dq(s_raw)
    cmd = m.group("cmd")
    # tokenize: colors, other vars, text
    toks, pos = [], 0
    for t in re.finditer(r"\$\{(?:green|red|yellow|blue|plain)\}|\$(?:\{[^}]+\}|[A-Za-z_][A-Za-z0-9_]*|[0-9])", s):
        if t.start() > pos:
            toks.append(("t", s[pos:t.start()]))
        toks.append(("c" if COLOR.fullmatch(t.group(0)) else "v", t.group(0)))
        pos = t.end()
    if pos < len(s):
        toks.append(("t", s[pos:]))
    if any(k == "v" and v == "$*" for k, v in toks):
        return ln
    # pure passthrough / commands: leave as-is
    plain_txt = "".join(v for k, v in toks if k == "t")
    if not COLOR.search(s) and not VAR.search(s):
        pass
    if re.match(r"^(ssh |http://localhost|docker |bash <\()", plain_txt.strip()):
        skipped.append(plain_txt[:60]); return ln
    vars_ = [v for k, v in toks if k == "v"]
    tmpl = "".join(("%s" if k == "v" else ("" if k == "c" else v)) for k, v in toks)
    if tmpl.strip() == "%s" and len(vars_) == 1:
        return ln                       # e.g. echo -e "${info}"
    if tmpl.strip() and not tmpl.strip("│┌┐└┘─╔╗╚╝═║━┃┃ \t\n"):
        return ln                       # pure box-drawing decoration
    if "$(" in tmpl:
        manual.append(f"CMD-SUBST: {tmpl[:70]!r}  ||  {ln.strip()[:80]}")
        return ln
    key = tmpl.strip()
    tr = lookup(key)
    if tr is None:
        manual.append(f"MISSING KEY: {key!r}  ||  {ln.strip()[:100]}")
        return ln
    needed[key] = tr
    args = " ".join(f'"{v}"' for v in vars_)
    call = "$(xui_tr " + quote_key(key) + ((" " + args) if args else "") + ")"
    colors = [v for k, v in toks if k == "c"]
    first = colors[0] if colors else ""
    last = colors[-1] if colors else ""
    if cmd.startswith("LOG"):
        if not vars_ and not colors:
            return ln                   # literal LOG: hook translates
    # sp carries the opening quote and post the closing quote; do not add more
    new = f'{m.group("pre")}{cmd}{m.group("sp")}{first}{call}{last}{m.group("post")}'
    changed += 1
    return new

# ---- 1. build table text (all entries + exact-key aliases) ----
def case_entry(k, v):
    kk = k.replace("\\", "\\\\").replace('"', '\\"')
    vv = v.replace("\\", "\\\\").replace('"', '\\"')
    return f'        "{kk}") printf \'%s\' "{vv}" ;;'

def build_table(extra_alias):
    out = []
    for k, v in TABLE.items():
        out.append(case_entry(k, v))
    for k, v in extra_alias.items():
        if k not in TABLE:
            out.append(case_entry(k, v))
    return "\n".join(out)

# ---- 2. helpers + scaffolding ----
SCAFFOLD = '''\
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
__TABLE__
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
    printf '\\u2502  %b%s%b%*s\\u2502\\n' "$green" "$t" "$plain" $((48 - 2 - $(xui_width "$t"))) ""
}
menu_line() {
    local t; t="$(xui_tr "$2")"
    printf '\\u2502  %b%s.%b %s%*s\\u2502\\n' "$green" "$1" "$plain" "$t" $((44 - ${#1} - $(xui_width "$t"))) ""
}
usage_title() {
    local t; t="$(xui_tr "$1")"
    printf '\\u2502  %b%s%b%*s\\u2502\\n' "$blue" "$t" "$plain" $((66 - 2 - $(xui_width "$t"))) ""
}
usage_line() {
    local t; t="$(xui_tr "$2")"
    printf '\\u2502  %b%s%b%*s- %s%*s\\u2502\\n' "$blue" "$1" "$plain" $((29 - ${#1})) "" "$t" $((33 - $(xui_width "$t"))) ""
}
'''

# ---- 3. replace the two boxes wholesale (frames built to exact widths) ----
_D = chr(0x2500)
MENU_ITEMS = [
    ("", "D3X-UI Panel Management Script", "title"),
    ("0", "Exit Script", "l"), ("sep",),
    ("1", "Install"), ("2", "Update"),
    ("3", "Update to Dev Channel (latest commit)"), ("4", "Update Menu"),
    ("5", "Legacy Version"), ("6", "Uninstall"), ("sep",),
    ("7", "Reset Username & Password"), ("8", "Reset Web Base Path"),
    ("9", "Reset Settings"), ("10", "Change Port"),
    ("11", "View Current Settings"), ("sep",),
    ("12", "Start"), ("13", "Stop"), ("14", "Restart"),
    ("15", "Restart Xray"), ("16", "Check Status"), ("17", "Logs Management"),
    ("sep",),
    ("18", "Enable Autostart"), ("19", "Disable Autostart"), ("sep",),
    ("20", "SSL Certificate Management"), ("21", "Cloudflare SSL Certificate"),
    ("22", "IP Limit Management"), ("23", "Firewall Management"),
    ("24", "SSH Port Forwarding Management"), ("25", "PostgreSQL Management"),
    ("sep",),
    ("26", "Enable BBR"), ("27", "Update Geo Files"), ("28", "Speedtest by Ookla"),
]
USAGE_ITEMS = [
    ("", "d3x-ui control menu usages (subcommands):", "title"), ("blank",),
    ("d3x-ui", "Admin Management Script"), ("d3x-ui start", "Start"),
    ("d3x-ui stop", "Stop"), ("d3x-ui restart", "Restart"),
    ("d3x-ui restart-xray", "Restart Xray"), ("d3x-ui status", "Current Status"),
    ("d3x-ui settings", "Current Settings"),
    ("d3x-ui enable", "Enable Autostart on OS Startup"),
    ("d3x-ui disable", "Disable Autostart on OS Startup"),
    ("d3x-ui log", "Check logs"), ("d3x-ui banlog", "Check Fail2ban ban logs"),
    ("d3x-ui update", "Update"), ("d3x-ui update-dev", "Update to Dev channel (latest)"),
    ("d3x-ui update-all-geofiles", "Update all geo files"),
    ("d3x-ui migrateDB [file]", "Convert .db <-> .dump (SQLite)"),
    ("d3x-ui pgclient [ver]", "Upgrade pg_dump/pg_restore tools"),
    ("d3x-ui legacy", "Legacy version"), ("d3x-ui install", "Install"),
    ("d3x-ui uninstall", "Uninstall"),
]
rows = ["    echo", '    echo "' + chr(0x2554) + _D * 48 + chr(0x2557) + '"']
for item in MENU_ITEMS:
    if item[0] == "sep":
        rows.append('    echo "' + chr(0x2502) + _D * 48 + chr(0x2502) + '"')
    elif len(item) > 2 and item[2] == "title":
        rows.append('    menu_title "%s"' % item[1])
    else:
        rows.append('    menu_line "%s" "%s"' % (item[0], item[1]))
rows.append('    echo "' + chr(0x255a) + _D * 48 + chr(0x255d) + '"')
MENU_NEW = "show_menu() {\n" + "\n".join(rows) + "\n" + \
    '    show_status\n    echo && read -rp "$(xui_tr \'Please enter your selection [0-28]:\') " num'

rows = ['    echo "' + chr(0x250c) + _D * 66 + chr(0x2510) + '"']
for item in USAGE_ITEMS:
    if item[0] == "blank":
        rows.append('    echo "' + chr(0x2502) + " " * 66 + chr(0x2502) + '"')
    elif len(item) > 2 and item[2] == "title":
        rows.append('    usage_title "%s"' % item[1])
    else:
        rows.append('    usage_line "%s" "%s"' % (item[0], item[1]))
rows.append('    echo "' + chr(0x2514) + _D * 66 + chr(0x2518) + '"')
USAGE_NEW = "show_usage() {\n" + "\n".join(rows) + "\n}"

text = "\n".join(lines)

# hook LOG helpers
text = text.replace(
    'function LOGD() {\n    echo -e "${yellow}[DEG] $* ${plain}"\n}',
    'function LOGD() {\n    echo -e "${yellow}[DEG] $(xui_tr "$*") ${plain}"\n}')
text = text.replace(
    'function LOGE() {\n    echo -e "${red}[ERR] $* ${plain}"\n}',
    'function LOGE() {\n    echo -e "${red}[ERR] $(xui_tr "$*") ${plain}"\n}')
text = text.replace(
    'function LOGI() {\n    echo -e "${green}[INF] $* ${plain}"\n}',
    'function LOGI() {\n    echo -e "${green}[INF] $(xui_tr "$*") ${plain}"\n}')

# replace the boxes (show_usage wholesale; show_menu only up to the read line,
# keeping the case dispatch that follows). Anchor on the line start so a call
# like `before_show_menu() {` cannot swallow the match.
def replace_fn(text, header, new_body):
    i = text.index("\n" + header) + 1
    j = text.index("\n}", i) + 2
    return text[:i] + new_body + text[j:]

def replace_menu(text):
    header = "show_menu() {"
    i = text.index("\n" + header) + 1
    marker = 'echo && read -rp "Please enter your selection [0-28]: " num'
    j = text.index(marker, i) + len(marker)
    return text[:i] + MENU_NEW + text[j:]

text = replace_fn(text, "show_usage() {", USAGE_NEW)
text = replace_menu(text)

# line transform
out_lines = [transform_line(l) for l in text.splitlines()]
text = "\n".join(out_lines) + "\n"

# insert scaffolding after the color vars (after 'plain=' line)
anchor = "plain='\\033[0m'\n"
pos = text.index(anchor) + len(anchor)
scaffold = SCAFFOLD.replace("__TABLE__", build_table({k: v for k, v in needed.items() if k not in TABLE}))
text = text[:pos] + "\n" + scaffold + text[pos:]

io.open(SRC, "w", encoding="utf-8", newline="\n").write(text)
print(f"call sites rewritten: {changed}")
print(f"table entries: {len(TABLE)} + aliases: {len([k for k in needed if k not in TABLE])}")
print(f"skipped (kept English): {len(skipped)}")
for s in skipped:
    print(f"  skip: {s}")
print(f"manual/missing: {len(manual)}")
for s in manual:
    print(f"  {s}")
