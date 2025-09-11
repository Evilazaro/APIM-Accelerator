@minLength(3)
@maxLength(24)
param name string

@description('Location for all resources')
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
    accessTier: accessTier
    publicNetworkAccess: 'Disabled'
  }
  tags: tags
}

@description('Storage Account ID output')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id

@description('Storage Account Name output')
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.name
