@export()
type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None'

@export()
type UserAssignedIdentity = {
  name: string
  scope: {
    type: 'subscription' | 'resourceGroup'
    name: string // Required if type is resourceGroup
  }
  rbacRoleAssignment: RBACRoleAssignment
}

@export()
type Identity = {
  type: IdentityType
  rbacRoleAssignment: RBACRoleAssignment
  userAssignedIdentities: UserAssignedIdentity[]
}

type Roles = {
  roleName: string
  id: string
}

type RBACRoleAssignment = {
  roles: Roles[]
}

@export()
type IdentitySettings = {
  resourceGroup: string
  userAssignedIdentities: UserAssignedIdentity[]
}
