# Project review — 14 October 2026

Scope: all application code, Terraform source, packaging and ingestion scripts, tests, dependencies and existing documentation. This was a local repository review, not a live Azure audit. No Terraform apply, deployment, paid-service activation or changes to the separate Sentinel lab were performed.

## What works locally

The API exposes a health endpoint and an API-key protected endpoint. Authentication compares keys in constant time and rejects missing/invalid keys. Production refuses an empty key or an unresolved Key Vault reference and does not load the local .env file.

Security events are JSON on stdout. Auth and HTTP events share a server-generated request ID. Logging excludes keys, headers, bodies, query strings and exception messages; unknown paths are normalized. Runtime stderr can still contain operational tracebacks and must be handled separately from the security stream.

The package builder includes only main.py and requirements.txt. The converter prepares a LogScale structured JSON payload locally. It is a small lab utility, not a production forwarder: it reads the complete input into memory and checks source/timestamp presence, but does not validate timestamp semantics, impose batch limits, retry or transmit data.

## Infrastructure represented in code

A VNet and two delegated subnets separate application and database traffic. NSGs permit backend-to-database traffic and PostgreSQL internal traffic. NSGs also retain Azure default rules; these definitions must not be described as a complete outbound allowlist. The resource group metadata location is West Europe; the VNet and planned workloads are Spain Central. That difference is explicit in the configuration, not evidence of a deployment failure.

Future App Service configuration selects Python 3.12, Gunicorn/Uvicorn workers, HTTPS, TLS 1.2 minimum, disabled FTP/basic publishing authentication, managed identity, VNet integration and a health check. The health endpoint checks the API process only; it does not check a database or secret-store connection.

Future PostgreSQL configuration uses private networking, private DNS and Entra authentication with password authentication disabled. The API has no database driver, queries, schema or database authentication implementation. Configuring a server administrator does not give the application database access.

## Open work before deployment

- Create/select the approved Key Vault secret and configure identity permissions and network reachability. The repository supplies a reference, not a vault or RBAC assignment.
- Review the complete Azure plan and current regional costs. deploy_workloads gates both App Service and PostgreSQL together; it is not an approval mechanism. PostgreSQL administrator variables are required even with workloads disabled.
- Verify Python 3.12 and end-to-end startup on the approved Azure environment. Local execution was tested on Python 3.13.
- Validate egress/DNS requirements with VNet route-all, PostgreSQL Entra access, globally available resource names, health monitoring and resource-lock behavior.
- Validate proxy handling before treating source_ip as an end-user IP. Do not enable broad trust of forwarded headers.
- Add an agreed abuse/rate-limit strategy before public exposure. The current API has no rate limiting or per-user authentication.
- Resolve and lock transitive Python dependencies and add automated checks before treating the deployment as reproducible production delivery. requirements.txt pins direct packages only; this review did not establish that dependencies are vulnerability-free.

## Monitoring and repository state

The earlier README recorded Entra/RBAC setup, an RBAC-change email alert and a public-IP denial policy. Their live status was not inspected and no corresponding Terraform definitions exist in the current repository. App logs are not yet forwarded to Azure Monitor or CrowdStrike. Suggested CrowdStrike searches are not enabled detection rules.

Local .env, virtual environments, generated packages and Terraform state are ignored. State remains in earlier Git history; no history rewrite or credential rotation was performed. Existing network-security.tf edits and resource-locks.tf were reviewed but left as the user's uncommitted work. Their presence does not establish that they have been applied in Azure.

## Changes and verification

The README was replaced with a short introduction, accurate status and local startup instructions. The package test now builds its ZIP first so a clean checkout does not need a manually prepared archive. Key Vault URI validation now uses explicit literal-dot classes; a representative valid URI was accepted in Terraform console. An intermediate escaping error introduced during review was corrected.

Three automated tests pass, covering authentication (missing, invalid, non-ASCII and valid keys), health and unknown routes, event correlation, sensitive-field exclusion, payload conversion, invalid-source rejection and ZIP membership. Terraform validate passes. These checks do not prove live Azure connectivity or successful CrowdStrike ingestion.
