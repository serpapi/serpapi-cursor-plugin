# Extract request examples

Each example is a set of request parameters. On the MCP route, put it inside `params` of the `extract` tool and leave the tool's own `mode` argument out: with `"compact"`, the examples that ask for JSON return Markdown instead. With curl, send each pair as `--data-urlencode 'name=value'` after the key, as in the skill's request pattern. Parameter definitions and limits are in `engines/extract.json` at the plugin root and in the [Extract API docs](https://serpapi.com/extract-api).

## Page content as Markdown

```json
{"engine": "extract", "url": "https://www.python.org/about/", "output": "md"}
```

## Structured page data

When the user wants structured data, or code must read JSON-LD, Open Graph, or meta tags, ask for JSON and leave the Markdown out:

```json
{"engine": "extract", "url": "https://www.python.org/about/", "include_markdown": false, "json_restrictor": "page_information,json_ld,open_graph,meta_tags,error"}
```

Which of these fields come back depends on what the page contains.

## Discover URLs

List the links on the starting page without reading the site's sitemaps, then choose which pages to extract:

```json
{"engine": "extract", "url": "https://www.python.org/about/", "mode": "map", "include_sitemap": false, "output": "md"}
```

## Read several pages

This crawl reads at most two pages, counting the starting page, and follows links one level deep. Each page's Markdown comes back under its URL:

```json
{"engine": "extract", "url": "https://www.python.org/about/", "mode": "crawl", "max_pages": 2, "max_depth": 1, "output": "md"}
```

Check every returned page before using it. JSON output reports the cost in `search_metadata.credits_consumed`.

## What Extract cannot return

Extract does not run JavaScript. `include_tags` and `exclude_tags` filter the fetched HTML; they cannot bring back content that needs JavaScript to load.

A search results page that has its own SerpApi engine, such as Google or Bing, is redirected to that engine. Check which engine answered before treating the response as page content.
