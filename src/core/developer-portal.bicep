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
//
// OVERVIEW:
// This Bicep module deploys and configures the Azure API Management
// developer portal to enable secure authentication and cross-origin
// resource sharing. It integrates Azure Active Directory as the
// identity provider, allowing tenant-specific user authentication.
//
// PREREQUISITES:
// - Existing Azure API Management service instance
// - Azure AD application registration with client ID and secret
// - Appropriate permissions to configure APIM resources
//
// USAGE:
// Deploy this module by referencing it from a parent Bicep file:
//   module devPortal 'developer-portal.bicep' = {
//     name: 'devPortalDeployment'
//     params: {
//       apiManagementName: 'your-apim-instance'
//       clientId: 'your-aad-client-id'
//       clientSecret: 'your-aad-client-secret'
//     }
//   }
//
// CONFIGURATION:
// - Update 'allowedTenants' array with your Azure AD tenant domains
// - Ensure AAD app registration has redirect URIs configured
// - Review CORS settings for your specific security requirements
// =================================================================

// =================================================================
// CONFIGURATION CONSTANTS
// =================================================================

// Resource naming constants for consistent deployment
// These follow Azure APIM naming conventions for child resources
var policyResourceName = 'policy' // Global policy identifier
var identityProviderName = 'aad' // Azure AD provider name
var identityProviderType = 'aad' // Identity provider type (Azure Active Directory)
var identityProviderAuthority = 'login.windows.net' // Azure AD authentication endpoint
var identityProviderClientLibrary = 'MSAL-2' // Microsoft Authentication Library version 2
var defaultPortalConfigName = 'default' // Default portal configuration name
var signInSettingName = 'signin' // Sign-in portal setting identifier
var signUpSettingName = 'signup' // Sign-up portal setting identifier

// Azure AD tenant configuration - customize for your environment
// Add your organization's tenant domain(s) to restrict access
// Format: 'tenantname.onmicrosoft.com' or custom domain
var allowedTenants = [
  'MngEnvMCAP341438.onmicrosoft.com'
]

// =================================================================
// PARAMETERS
@minLength(1)
@maxLength(50)
param apiManagementName string

@description('Azure AD application client ID for developer portal authentication. Obtain from Azure AD app registration.')
@minLength(36)
@maxLength(36)
param clientId string

@description('Azure AD application client secret for developer portal authentication. Obtain from Azure AD app registration certificates & secrets.')
@secure()
param clientSecret string

// =================================================================
// EXISTING RESOURCES
// =================================================================

// Configures Cross-Origin Resource Sharing (CORS) at the global level
// to allow the developer portal to make API calls to the APIM gateway.
// 
// SECURITY NOTE:
// - Credentials are allowed for authenticated requests
// - All HTTP methods, headers, and exposed headers are permitted
// - Preflight cache is set to 300 seconds for performance
// - Only the developer portal URL is whitelisted as an origin
// =================================================================
@description('Reference to existing API Management service')
resource apim 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementName
}

// Configures Azure Active Directory as an identity provider for the
// developer portal, enabling users to sign in with their Azure AD
// organizational accounts.
//
// CONFIGURATION DETAILS:
// - Uses MSAL 2.0 for modern authentication flows
// - Restricts access to specified tenant domains
// - Requires AAD app registration with appropriate redirect URIs
// - Client secret is securely passed as a parameter
// =================================================================
// =================================================================
// CORS POLICY CONFIGURATION
// =================================================================

@description('Global CORS policy for API Management - Enables cross-origin requests from developer portal')
resource apimPolicy 'Microsoft.ApiManagement/service/policies@2025-03-01-preview' = {
  parent: apim
  name: policyResourceName
  // Configures the developer portal's CORS settings to allow requests
  // from the portal itself, the APIM gateway, and the management API.
  // This ensures proper communication between portal components.
  //
  // ALLOWED ORIGINS:
  // - Developer Portal URL: For portal self-hosted scenarios
  // - Gateway URL: For API testing and interactive console
  // - Management API URL: For portal administrative operations
  // =================================================================
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - Only the <forward-request> policy element can appear within the <backend> section element.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <cors allow-credentials="true" terminate-unmatched-request="false">\r\n      <allowed-origins>\r\n        <origin>${apim.properties.developerPortalUrl}</origin>\r\n      </allowed-origins>\r\n      <allowed-methods preflight-result-max-age="300">\r\n        <method>*</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <header>*</header>\r\n      </allowed-headers>\r\n      <expose-headers>\r\n        <header>*</header>\r\n      </expose-headers>\r\n    </cors>\r\n  </inbound>\r\n  <backend>\r\n    <forward-request />\r\n  </backend>\r\n  <outbound />\r\n</policies>'
    format: 'xml'
  }
}

// =================================================================
// AZURE AD IDENTITY PROVIDER
// =================================================================

@description('Azure AD identity provider configuration - Enables AAD authentication for developer portal users')
resource apimIdentityProvider 'Microsoft.ApiManagement/service/identityProviders@2025-03-01-preview' = {
  parent: apim
  // Configures sign-in and sign-up settings for the developer portal.
  // These settings control user registration and authentication flows.
  //
  // SIGN-IN: Enables user authentication via configured identity providers
  // SIGN-UP: Allows new user registration with mandatory terms acceptance
  // =================================================================
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
resource devPortalConfig 'Microsoft.ApiManagement/service/portalconfigs@2025-03-01-preview' = {
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
resource devPortalSignInSetting 'Microsoft.ApiManagement/service/portalsettings@2025-03-01-preview' = {
  parent: apim
  name: signInSettingName
  properties: {
    enabled: true
  }
}

@description('Developer portal sign-up settings - Enables user registration with terms of service')
resource devPortalSignUpSetting 'Microsoft.ApiManagement/service/portalsettings@2025-03-01-preview' = {
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
