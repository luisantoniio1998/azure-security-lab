# Azure Security Lab

My personal lab for learning how to build and secure an application in Azure, then use its logs to investigate suspicious activity.

## What is here

- Terraform for a virtual network, separate application and database subnets, and network security rules.
- A small Python API with a public health check and an API-key protected endpoint.
- JSON logs for requests, authentication successes, failures and application errors. Keys and request bodies are not logged.
- Configuration for a future Python App Service and private PostgreSQL server.
- A local script that prepares logs for CrowdStrike ingestion.

The API works locally. It does not use PostgreSQL yet. App Service and PostgreSQL are disabled by default (`deploy_workloads=false`). CrowdStrike ingestion and detection alerts are not connected yet.

Earlier lab work also covered Entra permissions, an RBAC-change email alert and an Azure Policy blocking public IPs. Those controls are not managed by the Terraform currently in this repository, and their live status has not been rechecked.

## Run locally

Requires Python 3.12 or 3.13. From the repository root:

```bash
python3 -m venv app/.venv
app/.venv/bin/python -m pip install -r app/requirements.txt
cp app/.env.example app/.env
```

Set a random local `API_KEY` in `app/.env`, then start the API:

```bash
cd app
.venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000 --no-access-log
```

Open `http://127.0.0.1:8000/health`. `/secure` returns 401 unless the correct key is supplied in the `X-API-Key` header.

## Next

Connect local logs to the CrowdStrike trial and test a detection. Azure deployment needs a separate cost review and explicit approval.

More detail: [CrowdStrike workflow](docs/crowdstrike.md), [deployment notes](docs/deployment.md), [project review](docs/review.md).
