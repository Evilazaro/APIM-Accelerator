// =================================================================
// OPERATIONAL MONITORING INFRASTRUCTURE
// =================================================================
// This module deploys Log Analytics workspace and storage account
// for operational monitoring, log aggregation, and long-term storage.
// These services provide the foundation for observability.
//
// File: src/shared/monitoring/operational/main.bicep
// Purpose: Deploys Log Analytics and storage for operational monitoring
// Dependencies: Constants module for naming functions
//
// OVERVIEW:
// This Bicep module creates the core monitoring infrastructure for the
// APIM Accelerator solution. It provisions:
// 1. Log Analytics Workspace - Centralized log collection and analysis
// 2. Storage Account - Long-term log retention and archival
// 3. Diagnostic Settings - Self-monitoring of the workspace itself
//
// USAGE:
// Deploy this module as part of the shared infrastructure before
// deploying application-specific resources that need to send logs
// to the workspace.
//
// SECURITY CONSIDERATIONS:
// - Supports System-Assigned and User-Assigned managed identities
// - Storage account uses Standard_LRS for cost-effective durability
// - Diagnostic settings enable audit trails for compliance
// =================================================================

import { generateStorageAccountName } from '../../constants.bicep'

// =================================================================
// PARAMETERS
// =================================================================
// Parameters control the configuration of monitoring resources.
// These values are passed in by the calling module or deployment script.
// =================================================================

@description('Name of the Log Analytics workspace')
@metadata({
  purpose: 'Identifies the workspace resource'
  example: 'apim-ops-logs'
  constraints: 'Must be unique within the resource group'
})
param name string

@description('Azure region where monitoring resources will be deployed')
@metadata({
  purpose: 'Specifies the deployment location for all monitoring resources'
  example: 'eastus'
  note: 'Should match the location of resources being monitored for optimal performance'
})
param location string

@description('Log Analytics workspace pricing tier - PerGB2018 recommended for most workloads')
@metadata({
  purpose: 'Determines the billing model and features available'
  recommendation: 'PerGB2018 for pay-as-you-go pricing with no minimum commitment'
  documentation: 'https://docs.microsoft.com/azure/azure-monitor/logs/cost-logs'
})
@allowed([
  'CapacityReservation' // Commitment-based pricing for high-volume scenarios
  'Free' // Limited 500MB/day, 7-day retention, for testing only
  'LACluster' // Dedicated cluster for 500GB+/day scenarios
  'PerGB2018' // Pay-per-GB ingestion, most flexible option
  'PerNode' // Legacy pricing, per-node billing
  'Premium' // Legacy tier with enhanced features
  'Standalone' // Legacy standalone pricing
  'Standard' // Legacy standard pricing
])
param skuName string = 'PerGB2018'

@description('Type of managed identity for Log Analytics workspace')
@metadata({
  purpose: 'Enables secure access to other Azure resources without credentials'
  systemAssigned: 'Lifecycle tied to the workspace, simpler but less flexible'
  userAssigned: 'Independent lifecycle, can be shared across resources'
  none: 'No managed identity, limited integration capabilities'
})
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'None'
])
param identityType string

@description('Array of user-assigned identity resource IDs (if using UserAssigned identity)')
@metadata({
  purpose: 'Specifies which user-assigned identities to attach to the workspace'
  example: '[\'/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity\']'
  note: 'Required when identityType is UserAssigned, ignored otherwise'
})
param userAssignedIdentities array

@description('Tags to be applied to monitoring resources for governance')
@metadata({
  purpose: 'Resource tagging for cost tracking, ownership, and compliance'
  example: '{ environment: \'production\', costCenter: \'IT-Ops\', owner: \'platform-team\' }'
  recommendation: 'Include environment, cost center, and owner tags at minimum'
})
param tags object

// =================================================================
// VARIABLES AND COMPUTED VALUES
// =================================================================
// Variables define computed values and configuration constants.
// These are derived from parameters or set as deployment-time constants.
// =================================================================

// Generate unique storage account name using centralized function
// Storage account names must be globally unique across Azure (3-24 lowercase alphanumeric chars)
// The generateStorageAccountName function combines the base name with a unique hash
var storageAccountName = generateStorageAccountName(name, uniqueString(resourceGroup().id))

// Storage account SKU configuration
// Standard_LRS provides locally-redundant storage for cost-effective durability
// Suitable for diagnostic logs where regional redundancy is not critical
var storageSkuName = 'Standard_LRS'

// StorageV2 is the current generation of general-purpose storage accounts
// Supports all storage types (blobs, files, queues, tables) with latest features
var storageKind = 'StorageV2'

// Naming convention for diagnostic settings resources
// Appends '-diag' to the parent resource name for consistency
var diagnosticSettingsSuffix = '-diag'

// Category groups for diagnostic settings
// 'allLogs' captures all available log categories without specifying each individually
var allLogsCategory = 'allLogs'
// 'allMetrics' captures all available metric categories
var allMetricsCategory = 'allMetrics'

// =================================================================
// STORAGE ACCOUNT FOR LOG ARCHIVAL
// =================================================================
// Storage account provides cost-effective long-term retention for logs
// that exceed the Log Analytics workspace retention period.
//
// PURPOSE:
// - Archive diagnostic logs for compliance and audit requirements
// - Reduce Log Analytics costs by storing cold data in blob storage
// - Enable long-term trend analysis and historical investigations
//
// CONFIGURATION:
// - Uses Standard_LRS for local redundancy (sufficient for logs)
// - StorageV2 provides latest features and performance optimizations
// - Inherits location and tags from parent deployment for consistency
// =================================================================

@description('Storage account for diagnostic log archival and long-term retention')
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName // Standard_LRS for cost-effective local redundancy
  }
  kind: storageKind // StorageV2 for modern feature set
  tags: tags
}

// =================================================================
// LOG ANALYTICS WORKSPACE
// =================================================================
// The Log Analytics workspace is the central repository for all logs
// and metrics from Azure resources and applications.
//
// CAPABILITIES:
// - Kusto Query Language (KQL) for powerful log analysis
// - Built-in alerting and visualization capabilities
// - Integration with Azure Monitor, Application Insights, and Sentinel
// - Configurable retention periods (30-730 days)
//
// IDENTITY CONFIGURATION:
// - Managed identities enable secure resource access without credentials
// - System-assigned: Automatically created/deleted with workspace
// - User-assigned: Independent lifecycle, reusable across resources
// - None: No identity, limited integration capabilities
//
// The identity configuration uses conditional logic:
// 1. If identityType is 'None', no identity block is created
// 2. For 'SystemAssigned', only the type is specified
// 3. For 'UserAssigned', identities are converted from array to object
//    using toObject() function with identity ID as both key and value
// =================================================================

@description('Log Analytics workspace - Central hub for log aggregation, analysis, and alerting')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  // Conditional identity configuration based on identityType parameter
  identity: (identityType != 'None')
    ? {
        type: identityType
        // User-assigned identities must be provided as an object with resource IDs as keys
        // toObject() transforms the array into the required object format
        userAssignedIdentities: (identityType == 'UserAssigned' && !empty(userAssignedIdentities))
          ? toObject(userAssignedIdentities, id => id, id => {})
          : null
      }
    : null
  tags: tags
  properties: {
    sku: {
      name: skuName // Determines pricing model and feature availability
    }
    // Additional properties like retentionInDays can be configured here
    // Default retention is 30 days for PerGB2018 SKU
  }
}

// =================================================================
// DIAGNOSTIC SETTINGS
// =================================================================
// Diagnostic settings enable self-monitoring of the Log Analytics workspace.
// This creates a feedback loop where the workspace monitors itself.
//
// WHY SELF-MONITORING?
// - Track workspace health, query performance, and capacity trends
// - Audit who accessed the workspace and what queries were run
// - Alert on ingestion failures, throttling, or capacity issues
// - Meet compliance requirements for audit trails
//
// DUAL DESTINATION STRATEGY:
// - Workspace (workspaceId): Enables real-time querying and alerting
// - Storage (storageAccountId): Provides long-term retention and cost-effective archival
//
// LOG CATEGORIES:
// - Using 'allLogs' category group captures all available log types:
//   * Audit: Access and permission changes
//   * Query: Query execution and performance
//   * Ingestion: Data ingestion operations
//
// METRICS:
// - Using 'allMetrics' captures workspace performance metrics:
//   * Query performance and duration
//   * Data ingestion volume and rate
//   * Workspace capacity utilization
// =================================================================

@description('Diagnostic settings for Log Analytics workspace - Enables self-monitoring and audit trails')
resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${logAnalyticsWorkspace.name}${diagnosticSettingsSuffix}'
  scope: logAnalyticsWorkspace // Attach diagnostic settings to the workspace
  properties: {
    // Send logs to the workspace itself for real-time analysis
    workspaceId: logAnalyticsWorkspace.id
    // Archive logs to storage for long-term retention
    storageAccountId: storageAccount.id
    logs: [
      {
        enabled: true
        categoryGroup: allLogsCategory // Captures all log categories without explicit enumeration
      }
    ]
    metrics: [
      {
        enabled: true
        category: allMetricsCategory // Captures all metric categories
      }
    ]
  }
}

// =================================================================
// OUTPUTS
// =================================================================
// Outputs expose resource identifiers for use in other modules.
// These values are returned to the calling module or deployment script.
//
// USAGE:
// Other modules can reference these outputs to:
// - Configure diagnostic settings for their resources
// - Send logs and metrics to the workspace
// - Store additional data in the archival storage account
//
// NAMING CONVENTION:
// Outputs use AZURE_ prefix and uppercase for consistency with
// Azure Developer CLI (azd) environment variable conventions.
// =================================================================

@description('Resource ID of the deployed Log Analytics workspace')
@metadata({
  purpose: 'Used by other resources to send logs and metrics to this workspace'
  example: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}'
  usage: 'Pass this value to the workspaceId property of diagnostic settings'
})
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

@description('Resource ID of the deployed storage account for log archival')
@metadata({
  purpose: 'Used by other resources to archive logs and metrics to this storage account'
  example: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{storageAccountName}'
  usage: 'Pass this value to the storageAccountId property of diagnostic settings'
})
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id
