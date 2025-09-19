import * as Identity from '../customtypes/identity-types.bicep'

targetScope = 'subscription'

@description('Object ID of the managed identity principal for subscription-scoped role assignments.')
param principalId string

@description('RBAC roles to assign at subscription scope for cross-resource group APIM operations.')
param rbacRoles Identity.RBACRoleAssignment.roles

@description('Creates subscription-scoped RBAC role assignments for centralized identity management.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [
  for role in rbacRoles: {
    name: guid(tenant().tenantId, subscription().id, principalId, role.roleName)
    scope: subscription()
    properties: {
      description: 'Role assignment for APIM Accelerator. Role: ${role.roleName}'
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.id)
    }
  }
]
