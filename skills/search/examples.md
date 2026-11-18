# SerpApi Curl Examples

These use the curl route. Each command pipes the key to curl, which keeps it out of the command's arguments, and curl URL-encodes the values. `-q` makes curl ignore `~/.curlrc`, where a verbose or trace setting would print the key. On the MCP route, pass the same parameters, without `api_key`, inside `params`:

```json
{"params": {"engine": "google_light", "q": "best python web frameworks"}, "mode": "compact"}
```

## Basic Google Search (Light)

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_light' \
  --data-urlencode 'q=best python web frameworks'
```

## Location-Specific Google Search

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_light' \
  --data-urlencode 'q=coffee shops' \
  --data-urlencode 'location=Austin, Texas, United States' \
  --data-urlencode 'hl=en' \
  --data-urlencode 'gl=us'
```

## Full Google Search (with Knowledge Graph, Ads, etc.)

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google' \
  --data-urlencode 'q=Tesla' \
  --data-urlencode 'location=New York, United States' \
  --data-urlencode 'hl=en' \
  --data-urlencode 'gl=us'
```

## Google Scholar — Academic Papers

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_scholar' \
  --data-urlencode 'q=transformer architecture attention' \
  --data-urlencode 'as_ylo=2020'
```

## Amazon Product Search

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=amazon' \
  --data-urlencode 'k=mechanical keyboard'
```

## Walmart Product Search

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=walmart' \
  --data-urlencode 'query=airpods pro' \
  --data-urlencode 'sort=price_low'
```

## eBay Product Search

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=ebay' \
  --data-urlencode '_nkw=vintage vinyl records'
```

## Google Maps — Local Businesses

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_maps' \
  --data-urlencode 'q=pizza' \
  --data-urlencode 'll=@40.7455096,-74.0083012,14z' \
  --data-urlencode 'type=search'
```

## Google Maps with Location Name

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_maps' \
  --data-urlencode 'q=restaurants' \
  --data-urlencode 'location=San Francisco, California' \
  --data-urlencode 'type=search' \
  --data-urlencode 'z=13'
```

## Google News — Current Events

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_news' \
  --data-urlencode 'q=artificial intelligence' \
  --data-urlencode 'gl=us' \
  --data-urlencode 'hl=en'
```

## Google Trends — Keyword Research

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_trends' \
  --data-urlencode 'q=react,vue,svelte'
```

## Google Flights

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_flights' \
  --data-urlencode 'departure_id=SFO' \
  --data-urlencode 'arrival_id=JFK' \
  --data-urlencode 'outbound_date=2026-06-01' \
  --data-urlencode 'return_date=2026-06-08' \
  --data-urlencode 'currency=USD' \
  --data-urlencode 'hl=en'
```

## Google Jobs

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_jobs' \
  --data-urlencode 'q=senior software engineer' \
  --data-urlencode 'location=Remote' \
  --data-urlencode 'hl=en'
```

## Google Finance — Stock Data

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_finance' \
  --data-urlencode 'q=AAPL:NASDAQ'
```

## YouTube Search

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=youtube' \
  --data-urlencode 'search_query=rust programming tutorial'
```

## Pagination — Google Page 2

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_light' \
  --data-urlencode 'q=machine learning' \
  --data-urlencode 'start=10'
```

## Pagination — Amazon Page 2

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=amazon' \
  --data-urlencode 'k=laptop stand' \
  --data-urlencode 'page=2'
```

## Using json_restrictor for Smaller Responses

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_light' \
  --data-urlencode 'q=openai' \
  --data-urlencode 'json_restrictor=organic_results.title,organic_results.link,organic_results.snippet'
```

## Price Comparison Across Engines

Run these sequentially and compare:

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' --data-urlencode 'engine=amazon' --data-urlencode 'k=sony wh-1000xm5'
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' --data-urlencode 'engine=walmart' --data-urlencode 'query=sony wh-1000xm5'
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' --data-urlencode 'engine=google_shopping' --data-urlencode 'q=sony wh-1000xm5'
```

## Google AI Mode

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_ai_mode' \
  --data-urlencode 'q=explain quantum computing in simple terms'
```

## Yelp — Local Reviews

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=yelp' \
  --data-urlencode 'find_desc=sushi' \
  --data-urlencode 'find_loc=Los Angeles, CA'
```

## Google Autocomplete Suggestions

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/search.json' \
  --data-urlencode 'api_key@-' \
  --data-urlencode 'engine=google_autocomplete' \
  --data-urlencode 'q=how to learn'
```

## Check Account Usage

```bash
printf '%s' "$SERPAPI_API_KEY" | curl -q -s --get 'https://serpapi.com/account.json' \
  --data-urlencode 'api_key@-'
```
