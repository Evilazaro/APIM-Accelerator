import * as Identity from '../shared/identity-types.bicep'
param location string
param identity Identity.Identity
param tags object

module userAssignedIdentity 'userAssignedIdentity.bicep' = if (identity.type == 'UserAssigned') {
  name: 'userAssignedIdentity'
  params: {
    location: location
    userAssignmentIdentities: identity.userAssignedIdentities
    tags: tags
  }
}
