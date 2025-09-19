import * as Identity from '../customtypes/identity-types.bicep'

@description('Azure region for user-assigned managed identity deployment.')
param location string

@description('User-assigned managed identity configuration including name, scope, and RBAC assignments.')
param userAssignedIdentity Identity.UserAssignedIdentity

@description('Resource tags for governance, cost management, and operational tracking.')
param tags object

@description('Creates a user-assigned managed identity for secure, credential-free service authentication.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentity.name
  location: location
  tags: tags
}

@description('Assigns subscription-scoped RBAC roles for cross-resource group operations.')
module roleAssignmentsSub 'roleAssignmentSub.bicep' = if (userAssignedIdentity.scope.type == 'subscription') {
  name: 'roleAssignmentsSub-${userAssignedIdentity.name}'
  scope: subscription()
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}

@description('Assigns resource group-scoped RBAC roles for workload isolation and least-privilege access.')
module roleAssignmentsRg 'roleAssignmentRg.bicep' = if (userAssignedIdentity.scope.type == 'resourceGroup') {
  name: 'roleAssignmentsRg-${userAssignedIdentity.name}'
  scope: resourceGroup(userAssignedIdentity.scope.name)
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}
