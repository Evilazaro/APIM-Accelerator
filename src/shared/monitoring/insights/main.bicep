param name string
param location string
@allowed([
  'web'
  'ios'
  'other'
  'store'
  'java'
  'phone'
])
param kind string = 'web'
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@allowed([
  'ApplicationInsights'
  'ApplicationInsightsWithDiagnosticSettings'
  'LogAnalytics'
])
param ingestionMode string = 'LogAnalytics'

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

param retentionInDays int = 90

param logAnalyticsWorkspaceResourceId string

param tags object

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  kind: kind
  location: location
  tags: tags
  properties: {
    Application_Type: applicationType
    IngestionMode: ingestionMode
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    RetentionInDays: retentionInDays
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

resource appInsightsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${appInsights.name}-diag'
  scope: appInsights
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'allMetrics'
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}
