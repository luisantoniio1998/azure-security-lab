# Azure Security Lab

My Azure lab for practising Terraform, network separation, and application security configuration. I’m keeping track of what is in the code and what I have actually tested.

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

The local API can generate events without deploying the paid Azure workloads. I check the Terraform plan and cost before deploying to Azure.

## Screenshots from the Azure exercises

<img width="985" height="495" alt="Screenshot 2026-10-13 at 17 28 09" src="https://github.com/user-attachments/assets/e0cd5de4-8382-4b02-9dd7-add2b6ff6926" />
<img width="2093" height="950" alt="Screenshot 2026-10-13 at 17 27 52" src="https://github.com/user-attachments/assets/a6c1fc56-801c-4a78-98de-9dce76c4d935" />
<img width="1474" height="791" alt="Screenshot 2026-10-13 at 17 18 37" src="https://github.com/user-attachments/assets/3f276723-2783-462c-9786-a65165b7cac3" />
