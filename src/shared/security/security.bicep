import * as Security from '../shared/key-vault-types.bicep'

param location string
param keyVault Security.KeyVault
param publicNetworkAccess bool
param tags object

resource apimKeyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVault.name
  location: location
  tags: tags
  properties: {
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    tenantId: subscription().tenantId
  }
}

output AZURE_KEY_VAULT_NAME string = apimKeyVault.name
