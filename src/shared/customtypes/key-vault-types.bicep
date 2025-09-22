@export()
@description('Settings model referencing an Azure Key Vault used to store API Management secrets, keys, and TLS certificates securely.')
type KeyVault = {
  name: string
}
