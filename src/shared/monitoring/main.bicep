import { LogAnalytics, ApplicationInsights } from '../common-types.bicep'

param location string
param logAnalyticsSettings LogAnalytics
param applicationInsightsSettings ApplicationInsights
param tags object

module operational 'operational/main.bicep' = {
  name: 'deploy-operational-insights'
  scope: resourceGroup()
  params: {
    name: logAnalyticsSettings.name
    location: location
    tags: tags
    identityType: logAnalyticsSettings.identity.type
    userAssignedIdentities: logAnalyticsSettings.identity.userAssignedIdentities
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

module insights 'insights/main.bicep' = {
  name: 'deploy-application-insights'
  scope: resourceGroup()
  params: {
    name: applicationInsightsSettings.name
    location: location
    tags: tags
    logAnalyticsWorkspaceResourceId: operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
  }
}
