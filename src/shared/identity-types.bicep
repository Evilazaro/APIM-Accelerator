@export()
type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None'

@export()
type UserAssignedIdentity = {
  name: string
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
  scope: {
    type: 'subscription' | 'resourceGroup' | 'resource'
    name: string
  }
}

type RBACRoleAssignment = {
  roles: Roles[]
}
