/*
==============================================================================
SHARED MONITORING INFRASTRUCTURE MODULE
==============================================================================

File: src/shared/monitoring/main.bicep
Purpose: Deploys centralized monitoring and observability infrastructure
Author: Cloud Platform Team
Created: 2025-10-28

Description:
  This module serves as the main entry point for deploying a comprehensive
  monitoring solution for Azure API Management (APIM) accelerator. It 
  orchestrates the deployment of critical observability components:
  
  - Log Analytics workspace for centralized logging and query analysis
  - Application Insights for application performance monitoring (APM)
  - Storage account for long-term diagnostic log retention and compliance
  - Diagnostic settings for comprehensive observability across resources

Architecture:
  The module follows a layered deployment pattern:
  1. Operational Layer: Deploys Log Analytics and diagnostic storage
  2. Insights Layer: Deploys Application Insights linked to operational resources
  
  This ensures dependencies are resolved correctly and resources are 
  provisioned in the proper sequence.

Usage:
  module monitoring 'src/shared/monitoring/main.bicep' = {
    name: 'deploy-monitoring'
    params: {
      solutionName: 'apim-solution'
      location: 'eastus'
      monitoringSettings: {
        logAnalytics: {
          name: 'custom-law-name'  // Optional
          identity: {
            type: 'SystemAssigned'
            userAssignedIdentities: {}
          }
        }
        applicationInsights: {
          name: 'custom-ai-name'    // Optional
        }
      }
      tags: {
        environment: 'production'
        costCenter: '12345'
      }
    }
  }

Parameters:
  - solutionName: Base name for all resources (used in naming convention)
  - location: Azure region for resource deployment
  - monitoringSettings: Monitoring configuration object (see Monitoring type)
  - tags: Resource tags for governance and cost tracking

Outputs:
  - AZURE_LOG_ANALYTICS_WORKSPACE_ID: Log Analytics workspace resource ID
  - AZURE_STORAGE_ACCOUNT_ID: Diagnostic storage account resource ID
  - APPLICATION_INSIGHTS_RESOURCE_ID: Application Insights resource ID
  - APPLICATION_INSIGHTS_NAME: Application Insights name
  - APPLICATION_INSIGHTS_INSTRUMENTATION_KEY: Instrumentation key (secure)

Dependencies:
  - ../common-types.bicep: Type definitions for monitoring configuration
  - ../constants.bicep: Shared constants and utility functions
  - operational/main.bicep: Operational monitoring resources
  - insights/main.bicep: Application Insights resources

Notes:
  - Resource names can be explicitly provided or auto-generated
  - Auto-generated names include unique suffix for collision prevention
  - Diagnostic storage is automatically configured for log retention
  - All resources inherit tags from parent configuration

==============================================================================
*/

import { Monitoring } from '../common-types.bicep'
import { generateUniqueSuffix } from '../constants.bicep'

//==============================================================================
// PARAMETERS
//==============================================================================

@description('Solution name used as prefix for all monitoring resources')
param solutionName string

@description('Azure region where monitoring resources will be deployed')
param location string

@description('Monitoring configuration object containing Log Analytics and Application Insights settings')
param monitoringSettings Monitoring

@description('Tags to be applied to all monitoring resources for governance and cost tracking')
param tags object

//==============================================================================
// VARIABLES AND CONFIGURATION
//==============================================================================

@description('Unique suffix for resource naming consistency across deployments')
var uniqueSuffix = generateUniqueSuffix(
  subscription().id,
  resourceGroup().id,
  resourceGroup().name,
  solutionName,
  location
)

// Resource naming suffixes following organizational standards
@description('Standard suffix for Log Analytics workspace naming')
var logAnalyticsWorkspaceSuffix = 'law'

@description('Standard suffix for Application Insights instance naming')
var applicationInsightsSuffix = 'ai'

// Resource naming logic with fallback to generated names
@description('Log Analytics workspace name with fallback to generated name if not specified in configuration')
var logAnalyticsWorkspaceName = (!empty(monitoringSettings.logAnalytics.name)
  ? monitoringSettings.logAnalytics.name
  : '${solutionName}-${uniqueSuffix}-${logAnalyticsWorkspaceSuffix}')

//==============================================================================
// OPERATIONAL MONITORING DEPLOYMENT
//==============================================================================
// Deploys Log Analytics workspace and diagnostic storage account
// This is the foundation for all monitoring and must be deployed first

@description('Log Analytics workspace and diagnostic storage for centralized logging and monitoring')
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

//==============================================================================
// OPERATIONAL MONITORING OUTPUTS
//==============================================================================

@description('Resource ID of Log Analytics workspace for use by dependent resources')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

@description('Resource ID of diagnostic storage account for log archival and compliance')
output AZURE_STORAGE_ACCOUNT_ID string = operational.outputs.AZURE_STORAGE_ACCOUNT_ID

//==============================================================================
// APPLICATION INSIGHTS DEPLOYMENT
//==============================================================================

@description('Application Insights instance name with fallback to generated name if not specified')
var appInsightsName = (!empty(monitoringSettings.applicationInsights.name)
  ? monitoringSettings.applicationInsights.name
  : '${solutionName}-${uniqueSuffix}-${applicationInsightsSuffix}')

@description('Application Insights instance for application performance monitoring and telemetry')
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

//==============================================================================
// MODULE OUTPUTS
//==============================================================================

@description('Resource ID of Application Insights instance for application monitoring integration')
output APPLICATION_INSIGHTS_RESOURCE_ID string = insights.outputs.APPLICATION_INSIGHTS_RESOURCE_ID

@description('Name of Application Insights instance for configuration and reference')
output APPLICATION_INSIGHTS_NAME string = insights.outputs.APPLICATION_INSIGHTS_NAME

@description('Application Insights instrumentation key for SDK configuration (sensitive data)')
@secure()
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = insights.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
