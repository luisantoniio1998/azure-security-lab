# Azure Security Lab

My lab for learning security by design in Azure: build the infrastructure with Terraform, apply security controls and use CrowdStrike to investigate the logs.

## What I've worked on

- Terraform for the network and workload configuration.
- Separate backend and database subnets, with network security groups controlling traffic.
- Entra ID and RBAC permissions, an email alert for RBAC changes and an Azure Policy to block public IPs. These were earlier lab exercises outside the current Terraform code.
- App Service configuration with HTTPS, managed identity and a Key Vault secret reference.
- Private PostgreSQL configuration with private DNS and Entra authentication instead of passwords.
- A small API to generate authentication and request events for monitoring.

## Where it stands

The network configuration is in Terraform. The API has been tested locally. App Service and PostgreSQL are still disabled (`deploy_workloads=false`) to preserve Azure credits.

The application still needs database connectivity and Key Vault access permissions. CrowdStrike is not connected yet.

## Next

Once CrowdStrike trial access is available, ingest the lab events and test detections for suspicious activity. Local events let me start that part before deploying the paid Azure workloads.

Any Azure deployment comes after checking the plan and cost.
