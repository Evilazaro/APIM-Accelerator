metadata name = 'API Management'
metadata description = 'This module deploys an API Management resource.'

param name string
param location string
param publisherEmail string
param publisherName string
param appInsightsInstrumentationKey string
param appInsightsResourceId string
param appInsightsConnectionString string
param logAnalyticsWorkspaceId string
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: name
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
    publisherEmail: publisherEmail
    publisherName: publisherName
    developerPortalStatus: 'Enabled'
  }
}

output AZURE_API_MANAGEMENT_ID string = apim.id
output AZURE_API_MANAGEMENT_NAME string = apim.name
output AZURE_API_MANAGEMENT_PRINCIPAL_ID string = apim.identity.principalId

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
    description: 'Application Insights logger using managed identity'
    resourceId: appInsightsResourceId
    isBuffered: true

    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
      connectionString: appInsightsConnectionString
      identityClientId: apim.identity.principalId
    }
  }
}

var monitoringMetricsPublisherRoleDefinitionGuid = '3913510d-42f4-4e42-8a64-420c390055eb'

// We scope the assignment *to the App Insights resource* (least privilege).
resource monitoringMetricsPublisherRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    subscription().id,
    resourceGroup().id,
    resourceGroup().name,
    appInsightsResourceId,
    apim.id,
    monitoringMetricsPublisherRoleDefinitionGuid
  )
  scope: resourceGroup()
  properties: {
    roleDefinitionId: monitoringMetricsPublisherRoleDefinitionGuid
    principalId: apim.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
