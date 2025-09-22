import * as Security from '../customtypes/key-vault-types.bicep'

@description('Azure region where the Key Vault will be deployed (aligned to Landing Zone regional strategy).')
param location string

@description('Strongly-typed Key Vault settings model (name reference) for APIM secret, key, and certificate storage.')
param keyVault Security.KeyVault

@description('Boolean flag controlling public network access to the Key Vault (disable to enforce zero‑trust posture).')
param publicNetworkAccess bool

@description('Standard resource tags applied for governance, cost management, and operational tracking.')
param tags object

@description('Azure Key Vault resource for secure storage of APIM secrets, keys, and TLS certificates (no access policies defined inline).')
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

@description('Outputs the Key Vault name for downstream APIM configuration and secret referencing.')
output AZURE_KEY_VAULT_NAME string = apimKeyVault.name
