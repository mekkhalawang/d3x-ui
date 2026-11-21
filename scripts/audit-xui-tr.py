#!/usr/bin/env python3
# Audit xui_tr call sites in install.sh against the fill-then-append contract:
#   1. args passed as single-quoted '${var}' or '$var' (never expand)  -> bug
#   2. more %s placeholders in the key than args                       -> bug
#   3. keys whose raw source text still carries \\ escape skew         -> bug
#   4. keys not resolvable by the zh table                             -> bug
#   (args beyond the %s count are fine: they append as a suffix)
import re, sys, os

SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "install.sh")
lines = open(SRC, encoding="utf-8").read().splitlines()

table = {}
for i, ln in enumerate(lines, 1):
    m = re.match(r'^        "(.*)"\) printf (.*) ;;$', ln)
    if m:
        table[m.group(1)] = (i, m.group(2))

call_re = re.compile(r"xui_tr\s+([\"'])(.*?)\1((?:\s+[\"'][^\"']*[\"'])*)\s*\)")
issues = []
for i, ln in enumerate(lines, 1):
    if "xui_tr" not in ln:
        continue
    m = call_re.search(ln)
    if not m:
        if re.search(r"xui_tr\s+[\"']", ln) and "()" not in ln:
            issues.append((i, "PARSE", "multi-line or unmatched xui_tr call", ln.strip()[:120]))
        continue
    key = m.group(2)
    args_raw = m.group(3).strip()
    args = re.findall(r"([\"'])([^\"']*)\1", args_raw)
    n_ph = key.count("%s")
    n_args = len(args)
    if n_args < n_ph:
        issues.append((i, "ARGCOUNT", f"key has {n_ph} %s but only {n_args} args", ln.strip()[:140]))
    for q, a in args:
        if q == "'" and a.startswith("$"):
            issues.append((i, "LITERAL", f"single-quoted literal arg: {a}", ln.strip()[:140]))
    if "\\\\" in key:
        issues.append((i, "ESCAPE", "key has \\\\ escapes (runtime lookup skew)", ln.strip()[:140]))
    if not key.startswith("$"):
        if key not in table:
            issues.append((i, "NOTABLE", f"key missing from zh table: {key[:60]!r}", ""))
        else:
            _, rhs = table[key]
            if rhs == f"printf '%s' \"{key}\"":
                issues.append((i, "IDENTITY", "table maps key to itself", ln.strip()[:140]))

for k, (ln, rhs) in table.items():
    if rhs == f"printf '%s' \"{k}\"":
        issues.append((ln, "IDENTITY", "table entry maps to itself", k[:100]))

for i, kind, msg, ctx in issues:
    print(f"{i:5d}  {kind:8s}  {msg}")
    if ctx:
        print(f"            {ctx}")

print(f"\ntotal issues: {len(issues)}")
