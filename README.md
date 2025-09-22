<div align="center">

# Azure API Management Landing Zone Accelerator

Provision, configure, and operationalize Azure API Management (APIM) following Azure Landing Zone (ALZ) design areas and enterprise guardrails.

![Status](https://img.shields.io/badge/status-active-success) ![License](https://img.shields.io/badge/license-MIT-blue) ![IaC-Bicep](https://img.shields.io/badge/IaC-Bicep-5C2D91)

</div>

## 1. Overview
This repository provides an opinionated, extensible Infrastructure as Code (IaC) accelerator to deploy Azure API Management aligned with Azure Landing Zone principles (identity, network topology & connectivity, security, observability, and operations). It helps platform and API teams accelerate adoption while enforcing consistent governance, tagging, and separation of duties across resource groups.

Core goals:
- Enable repeatable APIM platform deployments across environments (Dev/Test/Prod) using Bicep.
- Codify enterprise network integration (VNet, private subnets, NSGs) and observability (Log Analytics, Application Insights, diagnostics).
- Simplify managed identity + RBAC setup for secure, credential‑free access to dependent services (e.g., Key Vault).
- Provide a modular foundation extendable to policies, gateway configuration, and multi-region scale.

## 2. Key Features & Benefits
- **Landing Zone Aligned**: Mirrors Azure ALZ design areas (Identity, Connectivity, Security, Management, Governance).
- **Modular Architecture**: Discrete Bicep modules for identity, networking, security, monitoring, and APIM core.
- **Enterprise Networking**: Virtual Network + APIM subnet + Application Gateway subnet with NSGs and diagnostics.
- **Zero‑Trust Ready**: Public network access toggles for monitoring and Key Vault; private network isolation pathways.
- **Managed Identity & RBAC**: System + user‑assigned identities with granular role assignments at subscription and RG scope.
- **Observability Built‑In**: Log Analytics, Application Insights, diagnostic settings for VNet, NSGs, Key Vault (extendable).
- **Consistent Tagging**: Rich tagging strategy (cost, compliance, ownership, lifecycle) baked into deployment.
- **Extensible**: Add custom policies, multi-region replicas, API versioning automation, or DevOps pipelines.
- **Declarative & Portable**: Pure Bicep—no external deployment logic required (optionally integrate with Azure Dev CLI / pipelines).

## 3. Repository Structure
```
infra/
	main.bicep              # Subscription-scoped orchestration (creates RGs + invokes modules)
	settings.yaml           # Central configuration for all shared + core settings
	main.parameters.json    # (Optional) parameters file (if using az deployment)  
	scripts/
		bash/pre-provision.sh # Pre-provision hook (azd) for environment setup

src/
	core/
		apim.bicep            # APIM service deployment (SKU, identity, integration bindings)
	shared/
		connectivity/         # Virtual network, subnets, NSGs, diagnostics
			networking.bicep
			subnets.bicep
			private-endpoint.bicep (placeholder / extend)
		identity/             # User/system managed identities + RBAC assignments
			identity.bicep
			roleAssignmentRg.bicep
			roleAssignmentSub.bicep
			userAssignedIdentity.bicep
		management/           # Monitoring & telemetry (Log Analytics, App Insights, diagnostics)
			monitoring.bicep
		security/             # Key Vault deployment
			security.bicep
		customtypes/          # Strongly typed configuration schemas (apim, networking, identity, etc.)
			*.bicep

azure.yaml                # Azure Developer CLI (azd) project metadata & hooks
LICENSE                   # MIT license
README.md                 # Project documentation (this file)
```

### Design Mapping to Azure Landing Zone
| ALZ Design Area | Implemented By |
|-----------------|----------------|
| [Identity & Access](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access) | Managed identities + roleAssignment modules |
| [Network Topology & Connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-connectivity) | VNet + subnets + NSGs + diagnostics |
| [Security](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/security) | Key Vault + restricted public access toggles |
| [Management & Monitoring](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/management) | Log Analytics + App Insights + diagnostic settings |
| [Governance](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/governance) | Tagging strategy + modular separation of resource groups |

## 4. Prerequisites
Before deploying, ensure you have:

| Requirement | Version / Notes |
|-------------|-----------------|
| [Azure Subscription](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/subscriptions) | Owner / User Access Admin rights recommended for initial deployment |
| [Azure CLI (`az`)](https://learn.microsoft.com/cli/azure/install-azure-cli) | Latest (>= 2.60) |
| [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) | Included with latest Azure CLI (verify with `az bicep version`) |
| [Azure Dev CLI (`azd`)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) | Optional (for `azure.yaml` workflow) |
| [RBAC Permissions](https://learn.microsoft.com/azure/role-based-access-control/overview) | Ability to create RGs, role assignments, managed identities |

Login & set subscription:
```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

## 5. Configuration (settings.yaml)
All environment‑specific values reside in `infra/settings.yaml`. Adjust before deployment:
- `shared.identity.usersAssigned` – Define user-assigned identities + RBAC roles.
- `shared.connectivity.virtualNetwork` – CIDR, subnet names, NSG names.
- `shared.monitoring` – Log Analytics and App Insights names.
- `shared.security.keyVault.name` – Key Vault logical name.
- `core.apiManagement` – APIM name, SKU, zones, identities, publisher metadata.
- `tags` – Governance and metadata (ownership, cost, compliance, lifecycle).

Tip: Keep a per-environment variant (e.g., `settings.prod.yaml`) and pre-process if needed.

### Example (Default configuration)
```yaml
shared:
  identity:
    resourceGroup: apim-plat-identity-rg
    usersAssigned:
      - name: apim-keyvault-identity
        scope:
          type: resourceGroup
          name: apim-plat-security-rg
        rbacRoleAssignment:
          roles:
            - roleName: "Key Vault Secrets User"
              id: "4633458b-17de-408a-b874-0445c86b69e6" # Key Vault Secrets User Role ID
            - roleName: "Key Vault Secrets Officer"
              id: "b86a8fe4-44ce-4948-aee5-eccb2c155cd7" # Key Vault Secrets Officer Role ID

  connectivity:
    resourceGroup: apim-plat-connectivity-rg
    publicNetworkAccess: false
    virtualNetwork:
      name: apim-plat-vnet
      addressPrefixes:
        - 10.0.0.0/16
      subnets:
        apiManagement:
          name: apim-plat-subnet
          addressPrefix: 10.0.1.0/24
          networkSecurityGroup:
            name: apim-plat-nsg
        applicationGateway:
          name: apim-plat-app-gateway-subnet
          addressPrefix: 10.0.2.0/24
          networkSecurityGroup:
            name: apim-plat-app-gateway-nsg

  monitoring:
    resourceGroup: apim-plat-monitoring-rg
    logAnalytics:
      name: apim-plat-log-analytics
    applicationInsights:
      name: apim-plat-app-insights

  security:
    resourceGroup: apim-plat-security-rg
    keyVault:
      name: apim-plat-kv

core:
  apiManagement:
    resourceGroup: apim-plat-rg
    name: apim-plat
    identity:
      type: "SystemAssigned, UserAssigned"
      systemAssigned:
        scope:
          type: resourceGroup
          name: apim-plat-security-rg
        rbacRoleAssignment:
          roles:
            - roleName: "Key Vault Secrets User"
              id: "4633458b-17de-408a-b874-0445c86b69e6" # Key Vault Secrets User Role ID
            - roleName: "Key Vault Secrets Officer"
              id: "b86a8fe4-44ce-4948-aee5-eccb2c155cd7" # Key Vault Secrets Officer Role ID

      usersAssigned:
        resourceGroup: apim-plat-identity-rg
        identities:
          - name: apim-keyvault-identity

    sku:
      name: Premium
      capacity: 3
      zones:
        - "1"
        - "2"
        - "3"
    publisherEmail: publisher@example.com
    publisherName: Contoso API Team

tags:
  CostCenter: "CC-1234" # Tracks cost allocation
  BusinessUnit: "IT" # Business unit or department
  Owner: "jdoe@contoso.com" # Resource/application owner
  ApplicationName: "APIM Platform" # Workload/application name

  Environment: "Production" # Environment (Dev, Test, QA, Prod)
  Lifecycle: "Operational" # Lifecycle stage
  ProjectName: "APIMForAll" # Project or initiative name
  ServiceClass: "Critical" # Workload tier (Critical, Standard, Experimental)

  DataClassification: "Confidential" # Data sensitivity (Public, Internal, Confidential, HighlyConfidential)
  RegulatoryCompliance: "GDPR" # Compliance requirements (GDPR, HIPAA, PCI, None)

  SupportContact: "cloudops@contoso.com" # Incident support team or contact

  ChargebackModel: "Dedicated" # Chargeback/Showback model
  BudgetCode: "FY25-Q1-InitiativeX" # Budget or initiative code
  ServiceOwner: "asmith@contoso.com" # Service manager accountable
```
Use this as a structural reference—substitute names, addresses, capacity, and tagging to fit your environment.

## 6. Deployment Options
### Option A: Azure CLI (Subscription Scope)
Deploy orchestrator:
```bash
az deployment sub create \
	--name apim-landingzone-$(date +%Y%m%d%H%M%S) \
	--location <region> \
	--template-file infra/main.bicep
```

### Option B: Azure Dev CLI (azd)
Initialize & provision:
```bash
azd init --template .
azd env new apim-prod --location <region>
azd provision
```
The `pre-provision` hook runs `infra/scripts/bash/pre-provision.sh` (ensure executable permission on non-Windows hosts).

### Option C: Pipelines
Integrate `az deployment sub create` in GitHub Actions / Azure DevOps with environment-approved `settings.yaml` versions. Add OIDC or service principal authentication.

## 7. Usage Scenarios
- **Greenfield Platform**: Stand up a production-ready APIM foundation with observability and identity in under 15 minutes.
- **Environment Parity**: Clone `settings.yaml`, adjust tags and SKU capacity for non-prod scaling.
- **Security Hardening**: Set `publicNetworkAccess: false` for network & Key Vault to move toward private-only posture.
- **API Team Onboarding**: Once APIM deployed, teams import APIs (policy automation can be layered later).
- **Cost / Right-Sizing**: Adjust APIM `sku.capacity` and zones to scale horizontally while maintaining SLA.

## 8. Extensibility Roadmap (Ideas)
- Add APIM policy module (global / product / API level).
- Add private endpoints (placeholder already in `connectivity`).
- Introduce multi-region (active/active) replication pattern.
- Add CI pipeline templates (GitHub Actions) for drift detection.
- Include APIM Developer Portal automation.

## 9. Troubleshooting
| Symptom | Possible Cause | Action |
|---------|----------------|--------|
| Role assignment failures | Insufficient permissions | Ensure you have `Owner` or `User Access Administrator` |
| APIM deployment timeout | SKU capacity or region constraints | Try different region or reduce capacity |
| Diagnostics not emitting | Workspace or storage ID mismatch | Verify outputs consumed by modules |
| Key Vault access denied | Identity role missing secrets access | Confirm RBAC roles in `settings.yaml` |

## 10. Contribution Guidelines
We welcome enhancements and extensions.
1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/<short-name>`.
3. Make changes (ensure descriptions / doc comments follow style used in existing modules).
4. Run a validation deployment in a non-production subscription.
5. Submit a Pull Request including:
	 - Summary of changes
	 - Rationale / design notes
	 - Any breaking considerations

Coding & Style:
- Keep modules surgical—avoid broad unrelated changes.
- Prefer adding new modules over expanding monolith logic.
- Use `@description` decorators for parameters, resources, outputs.
- Maintain consistent tag usage.

## 11. Security
No secrets are stored in the repo. Use Azure Key Vault for certificate and secret material. Report vulnerabilities via a private issue (do not disclose publicly until triaged).

## 12. License
This project is licensed under the [MIT License](./LICENSE). You are free to use, modify, and distribute with attribution.

## 13. References
- Azure API Management docs: https://learn.microsoft.com/azure/api-management/
- Azure Landing Zone guidance: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/
- Bicep documentation: https://learn.microsoft.com/azure/azure-resource-manager/bicep/
- Azure Monitor & Observability: https://learn.microsoft.com/azure/azure-monitor/
- Managed Identities: https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/

## 14. Feedback
Issues and feature requests welcome—open an issue with details. For roadmap discussions, propose via a GitHub Discussion or PR draft.

---
Accelerate securely. Operate confidently. Extend endlessly.