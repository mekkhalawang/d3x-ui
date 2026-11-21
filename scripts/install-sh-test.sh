#!/bin/bash
# Regression tests for install.sh: credential selection + localization.
#
# The functions are extracted straight from install.sh so the test always
# exercises the real implementation instead of a copy that can drift.
#
# Usage: bash scripts/install-sh-test.sh
set -u

# The colour variables install.sh uses in its messages. They are defined here
# too: the extracted functions reference them, and `set -u` turns a missing
# one into an unbound-variable error that aborts the whole test run.
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
plain='\033[0m'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/install.sh"
# Git Bash hands out a Windows-style path (C:/.../tmp.XXXX) from mktemp, and
# the inner bash -c calls below need a POSIX path anyway. One POSIX directory
# serves both, so mktemp is not used at all.
TMP_POSIX="/tmp/d3x-install-sh-test.$$"
mkdir -p "$TMP_POSIX"
# The cleanup runs with MSYS2_ARG_CONV_EXCL set: without it the runtime turns
# the POSIX path into a drive-letter path, and the sandbox refuses to remove
# anything that looks like an embedded drive prefix.
#
# The EXIT trap is inherited by every subshell, so it fires when a subshell
# exits too. BASHPID identifies the shell that is actually running the trap
# handler: only the outermost one (the one that created the directory) may
# delete it, otherwise a subshell would wipe the scratch directory while the
# test is still using it.
cleanup() {
    [[ "$BASHPID" == "$MAIN_PID" ]] || return 0
    MSYS2_ARG_CONV_EXCL='*' MSYS_NO_PATHCONV=1 rm -rf -- "$TMP_POSIX" 2> /dev/null
}
MAIN_PID="$BASHPID"
trap cleanup EXIT

pass=0
fail=0

check() {
    local name="$1" cond="$2"
    if eval "$cond"; then
        printf 'PASS  %s\n' "$name"
        pass=$((pass + 1))
    else
        printf 'FAIL  %s\n' "$name"
        fail=$((fail + 1))
    fi
}

# check_fails <name> <command...>
# Asserts that a command exits non-zero. The command is run directly instead
# of behind a `!` prefix: `!` makes bash fork a subshell, and the inherited
# EXIT trap would then delete the scratch directory while the test runs.
check_fails() {
    local name="$1"
    shift
    if "$@" > /dev/null 2>&1; then
        printf 'FAIL  %s\n' "$name"
        fail=$((fail + 1))
    else
        printf 'PASS  %s\n' "$name"
        pass=$((pass + 1))
    fi
}

# Extract one function definition (from its header to the first closing brace
# at column 0) out of install.sh.
extract() {
    local start end
    start=$(grep -n "^$1() {" "$SRC" | cut -d: -f1)
    if [[ -z "$start" ]]; then
        echo "cannot locate $1() in $SRC" >&2
        exit 1
    fi
    end=$(awk -v s="$start" 'NR>s && /^}/ {print NR; exit}' "$SRC")
    sed -n "${start},${end}p" "$SRC"
}

# The localization block: language resolution + xui_tr + width helpers.
awk '/^case "\${XUI_LANG:-zh\}"/,/^xui_folder=/' "$SRC" | head -n -1 > "${TMP_POSIX}/loc.sh"
extract gen_random_string > "${TMP_POSIX}/gen.sh"
extract select_credentials > "${TMP_POSIX}/cred.sh"
extract setup_self_signed_certificate > "${TMP_POSIX}/selfsigned.sh"
# The helper validates its address with is_ipv4(), so that has to be loaded
# alongside it.
extract is_ipv4 > "${TMP_POSIX}/is_ipv4.sh"

# shellcheck disable=SC1090
source "${TMP_POSIX}/gen.sh"
# shellcheck disable=SC1090
source "${TMP_POSIX}/loc.sh"
# shellcheck disable=SC1090
source "${TMP_POSIX}/cred.sh"
# shellcheck disable=SC1090
source "${TMP_POSIX}/is_ipv4.sh"
# shellcheck disable=SC1090
source "${TMP_POSIX}/selfsigned.sh"

# Run select_credentials in a subshell so its globals cannot leak between
# cases. The here-string feeds stdin; bash only renders the -p prompt when
# stdin is a terminal, so the captured output holds the stderr notices and
# the resolved values, not the prompt text itself.
inter() {
    local input="$1"
    (
        unset XUI_USERNAME XUI_PASSWORD
        NONINTERACTIVE=0
        select_credentials <<< "$input"
        printf 'u=%s p=%s\n' "$SELECTED_USERNAME" "$SELECTED_PASSWORD"
    ) 2>&1
}

noninter() {
    (
        unset XUI_USERNAME XUI_PASSWORD
        NONINTERACTIVE=1
        select_credentials
        printf 'u=%s p=%s\n' "$SELECTED_USERNAME" "$SELECTED_PASSWORD"
    ) 2>&1
}

echo '--- select_credentials ---'

out=$(noninter)
check 'non-interactive random username' 'grep -qE "^u=[A-Za-z0-9]{10} " <<< "$out"'
check 'non-interactive random password' 'grep -qE " p=[A-Za-z0-9]{10}$" <<< "$out"'
check 'non-interactive username != password' '! grep -qE "^u=([A-Za-z0-9]{10}) p=\1$" <<< "$out"'

out=$(
    (
        XUI_USERNAME='envuser' XUI_PASSWORD='envpass'
        NONINTERACTIVE=1
        select_credentials
        printf 'u=%s p=%s\n' "$SELECTED_USERNAME" "$SELECTED_PASSWORD"
    ) 2>&1
)
check 'env vars win outright' 'grep -q "^u=envuser p=envpass$" <<< "$out"'

out=$(
    (
        XUI_USERNAME='envuser'
        unset XUI_PASSWORD
        NONINTERACTIVE=1
        select_credentials
        printf 'u=%s p=%s\n' "$SELECTED_USERNAME" "$SELECTED_PASSWORD"
    ) 2>&1
)
check 'env username with random password' 'grep -qE "^u=envuser p=[A-Za-z0-9]{10}$" <<< "$out"'

out=$(inter $'n\n')
check 'interactive "n" keeps random values' 'grep -qE "^u=[A-Za-z0-9]{10} p=[A-Za-z0-9]{10}$" <<< "$out"'

out=$(inter $'\n')
check 'interactive empty keeps random values' 'grep -qE "^u=[A-Za-z0-9]{10} p=[A-Za-z0-9]{10}$" <<< "$out"'

out=$(inter $'y\nmyadmin\ns3cret!\ns3cret!\n')
check 'interactive "y" takes custom values' 'grep -q "^u=myadmin p=s3cret!$" <<< "$out"'

out=$(inter $'y\nadmin\nwrong\nadmin\nright\nright\n')
check 'password mismatch re-prompts' 'grep -q "^u=admin p=right$" <<< "$out"'
check 'password mismatch is reported' 'grep -q "密码不一致" <<< "$out"'

out=$(inter $'y\n\nadmin\npass\npass\n')
check 'empty username re-prompts' 'grep -q "^u=admin p=pass$" <<< "$out"'
check 'empty username is reported' 'grep -q "用户名不能为空" <<< "$out"'

out=$(inter $'y\nadmin\n\npass\npass\n')
check 'empty password re-prompts' 'grep -q "^u=admin p=pass$" <<< "$out"'
check 'empty password is reported' 'grep -q "密码不能为空" <<< "$out"'

out=$(inter $'maybe\nn\n')
check 'invalid yes/no answer re-asks' 'grep -q "请回答 yes 或 no" <<< "$out"'

long=$(printf 'a%.0s' $(seq 1 257))
out=$(inter $'y\n'"$long"$'\nadmin\npass\npass\n')
check 'oversize username rejected' 'grep -q "不能超过 256" <<< "$out"'
check 'oversize username re-prompts' 'grep -q "^u=admin p=pass$" <<< "$out"'

exact=$(printf 'a%.0s' $(seq 1 256))
out=$(inter $'y\n'"$exact"$'\npass\npass\n')
check '256-char username accepted' 'grep -q "^u=${exact} p=pass$" <<< "$out"'

out=$(inter $'y\nad min\np a$$ w0rd!\np a$$ w0rd!\n')
check 'special characters preserved' 'grep -qF "u=ad min p=p a\$\$ w0rd!" <<< "$out"'

out=$(inter $'y\n  spaced  \n  keep me  \n  keep me  \n')
check 'username is trimmed' 'grep -q "^u=spaced " <<< "$out"'
check 'password is not trimmed' 'grep -qF "p=  keep me  " <<< "$out"'

echo
echo '--- localization ---'

# The localization checks run the block in a child process so each case can
# pick its own XUI_LANG. They go through a helper script instead of an inline
# `bash -c` string: nested quoting around prompt texts that contain spaces,
# parentheses and dots is error-prone, and a helper file keeps the prompt
# text verbatim.
cat > "${TMP_POSIX}/loc-probe.sh" <<'PROBE'
source "$1/loc.sh"
case "$2" in
    resolved) printf '%s\n' "$XUI_LANG_RESOLVED" ;;
    unknown) printf '%s\n' "$(xui_tr 'Some string not in the table')" ;;
    hint) printf '%s\n' "$(xui_tr 'Please answer yes or no (Enter defaults to No).')" ;;
    title) printf '%s\n' "$(xui_width "$(xui_box_title 'SSL Certificate Setup (RECOMMENDED)')")" ;;
    allkeys)
        unresolved=0
        while IFS= read -r k; do
            [[ -z "$k" ]] && continue
            [[ "$(xui_zh "$k")" == "$k" ]] && unresolved=$((unresolved + 1))
        done < "$1/table-keys.txt"
        printf 'unresolved=%s\n' "$unresolved"
        ;;
    allused)
        untranslated=0
        while IFS= read -r k; do
            [[ -z "$k" ]] && continue
            [[ "$(xui_zh "$k")" == "$k" ]] && untranslated=$((untranslated + 1))
        done < "$1/used-keys.txt"
        printf 'untranslated=%s\n' "$untranslated"
        ;;
esac
PROBE

# The keys the translation table defines, and the keys the installer asks for.
grep -oE '^        "[^"]*"\) printf' "$SRC" \
    | sed -E 's/^        "(.*)"\) printf$/\1/' > "${TMP_POSIX}/table-keys.txt"
{
    grep -oE "xui_tr '[^']*'" "$SRC" | sed -E "s/^xui_tr '//; s/'$//"
    grep -oE 'xui_tr "[^"]*"' "$SRC" | sed -E 's/^xui_tr "//; s/"$//'
    grep -oE 'prompt_or_default [A-Za-z_]+ "[^"]*"' "$SRC" \
        | sed -E 's/^prompt_or_default [A-Za-z_]+ "//; s/"$//'
} | grep -v '^\$' | grep -v '^prompt text$' | sort -u > "${TMP_POSIX}/used-keys.txt"

probe() {
    # probe <XUI_LANG-value|__unset__> <case>
    local lang="$1" case_name="$2"
    if [[ "$lang" == "__unset__" ]]; then
        env -u XUI_LANG bash "${TMP_POSIX}/loc-probe.sh" "$TMP_POSIX" "$case_name"
    else
        XUI_LANG="$lang" bash "${TMP_POSIX}/loc-probe.sh" "$TMP_POSIX" "$case_name"
    fi
}

check 'default language is Chinese' '[[ "$(probe zh resolved)" == zh ]]'
check 'XUI_LANG=en selects English' '[[ "$(probe en resolved)" == en ]]'
check 'XUI_LANG=EN selects English' '[[ "$(probe EN resolved)" == en ]]'
check 'unset XUI_LANG stays Chinese' '[[ "$(probe __unset__ resolved)" == zh ]]'
check 'system locale does not override the default' \
    '[[ "$(LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 probe __unset__ resolved)" == zh ]]'

check 'unknown key falls back to English' \
    '[[ "$(probe zh unknown)" == "Some string not in the table" ]]'

check 'English mode keeps English wording' \
    '[[ "$(probe en hint)" == "Please answer yes or no (Enter defaults to No)." ]]'

check 'Chinese mode translates the wording' \
    '[[ "$(probe zh hint)" == *"请回答 yes 或 no"* ]]'

# The boxed section titles must stay the same display width in both languages
# so the surrounding "═══" rule still lines up.
check 'boxed title keeps the frame width in English' '[[ "$(probe en title)" == 43 ]]'
check 'boxed title keeps the frame width in Chinese' '[[ "$(probe zh title)" == 43 ]]'

# Every key the case table defines must resolve to a different Chinese string,
# and every key the installer actually asks for must be present. An
# associative array cannot be used for this: bash re-parses the subscript of a
# key containing parentheses, so the lookup silently misses those entries.
check 'every table key resolves to Chinese' \
    '[[ "$(probe zh allkeys)" == "unresolved=0" ]]'
check 'every prompt used by the installer is translated' \
    '[[ "$(probe zh allused)" == "untranslated=0" ]]'

echo
echo '--- self-signed certificate ---'

check 'the self-signed certificate helper exists' \
    'declare -f setup_self_signed_certificate > /dev/null'
check_fails 'the helper rejects an empty address' \
    setup_self_signed_certificate ""
check_fails 'the helper rejects a malformed address' \
    setup_self_signed_certificate "not-an-ip"
check_fails 'the helper rejects a domain name' \
    setup_self_signed_certificate "example.com"

# The SAN must carry the IP address: a certificate whose CN is an IP but
# whose subjectAltName omits it fails the hostname check in every modern
# TLS client.
check 'the certificate carries the IP in its SAN' \
    'grep -q "subjectAltName = IP:" "${TMP_POSIX}/selfsigned.sh"'
check 'the certificate is valid for ten years' \
    'grep -q -- "-days 3650" "${TMP_POSIX}/selfsigned.sh"'

# The SSL menu must offer the self-signed option as 3 and keep the other
# four methods reachable.
check 'the SSL menu offers the self-signed option' \
    'grep -q "Self-signed Certificate for IP" "$SRC"'
check 'the SSL menu keeps all five methods' \
    '[[ "$(grep -cE "^        [1-5]\)" "$SRC")" -ge 5 ]]'
check 'the self-signed mode maps to option 3' \
    'grep -q "selfsigned | self_signed | self-sign) ssl_choice=\"3\"" "$SRC"'
check 'the IP prompt defaults to the detected address' \
    'grep -q "press Enter to use %s" "$SRC"'

printf '\n=== %d passed, %d failed ===\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
