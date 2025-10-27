metadata name = 'Application Insights'
metadata description = 'This module deploys an Application Insights resource with comprehensive diagnostic settings following Azure monitoring best practices.'

param name string
param location string
param workspaceResourceId string
param tags object

param storageAccountId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceResourceId
    Flow_Type: 'Redfield'
    Request_Source: 'rest'
    RetentionInDays: 90
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableIpMasking: false
    DisableLocalAuth: false
  }
}

// Diagnostic settings for Application Insights
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}-diag'
  scope: appInsights
  properties: {
    workspaceId: workspaceResourceId
    storageAccountId: storageAccountId

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

// Outputs
output AZURE_APPLICATION_INSIGHTS_ID string = appInsights.id
output AZURE_APPLICATION_INSIGHTS_NAME string = appInsights.name
output AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = appInsights.properties.InstrumentationKey
output AZURE_APPLICATION_INSIGHTS_CONNECTION_STRING string = appInsights.properties.ConnectionString
