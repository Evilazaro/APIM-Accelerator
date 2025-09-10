targetScope = 'subscription'

@description('Location for the network resources')
param location string

var settings = loadYamlContent('./settings.yaml')

@description('Conditionally create a new resource group or use an existing one.')
resource networkRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.resourceGroup.name
  location: location
}

@description('Module to create Virtual Network')
module virtualNetwork 'modules/vitual-network.bicep' = {
  scope: networkRG
  params: {
    name: settings.name
    location: location
    addressPrefixes: settings.ipAddresses.addressSpaces
    subnets: settings.ipAddresses.subnets
    enableEncryption: settings.security.encryption.enabled
  }
}

@description('Virtual Network Name output')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME

@description('Virtual Network ID output')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_ID

var firewallSubnetId = resourceId(
  subscription().subscriptionId,
  networkRG.name,
  'Microsoft.Network/virtualNetworks/subnets',
  virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME,
  settings.security.azureFirewall.subnetName
)
// subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/myNetwork/subnets/AzureBastionSubnet
@description('Module to create Azure Firewall')
module azureFirewall './modules/firewall.bicep' = {
  scope: networkRG
  params: {
    name: settings.security.azureFirewall.name
    location: location
    skuName: 'AZFW_VNet'
    skuTier: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPSkuName: 'Standard'
    publicIPSkuTier: 'Regional'
    virtualNetworkSubnetId: firewallSubnetId
  }
  dependsOn: [
    virtualNetwork
  ]
}
