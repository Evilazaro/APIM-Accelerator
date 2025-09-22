import * as Identity from '../customtypes/identity-types.bicep'

@description('Object (principal) ID of the managed identity receiving resource group–scoped RBAC role assignments.')
param principalId string

@description('Collection of RBAC role references to grant least-privilege access at the resource group scope.')
param rbacRoles Identity.RBACRoleAssignment.roles

@description('Iterative deployment of RBAC role assignments at the resource group scope binding each specified role to the managed identity.')
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
