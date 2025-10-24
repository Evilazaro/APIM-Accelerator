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

