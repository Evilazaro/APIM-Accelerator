param privateEndpoints_fdsfsa_name string = 'fdsfsa'
param storageAccounts_apimacceleratorstorage_externalid string = '/subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/apim-monitoring-rg/providers/Microsoft.Storage/storageAccounts/apimacceleratorstorage'
param virtualNetworks_apimplatvnet_externalid string = '/subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/apim-connectivity-rg/providers/Microsoft.Network/virtualNetworks/apimplatvnet'
param privateDnsZones_privatelink_blob_core_windows_net_externalid string = '/subscriptions/6a4029ea-399b-4933-9701-436db72883d4/resourceGroups/apim-connectivity-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'

resource privateEndpoints_fdsfsa_name_resource 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: privateEndpoints_fdsfsa_name
  location: 'westus3'
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoints_fdsfsa_name
        id: '${privateEndpoints_fdsfsa_name_resource.id}/privateLinkServiceConnections/${privateEndpoints_fdsfsa_name}'
        properties: {
          privateLinkServiceId: storageAccounts_apimacceleratorstorage_externalid
          groupIds: [
            'blob'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${privateEndpoints_fdsfsa_name}-nic'
    subnet: {
      id: '${virtualNetworks_apimplatvnet_externalid}/subnets/privateEndPointSubnet'
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource privateEndpoints_fdsfsa_name_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  name: '${privateEndpoints_fdsfsa_name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZones_privatelink_blob_core_windows_net_externalid
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints_fdsfsa_name_resource
  ]
}
