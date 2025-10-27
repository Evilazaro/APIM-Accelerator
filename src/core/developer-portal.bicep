param apiManagementName string
param clientId string
@secure()
param clientSecret string
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

resource apimPolicy 'Microsoft.ApiManagement/service/policies@2024-10-01-preview' = {
  parent: apim
  name: 'policy'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - Only the <forward-request> policy element can appear within the <backend> section element.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <cors allow-credentials="true" terminate-unmatched-request="false">\r\n      <allowed-origins>\r\n        <origin>${apim.properties.developerPortalUrl}</origin>\r\n      </allowed-origins>\r\n      <allowed-methods preflight-result-max-age="300">\r\n        <method>*</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <header>*</header>\r\n      </allowed-headers>\r\n      <expose-headers>\r\n        <header>*</header>\r\n      </expose-headers>\r\n    </cors>\r\n  </inbound>\r\n  <backend>\r\n    <forward-request />\r\n  </backend>\r\n  <outbound />\r\n</policies>'
    format: 'xml'
  }
}

resource apimIdentityProvider 'Microsoft.ApiManagement/service/identityProviders@2024-06-01-preview' = {
  parent: apim
  name: 'aad'
  properties: {
    clientId: clientId
    type: 'aad'
    authority: 'login.windows.net'
    allowedTenants: [
      'MngEnvMCAP341438.onmicrosoft.com'
    ]
    clientLibrary: 'MSAL-2'
    clientSecret: clientSecret
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
