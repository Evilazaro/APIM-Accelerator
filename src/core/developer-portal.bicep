// =================================================================
// AZURE API MANAGEMENT DEVELOPER PORTAL CONFIGURATION
// =================================================================
// This module configures the API Management developer portal with:
// - CORS policies for cross-origin requests
// - Azure AD identity provider integration
// - Portal settings for sign-in and sign-up functionality
// - Terms of service configuration
//
// File: src/core/developer-portal.bicep
// Purpose: Configures developer portal authentication and policies
// Dependencies: API Management service (existing resource)
// =================================================================

// =================================================================
// CONFIGURATION CONSTANTS
// =================================================================

// Resource naming constants for consistent deployment
var policyResourceName = 'policy'
var identityProviderName = 'aad'
var identityProviderType = 'aad'
var identityProviderAuthority = 'login.windows.net'
var identityProviderClientLibrary = 'MSAL-2'
var defaultPortalConfigName = 'default'
var signInSettingName = 'signin'
var signUpSettingName = 'signup'

// Azure AD tenant configuration - customize for your environment
var allowedTenants = [
  'MngEnvMCAP341438.onmicrosoft.com'
]

// =================================================================
// PARAMETERS
// =================================================================

@description('Name of the existing API Management service to configure')
param apiManagementName string

@description('Azure AD application client ID for developer portal authentication')
param clientId string

@description('Azure AD application client secret for developer portal authentication')
@secure()
param clientSecret string

// =================================================================
// EXISTING RESOURCES
// =================================================================

@description('Reference to existing API Management service')
resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

// =================================================================
// CORS POLICY CONFIGURATION
// =================================================================

@description('Global CORS policy for API Management - Enables cross-origin requests from developer portal')
resource apimPolicy 'Microsoft.ApiManagement/service/policies@2024-10-01-preview' = {
  parent: apim
  name: policyResourceName
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - Only the <forward-request> policy element can appear within the <backend> section element.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <cors allow-credentials="true" terminate-unmatched-request="false">\r\n      <allowed-origins>\r\n        <origin>${apim.properties.developerPortalUrl}</origin>\r\n      </allowed-origins>\r\n      <allowed-methods preflight-result-max-age="300">\r\n        <method>*</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <header>*</header>\r\n      </allowed-headers>\r\n      <expose-headers>\r\n        <header>*</header>\r\n      </expose-headers>\r\n    </cors>\r\n  </inbound>\r\n  <backend>\r\n    <forward-request />\r\n  </backend>\r\n  <outbound />\r\n</policies>'
    format: 'xml'
  }
}

// =================================================================
// AZURE AD IDENTITY PROVIDER
// =================================================================

@description('Azure AD identity provider configuration - Enables AAD authentication for developer portal users')
resource apimIdentityProvider 'Microsoft.ApiManagement/service/identityProviders@2024-06-01-preview' = {
  parent: apim
  name: identityProviderName
  properties: {
    clientId: clientId
    type: identityProviderType
    authority: identityProviderAuthority
    allowedTenants: allowedTenants
    clientLibrary: identityProviderClientLibrary
    clientSecret: clientSecret
  }
}

// =================================================================
// DEVELOPER PORTAL CONFIGURATION
// =================================================================

@description('Developer portal configuration - Sets CORS origins and portal behavior')
resource devPortalConfig 'Microsoft.ApiManagement/service/portalconfigs@2023-05-01-preview' = {
  name: defaultPortalConfigName
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
}

// =================================================================
// PORTAL AUTHENTICATION SETTINGS
// =================================================================

@description('Developer portal sign-in settings - Enables user authentication')
resource devPortalSignInSetting 'Microsoft.ApiManagement/service/portalsettings@2024-06-01-preview' = {
  parent: apim
  name: signInSettingName
  properties: {
    enabled: true
  }
}

@description('Developer portal sign-up settings - Enables user registration with terms of service')
resource devPortalSignUpSetting 'Microsoft.ApiManagement/service/portalsettings@2024-06-01-preview' = {
  parent: apim
  name: signUpSettingName
  properties: {
    enabled: true
    termsOfService: {
      enabled: true
      consentRequired: true
    }
  }
}
