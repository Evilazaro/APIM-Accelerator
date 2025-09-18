import * as Identity from '../identity-types.bicep'

param principalId string
param roles Identity.RBACRoleAssignment.roles

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, principalId, role.roleName)
    scope: resourceGroup()
    properties: {
      description: 'Role assignment for APIM Accelerator. Role: ${role.roleName}'
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.id)
    }
  }
]
