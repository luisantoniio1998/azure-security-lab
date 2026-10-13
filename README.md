# Azure Security Lab

Azure security engineering playground.

## Current Architecture

```text
Azure for Students
│
├── Microsoft Entra ID
│   └── sg-azure-security-readers
│       └── Reader → rg-azure-security-lab
│
├── Azure Monitor
│   └── SEC-004: RBAC Changes
│       └── Activity Log → Email Alert
│
├── Azure Policy
│   └── SEC-005: Deny Public IP Addresses
│
└── rg-azure-security-lab
    │
    └── Spain Central
        │
        └── vnet-security-lab (10.10.0.0/16)
            │
            ├── snet-backend (10.10.1.0/24)
            │   ├── nsg-backend
            │   └── Delegation: App Service
            │
            └── snet-database (10.10.2.0/24)
                ├── nsg-database
                └── Delegation: PostgreSQL
```

Infrastructure managed with Terraform.

Application and database workloads are not deployed.

## Planned Architecture

```text
                        INTERNET
                           │
                           ▼
                    ┌─────────────┐
                    │  App Service│
                    │  HTTPS Only │
                    └──────┬──────┘
                           │
                 VNet Integration
                           │
                           ▼
              ┌──────────────────────┐
              │  vnet-security-lab   │
              │    10.10.0.0/16      │
              │                      │
              │  ┌────────────────┐  │
              │  │ snet-backend   │  │
              │  │ 10.10.1.0/24   │  │
              │  │ nsg-backend    │  │
              │  └───────┬────────┘  │
              │          │ TCP 5432  │
              │          ▼           │
              │  ┌────────────────┐  │
              │  │ snet-database  │  │
              │  │ 10.10.2.0/24   │  │
              │  │                │  │
              │  │ PostgreSQL     │  │
              │  │ Private Access │  │
              │  │ nsg-database   │  │
              │  └────────────────┘  │
              │                      │
              │  Private DNS         │
              └──────────────────────┘
                           │
                           ▼
                 ┌─────────────────┐
                 │ Azure Monitoring│
                 │ Activity Logs   │
                 │ Diagnostic Logs │
                 └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │ Security / SIEM │
                 │ Detection Rules │
                 │ Threat Hunting  │
                 └─────────────────┘

              ┌─────────────────────┐
              │   Security Controls │
              ├─────────────────────┤
              │ Entra ID + RBAC     │
              │ Azure Policy        │
              │ Network Isolation   │
              │ Managed Identity    │
              │ TLS / HTTPS         │
              │ Security Monitoring │
              └─────────────────────┘
```

## Roadmap

- [x] Terraform infrastructure
- [x] Virtual network and subnet segmentation
- [x] Network Security Groups
- [x] Entra ID security group and RBAC
- [x] RBAC activity monitoring and email alerts
- [x] Azure Policy — deny Public IP resources
- [ ] Network hardening
- [ ] Resource locks
- [ ] App Service deployment
- [ ] Private PostgreSQL deployment
- [ ] Private DNS configuration
- [ ] Managed identity authentication
- [ ] Diagnostic logging
- [ ] SIEM integration
- [ ] Detection engineering and threat hunting

---

Build. Break. Secure. Repeat.
