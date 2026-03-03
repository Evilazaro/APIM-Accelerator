# APIM Accelerator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Azure](https://img.shields.io/badge/Azure-API%20Management-0078D4?logo=microsoftazure)](https://azure.microsoft.com/products/api-management)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-orange)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![azd Compatible](https://img.shields.io/badge/azd-compatible-blue)](https://learn.microsoft.com/azure/developer/azure-developer-cli/)

An enterprise-ready landing zone accelerator for **Azure API Management** that deploys a complete API platform with centralized monitoring, multi-team workspace isolation, a self-service developer portal, and API inventory governance — all orchestrated through modular Bicep templates and the Azure Developer CLI (`azd`).

> 💡 **Why This Accelerator?** Standing up a production-grade APIM environment typically requires coordinating dozens of Azure resources across monitoring, networking, identity, and governance. This accelerator codifies Microsoft best practices into a single `azd up` deployment, reducing weeks of manual setup to under an hour.

## Architecture

**Overview**

The accelerator follows a layered landing zone pattern with clear separation between shared infrastructure, core platform services, and API governance capabilities.

```mermaid
---
title: "APIM Accelerator – Landing Zone Architecture"
---
flowchart TB
    subgraph Orchestration["Deployment Orchestration"]
        AZD["Azure Developer CLI<br/>(azd up)"]
        HOOK["Pre-Provision Hook<br/>Purge soft-deleted APIM"]
    end

    subgraph RG["Resource Group<br/>apim-accelerator-{env}-{region}-rg"]
        subgraph Shared["Shared Infrastructure"]
            LAW["Log Analytics<br/>Workspace"]
            AI["Application<br/>Insights"]
            SA["Storage Account<br/>Diagnostic Logs"]
        end

        subgraph Core["Core Platform"]
            APIM["API Management<br/>Premium SKU"]
            WS["Workspaces<br/>Multi-team Isolation"]
            DP["Developer Portal<br/>Azure AD Auth"]
        end

        subgraph Inventory["API Governance"]
            AC["API Center<br/>Catalog & Compliance"]
            RBAC["RBAC<br/>Role Assignments"]
        end
    end

    AZD --> HOOK --> RG
    LAW --> AI
    SA --> AI
    AI --> APIM
    LAW --> APIM
    SA --> APIM
    APIM --> WS
    APIM --> DP
    APIM --> AC
    AC --> RBAC
```

**Component Roles:**

| Component | Purpose |
|---|---|
| **Log Analytics Workspace** | Centralized logging, KQL queries, and diagnostic data |
| **Application Insights** | APM telemetry, distributed tracing, and performance monitoring |
| **Storage Account** | Long-term diagnostic log retention and compliance archival |
| **API Management** | Gateway, policies, rate limiting, caching, and API lifecycle |
| **Workspaces** | Logical isolation for teams to manage APIs independently |
| **Developer Portal** | Self-service API discovery, testing, and subscription management |
| **API Center** | Centralized API catalog, governance, and compliance management |

## Features

**Overview**

The accelerator provides production-ready capabilities out of the box, following Azure Well-Architected Framework principles for reliability, security, and operational excellence.

> 📌 **How It Works**: Modular Bicep templates are composed by a subscription-scoped orchestrator that deploys resources in dependency order — shared monitoring first, then core APIM, then API governance — with each layer receiving outputs from the previous one.

| Feature | Description | Status |
|---|---|---|
| **Modular Bicep IaC** | Composable templates with typed parameters and shared constants | ✅ Stable |
| **One-Command Deploy** | Full provisioning via `azd up` with pre-provision hooks | ✅ Stable |
| **Multi-Environment** | Support for `dev`, `test`, `staging`, `prod`, and `uat` environments | ✅ Stable |
| **Observability Stack** | Log Analytics + Application Insights + Storage diagnostics | ✅ Stable |
| **Multi-Team Workspaces** | Isolated APIM workspaces for independent API lifecycle management | ✅ Stable |
| **Developer Portal** | Azure AD–integrated portal with CORS, sign-in, and sign-up | ✅ Stable |
| **API Governance** | API Center integration with automated discovery from APIM | ✅ Stable |
| **Managed Identity** | System-assigned and user-assigned identity support across all resources | ✅ Stable |
| **RBAC Automation** | Deterministic role assignments for API Center operations | ✅ Stable |
| **Type-Safe Config** | Custom Bicep type definitions for validated, consistent configuration | ✅ Stable |

## Prerequisites

| Requirement | Minimum Version | Purpose |
|---|---|---|
| [Azure Subscription](https://azure.microsoft.com/free/) | — | Target for resource deployment |
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | 2.60+ | Azure resource management |
| [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) | 1.5+ | Deployment orchestration |
| [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) | 0.25+ | Infrastructure-as-Code compilation |

> ⚠️ **Permissions**: You need **Owner** or **Contributor + User Access Administrator** at the subscription level to create resource groups and assign RBAC roles.

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Evilazaro/APIM-Accelerator.git
cd APIM-Accelerator
```

### 2. Authenticate with Azure

```bash
az login
azd auth login
```

### 3. Initialize and Deploy

```bash
azd up
```

You will be prompted for:

- **Environment name** — a label for this deployment (e.g., `dev`, `prod`)
- **Azure location** — the target region (e.g., `eastus`, `westeurope`)

> 💡 **What happens**: `azd up` runs the pre-provision hook to purge soft-deleted APIM instances, then deploys shared monitoring, core APIM (Premium SKU), and API Center in dependency order.

### 4. Verify Deployment

```bash
az apim show --name <apim-name> --resource-group <rg-name> --query "{name:name, sku:sku.name, state:provisioningState}" -o table
```

## Configuration

All environment-specific settings are centralized in `infra/settings.yaml`. Resource names are auto-generated when left empty.

```yaml
solutionName: "apim-accelerator"

core:
  apiManagement:
    name: ""                          # Auto-generated if empty
    publisherEmail: "admin@contoso.com"
    publisherName: "Contoso"
    sku:
      name: "Premium"                 # Developer | Basic | Standard | Premium
      capacity: 1                     # Scale units (Premium: 1–10)
    identity:
      type: "SystemAssigned"          # SystemAssigned | UserAssigned
      userAssignedIdentities: []
    workspaces:
      - name: "workspace1"           # Premium SKU only
```

### Key Configuration Options

| Setting | Path | Description |
|---|---|---|
| **SKU Tier** | `core.apiManagement.sku.name` | APIM pricing tier — `Premium` required for workspaces and VNet |
| **Scale Units** | `core.apiManagement.sku.capacity` | Number of gateway units (affects throughput and cost) |
| **Publisher Email** | `core.apiManagement.publisherEmail` | Required by Azure for APIM service notifications |
| **Identity Type** | `core.apiManagement.identity.type` | Managed identity for secure Azure service integration |
| **Tags** | `shared.tags.*` | Governance tags applied to all resources (cost center, owner, etc.) |

## Project Structure

```
├── azure.yaml                    # azd project configuration
├── infra/
│   ├── main.bicep                # Subscription-scoped orchestrator
│   ├── main.parameters.json      # Parameter file for azd
│   ├── settings.yaml             # Environment configuration
│   └── azd-hooks/
│       └── pre-provision.sh      # Purge soft-deleted APIM instances
└── src/
    ├── core/
    │   ├── main.bicep            # Core platform orchestrator
    │   ├── apim.bicep            # APIM service + diagnostics + RBAC
    │   ├── workspaces.bicep      # Multi-team workspace isolation
    │   └── developer-portal.bicep # Azure AD portal configuration
    ├── inventory/
    │   └── main.bicep            # API Center + governance + RBAC
    └── shared/
        ├── main.bicep            # Shared infra orchestrator
        ├── common-types.bicep    # Reusable Bicep type definitions
        ├── constants.bicep       # Shared constants and utilities
        ├── monitoring/
        │   ├── main.bicep        # Monitoring orchestrator
        │   ├── insights/
        │   │   └── main.bicep    # Application Insights
        │   └── operational/
        │       └── main.bicep    # Log Analytics + Storage
        └── networking/
            └── main.bicep        # Networking (placeholder)
```

## Deployment

### Using Azure Developer CLI (Recommended)

```bash
# Provision infrastructure only
azd provision

# Full provision + deploy
azd up

# Tear down all resources
azd down
```

### Using Azure CLI Directly

```bash
az deployment sub create \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters envName=dev location=eastus
```

### Deployment Sequence

The orchestrator deploys resources in strict dependency order:

1. **Resource Group** — Container for all landing zone resources
2. **Shared Monitoring** — Log Analytics, Application Insights, Storage Account
3. **Core APIM Platform** — API Management service, workspaces, developer portal
4. **API Inventory** — API Center with APIM integration and RBAC

> ⚠️ **Deployment Time**: Initial APIM provisioning (especially Premium SKU) can take **30–60 minutes**. Subsequent deployments are incremental and significantly faster.

## Environments

The accelerator supports five environment tiers configured via the `envName` parameter:

| Environment | Use Case | Recommended SKU |
|---|---|---|
| `dev` | Development and experimentation | Developer |
| `test` | Automated testing and CI | Basic / Standard |
| `staging` | Pre-production validation | Standard / Premium |
| `uat` | User acceptance testing | Standard / Premium |
| `prod` | Production workloads | Premium |

## Troubleshooting

| Issue | Cause | Resolution |
|---|---|---|
| Name conflict on APIM deploy | Soft-deleted APIM with same name exists | Re-run `azd up` — the pre-provision hook purges soft-deleted instances |
| Workspace creation fails | Non-Premium SKU selected | Set `sku.name` to `Premium` in `infra/settings.yaml` |
| Developer portal auth error | Missing Azure AD app registration | Register an app in Azure AD and provide `clientId`/`clientSecret` |
| Role assignment denied | Insufficient subscription permissions | Ensure you have **Owner** or **Contributor + User Access Administrator** |
| Deployment timeout | Premium SKU initial provisioning | Wait up to 60 minutes; check status with `az apim show` |

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
