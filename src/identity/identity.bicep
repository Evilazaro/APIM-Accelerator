import * as Identity from '../shared/identity-types.bicep'
param location string
param applicationGateway Identity.UserAssignedIdentity
param publicNetworkAccess bool
param tags object

resource apimAppGwIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = if (!publicNetworkAccess) {
  name: applicationGateway.name
  location: location
  tags: tags
}

module appGwIdentityRoleAssignment 'roleAssignmentSub.bicep' = [
  for role in applicationGateway.rbacRoleAssignment.roles: if (role.scope == 'Subscription' && (!publicNetworkAccess)) {
    name: 'appGwIdentityRoleAssignment'
    scope: subscription()
    params: {
      principalId: apimAppGwIdentity.properties.principalId
      roleName: 'Contributor'
    }
    dependsOn: [
      apimAppGwIdentity
    ]
  }
]

module appGwIdentityRoleAssignmentRg 'roleAssignmentRg.bicep' = [
  for role in applicationGateway.rbacRoleAssignment.roles: if (role.scope == 'ResourceGroup' && (!publicNetworkAccess)) {
    name: 'appGwIdentityRoleAssignmentRg'
    scope: resourceGroup()
    params: {
      principalId: apimAppGwIdentity.properties.principalId
      roleName: 'Contributor'
    }
    dependsOn: [
      apimAppGwIdentity
    ]
  }
]
