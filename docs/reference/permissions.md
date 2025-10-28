# RBAC & Permissions Reference

This document provides a comprehensive reference for Role-Based Access Control (RBAC) and permissions required for the Azure API Management Landing Zone Accelerator.

## 🎯 Overview

The accelerator implements a security-first approach using managed identities and least-privilege access principles. All service-to-service communication uses managed identities instead of secrets or keys.

## 🔐 Deployment Permissions

### Required Permissions for Deployment

The user or service principal deploying the accelerator requires these permissions:

#### Subscription-Level Permissions
| Role | Scope | Purpose | Required For |
|------|-------|---------|--------------|
| `Contributor` | Subscription | Create resource groups and resources | All deployments |
| `User Access Administrator` | Subscription | Assign RBAC roles to managed identities | RBAC assignments |

#### Alternative Minimal Permissions
If `Contributor` at subscription level is too broad, use these specific permissions:

| Permission | Scope | Purpose |
|------------|-------|---------|
| `Microsoft.Resources/resourceGroups/write` | Subscription | Create resource groups |
| `Microsoft.Resources/deployments/*` | Subscription | Manage ARM/Bicep deployments |
| `Microsoft.Authorization/roleAssignments/write` | Resource Group | Assign roles to managed identities |
| `Microsoft.OperationalInsights/*` | Resource Group | Create Log Analytics workspace |
| `Microsoft.Insights/*` | Resource Group | Create Application Insights |
| `Microsoft.Storage/*` | Resource Group | Create storage accounts |
| `Microsoft.ApiManagement/*` | Resource Group | Create APIM service |
| `Microsoft.ApiCenter/*` | Resource Group | Create API Center service |

### Service Principal Deployment (CI/CD)

For automated deployments, create a service principal with:

```bash
# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "apim-accelerator-deploy" \
  --role "Contributor" \
  --scopes "/subscriptions/{subscription-id}" \
  --sdk-auth

# Add User Access Administrator for RBAC assignments
az role assignment create \
  --assignee "{service-principal-id}" \
  --role "User Access Administrator" \
  --scope "/subscriptions/{subscription-id}"
```

## 🏗️ Managed Identity Configuration

### System-Assigned Managed Identities

#### API Management Service Identity
| Resource | Identity Type | Principal ID Source | Purpose |
|----------|---------------|-------------------|---------|
| API Management | System-assigned | `apim.identity.principalId` | Service authentication |

**Automatically Assigned Roles**:
- **Role**: `Reader` (`acdd72a7-3385-48ef-bd42-f606fba81ae7`)
- **Scope**: Resource Group
- **Purpose**: Read access to resource group resources

#### Log Analytics Workspace Identity
| Resource | Identity Type | Purpose |
|----------|---------------|---------|
| Log Analytics | System-assigned | Workspace authentication and diagnostics |

**Role Assignments**: None (uses system permissions)

#### API Center Service Identity
| Resource | Identity Type | Principal ID Source | Purpose |
|----------|---------------|-------------------|---------|
| API Center | System-assigned | `apiCenter.identity.principalId` | Service authentication |

**Automatically Assigned Roles**:
- **Role**: `API Center Service Reader` (`71522526-b88f-4d52-b57f-d31fc3546d0d`)
- **Scope**: Resource Group  
- **Purpose**: Read access to API Center resources

### User-Assigned Managed Identities

The templates support user-assigned managed identities through configuration:

```yaml
# In settings.yaml
core:
  apiManagement:
    identity:
      type: "UserAssigned"
      userAssignedIdentities:
        - "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{name}"
```

**Requirements for User-Assigned Identities**:
- Must exist before deployment
- Must have appropriate permissions pre-assigned
- Identity resource ID must be provided in configuration

## 🔧 Built-in Role Definitions

### Roles Used by the Accelerator

#### Reader (acdd72a7-3385-48ef-bd42-f606fba81ae7)
**Assigned to**: API Management system identity  
**Permissions**:
- `*/read` - Read all resources
- `Microsoft.Support/*` - Create support requests

**Purpose**: Allows APIM to read configuration and status of other resources in the resource group.

#### API Center Service Reader (71522526-b88f-4d52-b57f-d31fc3546d0d)
**Assigned to**: API Center system identity  
**Permissions**:
- `Microsoft.ApiCenter/services/*/read` - Read API Center resources
- `Microsoft.ApiManagement/service/*/read` - Read APIM resources for integration

**Purpose**: Allows API Center to read APIM service configuration for inventory management.

### Additional Roles for Operations

#### For Platform Engineers
| Role | Scope | Purpose |
|------|-------|---------|
| `API Management Service Contributor` | Resource Group | Full APIM management |
| `Log Analytics Contributor` | Resource Group | Monitoring configuration |
| `Monitoring Contributor` | Resource Group | Configure alerts and metrics |

#### For Developers
| Role | Scope | Purpose |
|------|-------|---------|
| `API Management Service Reader` | Resource Group | Read APIM configuration |
| `API Management Developer Portal Content Editor` | APIM Service | Manage developer portal content |

#### For Security Engineers
| Role | Scope | Purpose |
|------|-------|---------|
| `Security Reader` | Resource Group | Security configuration review |
| `Security Admin` | Resource Group | Security policy management |

## 🌐 Network Security Considerations

### Public Network Access

By default, all services allow public network access:

```yaml
# Current configuration
core:
  apiManagement:
    publicNetworkAccess: true    # Default: allows internet access
    virtualNetworkType: "None"   # Default: no VNet integration
```

### Private Network Configuration

For enhanced security, configure VNet integration:

```yaml
core:
  apiManagement:
    publicNetworkAccess: false
    virtualNetworkType: "Internal"  # Internal VNet integration
    virtualNetworkConfiguration:
      subnetResourceId: "/subscriptions/.../subnets/{subnet-name}"
```

**Required Permissions for VNet Integration**:
- `Microsoft.Network/virtualNetworks/subnets/join/action`
- `Microsoft.Network/virtualNetworks/read`

## 🔍 Permission Validation

### Pre-Deployment Checks

```bash
# Check current user permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --all

# Verify subscription-level access
az deployment sub validate \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters envName=dev location=eastus

# Test resource group creation
az group create --name "test-permissions-rg" --location "eastus"
az group delete --name "test-permissions-rg" --yes --no-wait
```

### Post-Deployment Verification

```bash
# Verify APIM managed identity
az apim show --name "{apimName}" --resource-group "{rgName}" \
  --query "identity.principalId" -o tsv

# Check APIM role assignments
az role assignment list --assignee "{principalId}" --all

# Verify API Center identity
az apic service show --service-name "{apiCenterName}" --resource-group "{rgName}" \
  --query "identity.principalId" -o tsv

# Validate integration between services
az apic api list --service-name "{apiCenterName}" --resource-group "{rgName}"
```

## 🚨 Security Best Practices

### 1. Principle of Least Privilege
- Grant only the minimum permissions required
- Use resource-scoped assignments instead of subscription-wide
- Regularly review and audit role assignments

### 2. Managed Identity Usage
- Always prefer system-assigned over user-assigned when possible
- Avoid storing secrets or connection strings in configuration
- Use managed identity for all service-to-service communication

### 3. Network Security
- Consider private endpoints for production deployments
- Implement VNet integration for internal access only
- Use Application Gateway for public-facing APIs

### 4. Monitoring and Auditing
- Enable diagnostic logging for all resources
- Monitor role assignment changes
- Set up alerts for privilege escalation attempts

## 🔧 Common Permission Issues

### Issue: "Insufficient privileges to complete the operation"
**Cause**: Missing `User Access Administrator` role  
**Solution**: 
```bash
az role assignment create \
  --assignee "{user-or-sp-id}" \
  --role "User Access Administrator" \
  --scope "/subscriptions/{subscription-id}"
```

### Issue: "Cannot assign roles to managed identity"
**Cause**: Managed identity created after RBAC assignment attempt  
**Solution**: Role assignments are created with `dependsOn` clauses to ensure proper ordering

### Issue: "API Center cannot read APIM service"
**Cause**: Missing or incorrect role assignment for API Center identity  
**Solution**: Verify API Center has `API Center Service Reader` role on resource group

### Issue: "APIM cannot write to Log Analytics"
**Cause**: Application Insights logger configuration issue  
**Solution**: Check instrumentation key and workspace linkage:
```bash
az monitor app-insights component show \
  --app "{appInsightsName}" \
  --resource-group "{rgName}" \
  --query "instrumentationKey"
```

## 📋 Permission Checklist

### Pre-Deployment
- [ ] User/SP has `Contributor` at subscription level
- [ ] User/SP has `User Access Administrator` at subscription level
- [ ] Target subscription is selected: `az account show`
- [ ] Required resource providers are registered

### Post-Deployment Validation
- [ ] All resources created successfully
- [ ] Managed identities have system-assigned identities
- [ ] RBAC assignments are in place
- [ ] API Center can discover APIM APIs
- [ ] Diagnostic settings are configured
- [ ] Application Insights is receiving telemetry

### Ongoing Operations
- [ ] Regular access reviews conducted
- [ ] Unused identities and role assignments removed
- [ ] Security monitoring alerts configured
- [ ] Compliance requirements documented and met

## 📚 Related Documentation

- [Azure RBAC Documentation](https://learn.microsoft.com/azure/role-based-access-control/)
- [Managed Identity Documentation](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/)
- [API Management Security](https://learn.microsoft.com/azure/api-management/api-management-security-controls)
- [Settings Schema Reference](settings-schema.md) - Identity configuration options
- [Azure Resources Reference](azure-resources.md) - Complete resource inventory