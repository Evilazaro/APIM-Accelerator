@export()
@description('Enumeration of supported managed identity configurations (system, user, combined, or none) used across Landing Zone resources.')
type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None' | 'SystemAssigned, UserAssigned'

@export()
@description('User-assigned managed identity definition including deployment scope and RBAC role assignments to grant least-privilege access.')
type UserAssignedIdentity = {
  name: string
  scope: {
    type: 'subscription' | 'resourceGroup' | 'deploymentScript'
    name: string // Required if type is resourceGroup
  }
  rbacRoleAssignment: RBACRoleAssignment
}

@export()
@description('API Management specific collection of user-assigned identities (resource group + identity names) for service integration scenarios.')
type UserAssignedApim = {
  resourceGroup: string
  identities: {
    name: string
  }[]
}

@export()
@description('System-assigned managed identity scope definition plus RBAC role assignments automatically bound to the hosting resource.')
type SystemAssignedIdentity = {
  scope: {
    type: 'subscription' | 'resourceGroup'
    name: string // Required if type is resourceGroup
  }
  rbacRoleAssignment: RBACRoleAssignment
}

@export()
@description('Generic identity wrapper pairing selected identity type with optional system-assigned identity settings.')
type Identity = {
  type: IdentityType
  systemAssigned: SystemAssignedIdentity
}

@export()
@description('Composite API Management identity configuration supporting system-assigned and user-assigned identities in a single model.')
type IdentityAPIM = {
  type: IdentityType
  systemAssigned: SystemAssignedIdentity
  usersAssigned: UserAssignedApim
}

@description('Azure RBAC role reference containing display name and unique role definition identifier.')
type Role = {
  roleName: string
  id: string
}

@export()
@description('Collection of RBAC role references to be assigned to the managed identity at its declared scope.')
type RBACRoleAssignment = {
  roles: Role[]
}

@export()
@description('Shared user-assigned identity grouping reused across multiple services (resource group context + identity list).')
type SharedIdentity = {
  resourceGroup: string
  usersAssigned: UserAssignedIdentity[]
}
