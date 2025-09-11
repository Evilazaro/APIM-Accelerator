targetScope = 'subscription'

@description('Azure region where all network infrastructure resources will be deployed')
param location string

@description('Key-value pairs of metadata tags to apply to all network resources')
param tags object

@description('Resource identifier of Log Analytics Workspace for collecting VNet diagnostic logs and metrics')
param logAnalyticsWorkspaceId string

@description('Resource identifier of Storage Account for archiving VNet diagnostic data')
param diagnosticStorageAccountId string

@description('Timestamp string for unique resource naming in deployments')
param dateTime string = utcNow('yyyyMMddHHmmss')

// Load network settings from the external YAML file
var settings = loadYamlContent('../../infra/settings/network.yaml')

@description('Resource group for network infrastructure resources loaded from external YAML configuration')
resource networkRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.resourceGroup.name
  location: location
  tags: tags
}

@description('Module deployment for Public IP Address with static allocation and diagnostic monitoring')
module publicIP './modules/public-ip-address.bicep' = {
  name: 'PublicIP-${dateTime}'
  scope: networkRG
  params: {
    name: '${settings.name}-pip'
    location: location
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
    publicIPAddressVersion: 'IPv4'
    enableDiagnostics: settings.diagnostics.enabled
    diagnosticStorageAccountId: diagnosticStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

@description('Module deployment for Virtual Network with subnets, encryption, DDoS protection, and diagnostic monitoring')
module virtualNetwork 'modules/vitual-network.bicep' = {
  name: 'virtualNetwork-${dateTime}'
  scope: networkRG
  params: {
    name: settings.name
    location: location
    addressPrefixes: settings.ipAddresses.addressSpaces
    subnets: settings.ipAddresses.subnets
    publicIpAddress: publicIP.outputs.AZURE_PUBLIC_IP_ADDRESS
    enableDiagnostics: settings.diagnostics.enabled
    enableEncryption: settings.security.encryption.enabled
    ddosProtectionConfig: settings.security.ddosProtection
    diagnosticStorageAccountId: diagnosticStorageAccountId!
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

@description('Name of the deployed Virtual Network resource for reference by dependent infrastructure modules')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME

@description('Resource identifier of the deployed Virtual Network for subnet association and resource dependencies')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_ID

// @description('Module to create Azure Firewall')
// module azureFirewall './modules/firewall.bicep' = if (settings.security.azureFirewall.enabled) {
//   name: 'azureFirewall-${dateTime}'
//   scope: networkRG
//   params: {
//     name: settings.security.azureFirewall.name
//     location: location
//     virtualNetworkName: virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME
//     azureFirewallSubnetName: settings.security.azureFirewall.subnetName
//     skuName: settings.security.azureFirewall.sku
//     skuTier: settings.security.azureFirewall.tier
//     publicIPName: publicIP.outputs.AZURE_PUBLIC_IP_NAME
//     enableDiagnostics: settings.diagnostics.enabled
//     diagnosticStorageAccountId: diagnosticStorageAccountId!
//     logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
//     tags: tags
//   }
//   dependsOn: [
//     virtualNetwork
//     publicIP
//   ]
// }

// @description('Azure Firewall Name output')
// output AZURE_FIREWALL_NAME string = azureFirewall!.outputs.AZURE_FIREWALL_NAME

// @description('Azure Firewall ID output')
// output AZURE_FIREWALL_ID string = azureFirewall!.outputs.AZURE_FIREWALL_ID
