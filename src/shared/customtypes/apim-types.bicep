import * as Identity from 'identity-types.bicep'

@export()
@description('Azure API Management configuration settings for Landing Zone deployment.')
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
