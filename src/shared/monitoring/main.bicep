import { Monitoring } from '../common-types.bicep'
import { generateUniqueSuffix } from '../constants.bicep'

param solutionName string
param location string
param monitoringSettings Monitoring
param tags object

// Optimized: Use centralized unique suffix function
var uniqueSuffix = generateUniqueSuffix(subscription().id, resourceGroup().id, resourceGroup().name, solutionName, location)

// Optimized: Constants for resource naming
var logAnalyticsWorkspaceSuffix = 'law'
var applicationInsightsSuffix = 'ai'

// Optimized: Simplified naming logic using coalesce
var logAnalyticsWorkspaceName = monitoringSettings.logAnalytics.name ?? '${solutionName}-${uniqueSuffix}-${logAnalyticsWorkspaceSuffix}'

module operational 'operational/main.bicep' = {
  name: 'deploy-operational-insights'
  scope: resourceGroup()
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    identityType: monitoringSettings.logAnalytics.identity.type
    userAssignedIdentities: monitoringSettings.logAnalytics.identity.userAssignedIdentities
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
output AZURE_STORAGE_ACCOUNT_ID string = operational.outputs.AZURE_STORAGE_ACCOUNT_ID

// Optimized: Simplified naming logic using coalesce
var appInsightsName = monitoringSettings.applicationInsights.name ?? '${solutionName}-${uniqueSuffix}-${applicationInsightsSuffix}'

module insights 'insights/main.bicep' = {
  name: 'deploy-application-insights'
  scope: resourceGroup()
  params: {
    name: appInsightsName
    location: location
    tags: tags
    logAnalyticsWorkspaceResourceId: operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    storageAccountResourceId: operational.outputs.AZURE_STORAGE_ACCOUNT_ID
  }
}

output APPLICATION_INSIGHTS_RESOURCE_ID string = insights.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
output APPLICATION_INSIGHTS_NAME string = insights.outputs.APPLICATION_INSIGHTS_NAME
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = insights.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
