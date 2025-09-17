import * as Identity from '../shared/identity-types.bicep'

param location string
param identity Identity.IdentitySettings
param tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = [
  for identity in identity.userAssignedIdentities: {
    name: identity.name
    location: location
    tags: tags
  }
]

module roleAssignmentsSub 'roleAssignmentSub.bicep' = [
  for (identity, index) in identity.userAssignedIdentities: if (identity.scope.type == 'subscription') {
    name: 'roleAssignment-${identity.name}'
    scope: subscription()
    params: {
      principalId: managedIdentity[index].properties.principalId
      roles: identity.rbacRoleAssignment.roles
    }
    dependsOn: [
      managedIdentity
    ]
  }
]

module roleAssignmentsRg 'roleAssignmentRg.bicep' = [
  for (identity, index) in identity.userAssignedIdentities: if (identity.scope.type == 'resourceGroup') {
    name: 'roleAssignment-${identity.name}'
    scope: resourceGroup(identity.scope.name)
    params: {
      principalId: managedIdentity[index].properties.principalId
      roles: identity.rbacRoleAssignment.roles
    }
    dependsOn: [
      managedIdentity
    ]
  }
]
