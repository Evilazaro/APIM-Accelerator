@description('Application Insights resource name')
@maxLength(60)
param name string

@description('Application Insights resource type')
param type string

@description('Location for all resources.')
param location string

@description('Request source for the Application Insights resource')
param requestSource string

@description('Enable diagnostics for the Application Insights resource')
param enableDiagnostics bool

@description('Log Analytics Workspace ID for diagnostics (optional)')
param logAnalyticsWorkspaceId string

@description('Storage Account ID for diagnostics (optional)')
param diagnosticStorageAccountId string

param tags object

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'other'
  properties: {
    Application_Type: type
    Request_Source: requestSource
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

@description('Diagnostics settings for the Application Insights resource')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: appInsights
  name: '${name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
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
      }
    ]
  }
  dependsOn: [
    appInsights
  ]
}
