param keyVaultName            string
param managedIdentity         object   

resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2024-11-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedIdentity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
        tenantId: managedIdentity.tenantId
      }
    ]
  }
}
