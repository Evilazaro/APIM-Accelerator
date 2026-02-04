/*
╔════════════════════════════════════════════════════════════════════════════╗
║                   APIM LANDING ZONE ORCHESTRATION TEMPLATE                  ║
╚════════════════════════════════════════════════════════════════════════════╝

PURPOSE:
  This is the main orchestration template for deploying a complete API Management
  landing zone on Azure. It coordinates the deployment of monitoring infrastructure,
  core API Management services, and API inventory management capabilities.

DEPLOYMENT SCOPE:
  Subscription level - creates resource groups and deploys child modules

KEY COMPONENTS:
  1. Shared Infrastructure - Monitoring foundation (Log Analytics, App Insights)
  2. Core Platform - API Management service with premium features
  3. API Inventory - API Center for governance and documentation

DEPENDENCIES:
  - settings.yaml: Environment-specific configuration file
  - ../src/shared/main.bicep: Shared monitoring infrastructure module
  - ../src/core/main.bicep: Core APIM platform module
  - ../src/inventory/main.bicep: API Center inventory module

DEPLOYMENT SEQUENCE:
  1. Resource group creation
  2. Shared monitoring infrastructure (required first)
  3. Core APIM platform (depends on monitoring)
  4. API inventory management (depends on APIM)

USAGE:
  az deployment sub create \
    --location <region> \
    --template-file infra/main.bicep \
    --parameters envName=<dev|test|staging|prod|uat> location=<azure-region>

OUTPUTS:
  - Application Insights details for monitoring integration
  - Storage account ID for diagnostic logs
  - Additional outputs from core and inventory modules

AUTHOR: Cloud Platform Team
VERSION: 2.0.0
LAST UPDATED: 2025-10-28
*/

metadata templateInfo = {
  name: 'APIM Landing Zone Main Orchestration Template'
  description: 'Deploys complete APIM landing zone with monitoring, core services, and inventory management'
  author: 'Cloud Platform Team'
  version: '2.0.0'
  lastUpdated: '2025-10-28'
}

targetScope = 'subscription'

//==============================================================================
// PARAMETERS
//==============================================================================

@description('Environment name (dev, test, staging, prod, uat) - determines resource sizing and configuration')
@allowed(['dev', 'test', 'staging', 'prod', 'uat'])
param envName string

@description('Azure region where all resources will be deployed - must support API Management Premium tier')
param location string

//==============================================================================
// CONFIGURATION AND VARIABLES
//==============================================================================

// Configuration file and naming constants
@description('Configuration file containing all environment-specific settings and parameters')
var settingsFile = 'settings.yaml'

@description('Standard suffix for resource group naming consistency across all deployments')
var resourceGroupSuffix = 'rg'

@description('Tag value indicating infrastructure is managed by Bicep templates')
var managedByValue = 'bicep'

@description('Complete configuration object loaded from YAML settings file')
var settings = loadYamlContent(settingsFile)

// Tag consolidation and resource naming
@description('Consolidated tags combining governance tags from settings with deployment metadata')
var commonTags = union(settings.shared.tags, {
  environment: envName
  managedBy: managedByValue
  templateVersion: '2.0.0'
})

@description('Resource group name following organizational naming convention: solution-environment-location-type')
var rgName = '${settings.solutionName}-${envName}-${location}-${resourceGroupSuffix}'

//==============================================================================
// RESOURCE GROUP DEPLOYMENT
//==============================================================================

@description('Primary resource group containing all APIM Landing Zone components')
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
  tags: commonTags
}

//==============================================================================
// SHARED INFRASTRUCTURE DEPLOYMENT
//==============================================================================
// Deploys foundational monitoring and observability infrastructure
// This module must be deployed first as other components depend on its outputs

@description('Shared monitoring infrastructure including Log Analytics workspace and Application Insights')
module shared '../src/shared/main.bicep' = {
  name: 'deploy-shared-components'
  scope: rg
  params: {
    solutionName: settings.solutionName
    location: location
    sharedSettings: settings.shared
  }
}

//==============================================================================
// SHARED INFRASTRUCTURE OUTPUTS
//==============================================================================
// Critical outputs from shared infrastructure for use by dependent resources

@description('Resource ID of Application Insights instance for application performance monitoring')
output APPLICATION_INSIGHTS_RESOURCE_ID string = shared.outputs.APPLICATION_INSIGHTS_RESOURCE_ID

@description('Name of Application Insights instance for configuration references')
output APPLICATION_INSIGHTS_NAME string = shared.outputs.APPLICATION_INSIGHTS_NAME

@description('Application Insights instrumentation key for SDK configuration (sensitive)')
@secure()
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = shared.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY

@description('Resource ID of storage account used for diagnostic logs and monitoring data')
output AZURE_STORAGE_ACCOUNT_ID string = shared.outputs.AZURE_STORAGE_ACCOUNT_ID

//==============================================================================
// CORE PLATFORM DEPLOYMENT
//==============================================================================
// Deploys the main API Management service and related core platform components
// Depends on shared infrastructure for monitoring and diagnostic capabilities

@description('Core API Management platform with premium features and monitoring integration')
module core '../src/core/main.bicep' = {
  name: 'deploy-core-platform'
  scope: resourceGroup(rgName)
  params: {
    solutionName: settings.solutionName
    location: location
    tags: union(commonTags, settings.core.tags)
    logAnalyticsWorkspaceId: shared.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    storageAccountResourceId: shared.outputs.AZURE_STORAGE_ACCOUNT_ID
    applicationInsIghtsResourceId: shared.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
    apiManagementSettings: settings.core.apiManagement
  }
}

//==============================================================================
// API INVENTORY MANAGEMENT DEPLOYMENT
//==============================================================================
// Deploys API Center for centralized API inventory and governance
// Integrates with API Management service for automated API discovery

@description('API Center service for centralized API inventory, documentation, and governance')
module inventory '../src/inventory/main.bicep' = {
  name: 'deploy-inventory-components'
  scope: resourceGroup(rgName)
  params: {
    solutionName: settings.solutionName
    inventorySettings: settings.inventory
    apiManagementName: core.outputs.API_MANAGEMENT_NAME
    apiManagementResourceId: core.outputs.API_MANAGEMENT_RESOURCE_ID
    tags: settings.shared.tags
  }
}
