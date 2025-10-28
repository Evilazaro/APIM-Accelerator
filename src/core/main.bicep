/*
==============================================================================
CORE API MANAGEMENT PLATFORM MODULE
==============================================================================

File: src/core/main.bicep
Purpose: Deploys core API Management service and related platform components
Author: Cloud Platform Team
Created: 2025-10-28

Description:
  Deploys the main API Management service with:
  - Premium tier API Management instance with monitoring integration
  - Managed identity configuration for secure service-to-service authentication
  - Diagnostic settings for comprehensive observability
  - Developer portal configuration with Azure AD integration
  - Workspace configuration for API organization

Dependencies:
  - Shared monitoring infrastructure (Log Analytics, Application Insights)
  - Common type definitions for API Management configuration

==============================================================================
*/

import { ApiManagement } from '../shared/common-types.bicep'
import { generateUniqueSuffix } from '../shared/constants.bicep'

//==============================================================================
// PARAMETERS
//==============================================================================

@description('Solution name used as prefix for all core platform resources')
param solutionName string

@description('Azure region where core platform resources will be deployed')
param location string

@description('API Management service configuration including SKU, identity, and workspace settings')
param apiManagementSettings ApiManagement

@description('Resource ID of Log Analytics workspace for diagnostic logging')
param logAnalyticsWorkspaceId string

@description('Resource ID of storage account for diagnostic log storage and archival')
param storageAccountResourceId string

@description('Resource ID of Application Insights instance for performance monitoring')
param applicationInsIghtsResourceId string

@description('Tags to be applied to all core platform resources')
param tags object

//==============================================================================
// VARIABLES AND CONFIGURATION
//==============================================================================

@description('Unique suffix for consistent resource naming across all deployments')
var uniqueSuffix = generateUniqueSuffix(subscription().id, resourceGroup().id, resourceGroup().name, solutionName, location)

@description('Standard suffix for API Management service naming')
var apimSuffix = 'apim'

@description('API Management service name with fallback to generated name if not specified')
var apimName = apiManagementSettings.name ?? '${solutionName}-${uniqueSuffix}-${apimSuffix}'

//==============================================================================
// API MANAGEMENT SERVICE DEPLOYMENT
//==============================================================================

@description('API Management service with premium features, monitoring integration, and security configuration')
module apim 'apim.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    tags: tags
    applicationInsIghtsResourceId: applicationInsIghtsResourceId
    identityType: apiManagementSettings.identity.type
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    storageAccountResourceId: storageAccountResourceId
    publisherEmail: apiManagementSettings.publisherEmail
    publisherName: apiManagementSettings.publisherName
    skuCapacity: apiManagementSettings.sku.capacity
    skuName: apiManagementSettings.sku.name
    userAssignedIdentities: apiManagementSettings.identity.userAssignedIdentities
  }
}

//==============================================================================
// API MANAGEMENT OUTPUTS
//==============================================================================

@description('Resource ID of API Management service for integration with other services')
output API_MANAGEMENT_RESOURCE_ID string = apim.outputs.API_MANAGEMENT_RESOURCE_ID

@description('Name of API Management service for configuration and reference')
output API_MANAGEMENT_NAME string = apim.outputs.API_MANAGEMENT_NAME

//==============================================================================
// WORKSPACE CONFIGURATION
//==============================================================================
// Creates organized workspaces within API Management for different teams or projects

@description('API Management workspaces for organizing APIs by team, project, or business domain')
module providers 'workspaces.bicep' = [
  for item in apiManagementSettings.workspaces: {
    name: item.name
    scope: resourceGroup()
    params: {
      name: item.name
      apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    }
  }
]

//==============================================================================
// DEVELOPER PORTAL CONFIGURATION
//==============================================================================
// Configures API Management developer portal with Azure AD authentication

@description('Developer portal configuration with Azure AD integration for self-service API consumption')
module devPortal 'developer-portal.bicep' = {
  name: 'deploy-developer-portal'
  scope: resourceGroup()
  params: {
    apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    clientId: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    clientSecret: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
  }
}
