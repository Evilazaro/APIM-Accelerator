// Common constants and reusable variables for the APIM Accelerator solution
// This file centralizes frequently used constants to improve maintainability

// Diagnostic settings constants
@export()
var diagnosticSettings object = {
  suffix: '-diag'
  allLogsCategory: 'allLogs'
  allMetricsCategory: 'allMetrics'
}

// Storage account constants
@export()
var storageAccount object = {
  standardLRS: 'Standard_LRS'
  storageV2: 'StorageV2'
  suffixSeparator: 'sa'
  maxNameLength: 24
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

// Function to generate consistent unique suffix
@export()
func generateUniqueSuffix(subscriptionId string, resourceGroupId string, resourceGroupName string, solutionName string, location string) string =>
  uniqueString(subscriptionId, resourceGroupId, resourceGroupName, solutionName, location)

// Function to generate storage account name with proper constraints
@export()
func generateStorageAccountName(baseName string, uniqueSuffix string) string =>
  toLower(take(replace('${baseName}${storageAccount.suffixSeparator}${uniqueSuffix}', '-', ''), storageAccount.maxNameLength))

// Function to generate diagnostic settings name
@export()
func generateDiagnosticSettingsName(resourceName string) string =>
  '${resourceName}${diagnosticSettings.suffix}'

// Function to create identity configuration
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
