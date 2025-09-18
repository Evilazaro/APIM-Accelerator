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
type SystemAssignedIdentity = {
  scope: {
    type: 'subscription' | 'resourceGroup'
    name: string // Required if type is resourceGroup
  }
  rbacRoleAssignment: RBACRoleAssignment
}

@export()
type Identity = {
  type: IdentityType
  systemAssigned: SystemAssignedIdentity
  userAssigned: UserAssignedIdentity
}

type Roles = {
  roleName: string
  id: string
}

@export()
type RBACRoleAssignment = {
  roles: Roles[]
}

@export()
type SharedIdentity = {
  resourceGroup: string
  usersAssigned: UserAssignedIdentity[]
}
