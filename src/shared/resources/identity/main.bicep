param solutionName string
param location string
param tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: '${solutionName}-${uniqueString(subscription().id,resourceGroup().id,resourceGroup().name,solutionName,location)}-mi'
  location: location
  tags: tags
}

var roles = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(
      subscription().id,
      resourceGroup().id,
      resourceGroup().name,
      managedIdentity.id,
      managedIdentity.name,
      role
    )
    scope: resourceGroup()
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      principalId: managedIdentity.properties.principalId
      principalType: 'ServicePrincipal'
    }
    dependsOn: [
      managedIdentity
    ]
  }
]

resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: managedIdentity
  name: 'default'
  dependsOn: [
    managedIdentity
  ]
}

output AZURE_CLIENT_SECRET_ID string = clientSecret.id
output AZURE_CLIENT_SECRET_NAME string = clientSecret.name
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = clientSecret.properties.principalId
output AZURE_CLIENT_SECRET_CLIENT_ID string = clientSecret.properties.clientId
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = managedIdentity.properties.principalId
