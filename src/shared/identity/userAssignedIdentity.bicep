import * as Identity from '../customtypes/identity-types.bicep'

@description('Azure region where the user-assigned managed identity resource will be created.')
param location string

@description('Strongly-typed user-assigned identity settings (name, deployment scope, RBAC role assignments).')
param userAssignedIdentity Identity.UserAssignedIdentity

@description('Standard resource tags applied for governance, cost management, and operational tracking.')
param tags object

@description('User-assigned managed identity resource enabling workload components to authenticate via Entra ID without embedded credentials.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentity.name
  location: location
  tags: tags
}

@description('Conditional module deploying subscription-scoped RBAC role assignments for the identity (used for cross–resource group operations or deployment scripts).')
module roleAssignmentsSub 'roleAssignmentSub.bicep' = if (userAssignedIdentity.scope.type == 'subscription' || userAssignedIdentity.scope.type == 'deploymentScript') {
  name: 'roleAssignmentsSub-${userAssignedIdentity.name}'
  scope: subscription()
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}

@description('Conditional module deploying resource group–scoped RBAC role assignments to enforce least-privilege access.')
module roleAssignmentsRg 'roleAssignmentRg.bicep' = if (userAssignedIdentity.scope.type == 'resourceGroup') {
  name: 'roleAssignmentsRg-${userAssignedIdentity.name}'
  scope: resourceGroup(userAssignedIdentity.scope.name)
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}
