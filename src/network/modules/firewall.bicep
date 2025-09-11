@description('Name of the Azure Firewall')
param name string

@description('Location of the Azure Firewall')
param location string

@description('Name of the virtual network where the Azure Firewall will be deployed')
param virtualNetworkName string

@description('Subnet Name for the Azure Firewall')
param azureFirewallSubnetName string

@description('Public IP Name for the Azure Firewall')
param publicIPName string

@description('Enable diagnostics for the Azure Firewall')
param enableDiagnostics bool

@description('Log Analytics Workspace ID for diagnostics (optional)')
param logAnalyticsWorkspaceId string

@description('Storage Account ID for diagnostics (optional)')
param diagnosticStorageAccountId string

@description('Tags for the Azure Firewall')
param tags object

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: 'vnet/subnet'
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-07-01' existing = {
  name: publicIPName
}

@description('Azure Firewall Resource')
resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'firewallPubIPConfig'
        id: publicIP.id
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

@description('Azure Firewall Name output')
output AZURE_FIREWALL_NAME string = azureFirewall.name

@description('Azure Firewall ID output')
output AZURE_FIREWALL_ID string = azureFirewall.id

@description('Diagnostics settings for the Azure Firewall')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: azureFirewall
  name: '${name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        categoryGroup: 'allLogs'
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
    azureFirewall
  ]
}
