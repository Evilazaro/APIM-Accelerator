import * as Identity from '../customtypes/identity-types.bicep'

param location string
param userAssignedIdentity Identity.UserAssignedIdentity
param tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentity.name
  location: location
  tags: tags
}

module roleAssignmentsSub 'roleAssignmentSub.bicep' = if (userAssignedIdentity.scope.type == 'subscription') {
  name: 'roleAssignmentsSub-${userAssignedIdentity.name}'
  scope: subscription()
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}

module roleAssignmentsRg 'roleAssignmentRg.bicep' = if (userAssignedIdentity.scope.type == 'resourceGroup') {
  name: 'roleAssignmentsRg-${userAssignedIdentity.name}'
  scope: resourceGroup(userAssignedIdentity.scope.name)
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}
