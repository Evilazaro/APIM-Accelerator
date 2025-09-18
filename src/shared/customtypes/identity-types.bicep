@export()
type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None' | 'SystemAssigned, UserAssigned'

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
type UserAssignedApim = {
  resourceGroup: string
  identities: {
    name: string
  }[]
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
}

@export()
type IdentityAPIM = {
  type: IdentityType
  systemAssigned: SystemAssignedIdentity
  usersAssigned: UserAssignedApim
}

type Role = {
  roleName: string
  id: string
}

@export()
type RBACRoleAssignment = {
  roles: Role[]
}

@export()
type SharedIdentity = {
  resourceGroup: string
  usersAssigned: UserAssignedIdentity[]
}
