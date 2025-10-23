metadata name = 'API Center'
metadata description = 'This module deploys an API Center resource.'

param name string
param location string = 'eastus'
param apiManagementName string
param apiManagementResourceId string
param tags object

@description('The name of an API to register in the API center.')
param apiName string = 'first-api'

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

resource apiCenterService 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: name
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

var roles = [
  '71522526-b88f-4d52-b57f-d31fc3546d0d'
]

resource apimRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(apiCenterService.id, apiCenterService.name, role)
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

resource apiCenterAPI 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: apiCenterWorkspace
  name: apiName
  properties: {
    title: apiName
    kind: apiType
    externalDocumentation: [
      {
        description: 'API Center documentation'
        title: 'API Center documentation'
        url: 'https://learn.microsoft.com/azure/api-center/overview'
      }
    ]
    contacts: [
      {
        email: 'apideveloper@contoso.com'
        name: 'API Developer'
        url: 'https://learn.microsoft.com/azure/api-center/overview'
      }
    ]
    customProperties: {}
    summary: 'This is a test API, deployed using a template!'
    description: 'This is a test API, deployed using a template!'
  }
}
