param location string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param keyVault KeyVaultSettings
param publicNetworkAccess bool
param tags object

type KeyVaultSettings = {
  name: string
}

resource keyVaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource apimKeyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVault.name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAcls: (!publicNetworkAccess) ? {
      virtualNetworkRules: [
        {
          id: keyVaultSubnet.id
        }
      ]
    }: null
    tenantId: subscription().tenantId
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = if (publicNetworkAccess) {
  name: '${apimKeyVault.name}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: keyVaultSubnet.id
      name: keyVaultSubnet.name
    }
    applicationSecurityGroups: [
      {
        id: keyVaultSubnet.properties.networkSecurityGroup.id
      }
    ]
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          groupId: 'vault'
          privateIPAddress: keyVaultSubnet.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}
