# Azure Resources Reference

This document provides a comprehensive inventory of all Azure resources created by the API Management Accelerator.

## 🎯 Resource Overview

The accelerator creates resources across multiple Azure services, organized by functional area and aligned with Azure Landing Zone design principles.

## 📋 Complete Resource Inventory

### Resource Groups
| Resource Type | Name Pattern | Purpose | Module |
|---------------|--------------|---------|---------|
| `Microsoft.Resources/resourceGroups` | `{solutionName}-{envName}-{location}-rg` | Single resource container for all components | `infra/main.bicep` |

### Monitoring & Observability

#### Log Analytics Workspace
| Resource Type | Name Pattern | SKU | Purpose | Module |
|---------------|--------------|-----|---------|---------|
| `Microsoft.OperationalInsights/workspaces` | `{solutionName}-{uniqueSuffix}-law` | PerGB2018 (default, configurable) | Centralized logging and analytics | `src/shared/monitoring/operational/main.bicep` |

**Key Properties**:
- SKU options: CapacityReservation, Free, LACluster, PerGB2018, PerNode, Premium, Standalone, Standard
- Identity: System-assigned managed identity (configurable)
- User-assigned identities: Supported via configuration
- Workspace-based ingestion for Application Insights

#### Application Insights
| Resource Type | Name Pattern | Kind | Purpose | Module |
|---------------|--------------|------|---------|---------|
| `Microsoft.Insights/components` | `{solutionName}-{uniqueSuffix}-ai` | web (configurable) | Application performance monitoring | `src/shared/monitoring/insights/main.bicep` |

**Key Properties**:
- Application types: web, other (configurable)
- Ingestion modes: ApplicationInsights, ApplicationInsightsWithDiagnosticSettings, LogAnalytics
- Retention: 90 days (default, configurable)
- Public network access: Enabled/Disabled (configurable)
- Workspace-based mode: Integrated with Log Analytics workspace

#### Storage Account (Monitoring Support)
| Resource Type | Name Pattern | SKU | Purpose | Module |
|---------------|--------------|-----|---------|---------|
| `Microsoft.Storage/storageAccounts` | `{baseName}sa{uniqueSuffix}` (max 24 chars) | Standard_LRS | Diagnostic data storage and archival | `src/shared/monitoring/operational/main.bicep` |

**Key Properties**:
- Kind: StorageV2 (latest storage account type)
- Access tier: Hot (optimized for frequently accessed data)
- Replication: Locally redundant storage (LRS) for cost optimization
- Name generation: Uses constants.bicep utility functions for compliance

### API Management Platform

#### API Management Service
| Resource Type | Name Pattern | SKU | Purpose | Module |
|---------------|--------------|-----|---------|---------|
| `Microsoft.ApiManagement/service` | `{solutionName}-{uniqueSuffix}-apim` | Premium (configurable) | Core API gateway and management platform | `src/core/apim.bicep` |

**Key Properties**:
- SKU options: Basic, BasicV2, Developer, Isolated, Standard, StandardV2, Premium, Consumption
- Capacity: Configurable scale units (affects performance and cost)
- Identity: System-assigned or User-assigned managed identity
- Developer portal: Enabled/Disabled (configurable, default enabled)
- Public network access: Enabled/Disabled (configurable)
- VNet integration: None/External/Internal (configurable)

**Associated Resources**:
- **Diagnostic Settings**: `{apimName}-diag`
  - Logs: allLogs category group
  - Metrics: AllMetrics category
  - Destination: Log Analytics workspace + Storage account

- **Application Insights Logger**: `{apimName}-appinsights`
  - Type: applicationInsights
  - Credentials: Instrumentation key from Application Insights
  - Integration: Full telemetry collection

- **RBAC Assignment**: Reader role for APIM managed identity
  - Scope: Resource group level
  - Purpose: Access to other Azure resources

#### API Management Workspaces
| Resource Type | Name Pattern | Purpose | Module |
|---------------|--------------|---------|---------|
| `Microsoft.ApiManagement/service/workspaces` | User-defined (from settings) | Multi-tenant API organization | `src/core/workspaces.bicep` |

**Key Properties**:
- Display name: Same as name
- Description: Same as name
- Parent: APIM service

#### Developer Portal Configuration
| Resource Type | Name Pattern | Purpose | Module |
|---------------|--------------|---------|---------|
| `Microsoft.ApiManagement/service/policies` | `policy` | Global API policies | `src/core/developer-portal.bicep` |
| `Microsoft.ApiManagement/service/identityProviders` | `aad` | Azure AD authentication | `src/core/developer-portal.bicep` |
| `Microsoft.ApiManagement/service/portalsettings` | `signin`, `signup` | Portal authentication settings | `src/core/developer-portal.bicep` |
| `Microsoft.ApiManagement/service/portalconfigs` | `default` | Portal CORS configuration | `src/core/developer-portal.bicep` |

### API Inventory & Governance

#### API Center Service
| Resource Type | Name Pattern | SKU | Purpose | Module |
|---------------|--------------|-----|---------|---------|
| `Microsoft.ApiCenter/services` | `{solutionName}-apicenter-{uniqueString}` | Standard | API catalog and governance | `src/inventory/main.bicep` |

**Key Properties**:
- Identity: System-assigned managed identity (default)
- Location: Same as resource group

#### API Center Workspace
| Resource Type | Name Pattern | Purpose | Module |
|---------------|--------------|---------|---------|
| `Microsoft.ApiCenter/services/workspaces` | `default` | Default API workspace | `src/inventory/main.bicep` |

**Key Properties**:
- Title: "Default workspace"
- Description: "Default workspace"

#### API Source Registration
| Resource Type | Name Pattern | Purpose | Module |
|---------------|--------------|---------|---------|
| `Microsoft.ApiCenter/services/workspaces/apiSources` | `{apiManagementName}` | Links APIM to API Center | `src/inventory/main.bicep` |

**Key Properties**:
- Source type: Azure API Management
- Resource ID: APIM service resource ID

### Identity & Access Management

#### Managed Identities
| Service | Identity Type | Purpose | RBAC Roles Assigned |
|---------|---------------|---------|-------------------|
| API Management | System/User-assigned (configurable) | Secure service authentication | Reader (`acdd72a7-3385-48ef-bd42-f606fba81ae7`) |
| Log Analytics | System/User-assigned (configurable) | Workspace operations and authentication | None (managed by platform) |
| API Center | System/User/None (configurable) | API catalog operations | API Center Service Reader (`71522526-b88f-4d52-b57f-d31fc3546d0d`), API Center Service Contributor (`6cba8790-29c5-48e5-bab1-c7541b01cb04`) |

#### RBAC Role Assignments
| Resource Type | Scope | Purpose | Module | Notes |
|---------------|-------|---------|---------|-------|
| `Microsoft.Authorization/roleAssignments` | Resource Group | APIM managed identity permissions | `src/core/apim.bicep` | Auto-generated GUID for assignment name |
| `Microsoft.Authorization/roleAssignments` | Resource Group | API Center managed identity permissions | `src/inventory/main.bicep` | Multiple roles assigned in array deployment |

### Networking (Placeholder)

#### Virtual Network
| Resource Type | Name Pattern | Purpose | Module | Status |
|---------------|--------------|---------|---------|--------|
| `Microsoft.ScVmm/virtualNetworks` | `vnet` | Network isolation | `src/shared/networking/main.bicep` | Placeholder |

**Note**: The networking module contains placeholder resources and is not fully implemented in the current version.

## 🏷️ Resource Tagging Strategy

### Standard Tags Applied to All Resources

| Tag Name | Source | Example Value | Purpose |
|----------|--------|---------------|---------|
| `CostCenter` | `shared.tags` | "CC-1234" | Cost allocation |
| `BusinessUnit` | `shared.tags` | "IT" | Organizational unit |
| `Owner` | `shared.tags` | "admin@contoso.com" | Resource ownership |
| `ApplicationName` | `shared.tags` | "APIM Platform" | Application context |
| `ProjectName` | `shared.tags` | "APIMForAll" | Project identification |
| `ServiceClass` | `shared.tags` | "Critical" | Service tier |
| `RegulatoryCompliance` | `shared.tags` | "GDPR" | Compliance requirements |
| `SupportContact` | `shared.tags` | "evilazaro@gmail.com" | Support escalation |
| `ChargebackModel` | `shared.tags` | "Dedicated" | Cost model |
| `BudgetCode` | `shared.tags` | "FY25-Q1-InitiativeX" | Budget tracking |
| `environment` | Runtime | "dev", "test", "prod" | Environment identification |

### Component-Specific Tags

| Component | Tag | Value | Purpose |
|-----------|-----|-------|---------|
| Monitoring | `lz-component-type` | "shared" | Landing zone categorization |
| Monitoring | `component` | "monitoring" | Component identification |
| API Management | `lz-component-type` | "core" | Landing zone categorization |
| API Management | `component` | "apiManagement" | Component identification |
| API Center | `lz-component-type` | "inventory" | Landing zone categorization |
| API Center | `component` | "inventory" | Component identification |

## 🔧 Resource Configuration Patterns

### Naming Conventions

```bicep
// Auto-generated names using centralized utility function
import { generateUniqueSuffix } from '../shared/constants.bicep'

var uniqueSuffix = generateUniqueSuffix(subscription().id, resourceGroup().id, resourceGroup().name, solutionName, location)
var resourceName = !empty(settings.name) 
  ? settings.name 
  : '${solutionName}-${uniqueSuffix}-{suffix}'
```

**Naming Suffixes** (defined in constants.bicep):
- API Management: `-apim`
- Log Analytics: `-law` 
- Application Insights: `-ai`
- API Center: `-apicenter`
- Storage Account: `sa` (with unique string, auto-truncated to 24 chars)
- Diagnostic Settings: `-diag`

### Identity Configuration

```bicep
// System-assigned identity pattern
identity: (identityType != 'None') ? {
  type: identityType
  userAssignedIdentities: (identityType == 'UserAssigned' && !empty(userAssignedIdentities))
    ? toObject(userAssignedIdentities, id => id, id => {})
    : null
} : null
```

### Diagnostic Settings Pattern

```bicep
// Standard diagnostic configuration
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${resource.name}-diag'
  scope: resource
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [{ category: 'AllMetrics', enabled: true }]
    logs: [{ category: 'allLogs', enabled: true }]
  }
}
```

## 📊 Resource Dependencies

```mermaid
graph TD
    A[Resource Group Creation] --> B[Shared Infrastructure]
    
    subgraph "Shared Module"
        B --> C[Log Analytics Workspace]
        B --> D[Storage Account] 
        C --> E[Application Insights]
        D --> E
    end
    
    subgraph "Core Module"
        B --> F[API Management Service]
        E --> F
        C --> F
        F --> G[APIM Workspaces]
        F --> H[Developer Portal Config]
    end
    
    subgraph "Inventory Module"
        F --> I[API Center Service]
        I --> J[API Center Workspace]
        I --> K[API Source Registration]
    end
```

## 🔍 Resource Validation

### Health Check Commands

```bash
# Show all deployed resources and their status
azd show

# Monitor service health and metrics
azd monitor

# View deployment logs
azd logs
```

### Cost Estimation

| Resource | SKU | Approximate Monthly Cost (USD) | Notes |
|----------|-----|-------------------------------|--------|
| API Management Premium (1 unit) | Premium | ~$2,000 | Base unit cost |
| Log Analytics (PerGB2018) | PerGB2018 | ~$50-200 | Depends on ingestion volume |
| Application Insights | Standard | ~$20-100 | Depends on telemetry volume |
| API Center | Standard | ~$100 | Fixed monthly cost |
| Storage Account (LRS) | Standard_LRS | ~$5-20 | Depends on storage usage |

**Total Estimated Monthly Cost**: ~$2,175-2,420 USD (excluding data transfer and additional API calls)

## 📚 Related Documentation

- [Settings Schema Reference](settings-schema.md) - Configuration parameters
- [Bicep Module Reference](bicep-modules.md) - Module structure and parameters
- [RBAC & Permissions](permissions.md) - Security and access control