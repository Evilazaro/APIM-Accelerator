import * as SubnetSettings from '../customtypes/networking-types.bicep'

param location string
param virtualNetworkName string
param subnet SubnetSettings.Subnet
param logAnalytcsWorkspaceName string
param monitoringStorageAccountName string
param monitoringResourceGroup string
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalytcsWorkspaceName
  scope: resourceGroup(monitoringResourceGroup)
}

resource monStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: monitoringStorageAccountName
  scope: resourceGroup(monitoringResourceGroup)
}

resource subnetNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnet.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: subnet.networkSecurityGroup.rules
  }
}

resource subnetNsgDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'apim-nsg-diag'
  scope: subnetNsg
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: monStorageAccount.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnet.name}'
  properties: {
    addressPrefix: subnet.addressPrefix
    networkSecurityGroup: {
      id: subnetNsg.id
    }
  }
  dependsOn: [
    subnetNsg
    subnetNsgDiag
  ]
}
