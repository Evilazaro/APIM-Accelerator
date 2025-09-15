param domain string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param privateIPAddresse string
param tags object

resource apimVnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}
resource dnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: '${domain}.azure-api.net'
  location: 'global'
  tags: tags
}

resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: apimVnet.name
  parent: dnsZone
  location: 'global'
  tags: tags
  properties: {
    virtualNetwork: {
      id: apimVnet.id
    }
    registrationEnabled: false
  }
}

resource gatewayRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: dnsZone
  name: '@'
  dependsOn: [
    dnsZone
  ]
  properties: {
    aRecords: [
      {
        ipv4Address: privateIPAddresse
      }
    ]
    ttl: 36000
  }
}

resource developerRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: dnsZone
  name: 'developer'
  dependsOn: [
    dnsZone
  ]
  properties: {
    aRecords: [
      {
        ipv4Address: privateIPAddresse
      }
    ]
    ttl: 36000
  }
}
