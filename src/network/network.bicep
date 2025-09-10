targetScope = 'subscription'

@description('Location for the network resources')
param location string

@description('Tags to apply to all resources')
param tags object

param dateTime string = utcNow('yyyyMMddHHmmss')

// Load network settings from the external YAML file
var settings = loadYamlContent('../../infra/settings/network.yaml')

@description('Conditionally create a new resource group or use an existing one.')
resource networkRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.resourceGroup.name
  location: location
  tags: tags
}

@description('Module to create DDoS Protection Plan')
module ddosProtection 'modules/ddos.bicep' = {
  name: 'ddosProtection-${dateTime}'
  scope: networkRG
  params: {
    name: settings.security.ddosProtection.name
    location: location
    tags: tags
  }
}

@description('DDoS Protection Plan ID output')
output DDOS_PROTECTION_PLAN_ID string = ddosProtection.outputs.DDOS_PROTECTION_PLAN_ID

@description('DDoS Protection Plan Name output')
output DDOS_PROTECTION_PLAN_NAME string = ddosProtection.outputs.DDOS_PROTECTION_PLAN_NAME

@description('Module to create Virtual Network')
module virtualNetwork 'modules/vitual-network.bicep' = {
  name: 'virtualNetwork-${dateTime}'
  scope: networkRG
  params: {
    name: settings.name
    location: location
    addressPrefixes: settings.ipAddresses.addressSpaces
    subnets: settings.ipAddresses.subnets
    enableEncryption: settings.security.encryption.enabled
    ddosProtectionPlanId: ddosProtection.outputs.DDOS_PROTECTION_PLAN_ID
    tags: tags
  }
  dependsOn: [
    ddosProtection
  ]
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

@description('Module to create Azure Firewall')
module azureFirewall './modules/firewall.bicep' = {
  name: 'azureFirewall-${dateTime}'
  scope: networkRG
  params: {
    name: settings.security.azureFirewall.name
    location: location
    skuName: settings.security.azureFirewall.sku
    skuTier: settings.security.azureFirewall.Tier
    publicIPAllocationMethod: 'Static'
    publicIPSkuName: 'Standard'
    publicIPSkuTier: 'Regional'
    virtualNetworkSubnetId: firewallSubnetId
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

var bastionSubnetId = resourceId(
  subscription().subscriptionId,
  networkRG.name,
  'Microsoft.Network/virtualNetworks/subnets',
  virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME,
  settings.security.azureBastion.subnetName
)

@description('Module to create Azure Bastion Host')
module azureBastion './modules/bastion.bicep' = {
  name: 'azureBastion-${dateTime}'
  scope: networkRG
  params: {
    name: settings.security.azureBastion.name
    location: location
    sku: settings.security.azureBastion.sku
    publicIPAllocationMethod: 'Static'
    privateIPAllocationMethod: 'Dynamic'
    virtualNetworkSubnetId: bastionSubnetId
    publicIPSkuName: 'Standard'
    publicIPSkuTier: 'Regional'
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

@description('Azure Bastion Host ID output')
output AZURE_BASTION_HOST_ID string = azureBastion.outputs.AZURE_BASTION_HOST_ID

@description('Azure Bastion Host Name output')
output AZURE_BASTION_HOST_NAME string = azureBastion.outputs.AZURE_BASTION_HOST_NAME
