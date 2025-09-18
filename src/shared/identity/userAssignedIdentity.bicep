import * as Identity from '../customtypes/identity-types.bicep'

param location string
param userAssignedIdentity Identity.UserAssignedIdentity
param tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentity.name
  location: location
  tags: tags
}
