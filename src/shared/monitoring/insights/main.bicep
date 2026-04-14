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
//
// OVERVIEW:
// Application Insights provides real-time monitoring, performance
// tracking, and diagnostics for applications. This module configures:
// - Application Insights resource with customizable settings
// - Integration with Log Analytics workspace
// - Diagnostic settings for comprehensive telemetry capture
// - Configurable retention, access controls, and ingestion modes
//
// USAGE EXAMPLE:
// module appInsights 'main.bicep' = {
//   name: 'appInsightsDeployment'
//   params: {
//     name: 'myapp-insights'
//     location: 'eastus'
//     kind: 'web'
//     applicationType: 'web'
//     retentionInDays: 90
//     logAnalyticsWorkspaceResourceId: logAnalytics.id
//     storageAccountResourceId: storage.id
//     tags: { environment: 'production' }
//   }
// }
//
// SECURITY CONSIDERATIONS:
// - Use privateNetworkAccessForIngestion/Query: 'Disabled' for secure environments
// - Instrumentation key is marked as @secure() output
// - Diagnostic logs stored in both workspace and storage account
// =================================================================

// =================================================================
// CONFIGURATION CONSTANTS
// =================================================================
// Constants used throughout the module for consistent naming and
// configuration of diagnostic settings and log categories.
// =================================================================

// Diagnostic settings configuration
// Suffix appended to diagnostic setting names for identification
var diagnosticSettingsSuffix = '-diag'

// Category group that captures all available log types
var allLogsCategory = 'allLogs'

// Category that captures all available metrics
var allMetricsCategory = 'allMetrics'

// =================================================================
// PARAMETERS
// =================================================================

@description('Name of the Application Insights instance')
@minLength(1)
@maxLength(260)
param name string

@description('Azure region where Application Insights will be deployed')
param location string

@description('''
Type of application being monitored - affects default dashboards and alerts
- web: Web applications and services
- ios: iOS mobile applications
- other: General purpose applications
- store: Windows Store applications
- java: Java applications
- phone: Phone applications
''')
@allowed([
  'web'
  'ios'
  'other'
  'store'
  'java'
  'phone'
])
param kind string = 'web'

@description('''
Application type for telemetry categorization
- web: Web applications (default)
- other: Non-web applications
''')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('''
Data ingestion mode - determines where telemetry data is stored
- ApplicationInsights: Classic mode (deprecated)
- ApplicationInsightsWithDiagnosticSettings: Hybrid mode
- LogAnalytics: Workspace-based mode (recommended for cost optimization and query integration)
''')
@allowed([
  'ApplicationInsights'
  'ApplicationInsightsWithDiagnosticSettings'
  'LogAnalytics'
])
param ingestionMode string = 'LogAnalytics'

@description('''
Public network access for data ingestion
- Enabled: Allow data ingestion from public internet
- Disabled: Restrict ingestion to private endpoints only (requires Private Link)
''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('''
Public network access for data queries
- Enabled: Allow queries from public internet
- Disabled: Restrict queries to private endpoints only (requires Private Link)
''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('''
Data retention period in days
Valid range: 90-730 days
Note: Retention beyond 90 days may incur additional costs
''')
@minValue(90)
@maxValue(730)
param retentionInDays int = 90

@description('''
Resource ID of Log Analytics workspace for data storage
Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}
Required for LogAnalytics ingestion mode
''')
param logAnalyticsWorkspaceResourceId string

@description('''
Resource ID of storage account for diagnostic log archival
Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}
Used for long-term retention and compliance requirements
''')
param storageAccountResourceId string

@description('''
Tags to be applied to Application Insights for governance
Recommended tags: environment, application, costCenter, owner
Example: { environment: 'production', application: 'api', costCenter: '12345' }
''')
param tags object

// =================================================================
// APPLICATION INSIGHTS RESOURCE
// =================================================================
// Deploys the core Application Insights component with specified
// configuration for monitoring, telemetry collection, and integration
// with Log Analytics workspace.
// =================================================================

@description('''
Application Insights component - Provides APM, distributed tracing, and analytics
API Version: 2020-02-02
Resource Type: Microsoft.Insights/components
''')
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
// Configures diagnostic settings to capture all logs and metrics from
// Application Insights and route them to Log Analytics workspace and
// storage account for centralized monitoring and compliance.
// =================================================================

@description('''
Diagnostic settings for Application Insights - Enables comprehensive logging and monitoring
API Version: 2021-05-01-preview
Captures: All logs and metrics
Destinations: Log Analytics workspace and storage account
''')
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
// Outputs provide essential information for integrating with the
// deployed Application Insights instance, including resource IDs,
// names, and secure instrumentation key.
// =================================================================

@description('''
Resource ID of the deployed Application Insights instance
Usage: Reference this in other modules for resource dependencies
Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Insights/components/{name}
''')
output APPLICATION_INSIGHTS_RESOURCE_ID string = appInsights.id

@description('''
Name of the deployed Application Insights instance
Usage: Reference for naming conventions and resource lookups
''')
output APPLICATION_INSIGHTS_NAME string = appInsights.name

@description('''
Instrumentation key for Application Insights SDK integration
Usage: Configure application SDKs to send telemetry to this instance
Security: Marked as @secure() to prevent logging in deployment outputs
Note: Consider using connection string for newer SDK versions
''')
@secure()
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = appInsights.properties.InstrumentationKey
