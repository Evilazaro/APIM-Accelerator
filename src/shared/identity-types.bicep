@export()
type IdentityType = 'SystemAssigned' | 'UserAssigned' | 'None'

@export()
type UserAssignedIdentity = {
  name: string
}

@export()
type Identity = {
  type: IdentityType
  userAssignedIdentities: UserAssignedIdentity[]
}
