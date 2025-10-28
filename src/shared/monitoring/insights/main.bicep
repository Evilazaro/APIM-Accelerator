// =================================================================
// APPLICATION INSIGHTS MONITORING
// =================================================================
// This module deploys Application Insights for application performance
// monitoring, distributed tracing, and analytics. It integrates with
// Log Analytics for centralized log management.
//
// File: src/shared/monitoring/insights/main.bicep
// Purpose: Deploys Application Insights with diagnostic settings
// Dependencies: Log Analytics workspace, storage account
// =================================================================

// =================================================================
// CONFIGURATION CONSTANTS
// =================================================================

// Diagnostic settings configuration
var diagnosticSettingsSuffix = '-diag'
var allLogsCategory = 'allLogs'
var allMetricsCategory = 'allMetrics'

// =================================================================
// PARAMETERS
// =================================================================

@description('Name of the Application Insights instance')
param name string

@description('Azure region where Application Insights will be deployed')
param location string

@description('Type of application being monitored - affects default dashboards and alerts')
@allowed([
  'web'
  'ios'
  'other'
  'store'
  'java'
  'phone'
])
param kind string = 'web'

@description('Application type for telemetry categorization')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Data ingestion mode - LogAnalytics recommended for integration with workspace')
@allowed([
  'ApplicationInsights'
  'ApplicationInsightsWithDiagnosticSettings'
  'LogAnalytics'
])
param ingestionMode string = 'LogAnalytics'

@description('Public network access for data ingestion - can be disabled for private deployment')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Public network access for data queries - can be disabled for private deployment')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Data retention period in days (90-730 days supported)')
param retentionInDays int = 90

@description('Resource ID of Log Analytics workspace for data storage')
param logAnalyticsWorkspaceResourceId string

@description('Resource ID of storage account for diagnostic log archival')
param storageAccountResourceId string

@description('Tags to be applied to Application Insights for governance')
param tags object

// =================================================================
// APPLICATION INSIGHTS RESOURCE
// =================================================================

@description('Application Insights component - Provides APM, distributed tracing, and analytics')
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

// =================================================================
// DIAGNOSTIC SETTINGS
// =================================================================

@description('Diagnostic settings for Application Insights - Enables comprehensive logging and monitoring')
resource appInsightsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${appInsights.name}${diagnosticSettingsSuffix}'
  scope: appInsights
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    storageAccountId: storageAccountResourceId
    logs: [
      {
        enabled: true
        categoryGroup: allLogsCategory
      }
    ]
    metrics: [
      {
        enabled: true
        category: allMetricsCategory
      }
    ]
  }
}

// =================================================================
// OUTPUTS
// =================================================================

@description('Resource ID of the deployed Application Insights instance')
output APPLICATION_INSIGHTS_RESOURCE_ID string = appInsights.id

@description('Name of the deployed Application Insights instance')
output APPLICATION_INSIGHTS_NAME string = appInsights.name

@description('Instrumentation key for Application Insights SDK integration')
@secure()
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = appInsights.properties.InstrumentationKey
