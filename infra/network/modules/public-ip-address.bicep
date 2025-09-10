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

@description('Public IP Address Resource')
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: name
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
  sku: {
    name: skuName
    tier: skuTier
  }
}

@description('Public IP Address ID output')
output AZURE_PUBLIC_IP_ADDRESS_ID string = publicIPAddress.id
