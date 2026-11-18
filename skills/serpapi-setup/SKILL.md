---
name: serpapi-setup
description: Guide the user through SerpApi setup or repair when first used, unconfigured, missing a key, or failing requests. Reuse working access or configure the plugin's SerpApi MCP server or cURL, collect credentials securely, and verify a real search before resuming the task with SerpApi.
license: MIT
---

## Identify and choose

1. Tell the user you will help configure SerpApi and then resume their task. Identify the available request routes and the execution host from the session; identify the OS and shell when using commands. Ask only for missing context. Local apps, WSL, containers, and remote hosts can have different credentials and network access.
2. Check whether the plugin's `serpapi` MCP server is connected and exposes a `search` tool. If shell access is available, also check for `curl` (`curl.exe` in PowerShell) and for credential presence in the cURL route's [stored source](references/credentials.md). Both routes need an API key; cURL also needs HTTPS access to `serpapi.com`. A listed `search` tool does not prove a key is set, because the server connects without one. An unset `SERPAPI_API_KEY` alone does not prove a key is unavailable. Never print credentials; config presence does not prove connectivity.
3. Reuse working access or honor the user's selected route. Otherwise explain the choices below, recommend the MCP server, and ask their preference. Carry out the chosen setup within existing authorization; do not stop at a menu.

| Route | Requirements | Guide |
|---|---|---|
| Plugin MCP server (recommended) | The plugin's `serpapi` MCP server enabled in Cursor, with the key entered in Cursor's plugin settings; no shell required | [MCP](references/mcp.md) |
| Raw cURL | Shell with an existing curl, HTTPS access to `serpapi.com`; no additional packages | [cURL](references/curl.md) |

Read the chosen guide and, for cURL, the relevant credential section. Do not install Python, Node.js, jq, or a package manager for setup. If no available route can protect the key and inspect the response, explain the missing capability and leave verification pending.

This workflow applies to SerpApi setup and repair. Follow the user's explicit instructions over its defaults. Keep the SerpApi request pending during setup and ask before substituting another provider. For a failed request, diagnose below while retaining the route and original task.

## Configure

For a missing key, share the [dashboard](https://serpapi.com/dashboard) and explain where to enter it. Never request the key in chat or put it in commands, history, or workspace files.

For the MCP server, only the user can enter the key: it goes in the plugin's **SerpApi API key** setting in Cursor. Follow the [MCP guide](references/mcp.md). Do not write the key into `mcp.json` or any other file.

For cURL, use an interactive hidden prompt or the [Windows password-dialog helper](references/credentials.md#windows-encrypted-storage). Launch the actual prompt and confirm completion; an empty terminal window is not a prompt.

Preserve existing credentials and their scope. If input, approval, or a restart is required, give the exact next action and wait for it; silence is not completion. Reload the stored key in the same process as each cURL request; never assume an earlier tool call's export persists. Keep verification pending while blocked; do not replace keys, disable TLS verification, disable the sandbox, or bypass host policy.

## Verify and resume

Make one small real search with `engine=google_light`, `q=coffee`, or the original task's valid request. It may use one credit. Do not force a fresh crawl, paginate, or test every route by default.

1. Verify **through the selected route**: the MCP `search` tool's result, or cURL's HTTP status and a parsed `/search.json` response. Run the request on the host that will perform subsequent searches.
2. Require a successful call, valid results, and no API `error`. A connected server, HTTP 200, or exit code 0 alone is insufficient. The coffee probe must return a nonempty organic title and link. Empty results from another query are inconclusive; use the probe if needed.
3. After repair, repeat the corrected original operation through the same route. A passing probe with a failing task means access works but the task remains unresolved.
4. Report the route, execution host, credential source/location without its value, checks passed, and anything pending. Keep the retrieval method available for future sessions; do not write a permanent verified flag.
5. Resume the [search](../search/SKILL.md) skill, discovering it by name if the sibling link is unavailable. If live calls are disallowed or results cannot be inspected, report verification pending.

## Diagnose failures

Retain the engine, route, sanitized error, and original task. Stay here until verification succeeds or a specific blocker is established.

| Failure | Action |
|---|---|
| MCP `search` tool not listed | The plugin's server is disabled or blocked by policy. Ask the user to enable it in Cursor, or help them choose cURL. Do not change policy. |
| MCP `Invalid SerpApi API key` or `Missing API key` | The key Cursor sent is empty or wrong. A `SERPAPI_API_KEY` in Cursor's environment overrides the plugin's key setting, so first check whether one is set (presence only); if so, have the user correct or remove it and restart Cursor. Otherwise have them set the plugin's key again as described in the [MCP guide](references/mcp.md). Verify once. |
| Missing curl executable | Check shell access and PATH. Help choose the MCP route if needed; keep verification pending when neither route is available. |
| cURL blocked by Cursor's sandbox | `serpapi.com` is not in the sandbox's default network allowlist. Rerun the request outside the sandbox with the user's approval, or have the user add `serpapi.com` to `networkPolicy.allow` in `sandbox.json`. Do not disable the sandbox. |
| 401/missing key | Check source and process access. A stale environment key overrides a stored one. Repair that source, then verify once. |
| 403 | Distinguish host policy, service access, and account restrictions from authentication. |
| 400/invalid or mismatched arguments | Read the engine's bundled schema in `engines/<engine>.json` at the plugin root, or its page linked from [SerpApi's documentation index](https://serpapi.com/llms.txt), and correct argument names, required inputs, and values before retrying. Do not reinstall or rotate credentials. |
| 429 | Check quota/throughput and retry delay; stop immediate retries. Report needed account action without purchasing credits or changing plans. |
| DNS/TLS/timeout/5xx | Check host, endpoint, proxy, and service availability. Retry once after a concrete correction or advised delay. |
| HTTP 200 with API error, malformed JSON, or empty probe | Inspect the sanitized error/structure and resolve it before claiming readiness. |

If a route is unavailable, help the user choose the other supported route. If setup is blocked or declined, explain the blocker and ask how the user wants to proceed. Leave the search pending until access works or the user explicitly chooses another provider.
