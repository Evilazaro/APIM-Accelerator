metadata name = 'Workload API Management Platform'
metadata description = 'This module deploys the Workload API Management platform.'

param solutionName string
param location string
param appInsightsResourceId string
param appInsightsInstrumentationKey string
param logAnalyticsWorkspaceId string
param tags object

var workloadSettings = loadYamlContent('../../infra/workload.yaml')

var apimName = (empty(workloadSettings.apiManagement.name))
  ? '${solutionName}-${uniqueString(subscription().id, resourceGroup().id, resourceGroup().name, solutionName,location)}-apim'
  : workloadSettings.apiManagement.name

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: apimName
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    publisherEmail: workloadSettings.apiManagement.publisherEmail
    publisherName: workloadSettings.apiManagement.publisherName
    developerPortalStatus: 'Enabled'
  }
}

output AZURE_API_MANAGEMENT_ID string = apim.id
output AZURE_API_MANAGEMENT_NAME string = apim.name

resource apimPolicy 'Microsoft.ApiManagement/service/policies@2024-10-01-preview' = {
  parent: apim
  name: 'policy'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - Only the <forward-request> policy element can appear within the <backend> section element.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <cors allow-credentials="true" terminate-unmatched-request="false">\r\n      <allowed-origins>\r\n        <origin>https://attg-uepnkfteneluw-apim.developer.azure-api.net</origin>\r\n      </allowed-origins>\r\n      <allowed-methods preflight-result-max-age="300">\r\n        <method>*</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <header>*</header>\r\n      </allowed-headers>\r\n      <expose-headers>\r\n        <header>*</header>\r\n      </expose-headers>\r\n    </cors>\r\n  </inbound>\r\n  <backend>\r\n    <forward-request />\r\n  </backend>\r\n  <outbound />\r\n</policies>'
    format: 'xml'
  }
}

module developerPortal 'apim-developer-portal.bicep' = {
  name: 'deploy-apim-developer-portal'
  scope: resourceGroup()
  params: {
    location: location
    apiManagementName: apim.name
    tags: tags
  }
}

output AZURE_CLIENT_SECRET_ID string = developerPortal.outputs.AZURE_CLIENT_SECRET_ID
output AZURE_CLIENT_SECRET_NAME string = developerPortal.outputs.AZURE_CLIENT_SECRET_NAME
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = developerPortal.outputs.AZURE_CLIENT_SECRET_PRINCIPAL_ID
output AZURE_CLIENT_SECRET_CLIENT_ID string = developerPortal.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = developerPortal.outputs.AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID
output AZURE_API_MANAGEMENT_DEVELOPER_PORTAL_URL string = apim.properties.developerPortalUrl
output AZURE_API_MANAGEMENT_GATEWAY_URL string = apim.properties.gatewayUrl
output AZURE_API_MANAGEMENT_MANAGEMENT_API_URL string = apim.properties.managementApiUrl

resource apimDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${apim.name}-diag'
  scope: apim
  properties: {
    workspaceId: logAnalyticsWorkspaceId

    logAnalyticsDestinationType: 'Dedicated'

    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]

    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        timeGrain: null
      }
    ]
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
  name: '${apim.name}-logger'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    description: 'Application Insights logger'
    resourceId: appInsightsResourceId
    isBuffered: true

    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}
