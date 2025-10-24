param apiManagementName string
param identityProviderClientId string
@secure()
param clientSecretClientId string

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

resource apimIdentityProvider 'Microsoft.ApiManagement/service/identityProviders@2024-06-01-preview' = {
  parent: apim
  name: 'aad'
  properties: {
    clientId: identityProviderClientId
    type: 'aad'
    authority: 'login.windows.net'
    allowedTenants: [
      'MngEnvMCAP341438.onmicrosoft.com'
    ]
    clientLibrary: 'MSAL-2'
    clientSecret: clientSecretClientId
  }
}

// resource devPortalConfig 'Microsoft.ApiManagement/service/portalconfigs@2024-10-01-preview' = {
//   name: 'devPortalConfig'
//   parent: apim
//   properties: {
//     signin: {
//       require: true
//     }
//     signup: {
//       termsOfService: {
//         requireConsent: true
//         text: 'By signing up, you agree to our terms of service.'
//       }
//     }
//     cors: {
//       allowedOrigins: [
//         '*'
//       ]
//     }
//     enableBasicAuth: false
//   }
//   dependsOn: [
//     apim
//     devPortalSignInSetting
//     devPortalSignUpSetting
//   ]
// }

// resource devPortalSignInSetting 'Microsoft.ApiManagement/service/portalsettings@2024-06-01-preview' = {
//   parent: apim
//   name: 'signin'
//   properties: {
//     enabled: true
//   }
// }

// resource devPortalSignUpSetting 'Microsoft.ApiManagement/service/portalsettings@2024-06-01-preview' = {
//   parent: apim
//   name: 'signup'
//   properties: {
//     enabled: true
//     termsOfService: {
//       enabled: true
//       consentRequired: true
//     }
//   }
// }
