@description('Name of the Azure Bastion Host')
param name string

@description('Location of the Azure Bastion Host')
param location string

@description('SKU Name of the Azure Bastion Host')
@allowed([
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string

@description('Public IP IP Allocation Method')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string

@description('Private IP IP Allocation Method')
@allowed([
  'Static'
  'Dynamic'
])
param privateIPAllocationMethod string

@description('Public IP Sku Name')
@allowed([
  'Basic'
  'Standard'
])
param publicIPSkuName string

@description('Public IP Sku Tier')
@allowed([
  'Regional'
  'Global'
])
param publicIPSkuTier string

@description('Virtual Network subnet ID to deploy the Azure Bastion Host into')
param virtualNetworkSubnetId string

@description('Tags for the Azure Bastion Host')
param tags object

@description('Module to create Public IP Address')
module publicIP './public-ip-address.bicep' = {
  name: 'bastion-PublicIP'
  scope: resourceGroup()
  params: {
    name: '${name}-pip'
    location: location
    publicIPAllocationMethod: publicIPAllocationMethod
    skuName: publicIPSkuName
    skuTier: publicIPSkuTier
    publicIPAddressVersion: 'IPv4'
    tags: tags
  }
}

@description('Azure Bastion Host Resource')
resource azureBastion 'Microsoft.Network/bastionHosts@2024-07-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: virtualNetworkSubnetId
          }
          publicIPAddress: {
            id: publicIP.outputs.AZURE_PUBLIC_IP_ADDRESS_ID
          }
        }
      }
    ]
  }
}
