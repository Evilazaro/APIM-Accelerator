import * as Identity from 'identity-types.bicep'

@export()
type ApiManagementSettings = {
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
