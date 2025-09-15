param principalId string
param roleDefinitionName string
param scope object

module roleAssignmentRG 'role-assignment-rg.bicep' = if (scope.type == 'resourceGroup') {
  name: 'roleAssignmentRG-${uniqueString(scope.name, principalId, roleDefinitionName)}'
  scope: resourceGroup(scope.name)
  params: {
    principalId: principalId
    roleDefinitionName: roleDefinitionName
  }
}
module roleAssignmentSub 'role-assignment-sub.bicep' = if (scope.type == 'subscription') {
  name: 'roleAssignmentSub-${uniqueString(subscription().id, principalId, roleDefinitionName)}'
  scope: subscription()
  params: {
    principalId: principalId
    roleDefinitionName: roleDefinitionName
  }
}
