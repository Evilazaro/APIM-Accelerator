import { Inventory } from '../shared/common-types.bicep'
param solutionName string
param location string = 'eastus'
param inventorySettings Inventory
param apiManagementName string
param apiManagementResourceId string
param tags object

var apiCenterSettings = inventorySettings.apiCenter

var apiCenterName = apiCenterSettings.name != ''
  ? apiCenterSettings.name
  : '${solutionName}-apicenter-${uniqueString(resourceGroup().id)}'

resource apiCenter 'Microsoft.ApiCenter/services@2024-06-01-preview' = {
  name: apiCenterName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  identity: (apiCenterSettings.identity.type != 'None')
    ? {
        type: apiCenterSettings.identity.type
        userAssignedIdentities: ((apiCenterSettings.identity.type == 'UserAssigned' || apiCenterSettings.identity.type == 'SystemAssigned, UserAssigned') && !empty(apiCenterSettings.identity.userAssignedIdentities))
          ? toObject(apiCenterSettings.identity.userAssignedIdentities, id => id, id => {})
          : null
      }
    : null
}

var roles = [
  '71522526-b88f-4d52-b57f-d31fc3546d0d'
]

resource apimRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(
      subscription().id,
      resourceGroup().id,
      resourceGroup().name,
      apiCenter.id,
      apiCenter.name,
      role
    )
    scope: resourceGroup()
    properties: {
      principalId: apiCenter.identity.principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    }
  }
]

resource apiCenterWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenter
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
