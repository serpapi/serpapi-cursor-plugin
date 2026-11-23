# <img src="https://user-images.githubusercontent.com/307597/154772945-1b7dba5f-21cf-41d0-bb2e-65b6eff4aaaf.png" width="30" height="30"/> SerpApi Plugin for Cursor

A [Cursor plugin](https://cursor.com/docs/plugins) that gives Cursor Agent the ability to search Google, Amazon, Walmart, YouTube, Google Maps, Google Scholar, and [100+ other engines](https://serpapi.com/search-engine-apis) through [SerpApi](https://serpapi.com). It can also read web pages, list a site's URLs, and crawl pages through SerpApi's [Extract API](https://serpapi.com/extract-api).

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Engines](https://img.shields.io/badge/engines-112-blue.svg)](engines/)
[![Validate](https://github.com/serpapi/serpapi-cursor-plugin/actions/workflows/validate.yml/badge.svg)](https://github.com/serpapi/serpapi-cursor-plugin/actions/workflows/validate.yml)
[![Update Engines](https://github.com/serpapi/serpapi-cursor-plugin/actions/workflows/update-engines.yml/badge.svg)](https://github.com/serpapi/serpapi-cursor-plugin/actions/workflows/update-engines.yml)

## Quick Start

### 1. Get an API key

Sign up at [serpapi.com](https://serpapi.com/users/sign_up?plan=free) and copy your key from [serpapi.com/manage-api-key](https://serpapi.com/manage-api-key).

> **Free tier** - 250 searches/month, no credit card required.

### 2. Install the plugin

**Local install** (recommended for testing):

```bash
# Option A: Copy the plugin
cp -r /path/to/serpapi-cursor-plugin ~/.cursor/plugins/local/serpapi

# Option B: Clone directly
git clone https://github.com/serpapi/serpapi-cursor-plugin.git ~/.cursor/plugins/local/serpapi
```

Then restart Cursor or run `Developer: Reload Window` from the command palette.

**From the marketplace** (when available):

Search for "serpapi" in the Cursor marketplace panel, or visit [cursor.com/marketplace](https://cursor.com/marketplace).

### 3. Add your API key

Open the SerpApi plugin in Cursor's **Customize** page, choose **Configure**, and enter your key as **SerpApi API key**. The bundled SerpApi MCP server sends it with each search. On a team-managed install, an admin sets it in the dashboard under **Plugins → Configure**.

To use `curl` instead, or if a search reports a missing key, run setup in chat. Cursor guides you through saving the key in your system keychain or a private file, then runs a test search:

```
/serpapi-setup
```

A `SERPAPI_API_KEY` already exported in your shell keeps working with `curl`.

### 4. Use it

Cursor Agent will automatically use SerpApi when you ask it to search for something. Just ask in natural language:

> *Search Google for the best Python web frameworks*
>
> *Compare prices for AirPods Pro on Amazon, Walmart, and eBay*
>
> *Find academic papers about transformer architectures published after 2020*
>
> *Read https://docs.python.org/3/whatsnew/ and summarize what changed*

Or invoke a skill explicitly:

```
/serpapi-web-search coffee shops near Times Square
/serpapi-extract https://example.com/pricing
```

You can also attach one as context:

```
@serpapi-web-search
```

## Features

- **One search skill, all engines** - `/serpapi-web-search` covers all 100+ SerpApi engines. Cursor Agent picks the right one based on your intent.
- **Page extraction** - `/serpapi-extract` reads a page you give it as Markdown, lists a site's URLs, or crawls a bounded set of pages.
- **Markdown results** - Searches and extractions ask SerpApi for Markdown, which leaves out response metadata. JSON is used when you need structured data.
- **MCP included** - Bundles SerpApi's hosted MCP server, so searches need no shell. Falls back to `curl` when the server isn't available.
- **Guided setup** - `/serpapi-setup` stores your key without it appearing in chat, then verifies a real search.
- **Always up to date** - Engine parameter schemas are auto-generated and kept fresh by weekly CI.
- **Auto-invocation** - Cursor Agent detects search-related requests and loads the skill automatically. No need to remember slash commands.
- **Cost-aware** - Defaults to `google_light` (faster, cheaper) for simple web searches. Confirms before making API calls.
- **Schema-driven** - The plugin ships an engine selection table for common intents and JSON schemas for every engine's parameters, so the agent can construct the right API call without guessing.

## Supported Engines

| Category | Engines |
|----------|---------|
| Web Search | Google, Google Light, Bing, DuckDuckGo, Yahoo, Yandex, Baidu, Naver |
| AI Search | Google AI Mode, Google AI Overview, Bing Copilot, Brave AI Mode |
| Shopping | Amazon, Walmart, eBay, Google Shopping, Home Depot |
| Local / Maps | Google Maps, Google Local, Yelp, TripAdvisor, OpenTable |
| Research | Google Scholar, Google Patents, Google Trends |
| News | Google News, Bing News, DuckDuckGo News, Baidu News |
| Media | Google Images, Google Videos, YouTube, Google Lens |
| Travel | Google Flights, Google Hotels, Google Travel Explore |
| Jobs | Google Jobs |
| Finance | Google Finance |
| Apps | Google Play, Apple App Store |

See the full list in [`engines/`](engines/).

## Troubleshooting

- **"Invalid API key" or "Missing API key"**: Check the key in the plugin's settings and at [serpapi.com/manage-api-key](https://serpapi.com/manage-api-key), or run `/serpapi-setup`
- **Plugin not showing up**: Ensure files are in `~/.cursor/plugins/local/serpapi/` and restart Cursor
- **Skill not loading**: Run `Developer: Reload Window` from the command palette
- **Rate limit exceeded**: Wait or [upgrade your plan](https://serpapi.com/pricing)

## Development

Engine schemas are auto-generated by `build-engines.py` and updated weekly via [GitHub Actions](.github/workflows/update-engines.yml).

To regenerate manually:

```bash
pip install -r requirements.txt
python build-engines.py
```

To validate the plugin structure:

```bash
bash test.sh
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run validation: `bash test.sh`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## Related

- [SerpApi Plugin for Claude Code](https://github.com/serpapi/serpapi-claude-plugin) - Claude Code plugin with the same capabilities
- [SerpApi MCP Server](https://github.com/serpapi/serpapi-mcp) - MCP server integration for Claude Desktop, VS Code, and Cursor
- [SerpApi Docs](https://serpapi.com/search-api) - Full API reference
- [SerpApi Playground](https://serpapi.com/playground) - Interactive API explorer

## License

MIT License - see [LICENSE](LICENSE) file for details.
