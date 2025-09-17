import * as Identity from '../shared/identity-types.bicep'

param principalId string
param systemAssignedIdentity Identity.SystemAssignedIdentity

module roleAssignmentsSub 'roleAssignmentSub.bicep' = if (systemAssignedIdentity.scope.type == 'subscription') {
  name: 'roleAssignment-systemAssigned'
  scope: subscription()
  params: {
    principalId: principalId
    roles: systemAssignedIdentity.rbacRoleAssignment.roles
  }
}

module roleAssignmentsRg 'roleAssignmentRg.bicep' = if (systemAssignedIdentity.scope.type == 'resourceGroup') {
  name: 'roleAssignment-systemAssigned'
  scope: resourceGroup(systemAssignedIdentity.scope.name)
  params: {
    principalId: principalId
    roles: systemAssignedIdentity.rbacRoleAssignment.roles
  }
}
