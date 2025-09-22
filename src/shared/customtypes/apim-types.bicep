import * as Identity from 'identity-types.bicep'

@export()
@description('Strongly-typed settings model for provisioning an Azure API Management instance (name, SKU/capacity/zones, managed identity, and publisher metadata) within the Landing Zone accelerator.')
type Settings = {
  resourceGroup: string
  name: string
  identity: Identity.IdentityAPIM
  sku: {
    name: 'BasicV2' | 'Consumption' | 'Developer' | 'Isolated' | 'Premium' | 'StandardV2'
    capacity: int
    zones: string[]
  }
  publisherEmail: string
  publisherName: string
}
