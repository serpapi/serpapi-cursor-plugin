# Request and response gotchas

Parameter names and allowed values are in `engines/<engine>.json` at the plugin root. The MCP `search` tool accepts any parameter object, so its schema does not show what an engine requires.

## Query inputs

Not every engine takes `q`:

| Engine | Input |
|---|---|
| `youtube` | `search_query` |
| `amazon` | `k` |
| `walmart` | `query` |
| `ebay` | `_nkw` |
| `yelp` | `find_desc`, with a required `find_loc` |
| `apple_app_store` | `term` |
| `facebook_profile`, `instagram_profile` | `profile_id` |
| `google_scholar_author` | `author_id` |
| `google_maps_reviews` | `data_id` or `place_id`, not a keyword |
| `google_maps` | `q` together with `type=search` |

## Time and place

`google_light` and `google` take `as_qdr` for recent results: `d`, `w`, `m`, or `y` followed by a number, such as `d10` for the past 10 days or `w2` for the past two weeks.

Results are localized. Set `location`, or `gl` and `hl`, when the place matters; without them a jobs or web search can return another country's results. If a place name is ambiguous, look it up with the [Locations API](https://serpapi.com/locations-api), which needs no key. For Maps, put the city in the query or center the map with `ll`.

## Output and pagination by route

| Route | Response handling |
|---|---|
| MCP | Put `"output": "md"` inside `params`. The tool's `mode` argument is separate: `"compact"` strips `search_metadata`, `search_parameters`, `search_information`, and `serpapi_pagination` from JSON, so use `"complete"` when a task needs them. Check the tool's error status and the returned text. |
| curl | Add `--data-urlencode 'output=md'`. Keep the key on stdin as in the request pattern, and check the HTTP status as well as the body's `error` field. |

To get the next page, follow the "Next page" link at the end of a Markdown response, or `serpapi_pagination.next` in complete JSON. Check that it is an HTTPS `serpapi.com` search URL, then send its query parameters through the same route, keeping `output=md` and your filters. Do not pass the URL itself as `params`, and do not assume every engine pages with `start`: Google engines use `start` (0, 10, 20), while Amazon and Walmart use `page`. Stop when the link is missing or repeats.

## Result sections that vary

- Maps returns `place_results` when the query matches one business and `local_results` for a list. Look for both, and confirm the name and address before using contact details or a `data_id`.
- Flights can return `best_flights`, `other_flights`, or both; combine them. Use future dates. A one-way search needs `type=2`; a round trip (the default) also needs `return_date`.
- Scholar Author returns one page of publications. Page with `start` and `num` when the full list is needed.
- `google` returns `knowledge_graph` and `answer_box` only for queries that trigger them. Their absence is not an error.
- A response can succeed and still carry an `error`, such as "Google hasn't returned any results for this query". Empty results for a valid query do not by themselves mean the key is wrong; setup uses a known probe to tell the two apart.

## Cache

An identical request is served from cache for one hour and is free. `no_cache=true` forces a new search. Do not combine `no_cache=true` with `async=true`.

On quota, access, or repeated request failures, follow [serpapi-setup](../../serpapi-setup/SKILL.md) and keep the original route and task with the diagnosis.
