/*
==============================================================================
SHARED CONSTANTS AND UTILITY FUNCTIONS
==============================================================================

File: src/shared/constants.bicep
Purpose: Centralized constants and utility functions for APIM Accelerator
Author: Cloud Platform Team
Created: 2025-10-28
Last Modified: 2025-10-28

Description:
  This module provides centralized constants and utility functions used across
  all APIM Accelerator templates. It includes:
  - Diagnostic settings configurations
  - Storage account naming and configuration constants
  - Log Analytics and Application Insights defaults
  - Identity type definitions and role mappings
  - API Management configuration constants
  - Utility functions for consistent resource naming

Usage:
  Import specific constants or functions as needed:
  import { diagnosticSettings, generateUniqueSuffix } from '../shared/constants.bicep'

Version: 1.0.0
==============================================================================
*/

//==============================================================================
// DIAGNOSTIC SETTINGS CONSTANTS
//==============================================================================

@description('Standard diagnostic settings configuration used across all Azure resources')
@export()
var diagnosticSettings object = {
  suffix: '-diag'                    // Standard suffix for diagnostic setting names
  allLogsCategory: 'allLogs'         // Category group for capturing all log types
  allMetricsCategory: 'allMetrics'   // Category for capturing all metric types
}

//==============================================================================
// STORAGE ACCOUNT CONFIGURATION CONSTANTS
//==============================================================================

@description('Storage account configuration constants for consistent deployment across environments')
@export()
var storageAccount object = {
  standardLRS: 'Standard_LRS'        // Locally redundant storage for cost optimization
  storageV2: 'StorageV2'            // Latest storage account type with all features
  suffixSeparator: 'sa'             // Standard abbreviation for storage accounts
  maxNameLength: 24                 // Azure limit for storage account name length
}

// Log Analytics constants
@export()
var logAnalytics object = {
  defaultSku: 'PerGB2018'
  skuOptions: [
    'CapacityReservation'
    'Free'
    'LACluster'
    'PerGB2018'
    'PerNode'
    'Premium'
    'Standalone'
    'Standard'
  ]
}

// Application Insights constants
@export()
var applicationInsights = {
  defaultKind: 'web'
  defaultApplicationType: 'web'
  defaultIngestionMode: 'LogAnalytics'
  defaultPublicNetworkAccess: 'Enabled'
  defaultRetentionDays: 90
  kindOptions: [
    'web'
    'ios'
    'other'
    'store'
    'java'
    'phone'
  ]
  applicationTypeOptions: [
    'web'
    'other'
  ]
  ingestionModeOptions: [
    'ApplicationInsights'
    'ApplicationInsightsWithDiagnosticSettings'
    'LogAnalytics'
  ]
  publicNetworkAccessOptions: [
    'Enabled'
    'Disabled'
  ]
}

// Identity type constants
@export()
var identityTypes = {
  systemAssigned: 'SystemAssigned'
  userAssigned: 'UserAssigned'
  systemAndUserAssigned: 'SystemAssigned, UserAssigned'
  none: 'None'
  allOptions: [
    'SystemAssigned'
    'UserAssigned'
    'SystemAssigned, UserAssigned'
    'None'
  ]
}

// APIM constants
@export()
var apiManagement = {
  skuOptions: [
    'Basic'
    'BasicV2'
    'Developer'
    'Isolated'
    'Standard'
    'StandardV2'
    'Premium'
    'Consumption'
  ]
  virtualNetworkTypes: [
    'External'
    'Internal'
    'None'
  ]
  defaultVirtualNetworkType: 'None'
  defaultPublicNetworkAccess: true
  defaultDeveloperPortalEnabled: true
}

// Common role definition IDs
@export()
var roleDefinitions = {
  keyVaultSecretsUser: '4633458b-17de-408a-b874-0445c86b69e6'
  keyVaultSecretsOfficer: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  apiCenterReader: '71522526-b88f-4d52-b57f-d31fc3546d0d'
  apiCenterContributor: '6cba8790-29c5-48e5-bab1-c7541b01cb04'
}

//==============================================================================
// UTILITY FUNCTIONS
//==============================================================================

@description('Generates consistent unique suffix for resource naming based on deployment context')
@export()
func generateUniqueSuffix(subscriptionId string, resourceGroupId string, resourceGroupName string, solutionName string, location string) string =>
  uniqueString(subscriptionId, resourceGroupId, resourceGroupName, solutionName, location)

@description('Generates compliant storage account name with length constraints and character restrictions')
@export()
func generateStorageAccountName(baseName string, uniqueSuffix string) string =>
  toLower(take(replace('${baseName}${storageAccount.suffixSeparator}${uniqueSuffix}', '-', ''), storageAccount.maxNameLength))

@description('Generates standardized diagnostic settings name for consistent monitoring configuration')
@export()
func generateDiagnosticSettingsName(resourceName string) string =>
  '${resourceName}${diagnosticSettings.suffix}'

@description('Creates properly formatted identity configuration object for Azure resources')
@export()
func createIdentityConfig(identityType string, userAssignedIdentities array) object =>
  identityType != identityTypes.none
    ? {
        type: identityType
        userAssignedIdentities: (identityType == identityTypes.userAssigned && !empty(userAssignedIdentities))
          ? toObject(userAssignedIdentities, id => id, id => {})
          : {}
      }
    : {}
