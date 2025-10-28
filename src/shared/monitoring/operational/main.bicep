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
// =================================================================

import { generateStorageAccountName } from '../../constants.bicep'

// =================================================================
// PARAMETERS
// =================================================================

@description('Name of the Log Analytics workspace')
param name string

@description('Azure region where monitoring resources will be deployed')
param location string

@description('Log Analytics workspace pricing tier - PerGB2018 recommended for most workloads')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param skuName string = 'PerGB2018'

@description('Type of managed identity for Log Analytics workspace')
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'None'
])
param identityType string

@description('Array of user-assigned identity resource IDs (if using UserAssigned identity)')
param userAssignedIdentities array

@description('Tags to be applied to monitoring resources for governance')
param tags object

// =================================================================
// VARIABLES AND COMPUTED VALUES
// =================================================================

// Generate unique storage account name using centralized function
var storageAccountName = generateStorageAccountName(name, uniqueString(resourceGroup().id))

// Storage and diagnostic configuration constants
var storageSkuName = 'Standard_LRS'
var storageKind = 'StorageV2'
var diagnosticSettingsSuffix = '-diag'
var allLogsCategory = 'allLogs'
var allMetricsCategory = 'allMetrics'

// =================================================================
// STORAGE ACCOUNT FOR LOG ARCHIVAL
// =================================================================

@description('Storage account for diagnostic log archival and long-term retention')
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName
  }
  kind: storageKind
  tags: tags
}

// =================================================================
// LOG ANALYTICS WORKSPACE
// =================================================================

@description('Log Analytics workspace - Central hub for log aggregation, analysis, and alerting')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  identity: (identityType != 'None')
    ? {
        type: identityType
        userAssignedIdentities: (identityType == 'UserAssigned' && !empty(userAssignedIdentities))
          ? toObject(userAssignedIdentities, id => id, id => {})
          : null
      }
    : null
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
  }
}

// =================================================================
// DIAGNOSTIC SETTINGS
// =================================================================

@description('Diagnostic settings for Log Analytics workspace - Enables self-monitoring and audit trails')
resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${logAnalyticsWorkspace.name}${diagnosticSettingsSuffix}'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
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

@description('Resource ID of the deployed Log Analytics workspace')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

@description('Resource ID of the deployed storage account for log archival')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id
