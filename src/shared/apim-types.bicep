import * as Identity from '../shared/identity-types.bicep'

@export()
type Settings = {
  name: string
  identity: Identity.Identity
  sku: {
    name: 'BasicV2' | 'Consumption' | 'Developer' | 'Isolated' | 'Premium' | 'StandardV2' 
    capacity: int
    zones: array
  }
  publisherEmail: string
  publisherName: string
}
