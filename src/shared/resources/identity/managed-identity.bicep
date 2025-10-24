param name string
param location string
param tags object

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: name
  location: location
  tags: tags
}

output AZURE_MANAGED_IDENTITY_ID string = userAssignedIdentity.id
output AZURE_MANAGED_IDENTITY_NAME string = userAssignedIdentity.name
output AZURE_MANAGED_IDENTITY_PRINCIPAL_ID string = userAssignedIdentity.properties.principalId
output AZURE_MANAGED_IDENTITY_CLIENT_ID string = userAssignedIdentity.properties.clientId

var roles = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, resourceGroup().name, userAssignedIdentity.id, role)
    scope: resourceGroup()
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      principalId: userAssignedIdentity.properties.principalId
      principalType: 'ServicePrincipal'
    }
    dependsOn: [
      userAssignedIdentity
    ]
  }
]

resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: userAssignedIdentity
  name: 'default'
dependsOn: [
    userAssignedIdentity
  ]
}

output AZURE_CLIENT_SECRET_ID string = clientSecret.id
output AZURE_CLIENT_SECRET_NAME string = clientSecret.name
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = clientSecret.properties.principalId
output AZURE_CLIENT_SECRET_CLIENT_ID string = clientSecret.properties.clientId
