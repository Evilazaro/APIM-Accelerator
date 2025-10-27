param name string

param location string
@allowed([
  'Basic'
  'BasicV2'
  'Developer'
  'Isolated'
  'Standard'
  'StandardV2'
  'Premium'
  'Consumption'
])
param skuName string
param skuCapacity int
param publisherEmail string
param publisherName string
param logAnalyticsWorkspaceId string
param ApplicationInsightsResourceId string
param enableSystemAssignedIdentity bool
param enableDeveloperPortal bool
param publicNetworkAccess bool
@allowed([
  'External'
  'Internal'
  'None'
])
param virtualNetworkType string
param subnetResourceId string
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  identity: (enableSystemAssignedIdentity)
    ? {
        type: 'SystemAssigned'
      }
    : null
  tags: tags
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    developerPortalStatus: (enableDeveloperPortal) ? 'Enabled' : 'Disabled'
    publicNetworkAccess: (publicNetworkAccess) ? 'Enabled' : 'Disabled'
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: (virtualNetworkType != 'None' && !empty(subnetResourceId))
      ? {
          subnetResourceId: subnetResourceId
        }
      : null
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${apim.name}-diag'
  scope: apim
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    logs: [
      {
        category: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
  }
}

resource appInsightsDiagnostic 'Microsoft.ApiManagement/service/diagnostics@2024-10-01-preview' = {
  name: 'name'
  parent: apim
  properties: {
    loggerId: logAnalyticsWorkspaceId
  }
}

resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2024-10-01-preview' = {
  name: 'looger'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    resourceId: ApplicationInsightsResourceId
    credentials: {
      instrumentationKey: reference(ApplicationInsightsResourceId, '2020-02-02').properties.InstrumentationKey
    }
  }
}
