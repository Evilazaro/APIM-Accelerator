/*
==============================================================================
API MANAGEMENT SERVICE DEPLOYMENT MODULE
==============================================================================

File: src/core/apim.bicep
Purpose: Deploys API Management service with monitoring and security configuration
Author: Cloud Platform Team
Created: 2025-10-28

Description:
  Deploys API Management service with:
  - Premium tier configuration for production workloads
  - Managed identity for secure service-to-service communication
  - Application Insights logger for performance monitoring
  - Diagnostic settings for comprehensive observability
  - Role-based access control for security

==============================================================================
*/

//==============================================================================
// CONFIGURATION CONSTANTS
//==============================================================================

@description('Suffix for diagnostic settings resource naming')
var diagnosticSettingsSuffix = '-diag'

@description('Suffix for Application Insights logger naming')
var appInsightsLoggerSuffix = '-appinsights'

@description('Reader role definition ID for API Management service identity')
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

//==============================================================================
// PARAMETERS
//==============================================================================

@description('Name of the API Management service instance')
param name string

@description('Azure region where the API Management service will be deployed')
param location string
@description('API Management service pricing tier - Premium recommended for production workloads')
@allowed([
  'Basic'
  'BasicV2'
  'Developer'
  'Isolated'
  'Standard'
  'StandardV2'
  'Premium'
  'Consumption'
])
param skuName string

@description('Type of managed identity to assign to the API Management service')
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'None'
])
param identityType string

@description('Array of user-assigned managed identity resource IDs (if using UserAssigned identity type)')
param userAssignedIdentities array

@description('Number of scale units for the API Management service (affects performance and cost)')
param skuCapacity int

@description('Email address of the API publisher for service configuration and notifications')
param publisherEmail string

@description('Name of the API publisher organization displayed in developer portal')
param publisherName string

@description('Resource ID of Log Analytics workspace for diagnostic logging')
param logAnalyticsWorkspaceId string

@description('Resource ID of storage account for diagnostic log archival')
param storageAccountResourceId string

@description('Resource ID of Application Insights instance for performance monitoring')
param applicationInsIghtsResourceId string

@description('Enable or disable the developer portal for API documentation and testing')
param enableDeveloperPortal bool = true

@description('Allow public network access to API Management service (set false for private deployment)')
param publicNetworkAccess bool = true

@description('Virtual network integration type - None for public, External/Internal for VNet integration')
@allowed([
  'External'
  'Internal'
  'None'
])
param virtualNetworkType string = 'None'

@description('Subnet resource ID for VNet integration (required if virtualNetworkType is not None)')
param subnetResourceId string = ''

@description('Tags to be applied to the API Management service for governance and cost tracking')
param tags object

// =================================================================
// VARIABLES AND COMPUTED VALUES
// =================================================================

// Identity Configuration - Build the identity object based on type
var identityObject = identityType == 'SystemAssigned' ? {
  type: identityType
} : identityType == 'UserAssigned' ? {
  type: identityType
  userAssignedIdentities: toObject(userAssignedIdentities, identity => identity, identity => {})
} : null

// Virtual Network Configuration - Only configure if VNet integration is enabled
var virtualNetworkConfiguration = virtualNetworkType != 'None' ? {
  subnetResourceId: subnetResourceId
} : null

// =================================================================
// AZURE API MANAGEMENT SERVICE
// =================================================================

@description('Azure API Management service - Provides API gateway, developer portal, and management capabilities')
resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  // Managed identity configuration - supports both System and User-assigned identities
  identity: identityObject
  tags: tags
  properties: {
    // Publisher information for service configuration
    publisherEmail: publisherEmail
    publisherName: publisherName
    
    // Developer portal configuration
    developerPortalStatus: (enableDeveloperPortal) ? 'Enabled' : 'Disabled'
    
    // Network access configuration
    publicNetworkAccess: (publicNetworkAccess) ? 'Enabled' : 'Disabled'
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: virtualNetworkConfiguration
  }
}

// =================================================================
// ROLE ASSIGNMENTS AND PERMISSIONS
// =================================================================

// Define required roles for API Management service principal
var roles = [
  readerRoleId
]

@description('Role assignments for API Management service principal - Grants necessary permissions for operation')
resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, resourceGroup().name, apim.id, apim.name, role)
    scope: resourceGroup()
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      principalId: apim.identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

// =================================================================
// MANAGED IDENTITY ACCESS (for existing client secret scenarios)
// =================================================================

@description('Reference to existing managed identity for client secret scenarios')
resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: apim
  name: 'default'
}

// =================================================================
// DIAGNOSTIC SETTINGS AND MONITORING
// =================================================================

@description('Diagnostic settings for API Management service - Enables comprehensive logging and monitoring')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${apim.name}${diagnosticSettingsSuffix}'
  scope: apim
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountResourceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

@description('Application Insights logger for API Management - Enables detailed performance monitoring and analytics')
resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2024-10-01-preview' = {
  name: '${apim.name}${appInsightsLoggerSuffix}'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    resourceId: applicationInsIghtsResourceId
    credentials: {
      instrumentationKey: reference(applicationInsIghtsResourceId, '2020-02-02').InstrumentationKey
    }
  }
}

// =================================================================
// OUTPUTS
// =================================================================

@description('Resource ID of the deployed API Management service')
output API_MANAGEMENT_RESOURCE_ID string = apim.id

@description('Name of the deployed API Management service')
output API_MANAGEMENT_NAME string = apim.name

@description('Principal ID of the API Management service managed identity')
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = apim.identity.principalId

@description('Client secret identity resource ID (for existing identity scenarios)')
output AZURE_CLIENT_SECRET_ID string = clientSecret.id

@description('Client secret identity name (for existing identity scenarios)')
output AZURE_CLIENT_SECRET_NAME string = clientSecret.name

@description('Client secret principal ID (for existing identity scenarios)')
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = clientSecret.properties.principalId

@description('Client secret client ID (for existing identity scenarios)')
output AZURE_CLIENT_SECRET_CLIENT_ID string = clientSecret.properties.clientId
