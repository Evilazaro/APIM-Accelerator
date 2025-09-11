@minLength(3)
@maxLength(24)
param name string

param location string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param sku string = 'Standard_RAGRS'

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@allowed([
  'Standard'
  'Premium'
])
param dnsEndpointType string = 'Standard'

@description('Default to OAuth Authentication')
param defaultToOAuthAuthentication bool = false

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

param allowCrossTenantReplication bool = false

@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Allow Blob Public Access')
param allowBlobPublicAccess bool = false

@description('Allow Shared Key Access')
param allowSharedKeyAccess bool = true

@allowed([
  'Enabled'
  'Disabled'
])
param largeFileSharesState string = 'Enabled'

@allowed([
  'None'
  'AzureServices'
  'Logging'
  'Metrics'
  'AzureServices,Logging'
  'AzureServices,Metrics'
  'Logging,Metrics'
  'AzureServices,Logging,Metrics'
])
param networkAclsBypass string = 'AzureServices'

@description('Virtual Network Rules for the Storage Account')
param networkAclsVirtualNetworkRules array = []

@description('IP Rules for the Storage Account')
param networkAclsIpRules array = []

@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Allow'

@description('Support HTTPS Traffic Only')
param supportsHttpsTrafficOnly bool = true

@description('Require Infrastructure Encryption')
param requireInfrastructureEncryption bool = false

@allowed([
  'Account'
  'Service'
])
param serviceKeyType string = 'Account'

@description('Enable File Service')
param enableFileService bool = true

@description('Enable Blob Service')
param enableBlobService bool = true

@description('Enable Queue Service')
param enableQueueService bool = true

@description('Enable Table Service')
param enableTableService bool = true

@allowed([
  'Hot'
  'Cool'
  'Premium'
])
param accessTier string = 'Hot'

param tags object = {}

@description('Storage Account Resource')
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    dnsEndpointType: dnsEndpointType
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    publicNetworkAccess: publicNetworkAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    largeFileSharesState: largeFileSharesState
    networkAcls: {
      bypass: networkAclsBypass
      virtualNetworkRules: networkAclsVirtualNetworkRules
      ipRules: networkAclsIpRules
      defaultAction: networkAclsDefaultAction
    }
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    encryption: {
      requireInfrastructureEncryption: requireInfrastructureEncryption
      services: {
        file: {
          keyType: serviceKeyType
          enabled: enableFileService
        }
        blob: {
          keyType: serviceKeyType
          enabled: enableBlobService
        }
        queue: {
          keyType: serviceKeyType
          enabled: enableQueueService
        }
        table: {
          keyType: serviceKeyType
          enabled: enableTableService
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: accessTier
  }
  tags: tags
}

@description('Storage Account ID output')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id

@description('Storage Account Name output')
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.name
