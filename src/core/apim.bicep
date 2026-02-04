//==============================================================================
// APIM BICEP TEMPLATE
//==============================================================================
// This Bicep template deploys an Azure API Management (APIM) service instance
// with comprehensive configuration options including:
// - Managed identity support (System-assigned and User-assigned)
// - Virtual network integration for private deployments
// - Diagnostic settings with Log Analytics and Storage Account integration
// - Application Insights logger for performance monitoring
// - Role-based access control (RBAC) assignments
// - Developer portal configuration
//
// USAGE EXAMPLE:
// --------------
// module apim './apim.bicep' = {
//   name: 'apim-deployment'
//   params: {
//     name: 'my-apim-service'
//     location: 'eastus'
//     skuName: 'Developer'
//     skuCapacity: 1
//     identityType: 'SystemAssigned'
//     userAssignedIdentities: []
//     publisherEmail: 'admin@contoso.com'
//     publisherName: 'Contoso'
//     logAnalyticsWorkspaceId: '/subscriptions/.../workspaces/...'
//     storageAccountResourceId: '/subscriptions/.../storageAccounts/...'
//     applicationInsIghtsResourceId: '/subscriptions/.../components/...'
//     enableDeveloperPortal: true
//     publicNetworkAccess: true
//     virtualNetworkType: 'None'
//     subnetResourceId: ''
//     tags: { environment: 'dev', project: 'api-platform' }
//   }
// }
//
// PREREQUISITES:
// --------------
// - Log Analytics workspace must exist
// - Application Insights instance must exist
// - Storage account must exist
// - For VNet integration: Virtual network and subnet must exist
// - Appropriate RBAC permissions to deploy resources
//
// SKU RECOMMENDATIONS:
// --------------------
// - Developer: Non-production, no SLA, low cost
// - Basic/BasicV2: Small-scale production workloads
// - Standard/StandardV2: Medium-scale production workloads
// - Premium: High-scale production with multi-region support
// - Consumption: Serverless, pay-per-execution model
//
// SECURITY BEST PRACTICES:
// ------------------------
// - Use System-assigned managed identity when possible
// - Set publicNetworkAccess to false for production environments
// - Use Internal VNet type for fully private deployments
// - Enable diagnostic settings for audit and compliance
// - Apply appropriate resource tags for governance
//==============================================================================

//==============================================================================
// CONSTANTS AND CONFIGURATION
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
// All parameters required for deploying and configuring the API Management
// service. Parameters are grouped by category:
// - Identity and Security
// - Networking
// - Monitoring and Diagnostics
// - Service Configuration
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
// Dynamic variables that compute configuration objects based on
// provided parameters. These enable conditional resource deployment
// and configuration.
// =================================================================

@description('Identity Configuration - Constructs the managed identity object based on the specified identity type. SystemAssigned creates a new identity, UserAssigned uses existing identities, and None results in null.')
var identityObject = identityType == 'SystemAssigned'
  ? {
      type: identityType
    }
  : identityType == 'UserAssigned'
      ? {
          type: identityType
          userAssignedIdentities: toObject(userAssignedIdentities, identity => identity, identity => {})
        }
      : null

@description('Virtual Network Configuration - Conditionally configures VNet integration by setting the subnet resource ID when virtualNetworkType is External or Internal. Returns null for public deployments.')
var virtualNetworkConfiguration = virtualNetworkType != 'None'
  ? {
      subnetResourceId: subnetResourceId
    }
  : null

// =================================================================
// AZURE API MANAGEMENT SERVICE
// =================================================================

@description('Azure API Management service - Provides API gateway, developer portal, and management capabilities')
resource apim 'Microsoft.ApiManagement/service@2025-03-01-preview' = {
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
// Assigns necessary RBAC roles to the API Management service's
// managed identity to enable access to required Azure resources.
// The Reader role allows APIM to read resource metadata.
// Additional roles can be added to the roles array as needed.
// =================================================================

@description('Collection of Azure RBAC role definition IDs to be assigned to the API Management service principal. Currently includes Reader role for accessing resources within the resource group.')
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
    dependsOn: [
      apim
    ]
  }
]

// =================================================================
// MANAGED IDENTITY ACCESS (for existing client secret scenarios)
// =================================================================
// References the default managed identity associated with the APIM
// service for scenarios requiring client secret authentication.
// This is a nested resource reference within the APIM scope.
// NOTE: This references a system-generated identity, not a custom
// user-assigned identity.
// =================================================================

@description('Reference to existing managed identity for client secret scenarios')
resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: apim
  name: 'default'
  dependsOn: [
    roleAssignments
  ]
}

// =================================================================
// DIAGNOSTIC SETTINGS AND MONITORING
// =================================================================
// Configures comprehensive monitoring and logging for the API
// Management service. Sends metrics and logs to Log Analytics
// for real-time monitoring and to Storage Account for long-term
// retention and compliance. Application Insights provides detailed
// API performance telemetry and distributed tracing.
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
resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2025-03-01-preview' = {
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
// Returns key identifiers and properties of the deployed resources.
// These outputs can be used by other modules or for reference in
// deployment pipelines.
//
// OUTPUT USAGE:
// - API_MANAGEMENT_RESOURCE_ID: Full ARM resource ID
// - API_MANAGEMENT_NAME: Service name for CLI/SDK operations
// - AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID: For RBAC assignments
// - AZURE_CLIENT_SECRET_*: For authentication scenarios
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
