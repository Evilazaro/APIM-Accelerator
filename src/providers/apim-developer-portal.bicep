param apiManagementName string
param location string
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: 'apim-dev-portal-identity'
  location: location
  tags: tags
}

output AZURE_MANAGED_IDENTITY_CLIENT_ID string = userAssignedIdentity.properties.clientId
output AZURE_MANAGED_IDENTITY_NAME string = userAssignedIdentity.name

resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: userAssignedIdentity
  name: 'default'
}

output AZURE_CLIENT_SECRET_CLIENT_ID string = clientSecret.properties.clientId

resource apimIdentityProvider 'Microsoft.ApiManagement/service/identityProviders@2024-06-01-preview' = {
  parent: apim
  name: 'aad'
  properties: {
    clientId: userAssignedIdentity.properties.clientId
    type: 'aad'
    authority: 'login.windows.net'
    allowedTenants: [
      'MngEnvMCAP341438.onmicrosoft.com'
    ]
    clientLibrary: 'MSAL-2'
    clientSecret: clientSecret.properties.clientId
  }
}

resource devPortalConfig 'Microsoft.ApiManagement/service/portalconfigs@2024-10-01-preview' = {
  name: 'devPortalConfig'
  parent: apim
  properties: {
    signin: {
      require: true
    }
    signup: {
      termsOfService: {
        requireConsent: true
        text: 'By signing up, you agree to our terms of service.'
      }
    }
    cors: {
      allowedOrigins: [
        '*'
      ]
    }
    enableBasicAuth: false
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
