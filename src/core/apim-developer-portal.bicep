param apiManagementName string
param location string
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

module identity '../shared/resources/identity/main.bicep' = {
  name: 'deploy-identity'
  scope: resourceGroup()
  params: {
    solutionName: apim.name
    location: location
    tags: tags
  }
}

output AZURE_CLIENT_SECRET_ID string = identity.outputs.AZURE_CLIENT_SECRET_ID
output AZURE_CLIENT_SECRET_NAME string = identity.outputs.AZURE_CLIENT_SECRET_NAME
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = identity.outputs.AZURE_CLIENT_SECRET_PRINCIPAL_ID
output AZURE_CLIENT_SECRET_CLIENT_ID string = identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = identity.outputs.AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID

resource apimIdentityProvider 'Microsoft.ApiManagement/service/identityProviders@2024-06-01-preview' = {
  parent: apim
  name: 'aad'
  properties: {
    clientId: identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    type: 'aad'
    authority: 'login.windows.net'
    allowedTenants: [
      'MngEnvMCAP341438.onmicrosoft.com'
    ]
    clientLibrary: 'MSAL-2'
    clientSecret: identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
  }
}

resource devPortalConfig 'Microsoft.ApiManagement/service/portalconfigs@2023-05-01-preview' = {
  name: 'default'
  parent: apim
  properties: {
    cors: {
      allowedOrigins: [
        '${apim.properties.developerPortalUrl}'
        '${apim.properties.gatewayUrl}'
        '${apim.properties.managementApiUrl}'
      ]
    }
  }
  dependsOn: [
    apim
    devPortalSignInSetting
    devPortalSignUpSetting
  ]
}

resource devPortalSignInSetting 'Microsoft.ApiManagement/service/portalsettings@2024-06-01-preview' = {
  parent: apim
  name: 'signin'
  properties: {
    enabled: true
  }
}

resource devPortalSignUpSetting 'Microsoft.ApiManagement/service/portalsettings@2024-06-01-preview' = {
  parent: apim
  name: 'signup'
  properties: {
    enabled: true
    termsOfService: {
      enabled: true
      consentRequired: true
    }
  }
}

