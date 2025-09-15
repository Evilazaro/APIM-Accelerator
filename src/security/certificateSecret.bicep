param keyVaultName string
param secretName   string

resource keyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2024-11-01' existing = {
  name: '${keyVaultName}/${secretName}'
}

output AZURE_APP_GATEWAY_CERTIFICATE_URI string = keyVaultCertificate.properties.secretUriWithVersion
