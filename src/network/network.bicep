targetScope = 'subscription'

@description('Location for the network resources')
param location string

@description('Tags to apply to all resources')
param tags object

@description('Log Analytics Workspace Resource ID for VNet diagnostics (optional)')
param logAnalyticsWorkspaceId string

@description('Storage Account Resource ID for VNet diagnostics (optional)')
param diagnosticStorageAccountId string

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
module ddosProtection 'modules/ddos.bicep' = if (settings.security.ddosProtection.enabled) {
  name: 'ddosProtection-${dateTime}'
  scope: networkRG
  params: {
    name: settings.security.ddosProtection.name
    location: location
    tags: tags
  }
}

@description('DDoS Protection Plan ID output')
output DDOS_PROTECTION_PLAN_ID string = ddosProtection!.outputs.DDOS_PROTECTION_PLAN_ID

@description('DDoS Protection Plan Name output')
output DDOS_PROTECTION_PLAN_NAME string = ddosProtection!.outputs.DDOS_PROTECTION_PLAN_NAME

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
    ddosProtectionPlanId: ddosProtection!.outputs.DDOS_PROTECTION_PLAN_ID
    enableDiagnostics: settings.diagnostics.enabled
    diagnosticStorageAccountId: diagnosticStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
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

var firewallSubnetId = (settings.security.azureFirewall.enabled)
  ? resourceId(
      subscription().subscriptionId,
      networkRG.name,
      'Microsoft.Network/virtualNetworks/subnets',
      virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME,
      settings.security.azureFirewall.subnetName
    )
  : null

@description('Module to create Azure Firewall')
module azureFirewall './modules/firewall.bicep' = if (settings.security.azureFirewall.enabled) {
  name: 'azureFirewall-${dateTime}'
  scope: networkRG
  params: {
    name: settings.security.azureFirewall.name
    location: location
    skuName: settings.security.azureFirewall.sku
    skuTier: settings.security.azureFirewall.tier
    publicIPAllocationMethod: 'Static'
    publicIPSkuName: 'Standard'
    publicIPSkuTier: 'Regional'
    virtualNetworkSubnetId: firewallSubnetId!
    enableDiagnostics: settings.diagnostics.enabled
    diagnosticStorageAccountId: diagnosticStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

@description('Azure Firewall Name output')
output AZURE_FIREWALL_NAME string = azureFirewall!.outputs.AZURE_FIREWALL_NAME

@description('Azure Firewall ID output')
output AZURE_FIREWALL_ID string = azureFirewall!.outputs.AZURE_FIREWALL_ID

var bastionSubnetId = (settings.security.azureBastion.enabled)
  ? resourceId(
      subscription().subscriptionId,
      networkRG.name,
      'Microsoft.Network/virtualNetworks/subnets',
      virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME,
      settings.security.azureBastion.subnetName
    )
  : null

@description('Module to create Azure Bastion Host')
module azureBastion './modules/bastion.bicep' = if (settings.security.azureBastion.enabled) {
  name: 'azureBastion-${dateTime}'
  scope: networkRG
  params: {
    name: settings.security.azureBastion.name
    location: location
    sku: settings.security.azureBastion.sku
    publicIPAllocationMethod: 'Static'
    privateIPAllocationMethod: 'Dynamic'
    virtualNetworkSubnetId: bastionSubnetId!
    publicIPSkuName: 'Standard'
    publicIPSkuTier: 'Regional'
    enableDiagnostics: settings.diagnostics.enabled
    diagnosticStorageAccountId: diagnosticStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}

@description('Azure Bastion Host ID output')
output AZURE_BASTION_HOST_ID string = azureBastion!.outputs.AZURE_BASTION_HOST_ID

@description('Azure Bastion Host Name output')
output AZURE_BASTION_HOST_NAME string = azureBastion!.outputs.AZURE_BASTION_HOST_NAME
