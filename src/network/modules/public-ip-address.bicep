@description('Name of the Public IP Address')
@minLength(3)
@maxLength(80)
param name string

@description('Location for the Public IP Address.')
param location string

@description('Public IP Allocation Method')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string

@description('Sku Name')
@allowed([
  'Basic'
  'Standard'
])
param skuName string

@description('skuTier')
@allowed([
  'Regional'
  'Global'
])
param skuTier string

@description('Public IP Address Version')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIPAddressVersion string

@description('Enable diagnostics for the Azure Public IP Address')
param enableDiagnostics bool

@description('Log Analytics Workspace ID for diagnostics (optional)')
param logAnalyticsWorkspaceId string

@description('Storage Account ID for diagnostics (optional)')
param diagnosticStorageAccountId string

@description('Tags for the Public IP Address')
param tags object

@description('Public IP Address Resource')
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: publicIPAddressVersion
  }
  sku: {
    name: skuName
    tier: skuTier
  }
}

@description('Public IP Address ID output')
output AZURE_PUBLIC_IP_ADDRESS_ID string = publicIPAddress.id

@description('Diagnostics settings for the Azure Public IP Address')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: publicIPAddress
  name: '${name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'AllLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
  dependsOn: [
    publicIPAddress
  ]
}
