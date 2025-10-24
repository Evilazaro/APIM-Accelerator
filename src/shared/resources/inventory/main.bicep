metadata name = 'API Center'
metadata description = 'This module deploys an API Center resource.'

param solutionName string
param location string = 'eastus'
param apiManagementName string
param apiManagementResourceId string
param tags object

@description('The type of the API to register in the API center.')
@allowed([
  'rest'
  'soap'
  'graphql'
  'grpc'
  'webhook'
  'websocket'
])
param apiType string = 'rest'

var apiCenterName = '${solutionName}-${uniqueString(subscription().id, resourceGroup().id, resourceGroup().name, solutionName,location)}-apicenter'

resource apiCenterService 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: apiCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {}
}

output AZURE_API_CENTER_ID string = apiCenterService.id
output AZURE_API_CENTER_NAME string = apiCenterService.name

var roles = [
  '71522526-b88f-4d52-b57f-d31fc3546d0d'
]

resource apimRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(
      subscription().id,
      resourceGroup().id,
      resourceGroup().name,
      apiCenterService.id,
      apiCenterService.name,
      role
    )
    scope: resourceGroup()
    properties: {
      principalId: apiCenterService.identity.principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    }
  }
]

resource apiCenterWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenterService
  name: 'default'
  properties: {
    title: 'Default workspace'
    description: 'Default workspace'
  }
}

resource apiResource 'Microsoft.ApiCenter/services/workspaces/apiSources@2024-06-01-preview' = {
  name: apiManagementName
  parent: apiCenterWorkspace
  properties: {
    azureApiManagementSource: {
      resourceId: apiManagementResourceId
    }
  }
}
