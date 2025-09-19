import * as Identity from '../customtypes/identity-types.bicep'

targetScope = 'subscription'

@description('The unique identifier (Object ID) of the managed identity principal that will receive the role assignments. This enables the identity to authenticate and access Azure resources at the subscription level within the landing zone hierarchy.')
param principalId string

@description('Array of RBAC roles to be assigned to the managed identity at subscription scope. These roles define the permissions and access levels required for Azure API Management operations across the entire subscription, supporting centralized governance and cross-resource group scenarios.')
param rbacRoles Identity.RBACRoleAssignment.roles

@description('Creates RBAC role assignments at subscription scope for the managed identity. These assignments grant necessary permissions for Azure API Management operations across the subscription, enabling centralized identity management and supporting landing zone governance principles with least-privilege access control.')
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
