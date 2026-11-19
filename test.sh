#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0
PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

echo "=== SerpApi Cursor Plugin Validation ==="
echo ""

# --- Structure checks ---
echo "Checking plugin structure..."

[ -f "$PLUGIN_DIR/.cursor-plugin/plugin.json" ] && pass "plugin.json exists" || fail "plugin.json missing"
[ -f "$PLUGIN_DIR/.cursor-plugin/marketplace.json" ] && pass "marketplace.json exists" || fail "marketplace.json missing"
for f in serpapi-web-search/SKILL.md serpapi-web-search/references/gotchas.md serpapi-web-search/references/recipes.md serpapi-extract/SKILL.md serpapi-extract/references/api.md; do
    [ -f "$PLUGIN_DIR/skills/$f" ] && pass "$f exists" || fail "$f missing"
done
[ -d "$PLUGIN_DIR/engines" ] && pass "engines/ directory exists" || fail "engines/ directory missing"
[ -f "$PLUGIN_DIR/mcp.json" ] && pass "mcp.json exists" || fail "mcp.json missing"

SETUP_DIR="$PLUGIN_DIR/skills/serpapi-setup"
for f in SKILL.md references/mcp.md references/curl.md references/credentials.md scripts/save-key.sh scripts/save-key.ps1; do
    [ -f "$SETUP_DIR/$f" ] && pass "serpapi-setup/$f exists" || fail "serpapi-setup/$f missing"
done

ENGINE_COUNT=$(ls "$PLUGIN_DIR/engines/"*.json 2>/dev/null | wc -l | tr -d ' ')
if [ "$ENGINE_COUNT" -gt 0 ]; then
    pass "Found $ENGINE_COUNT engine schemas"
else
    fail "No engine JSON files found"
fi

echo ""

# --- JSON validity ---
echo "Checking JSON validity..."

if python3 -c "import json; json.load(open('$PLUGIN_DIR/.cursor-plugin/plugin.json'))" 2>/dev/null; then
    pass "plugin.json is valid JSON"
else
    fail "plugin.json is invalid JSON"
fi

if python3 -c "import json; json.load(open('$PLUGIN_DIR/.cursor-plugin/marketplace.json'))" 2>/dev/null; then
    pass "marketplace.json is valid JSON"
else
    fail "marketplace.json is invalid JSON"
fi

if python3 -c "import json; json.load(open('$PLUGIN_DIR/mcp.json'))" 2>/dev/null; then
    pass "mcp.json is valid JSON"
else
    fail "mcp.json is invalid JSON"
fi

INVALID_ENGINES=0
for f in "$PLUGIN_DIR/engines/"*.json; do
    if ! python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
        fail "Invalid JSON: $(basename "$f")"
        INVALID_ENGINES=$((INVALID_ENGINES + 1))
    fi
done
if [ "$INVALID_ENGINES" -eq 0 ]; then
    pass "All engine JSONs are valid"
fi

echo ""

# --- MCP variables and setup helper ---
echo "Checking MCP variables and setup helper..."

UNDECLARED=$(python3 - "$PLUGIN_DIR" <<'PY' 2>/dev/null || echo "unreadable"
import json, re, sys
root = sys.argv[1]
used = set(re.findall(r"\$\{([A-Z][A-Z0-9_]*)\}", open(f"{root}/mcp.json").read()))
manifest = json.load(open(f"{root}/.cursor-plugin/plugin.json"))
declared = set(manifest.get("variables", {}).get("properties", {}))
print(" ".join(sorted(used - declared)))
PY
)
if [ -z "$UNDECLARED" ]; then
    pass "Every mcp.json variable is declared in plugin.json"
else
    fail "mcp.json variables not declared in plugin.json: $UNDECLARED"
fi

if bash -n "$SETUP_DIR/scripts/save-key.sh" 2>/dev/null; then
    pass "save-key.sh parses"
else
    fail "save-key.sh is missing or has a syntax error"
fi

HELPER_TMP=$(mktemp -d)
mkdir "$HELPER_TMP/real" && ln -s "$HELPER_TMP/real" "$HELPER_TMP/link"
if ! XDG_CONFIG_HOME="$HELPER_TMP/link/" HOME="$HELPER_TMP" SERPAPI_API_KEY=test-key bash "$SETUP_DIR/scripts/save-key.sh" >/dev/null 2>&1 && [ ! -e "$HELPER_TMP/real/serpapi/api_key" ]; then
    pass "save-key.sh refuses a symlinked config directory given with a trailing slash"
else
    fail "save-key.sh wrote through a symlinked config directory given with a trailing slash"
fi
rm -rf "$HELPER_TMP"

echo ""

# --- Skill links and engine references ---
echo "Checking skill links and engine references..."

DOC_PROBLEMS=$(python3 - "$PLUGIN_DIR" <<'PY' 2>/dev/null || printf 'links: checker failed\nengines: checker failed\n'
import glob, os, re, sys
root = sys.argv[1]
docs = sorted(glob.glob(f"{root}/skills/**/*.md", recursive=True)) + [f"{root}/README.md"]
for doc in docs:
    text = open(doc, encoding="utf-8").read()
    rel = os.path.relpath(doc, root)
    for target in re.findall(r"\]\(([^)\s]+)\)", text):
        if re.match(r"[a-z][a-z0-9+.-]*:", target) or target.startswith("#"):
            continue
        path = os.path.normpath(os.path.join(os.path.dirname(doc), target.split("#")[0]))
        if not os.path.exists(path):
            print(f"links: {rel} -> {target}")
    if not rel.startswith("skills"):
        continue
    engines = set(re.findall(r'"engine":\s*"([a-z0-9_]+)"', text))
    engines |= set(re.findall(r"engine=([a-z0-9_]+)", text))
    column = None
    for line in text.splitlines():
        if not line.startswith("|"):
            column = None
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if "Engine" in cells:
            column = cells.index("Engine")
        elif column is not None and column < len(cells):
            engines |= set(re.findall(r"`([a-z0-9_]+)`", cells[column]))
    for engine in sorted(engines):
        if not os.path.exists(f"{root}/engines/{engine}.json"):
            print(f"engines: {rel} names {engine}")
PY
)
if ! printf '%s\n' "$DOC_PROBLEMS" | grep -q '^links:'; then
    pass "Every relative link in the skills and README resolves"
else
    fail "Broken relative links: $(printf '%s\n' "$DOC_PROBLEMS" | grep '^links:' | sed 's/^links: //' | tr '\n' ';')"
fi
if ! printf '%s\n' "$DOC_PROBLEMS" | grep -q '^engines:'; then
    pass "Every engine named in the skills has a bundled schema"
else
    fail "Engines without a bundled schema: $(printf '%s\n' "$DOC_PROBLEMS" | grep '^engines:' | sed 's/^engines: //' | tr '\n' ';')"
fi

echo ""

# --- SKILL.md frontmatter ---
echo "Checking SKILL.md frontmatter..."

for skill_file in "$PLUGIN_DIR"/skills/*/SKILL.md; do
    skill_name=$(basename "$(dirname "$skill_file")")
    if head -1 "$skill_file" | grep -q "^---$"; then
        pass "$skill_name: SKILL.md has YAML frontmatter"
    else
        fail "$skill_name: SKILL.md missing YAML frontmatter"
    fi
    if grep -q "^name: $skill_name$" "$skill_file"; then
        pass "$skill_name: frontmatter name matches its folder"
    else
        fail "$skill_name: frontmatter name does not match its folder"
    fi
    skill_lines=$(wc -l < "$skill_file" | tr -d ' ')
    if [ "$skill_lines" -le 500 ]; then
        pass "$skill_name: SKILL.md is $skill_lines lines (under 500 limit)"
    else
        fail "$skill_name: SKILL.md is $skill_lines lines (exceeds 500 limit)"
    fi
done

echo ""

# --- API key & live test ---
echo "Checking API connectivity..."

if [ -z "${SERPAPI_API_KEY:-}" ]; then
    echo "  SKIP: SERPAPI_API_KEY not set — skipping live API test"
else
    pass "SERPAPI_API_KEY is set"

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://serpapi.com/account.json?api_key=$SERPAPI_API_KEY" 2>/dev/null || echo "000")
    if [ "$RESPONSE" = "200" ]; then
        pass "API key is valid (account endpoint returned 200)"
    else
        fail "API key check failed (HTTP $RESPONSE)"
    fi
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
