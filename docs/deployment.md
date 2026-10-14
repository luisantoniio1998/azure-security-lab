# Prepared deployment, approval still required

`deploy_workloads` remains false. App Service B1 and PostgreSQL B_Standard_B1ms remain gated by this flag. Do not run Terraform apply or enable this flag without explicit user approval. The approximate remaining Azure for Students budget is $88; it is not a live billing balance. Review a current regional estimate and the full Terraform plan before approval, including both services and ingestion infrastructure. Do not alter the separate Sentinel lab.

Python runtime: 3.12. Startup: Gunicorn with two Uvicorn workers on port 8000. Build automation installs app/requirements.txt. Public /health is the App Service health check; /secure requires X-API-Key. Local verification currently uses Python 3.13; Azure Python 3.12 startup remains to be verified after approval.

Run `python3 scripts/package_app.py` to build dist/app.zip using an explicit allowlist (main.py and requirements.txt). No .env, credentials, virtual environment or state is included. This command does not deploy. Rebuild after app changes.

Production does not load .env. An empty or unresolved API_KEY prevents startup. Terraform stores only an existing Key Vault secret URI supplied through api_key_secret_uri, never a secret value. The app's system-assigned identity still needs secret-read permission and network access to that existing vault. These permissions are not provisioned here; with a newly created identity, configure them before the app can start. Key Vault references may cache values: account for reference refresh/restart when rotating keys. Do not supply an API key through Terraform variables or commit local .env.

Reference: https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references
Runtime/build reference: https://learn.microsoft.com/en-us/azure/app-service/configure-language-python

State files are now untracked and preserved locally. Earlier Git history still contains state; removing current files does not remove that history. No history was rewritten. Use a separately approved secure remote-state setup before shared infrastructure work.

Local checks:

```
python3 scripts/package_app.py
app/.venv/bin/python -m unittest discover -s tests -v
terraform -chdir=terraform validate
```

Existing network-security.tf and resource-locks.tf edits were present at takeover. They were inspected during the local review and remain uncommitted; no Azure application was performed. See review.md for remaining deployment prerequisites.
