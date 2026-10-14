# Azure Security Lab

A personal lab to learn Azure security. I'm building a small environment, trying security controls and learning how to monitor what happens.

## So far

- Set up a virtual network with separate backend and database subnets using Terraform.
- Added network security rules.
- Worked through Entra ID permissions, an email alert for RBAC changes and a policy to block public IPs.
- Added a small Python API with API-key authentication and JSON security logs.
- Prepared the App Service and private PostgreSQL configuration, but kept them disabled to save credits.

The API runs locally. It isn't connected to PostgreSQL or CrowdStrike yet.

## Run the app

```bash
python3 -m venv app/.venv
app/.venv/bin/pip install -r app/requirements.txt
cp app/.env.example app/.env
```

Add a local API key to `app/.env`, then:

```bash
cd app
.venv/bin/uvicorn main:app --reload --no-access-log
```

Try `/health` at `http://127.0.0.1:8000`. `/secure` needs the key in the `X-API-Key` header.

## Next

Send the local logs to CrowdStrike when trial access is available, then try a detection for failed authentication attempts.

Paid Azure workloads stay off (`deploy_workloads=false`). No deployment until I've checked the cost.
