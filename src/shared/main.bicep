// =================================================================
// SHARED INFRASTRUCTURE ORCHESTRATION
// =================================================================
// This module orchestrates the deployment of shared infrastructure
// components including monitoring, logging, and optional networking.
// These services provide foundational capabilities for the APIM platform.
//
// File: src/shared/main.bicep
// Purpose: Deploys shared infrastructure services
// Dependencies: Monitoring modules, common types
// =================================================================

import { Shared } from 'common-types.bicep'

// =================================================================
// PARAMETERS
// =================================================================

@description('Solution name used for resource naming and identification')
param solutionName string

@description('Azure region where shared resources will be deployed')
param location string

@description('Configuration settings for shared infrastructure components')
param sharedSettings Shared

// =================================================================
// MONITORING INFRASTRUCTURE
// =================================================================

@description('Monitoring infrastructure deployment - Provides Log Analytics, Application Insights, and storage')
module monitoring 'monitoring/main.bicep' = {
  name: 'deploy-monitoring-resources'
  scope: resourceGroup()
  params: {
    location: location
    tags: union(sharedSettings.tags, sharedSettings.monitoring.tags)
    solutionName: solutionName
    monitoringSettings: sharedSettings.monitoring
  }
}

// =================================================================
// OUTPUTS
// =================================================================

@description('Log Analytics workspace resource ID for diagnostic logging')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

@description('Application Insights resource ID for performance monitoring')
output APPLICATION_INSIGHTS_RESOURCE_ID string = monitoring.outputs.APPLICATION_INSIGHTS_RESOURCE_ID

@description('Application Insights instance name')
output APPLICATION_INSIGHTS_NAME string = monitoring.outputs.APPLICATION_INSIGHTS_NAME

@description('Application Insights instrumentation key for SDK integration')
@secure()
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = monitoring.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY

@description('Storage account resource ID for diagnostic log archival')
output AZURE_STORAGE_ACCOUNT_ID string = monitoring.outputs.AZURE_STORAGE_ACCOUNT_ID

// module networking 'networking/main.bicep' = {
//   name: 'deploy-networking-resources'
//   scope: resourceGroup()
//   dependsOn: [
//     monitoring
//   ]
// }
