# Bicep Module Reference

This document provides a comprehensive reference for all Bicep modules in the Azure API Management Accelerator.

## 🏗️ Module Architecture

The accelerator uses a hierarchical module structure organized by functional areas:

```
infra/main.bicep              # Subscription-level orchestration
├── src/shared/main.bicep     # Shared infrastructure
│   ├── monitoring/main.bicep # Monitoring orchestration
│   │   ├── operational/main.bicep # Log Analytics workspace
│   │   └── insights/main.bicep    # Application Insights
│   └── networking/main.bicep # Network components (placeholder)
├── src/core/main.bicep       # Core platform
│   ├── apim.bicep           # API Management service
│   ├── developer-portal.bicep # Developer portal config
│   └── workspaces.bicep     # APIM workspaces
└── src/inventory/main.bicep  # API inventory management
```

## 📋 Module Reference

### Infrastructure Orchestration

#### `infra/main.bicep`
**Scope**: `subscription`  
**Purpose**: Creates resource groups and coordinates all deployments

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `envName` | string | Yes | Environment name (dev, test, prod) |
| `location` | string | Yes | Azure region for deployment |

**Key Resources**:
- Resource group creation
- Module orchestration for shared, core, and inventory components

**Outputs**:
| Name | Type | Description |
|------|------|-------------|
| `APPLICATION_INSIGHTS_RESOURCE_ID` | string | Application Insights resource ID |
| `APPLICATION_INSIGHTS_NAME` | string | Application Insights name |
| `APPLICATION_INSIGHTS_INSTRUMENTATION_KEY` | string | Instrumentation key |

### Shared Infrastructure

#### `src/shared/main.bicep`
**Purpose**: Orchestrates shared infrastructure components

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `solutionName` | string | Yes | Base name for resources |
| `location` | string | Yes | Azure region |
| `sharedSettings` | Shared | Yes | Shared configuration object |

**Key Features**:
- Deploys monitoring infrastructure
- Manages shared tagging strategy
- Provides outputs for dependent modules

**Outputs**:
| Name | Type | Description |
|------|------|-------------|
| `AZURE_LOG_ANALYTICS_WORKSPACE_ID` | string | Log Analytics workspace resource ID |
| `APPLICATION_INSIGHTS_RESOURCE_ID` | string | Application Insights resource ID |
| `APPLICATION_INSIGHTS_NAME` | string | Application Insights component name |
| `APPLICATION_INSIGHTS_INSTRUMENTATION_KEY` | string | Application Insights instrumentation key |

#### `src/shared/monitoring/main.bicep`
**Purpose**: Monitoring infrastructure orchestration

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `location` | string | Yes | Azure region |
| `tags` | object | Yes | Resource tags |
| `solutionName` | string | Yes | Solution identifier |
| `monitoringSettings` | Monitoring | Yes | Monitoring configuration |

**Modules Deployed**:
- `operational/main.bicep` - Log Analytics workspace with storage
- `insights/main.bicep` - Application Insights component

#### `src/shared/monitoring/operational/main.bicep`
**Purpose**: Log Analytics workspace deployment

**Parameters**:
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | string | Yes | - | Workspace name |
| `location` | string | Yes | - | Azure region |
| `skuName` | string | No | `PerGB2018` | Pricing tier |
| `identityType` | string | Yes | - | Identity type |
| `userAssignedIdentities` | array | Yes | - | User-assigned identities |
| `tags` | object | Yes | - | Resource tags |

**Resources Created**:
- Log Analytics workspace
- Storage account (for diagnostic data)

**Outputs**:
| Name | Type | Description |
|------|------|-------------|
| `AZURE_LOG_ANALYTICS_WORKSPACE_ID` | string | Workspace resource ID |
| `AZURE_STORAGE_ACCOUNT_ID` | string | Storage account resource ID |

#### `src/shared/monitoring/insights/main.bicep`
**Purpose**: Application Insights component deployment

**Parameters**:
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | string | Yes | - | Component name |
| `location` | string | Yes | - | Azure region |
| `kind` | string | No | `web` | Application type |
| `applicationType` | string | No | `web` | Insights type |
| `ingestionMode` | string | No | `LogAnalytics` | Data ingestion mode |
| `publicNetworkAccessForIngestion` | string | No | `Enabled` | Ingestion access |
| `publicNetworkAccessForQuery` | string | No | `Enabled` | Query access |
| `retentionInDays` | int | No | `90` | Data retention period |
| `logAnalyticsWorkspaceResourceId` | string | Yes | - | Linked workspace |
| `storageAccountResourceId` | string | Yes | - | Storage account |
| `tags` | object | Yes | - | Resource tags |

**Outputs**:
| Name | Type | Description |
|------|------|-------------|
| `APPLICATION_INSIGHTS_RESOURCE_ID` | string | Component resource ID |
| `APPLICATION_INSIGHTS_NAME` | string | Component name |
| `APPLICATION_INSIGHTS_INSTRUMENTATION_KEY` | string | Instrumentation key |

### Core Platform

#### `src/core/main.bicep`
**Purpose**: Core API Management platform orchestration

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `solutionName` | string | Yes | Solution identifier |
| `location` | string | Yes | Azure region |
| `apiManagementSettings` | ApiManagement | Yes | APIM configuration |
| `logAnalyticsWorkspaceId` | string | Yes | Monitoring workspace ID |
| `ApplicationInsightsResourceId` | string | Yes | Application Insights ID |
| `tags` | object | Yes | Resource tags |

**Modules Deployed**:
- `apim.bicep` - API Management service
- `workspaces.bicep` - APIM workspaces (array deployment)
- `developer-portal.bicep` - Developer portal configuration

**Outputs**:
| Name | Type | Description |
|------|------|-------------|
| `API_MANAGEMENT_RESOURCE_ID` | string | APIM service resource ID |
| `API_MANAGEMENT_NAME` | string | APIM service name |

#### `src/core/apim.bicep`
**Purpose**: Core API Management service deployment

**Parameters**:
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | string | Yes | - | APIM service name |
| `location` | string | Yes | - | Azure region |
| `skuName` | string | Yes | - | APIM pricing tier |
| `identityType` | string | Yes | - | Managed identity type |
| `userAssignedIdentities` | array | Yes | - | User-assigned identities |
| `skuCapacity` | int | Yes | - | Scale unit count |
| `publisherEmail` | string | Yes | - | Publisher contact email |
| `publisherName` | string | Yes | - | Publisher organization |
| `logAnalyticsWorkspaceId` | string | Yes | - | Monitoring workspace |
| `ApplicationInsightsResourceId` | string | Yes | - | Application Insights |
| `enableDeveloperPortal` | bool | No | `true` | Enable developer portal |
| `publicNetworkAccess` | bool | No | `true` | Allow public access |
| `virtualNetworkType` | string | No | `None` | VNet integration type |
| `subnetResourceId` | string | No | `''` | Subnet for VNet integration |
| `tags` | object | Yes | - | Resource tags |

**Key Features**:
- System or user-assigned managed identity
- Diagnostic settings integration
- Application Insights logger configuration
- RBAC role assignments
- Developer portal enablement

**Outputs**:
| Name | Type | Description |
|------|------|-------------|
| `API_MANAGEMENT_RESOURCE_ID` | string | APIM service resource ID |
| `API_MANAGEMENT_NAME` | string | APIM service name |
| `AZURE_CLIENT_SECRET_ID` | string | Managed identity ID |
| `AZURE_CLIENT_SECRET_CLIENT_ID` | string | Managed identity client ID |
| `AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID` | string | Service principal ID |

#### `src/core/workspaces.bicep`
**Purpose**: APIM workspace creation

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | string | Yes | Workspace name |
| `apiManagementName` | string | Yes | Parent APIM service name |

**Resources Created**:
- API Management workspace with display name and description

#### `src/core/developer-portal.bicep`
**Purpose**: Developer portal configuration

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `apiManagementName` | string | Yes | APIM service name |
| `clientId` | string | Yes | Azure AD client ID |
| `clientSecret` | string | Yes | Azure AD client secret (secure) |
| `tags` | object | Yes | Resource tags |

**Resources Created**:
- Global policy configuration
- Azure AD identity provider
- Portal sign-in settings
- Portal sign-up settings
- Portal configuration with CORS

### API Inventory

#### `src/inventory/main.bicep`
**Purpose**: API Center integration for inventory management

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `solutionName` | string | Yes | Solution identifier |
| `location` | string | No | Azure region (default: eastus) |
| `inventorySettings` | Inventory | Yes | API Center configuration |
| `apiManagementName` | string | Yes | APIM service name |
| `apiManagementResourceId` | string | Yes | APIM service resource ID |
| `tags` | object | Yes | Resource tags |

**Resources Created**:
- API Center service with Standard SKU
- System or user-assigned managed identity
- RBAC role assignments
- API Center workspace (default)
- API source registration (links to APIM)

### Type Definitions

#### `src/shared/common-types.bicep`
**Purpose**: Shared type definitions using Bicep's type system

**Exported Types**:

```bicep
@export()
type ApiManagement = {
  name: string
  publisherEmail: string
  publisherName: string
  sku: {
    name: 'Basic' | 'BasicV2' | 'Developer' | 'Isolated' | 'Standard' | 'StandardV2' | 'Premium' | 'Consumption'
    capacity: int
  }
  identity: {
    type: 'SystemAssigned' | 'UserAssigned'
    userAssignedIdentities: []
  }
  workspaces: array
}

@export()
type Inventory = {
  apiCenter: ApiCenter
  tags: object
}

@export()
type Monitoring = {
  logAnalytics: LogAnalytics
  applicationInsights: ApplicationInsights
  tags: object
}

@export()
type Shared = {
  monitoring: Monitoring
  tags: object
}
```

## 🔧 Module Usage Patterns

### Basic Deployment
```bicep
// Deploy with minimum configuration
module apim 'src/core/apim.bicep' = {
  name: 'deploy-apim'
  params: {
    name: 'my-apim'
    location: 'eastus'
    skuName: 'Developer'
    skuCapacity: 1
    identityType: 'SystemAssigned'
    userAssignedIdentities: []
    publisherEmail: 'admin@contoso.com'
    publisherName: 'Contoso'
    logAnalyticsWorkspaceId: lawId
    ApplicationInsightsResourceId: aiId
    tags: commonTags
  }
}
```

### Advanced Configuration
```bicep
// Deploy with VNet integration and custom settings
module apim 'src/core/apim.bicep' = {
  name: 'deploy-apim-advanced'
  params: {
    name: 'enterprise-apim'
    location: 'eastus'
    skuName: 'Premium'
    skuCapacity: 3
    identityType: 'SystemAssigned'
    userAssignedIdentities: []
    publisherEmail: 'api-ops@contoso.com'
    publisherName: 'Contoso API Operations'
    logAnalyticsWorkspaceId: lawId
    ApplicationInsightsResourceId: aiId
    virtualNetworkType: 'Internal'
    subnetResourceId: subnetId
    publicNetworkAccess: false
    enableDeveloperPortal: true
    tags: commonTags
  }
}
```

## 📊 Resource Dependencies

```mermaid
graph TD
    A[infra/main.bicep] --> B[shared/main.bicep]
    A --> C[core/main.bicep]
    A --> D[inventory/main.bicep]
    
    B --> E[monitoring/main.bicep]
    E --> F[operational/main.bicep]
    E --> G[insights/main.bicep]
    
    C --> H[apim.bicep]
    C --> I[workspaces.bicep]
    C --> J[developer-portal.bicep]
    
    H --> I
    H --> J
    B --> C
    C --> D
```

## 🏷️ Tagging Conventions

All modules support consistent tagging through:

### Module-Level Tags
```bicep
// Applied to all resources in a module
param tags object

resource someResource 'Microsoft.SomeProvider/someType@2024-01-01' = {
  name: resourceName
  location: location
  tags: tags  // Inherited from module parameter
}
```

### Component-Specific Tags
```bicep
// Merge module tags with component-specific tags
tags: union(tags, {
  'component': 'monitoring'
  'lz-design-area': 'management'
})
```

## 🔍 Debugging and Validation

### Template Validation
```bash
# Validate individual modules
az deployment group validate \
  --resource-group myRG \
  --template-file src/core/apim.bicep \
  --parameters @params.json

# Validate complete deployment
az deployment sub validate \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters envName=dev location=eastus
```

### Parameter Testing
```bash
# Test parameter combinations with whatif
az deployment sub what-if \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters envName=test location=westus
```

## 📚 Related Documentation

- [Settings Schema Reference](settings-schema.md) - Configuration file reference
- [Azure Resources Reference](azure-resources.md) - Complete resource inventory
- [Type Definitions](../../src/shared/common-types.bicep) - Bicep type definitions