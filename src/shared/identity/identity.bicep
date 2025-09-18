import * as Identity from '../customtypes/identity-types.bicep'

param location string
param identity Identity.SharedIdentity
param tags object

module userAssignedIdentities 'userAssignedIdentity.bicep' = [
  for userAssigned in identity.usersAssigned: {
    name: 'userAssignedIdentities-${userAssigned.name}'
    scope: resourceGroup()
    params: {
      location: location
      tags: tags
      userAssignedIdentity: userAssigned
    }
  }
]
