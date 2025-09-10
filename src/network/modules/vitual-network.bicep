@description('Name of the Virtual Network')
@minLength(3)
@maxLength(80)
param name string

@description('Location for all resources.')
param location string

@description('The address prefixes for the virtual network.')
param addressPrefixes array

@description('The subnets for the virtual network.')
param subnets array

@description('Enable Virtual network encryption')
param enableEncryption bool

@description('The resource ID of the DDoS Protection Plan to associate with the virtual network.')
param ddosProtectionPlanId string

@description('Enable diagnostics for the Virtual Network')
param enableDiagnostics bool

@description('Log Analytics Workspace ID for diagnostics (optional)')
param logAnalyticsWorkspaceId string

@description('Storage Account ID for diagnostics (optional)')
param diagnosticStorageAccountId string

@description('Tags for the Virtual Network')
param tags object

@description('Virtual Network Resource')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
    encryption: (enableEncryption)
      ? {
          enabled: enableEncryption
          enforcement: 'AllowUnencrypted'
        }
      : null
    ddosProtectionPlan: empty(ddosProtectionPlanId)
      ? null
      : {
          id: ddosProtectionPlanId
        }
  }
}

@description('Virtual Network Name output')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.name

@description('Virtual Network ID output')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.id

@description('Virtual Network Subnets output')
output AZURE_VIRTUAL_NETWORK_SUBNETS object[] = [
  for (item, index) in subnets: {
    name: item.name
    id: virtualNetwork.properties.subnets[index].id
  }
]

@description('Diagnostics settings for the Virtual Network')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: virtualNetwork
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
    virtualNetwork
  ]
}
