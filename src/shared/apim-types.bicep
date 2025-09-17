import * as Identity from '../shared/identity-types.bicep'

@export()
type Settings = {
  name: string
  identity: Identity.Identity
  sku: {
    name: 'Developer' | 'Basic' | 'Standard' | 'Premium' | 'Consumption'
    capacity: int
    zones: array
  }
  publisherEmail: string
  publisherName: string
}
