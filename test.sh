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
[ -f "$PLUGIN_DIR/skills/search/SKILL.md" ] && pass "SKILL.md exists" || fail "SKILL.md missing"
[ -f "$PLUGIN_DIR/skills/search/examples.md" ] && pass "examples.md exists" || fail "examples.md missing"
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
