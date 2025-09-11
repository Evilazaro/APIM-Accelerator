targetScope = 'subscription'

@description('Location for all resources')
param location string

@description('Tags for all resources')
param tags object

param dateTime string = utcNow('yyyyMMddHHmmss')

var settings = loadYamlContent('../../infra/settings/monitor.yaml')

@description('Resource Group for monitoring resources')
resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.resourceGroup.name
  location: location
}

@description('Deploy the monitoring resources')
module logAnalyticsWorkspace 'modules/logAnalytics-workspace.bicep' = {
  name: 'logAnalytics-${dateTime}'
  scope: monitoringRG
  params: {
    name: settings.logAnalytics.name
    location: location
    tags: tags
  }
}

@description('Log Analytics Workspace ID output')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

@description('Log Analytics Workspace Name output')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME

@description('Deploy Storage Account for Application Insights diagnostics (if enabled)')
module storageAccount 'modules/storage-account.bicep' = if (settings.logAnalytics.provisionStorageAccount) {
  name: 'appInsightsStorage-${dateTime}'
  scope: monitoringRG
  params: {
    name: 'appinsightsdiag${toLower(replace(dateTime, '-', ''))}'
    location: location
    sku: 'Standard_LRS'
    kind: 'StorageV2'
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Disabled'
    networkAclsBypass: 'AzureServices'
    networkAclsVirtualNetworkRules: []
    networkAclsIpRules: []
    networkAclsDefaultAction: 'Allow'
    supportsHttpsTrafficOnly: true
    requireInfrastructureEncryption: false
    serviceKeyType: 'Account'
    enableFileService: false
    enableBlobService: true
    enableQueueService: true
    enableTableService: true
    accessTier: 'Hot'
    tags: tags
  }
}

@description('Storage Account ID output')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount!.outputs.AZURE_STORAGE_ACCOUNT_ID

@description('Storage Account Name output')
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount!.outputs.AZURE_STORAGE_ACCOUNT_NAME
