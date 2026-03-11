# APIM Accelerator

[![Azure](https://img.shields.io/badge/Azure-API%20Management-0078D4?logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/azure/api-management/)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-orange?logo=microsoftazure)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![azd Compatible](https://img.shields.io/badge/azd-compatible-blue)](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

**Overview**

The APIM Accelerator is an Azure API Management landing zone solution that deploys a production-ready API platform on Azure using Infrastructure as Code (Bicep). It provides enterprises with a fully configured API Management service, integrated monitoring, developer portal with Azure AD authentication, and centralized API governance through API Center.

This accelerator reduces the time to deploy a compliant, enterprise-grade API Management environment from weeks to minutes. It follows Azure landing zone principles with modular Bicep templates, centralized configuration through YAML settings, and one-command deployment via Azure Developer CLI (`azd`). Teams gain a complete API platform with multi-workspace isolation, comprehensive observability, and built-in governance capabilities.

> [!TIP]
> Run `azd up` to provision the entire APIM landing zone in a single command. The accelerator handles resource group creation, monitoring infrastructure, API Management deployment, and API Center configuration automatically.

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Architecture

**Overview**

The APIM Accelerator follows a modular, layered architecture aligned with Azure landing zone principles. The deployment orchestrator provisions resources in a dependency-ordered sequence: shared monitoring infrastructure first, then the core API Management platform, and finally the API inventory layer.

The architecture separates concerns into three tiers. The shared tier provides Log Analytics, Application Insights, and diagnostic storage. The core tier deploys the API Management service with managed identity, developer portal, and workspaces. The inventory tier provisions API Center for centralized API governance and automated discovery from the APIM instance.

```mermaid
---
title: "APIM Accelerator Architecture"
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
---
flowchart TB
    accTitle: APIM Accelerator Architecture
    accDescr: Shows the three-tier architecture of the APIM Accelerator including shared monitoring, core API Management platform, and API inventory layers with deployment dependencies

    %% ═══════════════════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v1.1
    %% (Semantic + Structural + Font + Accessibility Governance)
    %% ═══════════════════════════════════════════════════════════════════════════
    %% PHASE 1 - FLUENT UI: All styling uses approved Fluent UI palette only
    %% PHASE 2 - GROUPS: Every subgraph has semantic color via style directive
    %% PHASE 3 - COMPONENTS: Every node has semantic classDef + icon prefix
    %% PHASE 4 - ACCESSIBILITY: accTitle/accDescr present, WCAG AA contrast
    %% PHASE 5 - STANDARD: Governance block present, classDefs centralized
    %% ═══════════════════════════════════════════════════════════════════════════

    subgraph orchestrator("📦 Deployment Orchestrator")
        direction TB
        azd("🚀 Azure Developer CLI"):::core
        mainBicep("📄 infra/main.bicep"):::core
        settings("⚙️ settings.yaml"):::neutral

        azd -->|"triggers"| mainBicep
        mainBicep -->|"reads"| settings
    end

    subgraph shared("🔍 Shared Infrastructure")
        direction TB
        law("📊 Log Analytics Workspace"):::data
        appInsights("📈 Application Insights"):::data
        storage("🗄️ Storage Account"):::data

        law -->|"linked to"| appInsights
        law -->|"archives to"| storage
    end

    subgraph coreLayer("🏢 Core API Platform")
        direction TB
        apim("🔌 API Management Service"):::core
        devPortal("🌐 Developer Portal"):::core
        workspaces("📂 Workspaces"):::core

        apim -->|"hosts"| devPortal
        apim -->|"organizes"| workspaces
    end

    subgraph inventoryLayer("📋 API Inventory")
        direction TB
        apiCenter("📦 API Center"):::success
        apiSource("🔗 API Source Integration"):::success

        apiCenter -->|"discovers from"| apiSource
    end

    mainBicep -->|"deploys first"| shared
    mainBicep -->|"deploys second"| coreLayer
    mainBicep -->|"deploys third"| inventoryLayer
    shared -->|"provides monitoring to"| coreLayer
    coreLayer -->|"registers APIs with"| inventoryLayer

    %% Centralized semantic classDefs (Phase 5 compliant)
    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130

    style orchestrator fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style shared fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style coreLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style inventoryLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
```

**Component Roles:**

| Component                      | Purpose                                                   | Source             |
| ------------------------------ | --------------------------------------------------------- | ------------------ |
| 📦 **Deployment Orchestrator** | Coordinates end-to-end provisioning via `azd` and Bicep   | `infra/main.bicep` |
| 🔍 **Shared Infrastructure**   | Provides centralized monitoring, logging, and diagnostics | `src/shared/`      |
| 🏢 **Core API Platform**       | Deploys API Management with portal and workspaces         | `src/core/`        |
| 📋 **API Inventory**           | Enables API governance and automated discovery            | `src/inventory/`   |

## Features

**Overview**

The APIM Accelerator delivers a complete API Management landing zone with six core capabilities designed for enterprise-grade API platform operations. Each capability is implemented as a modular Bicep template that can be configured independently.

These features address the full lifecycle of API platform management, from infrastructure provisioning and identity security to developer experience and API governance. The modular design enables teams to adopt individual capabilities incrementally while maintaining a consistent deployment pattern.

| Feature                           | Description                                                                                                                                         | Status    |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| 🔌 **API Management Service**     | Deploys Azure APIM with configurable SKU (Developer through Premium), managed identity, and optional VNet integration for private deployments       | ✅ Stable |
| 🔒 **Managed Identity & RBAC**    | Supports System-assigned and User-assigned managed identities with automatic role assignments for secure, credential-free Azure service integration | ✅ Stable |
| 📊 **Comprehensive Monitoring**   | Provisions Log Analytics workspace, Application Insights, and diagnostic storage account with full telemetry capture across all deployed resources  | ✅ Stable |
| 🌐 **Developer Portal**           | Configures self-service developer portal with Azure AD authentication, CORS policies, sign-in/sign-up flows, and terms of service enforcement       | ✅ Stable |
| 📂 **Workspace Isolation**        | Creates APIM workspaces for multi-team API isolation, enabling independent API lifecycle management within a shared infrastructure                  | ✅ Stable |
| 📋 **API Inventory & Governance** | Deploys Azure API Center with APIM integration for automated API discovery, centralized catalog, and compliance management via RBAC                 | ✅ Stable |

## Requirements

**Overview**

The APIM Accelerator requires an Azure subscription, Azure CLI, and Azure Developer CLI as core prerequisites. These tools handle authentication, resource provisioning, and deployment orchestration for the entire landing zone.

All infrastructure is defined as Bicep templates with no additional runtime dependencies. The deployment process is fully automated through `azd` lifecycle hooks including a pre-provision script that purges soft-deleted APIM instances to prevent naming conflicts during redeployment.

| Requirement                      | Details                                                                                        | Installation                                                                                   |
| -------------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| ☁️ **Azure Subscription**        | Active subscription with permissions to create resource groups, APIM, and API Center resources | [Create a free account](https://azure.microsoft.com/free/)                                     |
| 🛠️ **Azure CLI**                 | Version 2.50 or later for Azure resource management and authentication                         | [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)                   |
| 🚀 **Azure Developer CLI**       | `azd` for one-command deployment, provisioning, and lifecycle management                       | [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)     |
| 📦 **Bicep CLI**                 | Included with Azure CLI; used for compiling Bicep templates to ARM                             | Bundled with Azure CLI                                                                         |
| 🔑 **Azure AD App Registration** | Required for developer portal authentication with client ID and client secret                  | [Register an app](https://learn.microsoft.com/entra/identity-platform/quickstart-register-app) |
| 🐚 **Bash Shell**                | Required for pre-provision hook script execution (Git Bash on Windows)                         | Included with Git for Windows                                                                  |

## Getting Started

**Overview**

Getting started with the APIM Accelerator requires three steps: cloning the repository, authenticating with Azure, and running `azd up`. The accelerator handles all infrastructure provisioning, monitoring setup, and service configuration automatically.

The deployment creates a resource group following the naming pattern `{solutionName}-{environment}-{location}-rg`, provisions shared monitoring infrastructure first, then deploys the core APIM platform, and finally configures API Center for governance.

### Quick Start

1. **Clone the repository**

```bash
git clone https://github.com/Evilazaro/APIM-Accelerator.git
cd APIM-Accelerator
```

2. **Authenticate with Azure**

```bash
az login
azd auth login
```

3. **Deploy the landing zone**

```bash
azd up
```

> [!NOTE]
> When prompted, provide an environment name (e.g., `dev`, `test`, `prod`) and an Azure region. The environment name determines resource sizing and is applied as a tag to all resources.

The `azd up` command executes the following sequence:

```text
Pre-provision hook (purge soft-deleted APIM instances)
  → Resource group creation
    → Shared monitoring deployment (Log Analytics, App Insights, Storage)
      → Core APIM platform deployment (APIM service, portal, workspaces)
        → API inventory deployment (API Center, API source integration)
```

### Expected Output

After successful deployment, the following resources are provisioned in your Azure subscription:

| Resource                       | Type                                                 | Purpose                                    |
| ------------------------------ | ---------------------------------------------------- | ------------------------------------------ |
| 📊 **Log Analytics Workspace** | `Microsoft.OperationalInsights/workspaces`           | Centralized log collection and KQL queries |
| 📈 **Application Insights**    | `Microsoft.Insights/components`                      | Application performance monitoring         |
| 🗄️ **Storage Account**         | `Microsoft.Storage/storageAccounts`                  | Diagnostic log archival                    |
| 🔌 **API Management**          | `Microsoft.ApiManagement/service`                    | API gateway, policies, and management      |
| 🌐 **Developer Portal**        | APIM sub-resource                                    | Self-service API documentation and testing |
| 📂 **APIM Workspace**          | `Microsoft.ApiManagement/service/workspaces`         | Team-based API isolation                   |
| 📦 **API Center**              | `Microsoft.ApiCenter/services`                       | API inventory and governance               |
| 🔗 **API Source**              | `Microsoft.ApiCenter/services/workspaces/apiSources` | Automated API discovery from APIM          |

## Configuration

**Overview**

All deployment configuration is centralized in the `infra/settings.yaml` file. This YAML file defines the solution name, monitoring settings, API Management service parameters, and API inventory configuration. Resource names can be auto-generated or explicitly overridden.

The configuration follows a hierarchical structure organized by deployment tier: shared infrastructure, core platform, and inventory services. Each tier includes its own identity settings, tags, and service-specific parameters. Tags provide governance metadata including cost center, business unit, regulatory compliance, and support contact information.

### Configuration File

The primary configuration file is located at `infra/settings.yaml`:

```yaml
# Solution identifier for naming conventions
solutionName: "apim-accelerator"

# Shared services: monitoring and observability
shared:
  monitoring:
    logAnalytics:
      name: "" # Leave empty for auto-generation
      identity:
        type: "SystemAssigned"
    applicationInsights:
      name: "" # Leave empty for auto-generation
  tags:
    CostCenter: "CC-1234"
    BusinessUnit: "IT"
    Owner: "your-email@example.com"

# Core platform: API Management service
core:
  apiManagement:
    name: "" # Leave empty for auto-generation
    publisherEmail: "admin@contoso.com"
    publisherName: "Contoso"
    sku:
      name: "Premium" # Developer, Basic, Standard, Premium, Consumption
      capacity: 1 # Scale units (Premium: 1-10)
    identity:
      type: "SystemAssigned"
    workspaces:
      - name: "workspace1"

# Inventory: API Center for governance
inventory:
  apiCenter:
    name: "" # Leave empty for auto-generation
    identity:
      type: "SystemAssigned"
```

### SKU Options

| SKU                          | Use Case                              | SLA    | VNet Support |
| ---------------------------- | ------------------------------------- | ------ | ------------ |
| 🧪 **Developer**             | Non-production testing and evaluation | No SLA | ❌           |
| 📦 **Basic / BasicV2**       | Small-scale production workloads      | ✅     | ❌           |
| ⚙️ **Standard / StandardV2** | Medium-scale production workloads     | ✅     | ❌           |
| 🏢 **Premium**               | Enterprise with multi-region and VNet | ✅     | ✅           |
| ⚡ **Consumption**           | Serverless, pay-per-execution model   | ✅     | ❌           |

### Parameters

Deployment parameters are passed through `infra/main.parameters.json`:

| Parameter     | Type     | Description                                                  |
| ------------- | -------- | ------------------------------------------------------------ |
| ⚙️ `envName`  | `string` | Environment name: `dev`, `test`, `staging`, `prod`, or `uat` |
| 🌍 `location` | `string` | Azure region for resource deployment                         |

> [!WARNING]
> Premium SKU is required for virtual network integration and multi-region deployments. Workspace isolation is only available on Premium tier. Choose the appropriate SKU based on your production requirements before deployment.

## Deployment

**Overview**

Deployment is automated through Azure Developer CLI (`azd`), which orchestrates the Bicep template compilation, resource group creation, and sequential module deployment. A pre-provision hook script automatically purges soft-deleted APIM instances to prevent naming conflicts.

The deployment operates at the subscription scope, creating a resource group named using the pattern `{solutionName}-{envName}-{location}-rg` and deploying all resources within it.

### Commands

| Command            | Purpose                                                    |
| ------------------ | ---------------------------------------------------------- |
| 🚀 `azd up`        | Provision infrastructure and deploy the complete solution  |
| 📦 `azd provision` | Provision Azure resources only (no application deployment) |
| 🔄 `azd deploy`    | Deploy application code only (resources must exist)        |
| 🗑️ `azd down`      | Remove all provisioned Azure resources                     |

### Manual Deployment (Azure CLI)

```bash
az deployment sub create \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters envName=dev location=eastus
```

### Pre-Provision Hook

The `infra/azd-hooks/pre-provision.sh` script runs automatically before provisioning. It purges all soft-deleted APIM instances in the target region to enable clean redeployment:

```bash
# The hook is triggered automatically by azd
# Manual execution (if needed):
./infra/azd-hooks/pre-provision.sh "East US"
```

## Project Structure

```text
├── azure.yaml                      # Azure Developer CLI configuration
├── LICENSE                         # MIT License
├── infra/
│   ├── main.bicep                  # Main orchestration template (subscription scope)
│   ├── main.parameters.json        # Deployment parameters
│   ├── settings.yaml               # Centralized configuration for all services
│   └── azd-hooks/
│       └── pre-provision.sh        # Pre-deployment hook for APIM cleanup
└── src/
    ├── core/
    │   ├── main.bicep              # Core platform orchestrator
    │   ├── apim.bicep              # API Management service definition
    │   ├── developer-portal.bicep  # Developer portal with Azure AD
    │   └── workspaces.bicep        # APIM workspace creation
    ├── inventory/
    │   └── main.bicep              # API Center with APIM integration
    └── shared/
        ├── main.bicep              # Shared infrastructure orchestrator
        ├── common-types.bicep      # Reusable type definitions
        ├── constants.bicep         # Shared constants and utility functions
        ├── monitoring/
        │   ├── main.bicep          # Monitoring orchestrator
        │   ├── insights/
        │   │   └── main.bicep      # Application Insights deployment
        │   └── operational/
        │       └── main.bicep      # Log Analytics and storage deployment
        └── networking/
            └── main.bicep          # Networking placeholder (future)
```

## Contributing

**Overview**

Contributions to the APIM Accelerator are welcome and follow the standard GitHub fork-and-pull-request workflow. All contributions must maintain the existing Bicep module structure, follow the established naming conventions, and include comprehensive documentation in template headers.

Before submitting changes, verify that your Bicep templates compile successfully using `az bicep build` and that all parameter descriptions follow the `@description()` decorator pattern used throughout the codebase.

### How to Contribute

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes following the existing code conventions
4. Validate Bicep templates compile without errors:

```bash
az bicep build --file infra/main.bicep
```

5. Submit a pull request with a clear description of changes

### Code Conventions

- Use `@description()` decorators on all parameters, variables, and resources
- Follow the naming pattern `{solutionName}-{uniqueSuffix}-{resourceType}`
- Organize modules by tier: `src/shared/`, `src/core/`, `src/inventory/`
- Include usage examples in module header comments
- Define reusable types in `src/shared/common-types.bicep`
- Export shared constants through `src/shared/constants.bicep`

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Evilázaro Alves
