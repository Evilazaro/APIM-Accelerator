import * as Identity from '../customtypes/identity-types.bicep'

@description('Azure region for deploying managed identity resources, aligned to Landing Zone regional strategy.')
param location string

@description('Shared identity settings object containing reusable user-assigned managed identities for APIM and related services.')
param identity Identity.SharedIdentity

@description('Standard resource tags applied for governance, cost management, and operational tracking.')
param tags object

@description('Looped module deployment creating user-assigned managed identities enabling credential-free access for APIM components.')
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

