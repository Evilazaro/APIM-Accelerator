param name string
param location string
param tags object

resource apimAppGwIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: name
  location: location
  tags: tags
}
