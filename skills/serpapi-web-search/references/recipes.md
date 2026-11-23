# Search recipes

Each recipe is a set of request parameters. Send it through the route you are already using.

MCP: put the object inside `params` of the `search` tool.

```json
{"params": {"engine": "youtube", "search_query": "machine learning tutorial", "output": "md"}}
```

curl: send each pair as `--data-urlencode 'name=value'` after the key.

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=youtube' \
  --data-urlencode 'search_query=machine learning tutorial' \
  --data-urlencode 'output=md'
```

The recipes set `output=md` because the agent reads the result; drop it for JSON. Replace `YYYY-MM-DD` with future dates.

## Inputs that are not `q`

```json
{"engine": "youtube", "search_query": "machine learning tutorial", "output": "md"}
```

```json
{"engine": "amazon", "k": "wireless headphones", "output": "md"}
```

```json
{"engine": "walmart", "query": "wireless headphones", "output": "md"}
```

```json
{"engine": "ebay", "_nkw": "vintage watch", "output": "md"}
```

```json
{"engine": "yelp", "find_desc": "sushi", "find_loc": "Los Angeles, CA", "output": "md"}
```

Results are under `video_results` for YouTube and `organic_results` for the others.

## Keep only what the task needs

`json_restrictor` filters the response before it is rendered, on either route and in either format. Keep `error` in the list so failures stay visible.

```json
{"engine": "google_light", "q": "coffee", "output": "md", "json_restrictor": "organic_results[0:5].title,organic_results[0:5].link,organic_results[0:5].snippet,error"}
```

## Search near a place

Name the place with `location`:

```json
{"engine": "google_light", "q": "coffee shops", "location": "Austin, Texas, United States", "output": "md"}
```

For Maps, put the place in the query, or center the map with `ll` (`@latitude,longitude,zoom`):

```json
{"engine": "google_maps", "type": "search", "q": "pizza", "ll": "@40.7455096,-74.0083012,14z", "output": "md"}
```

## Find a business, then read its reviews

```json
{"engine": "google_maps", "type": "search", "q": "The French Laundry Yountville California", "output": "md"}
```

Pick the matching business and take its `data_id`, which the Markdown shows as `Data Id` next to a Reviews link. Then:

```json
{"engine": "google_maps_reviews", "data_id": "DATA_ID", "sort_by": "newestFirst", "output": "md"}
```

## Follow an AI Overview

```json
{"engine": "google", "q": "what is serpapi", "output": "md"}
```

Use an overview that is already in the response. If the response carries a `page_token` for the overview instead of its text, send it at once, because it expires within one minute. If there is neither, say that no overview was returned.

```json
{"engine": "google_ai_overview", "page_token": "PAGE_TOKEN", "output": "md"}
```

## Flights and hotels

A one-way flight search sets `type=2`. For a round trip, drop `type` and add `return_date`. Read both `best_flights` and `other_flights`.

```json
{"engine": "google_flights", "departure_id": "JFK", "arrival_id": "LAX", "outbound_date": "YYYY-MM-DD", "type": "2", "output": "md"}
```

```json
{"engine": "google_hotels", "q": "hotels in Kyoto", "check_in_date": "YYYY-MM-DD", "check_out_date": "YYYY-MM-DD", "adults": "2", "output": "md"}
```

## Next page

```json
{"engine": "google_light", "q": "machine learning", "start": "10", "output": "md"}
```

```json
{"engine": "amazon", "k": "laptop stand", "page": "2", "output": "md"}
```

## Compare prices across stores

Run one request per engine. Confirm that each result is the same product before comparing prices.

```json
{"engine": "amazon", "k": "sony wh-1000xm5", "output": "md"}
```

```json
{"engine": "walmart", "query": "sony wh-1000xm5", "output": "md"}
```

```json
{"engine": "google_shopping_light", "q": "sony wh-1000xm5", "output": "md"}
```

## Check account usage

The account endpoint is not a search engine, so use curl for it:

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/account.json' \
  --data-urlencode 'api_key@-'
```
