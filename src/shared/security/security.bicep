import * as Security from '../customtypes/key-vault-types.bicep'

@description('Azure region for Key Vault deployment, aligned with landing zone regional strategy.')
param location string

@description('Key Vault configuration containing name and security settings for APIM secrets management.')
param keyVault Security.KeyVault

@description('Controls public network access to Key Vault. Disable for zero-trust security compliance.')
param publicNetworkAccess bool

@description('Resource tags for governance, cost management, and operational tracking.')
param tags object

@description('Creates Azure Key Vault for secure storage of APIM secrets, certificates, and keys.')
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

@description('Key Vault name for referencing in APIM configurations and secret management integrations.')
output AZURE_KEY_VAULT_NAME string = apimKeyVault.name
