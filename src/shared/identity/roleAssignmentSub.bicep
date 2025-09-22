import * as Identity from '../customtypes/identity-types.bicep'

targetScope = 'subscription'

@description('Object (principal) ID of the managed identity receiving subscription‑scoped RBAC role assignments.')
param principalId string

@description('Collection of RBAC role references to grant least‑privilege access at subscription scope across resource groups.')
param rbacRoles Identity.RBACRoleAssignment.roles

@description('Iterative deployment of RBAC role assignments at subscription scope binding each specified role to the managed identity.')
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
