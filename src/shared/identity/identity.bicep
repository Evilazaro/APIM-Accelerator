import * as Identity from '../customtypes/identity-types.bicep'

@description('Azure region for identity resource deployment, aligned with landing zone regional strategy.')
param location string

@description('Shared identity configuration containing user-assigned managed identities for APIM services.')
param identity Identity.SharedIdentity

@description('Resource tags for governance, cost management, and operational tracking.')
param tags object

@description('Deploys user-assigned managed identities for secure, credential-free access across APIM Landing Zone.')
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

