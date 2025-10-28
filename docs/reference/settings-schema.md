# Settings Schema Reference

This document provides a comprehensive reference for the `settings.yaml` configuration file used by the Azure API Management Accelerator.

## 🎯 Overview

The `settings.yaml` file serves as the central configuration hub for all deployment parameters, resource settings, and environment-specific values. It follows a hierarchical structure aligned with the actual implementation.

## 📋 Current Schema Structure

Based on the current implementation in `infra/settings.yaml` and validated against the Bicep type definitions:

### Root Level Configuration

```yaml
solutionName: string          # Base name for all resources (required)
shared: Shared               # Shared infrastructure configuration  
core: Core                   # Core platform configuration (contains apiManagement)
inventory: Inventory         # API inventory and governance configuration
```

## 🔧 Current Implementation Reference

### Complete Current Schema

```yaml
solutionName: "apim-accelerator"

shared:
  monitoring:
    logAnalytics:
      name: ""                           # Auto-generated if empty
      workSpaceResourceId: ""           # Optional: use existing workspace
      identity:
        type: "SystemAssigned"          # SystemAssigned | UserAssigned
        userAssignedIdentities: []      # Array of identity resource IDs
    applicationInsights:
      name: ""                          # Auto-generated if empty
      logAnalyticsWorkspaceResourceId: "" # Linked workspace (auto-linked if empty)
    tags:
      lz-component-type: "shared"
      component: "monitoring"
  tags:
    # Governance and compliance tags
    CostCenter: "CC-1234"              # Cost center tracking
    BusinessUnit: "IT"                 # Organizational unit
    Owner: "jdoe@contoso.com"          # Resource owner
    ApplicationName: "APIM Platform"   # Application identifier
    ProjectName: "APIMForAll"          # Project name
    ServiceClass: "Critical"           # Critical | Standard | Experimental
    RegulatoryCompliance: "GDPR"       # GDPR | HIPAA | PCI | None
    SupportContact: "cloudops@contoso.com" # Support team
    ChargebackModel: "Dedicated"       # Chargeback model
    BudgetCode: "FY25-Q1-InitiativeX"  # Budget identifier

core:
  apiManagement: 
    name: ""                           # Auto-generated if empty
    publisherEmail: "evilazaro@gmail.com" # Required: publisher email
    publisherName: "Contoso"           # Required: publisher name
    sku:
      name: "Premium"                  # Basic | BasicV2 | Developer | Standard | StandardV2 | Premium | Consumption
      capacity: 1                     # Scale units
    identity:
      type: "SystemAssigned"          # SystemAssigned | UserAssigned
      userAssignedIdentities: []      # Array of managed identity resource IDs
    workspaces: 
      - name: "workspace1"            # APIM workspace definition
  tags:
    lz-component-type: "core"
    component: "apiManagement"

inventory:
  apiCenter:
    name: ""                          # Auto-generated if empty
    identity:
      type: "SystemAssigned"         # SystemAssigned | UserAssigned | SystemAssigned,UserAssigned | None
      userAssignedIdentities: []     # Array of managed identity resource IDs
  tags:
    lz-component-type: "inventory"   # Landing zone component classification
    component: "inventory"           # Component identifier for API Center
```

## 🔧 Field Descriptions

### Solution Configuration
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `solutionName` | string | Yes | Base identifier for resource naming |

### Shared Configuration
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `shared.monitoring.logAnalytics.name` | string | No | Log Analytics workspace name (auto-generated if empty) |
| `shared.monitoring.logAnalytics.workSpaceResourceId` | string | No | Existing workspace resource ID |
| `shared.monitoring.logAnalytics.identity.type` | string | Yes | Identity type for Log Analytics |
| `shared.monitoring.applicationInsights.name` | string | No | Application Insights name (auto-generated if empty) |
| `shared.monitoring.applicationInsights.logAnalyticsWorkspaceResourceId` | string | No | Linked workspace resource ID |

### Core Configuration  
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `core.apiManagement.name` | string | No | APIM service name (auto-generated if empty) |
| `core.apiManagement.publisherEmail` | string | Yes | Publisher contact email |
| `core.apiManagement.publisherName` | string | Yes | Publisher organization name |
| `core.apiManagement.sku.name` | string | Yes | APIM pricing tier |
| `core.apiManagement.sku.capacity` | integer | Yes | Number of scale units |
| `core.apiManagement.identity.type` | string | Yes | Managed identity configuration |
| `core.apiManagement.workspaces` | array | No | Array of workspace definitions |

### Inventory Configuration
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `inventory.apiCenter.name` | string | No | API Center service name (auto-generated if empty) |
| `inventory.apiCenter.identity.type` | string | Yes | Identity type for API Center |

## 🏷️ Tagging Strategy

### Standard Tags (Applied Globally via `shared.tags`)

| Tag | Purpose | Example Values |
|-----|---------|----------------|
| `CostCenter` | Cost allocation tracking | "CC-1234", "Finance-001" |
| `BusinessUnit` | Organizational unit | "IT", "Marketing", "Sales" |
| `Owner` | Resource ownership | "admin@contoso.com" |
| `ApplicationName` | Application identifier | "APIM Platform", "API Gateway" |
| `ProjectName` | Project/initiative name | "APIMForAll", "DigitalTransformation" |
| `ServiceClass` | Service tier | "Critical", "Standard", "Experimental" |
| `RegulatoryCompliance` | Compliance requirements | "GDPR", "HIPAA", "PCI", "None" |
| `SupportContact` | Support team contact | "cloudops@contoso.com" |
| `ChargebackModel` | Cost allocation model | "Dedicated", "Shared", "Hybrid" |
| `BudgetCode` | Budget tracking code | "FY25-Q1-InitiativeX" |

### Component-Specific Tags

Component tags are applied at the module level and combined with global tags during deployment:

```yaml
# Monitoring components
shared:
  monitoring:
    tags:
      lz-component-type: "shared"      # Shared infrastructure classification
      component: "monitoring"          # Monitoring services identifier

# API Management components      
core:
  tags:
    lz-component-type: "core"          # Core platform classification
    component: "apiManagement"         # API Management identifier

# API Center components
inventory:
  tags:
    lz-component-type: "inventory"     # Inventory management classification  
    component: "inventory"             # API Center identifier
```

**Tag Inheritance**: Component tags are merged with global `shared.tags` during deployment, with deployment-specific tags (environment, managedBy, templateVersion) added automatically.

## 🌍 Environment-Specific Configurations

### Development Environment Example
```yaml
solutionName: "contoso-apim"

core:
  apiManagement:
    sku:
      name: "Developer"        # Lower cost for development
      capacity: 1
    publisherEmail: "dev-team@contoso.com"
    publisherName: "Contoso Dev Team"

shared:
  tags:
    Environment: "Development"
    ServiceClass: "Standard"   # Lower priority for dev
```

### Production Environment Example
```yaml
solutionName: "contoso-apim"

core:
  apiManagement:
    sku:
      name: "Premium"          # High availability for production
      capacity: 3              # Multi-instance for scale
    publisherEmail: "api-ops@contoso.com"
    publisherName: "Contoso API Operations"

shared:
  tags:
    Environment: "Production"
    ServiceClass: "Critical"   # Highest priority
    RegulatoryCompliance: "GDPR"
```

## ✅ Configuration Validation

### Required Fields Validation
```bash
# Check required fields are present
if [ -z "$(yq '.solutionName' infra/settings.yaml)" ]; then
  echo "ERROR: solutionName is required"
fi

if [ -z "$(yq '.core.apiManagement.publisherEmail' infra/settings.yaml)" ]; then
  echo "ERROR: publisherEmail is required"
fi
```

### Schema Validation with Bicep
```bash
# Validate configuration with actual deployment
az deployment sub validate \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters envName=dev location=eastus
```

## 🔗 Related Files

- **Source Configuration**: [`infra/settings.yaml`](../../infra/settings.yaml)
- **Type Definitions**: [`src/shared/common-types.bicep`](../../src/shared/common-types.bicep)
- **Main Orchestration**: [`infra/main.bicep`](../../infra/main.bicep)

## 📚 Additional Resources

- [Bicep Module Reference](bicep-modules.md) - Module parameters and outputs
- [Azure Resources Reference](azure-resources.md) - Created resources inventory
- [Configuration Examples](../user-guide/examples/) - Real-world configuration scenarios