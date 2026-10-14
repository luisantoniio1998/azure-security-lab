# CrowdStrike: start locally, without Azure deployment

## Local workflow

From the repository root, install `app/requirements.txt` into your virtual environment.
Set a local API_KEY in the ignored app/.env (app/.env.example contains no key).
Run from app/: `./.venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000 --no-access-log > ../work/security.jsonl` after creating work/.
Exercise GET /health, GET /secure without a key, with an incorrect key, and with your local key in X-API-Key.
Stop the app, then run:

```
python3 scripts/logscale_payload.py work/security.jsonl work/logscale-payload.json
```

The converter validates the source and creates a structured ingestion payload locally. It does not transmit anything. Gunicorn/Uvicorn operational errors go to stderr, separately from the JSON security stream. Disable access logs to avoid duplicating events and exposing URLs.

## Connect the tenant

Required: access to an existing Falcon Next-Gen SIEM tenant, its supported HTTP ingestion connector/endpoint, and a repository-scoped ingestion token supplied through a secret store or environment. Do not paste tokens into Git, screenshots, or command arguments. Confirm ingestion entitlement and cost before transmitting.

For tenants exposing the LogScale structured ingestion API, POST the prepared JSON to the tenant-provided base URL plus `/api/v1/ingest/humio-structured` with Content-Type application/json and Authorization Bearer using an ingest token. Do not assume a generic cloud.humio.com endpoint matches your Falcon region or entitlement. A successful upload confirms acceptance; verify timestamp, fields and event counts in the tenant before claiming integration is complete.

Reference: https://library.humio.com/logscale-api/api-ingest-structured-data.html

Next-Gen SIEM connector/parser normalization and CrowdStrike Parsing Standard mapping must be confirmed in the actual tenant; these custom lab fields are not claimed to be CPS compliant. No Falcon access or ingest token is configured in this repository.

## Events and first hunts

Each JSON event includes UTC timestamp, schema_version, service, environment, event, request_id and transport-peer source_ip. Auth outcomes are success/failure; HTTP events carry method, normalized path, status_code and duration_ms. Auth and request events share a server-generated request ID. Headers, keys, query strings, bodies and exception messages are excluded; unknown paths are replaced with <unmatched>. Forwarded IP headers are not trusted. Behind Azure proxies, source_ip may be the proxy; validate trusted proxy configuration before relying on it for detections.

Suggested LogScale searches after ingestion (validate in your tenant):

```
#service="azure-security-lab" event="authentication_failure"
| groupBy([source_ip], function=count())
```

```
#service="azure-security-lab" event="http_request" status_code>=500
```

Use a five-minute search window and start with five failed authentications per source as a lab hypothesis, then tune against health checks, shared proxies and expected traffic. Correlate successful authentication with the same source after failures; use request_id to inspect the corresponding request. Treat these as hunts until validated, not enabled production alerts.

## Later Azure ingestion

After explicit Azure approval: App Service console JSON -> approved diagnostic destination/forwarder -> Falcon ingestion connector. Select the tenant-supported Azure/Event Hub or collector route and review any Event Hub, storage and diagnostic charges first. A durable forwarder needs batching, bounded retry/backoff for 429/5xx, failed-event storage, token rotation and ingestion monitoring. Keep network ingestion out of the API request path. No forwarding infrastructure is created by this change.
