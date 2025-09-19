import * as Identity from '../customtypes/identity-types.bicep'

@description('Object ID of the managed identity principal for resource group-scoped role assignments.')
param principalId string

@description('RBAC roles to assign at resource group scope for least-privilege access and workload isolation.')
param rbacRoles Identity.RBACRoleAssignment.roles

@description('Creates resource group-scoped RBAC role assignments for fine-grained access control.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [
  for role in rbacRoles: {
    name: guid(tenant().tenantId, subscription().id, resourceGroup().id, principalId, role.roleName)
    scope: resourceGroup()
    properties: {
      description: 'Role assignment for APIM Accelerator. Role: ${role.roleName}'
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.id)
    }
  }
]
