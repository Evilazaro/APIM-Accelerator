import * as Identity from 'identity-types.bicep'

@export()
type Settings = {
  resourceGroup: string
  name: string
  identity: Identity.IdentityAPIM
  sku: {
    name: 'BasicV2' | 'Consumption' | 'Developer' | 'Isolated' | 'Premium' | 'StandardV2' 
    capacity: int
    zones: array
  }
  publisherEmail: string
  publisherName: string
}
