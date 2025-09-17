type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None'

type UserAssignedIdentity = {
  name: string
}

type Identity = {
  type: IdentityType
  userAssignedIdentities: UserAssignedIdentity[]
  rbacRoleAssignment: {
    roles: RBACRole[]
  }
}

@export()
type Settings = {
  name: string
  identity: Identity
  sku: {
    name: 'Developer' | 'Basic' | 'Standard' | 'Premium' | 'Consumption'
    capacity: int
    zones: array
  }
  publisherEmail: string
  publisherName: string
}

type RBACRole = {
  roleName: string
  scope: {
    type: 'subscription' | 'resourceGroup' | 'resource'
    name: string
  }
}
