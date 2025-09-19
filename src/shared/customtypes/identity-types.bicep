@export()
@description('Supported Azure managed identity types for Landing Zone resources.')
type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None' | 'SystemAssigned, UserAssigned'

@export()
@description('User-assigned managed identity configuration with scope and RBAC role assignments.')
type UserAssignedIdentity = {
  name: string
  scope: {
    type: 'subscription' | 'resourceGroup'
    name: string // Required if type is resourceGroup
  }
  rbacRoleAssignment: RBACRoleAssignment
}

@export()
@description('APIM-specific user-assigned identity configuration for service integration.')
type UserAssignedApim = {
  resourceGroup: string
  identities: {
    name: string
  }[]
}

@export()
@description('System-assigned managed identity configuration with scope and RBAC assignments.')
type SystemAssignedIdentity = {
  scope: {
    type: 'subscription' | 'resourceGroup'
    name: string // Required if type is resourceGroup
  }
  rbacRoleAssignment: RBACRoleAssignment
}

@export()
@description('Generic identity configuration supporting system-assigned managed identities.')
type Identity = {
  type: IdentityType
  systemAssigned: SystemAssignedIdentity
}

@export()
@description('APIM identity configuration supporting both system and user-assigned identities.')
type IdentityAPIM = {
  type: IdentityType
  systemAssigned: SystemAssignedIdentity
  usersAssigned: UserAssignedApim
}

@description('Azure RBAC role definition with name and identifier.')
type Role = {
  roleName: string
  id: string
}

@export()
@description('RBAC role assignment configuration for managed identity permissions.')
type RBACRoleAssignment = {
  roles: Role[]
}

@export()
@description('Shared identity configuration for cross-service user-assigned identities.')
type SharedIdentity = {
  resourceGroup: string
  usersAssigned: UserAssignedIdentity[]
}
