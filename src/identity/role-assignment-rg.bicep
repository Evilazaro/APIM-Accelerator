param principalId string
param roleDefinitionName string

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: roleDefinitionName
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, roleDefinitionName, roleDefinition.id)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: 'ServicePrincipal'
  }
}
