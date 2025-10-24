param apiManagementName string

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

var roles = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, resourceGroup().name, apim.id, apim.name, role)
    scope: apim
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      principalId: apim.identity.principalId
      principalType: 'ServicePrincipal'
    }
    dependsOn: [
      apim
    ]
  }
]

resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: apim
  name: 'default'
  dependsOn: [
    apim
  ]
}

output AZURE_CLIENT_SECRET_ID string = clientSecret.id
output AZURE_CLIENT_SECRET_NAME string = clientSecret.name
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = clientSecret.properties.principalId
output AZURE_CLIENT_SECRET_CLIENT_ID string = clientSecret.properties.clientId
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = apim.identity.principalId
