# Credential storage and retrieval

Reuse the credential source already working for the chosen route. Load the key into the requesting process without displaying it or creating another stored copy.

The plugin's MCP server keeps its key in Cursor's plugin settings; see the [MCP guide](mcp.md). The stores, commands, and helpers below serve the cURL route and need a shell.

To find an existing key for cURL, check presence only, in this order: `SERPAPI_API_KEY` in the environment, the preferred source for the environment in the table below, then the private file.

For new storage, prefer an available OS secret store. Explain the prompt and launch it when the host lets the user interact with it. Otherwise give the exact command for their terminal and wait for completion. A tool's stdin or allocated PTY is not necessarily visible or writable by the user. Secret reads must happen inside a variable assignment or pipe, never as a standalone tool call that prints the key. Disable shell tracing before reading secrets. Do not put literal keys in commands, chat, `.env` files in repositories, or shell profiles.

The load functions return a failure without exiting your terminal and clear a stale environment key when loading fails. Stop on that failure; do not make a request. An environment variable lasts only in that process and its children. Load the key again for later agent commands, or launch the client from the process that loaded it. A desktop app already running will not inherit an export from an unrelated terminal. A remote execution host needs its own credential source.

| Environment | Preferred source | Retrieval |
|---|---|---|
| macOS | Keychain | Assignment below in the requesting process |
| Linux desktop | Existing Secret Service | `secret-tool` assignment below |
| Native Windows | DPAPI-protected user file | PowerShell load step below |
| Headless/CI | Host secret manager | Inject `SERPAPI_API_KEY` into the job |
| No secret store | Private file outside Git | Helper below; permission-protected plaintext |

## macOS Keychain

Use service `serpapi` and the current login account. Check for an existing item with output redirected before adding one. Have the user run this command in their terminal, with `-w` last so `security` prompts for the password:

```bash
security add-generic-password -a "$USER" -s serpapi -w
```

Do not add `-A` or broaden the item's access controls. Keychain can ask the user to unlock or approve access. Load the key in the process that will run cURL:

```bash
serpapi_load_key() {
  set +x
  SERPAPI_API_KEY="$(security find-generic-password -a "$USER" -s serpapi -w)" || { unset SERPAPI_API_KEY; return 1; }
  test -n "$SERPAPI_API_KEY" || { unset SERPAPI_API_KEY; printf 'Stored key is empty.\n' >&2; return 1; }
  export SERPAPI_API_KEY
}
serpapi_load_key
```

Then run the cURL request in that same process. Verify access with a real request; successful retrieval alone does not validate the key. `security help add-generic-password` documents the hidden prompt.

## Linux Secret Service

If `secret-tool` and an unlocked Secret Service are already available, have the user store the key through its hidden terminal prompt:

```bash
secret-tool store --label=SerpApi service serpapi
```

Reuse an existing item; do not run `store` over it unless replacing the key is intended. Retrieve in the process that makes the request:

```bash
serpapi_load_key() {
  set +x
  SERPAPI_API_KEY="$(secret-tool lookup service serpapi)" || { unset SERPAPI_API_KEY; return 1; }
  test -n "$SERPAPI_API_KEY" || { unset SERPAPI_API_KEY; printf 'Stored key is empty.\n' >&2; return 1; }
  export SERPAPI_API_KEY
}
serpapi_load_key
```

See the [secret-tool manual](https://manpages.debian.org/bookworm/libsecret-tools/secret-tool.1.en.html). Headless hosts may have no unlocked collection. Use an injected secret or the private-file fallback rather than installing a desktop keyring for a cURL-only workflow.

## Windows encrypted storage

On native Windows, PowerShell's [ConvertFrom-SecureString](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertfrom-securestring) uses DPAPI when no encryption key is supplied. Keep the encrypted file in the current user's local application data. This recipe is Windows-only; do not assume the same protection on other platforms.

Use [save-key.ps1](../scripts/save-key.ps1) for a masked Windows password dialog when an agent's terminal cannot accept user input. Resolve the helper's absolute path inside the installed skill, then launch it directly on the user's Windows desktop:

```powershell
powershell.exe -NoProfile -STA -File 'C:\absolute\path\to\serpapi-setup\scripts\save-key.ps1'
```

This invokes the script in a single-threaded apartment for the dialog. Do not launch bare `powershell.exe` or send a later command to an unrelated new window. Tell the user to paste the key into **SerpApi API key** and select **Save**. Wait for the helper's result; a spawned process or visible window does not prove storage. Cancellation leaves setup pending. If execution policy blocks the script, use the [MCP route](mcp.md) or ask the user to run an approved copy; do not add an execution-policy bypass.

When Python or another intermediate process launches `powershell.exe` from a PowerShell 7 environment, remove `PSModulePath` from the child environment only. Otherwise Windows PowerShell 5.1 can try to load incompatible PowerShell 7 modules and fail at `ConvertTo-SecureString`. See [Microsoft's module-path guidance](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath#starting-windows-powershell-from-powershell-7). A direct PowerShell 7 launch handles this itself.

The helper uses a [masked textbox](https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.textbox.usesystempasswordchar), writes DPAPI ciphertext to `%LOCALAPPDATA%\SerpApi\api-key.dpapi`, and refuses blank input, a key containing whitespace, existing files, and symbolic links or junctions in the path. It accepts no plaintext key argument. For a real user-operated console, append `-Terminal` to use `Read-Host -AsSecureString`. Windows PowerShell 5.1 and Windows `pwsh -STA` can run it. Remote, service, and headless sessions may have no interactive desktop; use their secret input mechanism instead.

The helper stores the key without changing the parent agent's environment. Load it in the PowerShell process that will issue the request. Trim the serialized text so files created with a trailing newline remain readable:

```powershell
$ErrorActionPreference = 'Stop'
$env:SERPAPI_API_KEY = $null
$serpapiSecret = $null
$serpapiKeyFile = Join-Path $env:LOCALAPPDATA 'SerpApi/api-key.dpapi'
try {
  $serpapiSecret = (Get-Content -LiteralPath $serpapiKeyFile -Raw).Trim() | ConvertTo-SecureString
  $env:SERPAPI_API_KEY = [System.Net.NetworkCredential]::new('', $serpapiSecret).Password
  if ([string]::IsNullOrWhiteSpace($env:SERPAPI_API_KEY) -or $env:SERPAPI_API_KEY -match '[\r\n]') { throw 'Stored key is empty or invalid.' }
}
catch {
  $env:SERPAPI_API_KEY = $null
  throw 'Could not load the stored SerpApi key for this Windows user and machine; resume serpapi-setup.'
}
finally {
  if ($null -ne $serpapiSecret) { $serpapiSecret.Dispose() }
}
```

The file belongs to that Windows user and machine. Supply credentials separately inside WSL, containers, and remote hosts. Do not log the decrypted environment or run secret-loading commands under a debugger that prints values.

## Private file on macOS, Linux, or WSL

If an OS secret store is unavailable or the user prefers a file, use `${XDG_CONFIG_HOME:-$HOME/.config}/serpapi/api_key`. This is **permission-protected plaintext, not encrypted storage**. Use an OS store or managed secret if encryption is required. Ensure the chosen config directory is outside the repository and is not a shared or synced location.

Run [save-key.sh](../scripts/save-key.sh) with Bash, resolving its path relative to this installed skill. It uses an existing `SERPAPI_API_KEY` or hidden terminal input, creates a `700` directory and `600` file, and refuses overwrites and symlinks at the store location. It resolves existing ancestors to reject Git worktrees, dot components, and a config parent writable by other users. A group-writable parent counts, as on logins that use umask 002; the helper prints the `chmod go-w` command that fixes it. Synced directories cannot be detected reliably; choose a local, unshared location. The helper stores the key; setup must still verify it with the API.

```bash
bash /absolute/path/to/serpapi-setup/scripts/save-key.sh
```

Later commands can redirect this file to cURL's stdin, as the [cURL guide](curl.md) shows, without loading the value into command arguments. To load it into the environment instead:

```bash
serpapi_load_key() {
  set +x
  SERPAPI_API_KEY="$(cat "${XDG_CONFIG_HOME:-$HOME/.config}/serpapi/api_key")" || { unset SERPAPI_API_KEY; return 1; }
  test -n "$SERPAPI_API_KEY" || { unset SERPAPI_API_KEY; printf 'Stored key is empty.\n' >&2; return 1; }
  export SERPAPI_API_KEY
}
serpapi_load_key
```

Check ownership and permissions before reuse; require directory mode `700` and key-file mode `600`, and reject symlinks. Read with `cat` only inside the assignment above. Rotate only when intended, and verify the replacement through the selected route.

## CI and remote agents

Use the host's secret manager to inject `SERPAPI_API_KEY` into the job or agent process. Record only the secret's name and scope. Do not copy local key files into a repository, image, or artifact. Confirm that the actual requesting process receives the variable before testing access.
