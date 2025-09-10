@description('Name of the Azure Firewall')
param name string

@description('Location of the Azure Firewall')
param location string

@description('SKU Name of the Azure Firewall')
param skuName string

@description('SKU Tier of the Azure Firewall')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuTier string

@description('Public IP IP Allocation Method')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string

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

@description('Virtual Network subnet ID to deploy the Azure Firewall into')
param virtualNetworkSubnetId string

@description('Tags for the Azure Firewall')
param tags object

@description('Module to create Public IP Address')
module publicIP './public-ip-address.bicep' = {
  name: 'firewall-PublicIP'
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

@description('Azure Firewall Resource')
resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: skuName
      tier: skuTier
    }
    ipConfigurations: [
      {
        name: 'ipConfig'
        id: publicIP.outputs.AZURE_PUBLIC_IP_ADDRESS_ID
        properties: {
          publicIPAddress: {
            id: publicIP.outputs.AZURE_PUBLIC_IP_ADDRESS_ID
          }
          subnet: {
            id: virtualNetworkSubnetId
          }
        }
      }
    ]
  }
}
