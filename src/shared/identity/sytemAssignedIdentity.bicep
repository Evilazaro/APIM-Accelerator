import * as Identity from '../identity-types.bicep'

param principalId string
param systemAssignedIdentity Identity.SystemAssignedIdentity

module roleAssignmentsSub 'roleAssignmentSub.bicep' = if (systemAssignedIdentity.scope.type == 'subscription') {
  name: 'roleAssignment-systemAssignedSub'
  scope: subscription()
  params: {
    principalId: principalId
    roles: systemAssignedIdentity.rbacRoleAssignment.roles
  }
}

module roleAssignmentsRg 'roleAssignmentRg.bicep' = if (systemAssignedIdentity.scope.type == 'resourceGroup') {
  name: 'roleAssignment-systemAssignedRg'
  scope: resourceGroup(systemAssignedIdentity.scope.name)
  params: {
    principalId: principalId
    roles: systemAssignedIdentity.rbacRoleAssignment.roles
  }
}
