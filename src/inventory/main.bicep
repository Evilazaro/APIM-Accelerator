import { Inventory } from '../shared/common-types.bicep'

param solutionName string
param location string = 'eastus'
param inventorySettings Inventory
param apiManagementName string
param apiManagementResourceId string
param tags object

// Optimized: Constants for API Center configuration
var apiCenterSuffix = 'apicenter'
var defaultWorkspaceName = 'default'
var defaultWorkspaceTitle = 'Default workspace'
var defaultWorkspaceDescription = 'Default workspace'

// Optimized: Role definition constants for API Center
var apiCenterReaderRoleId = '71522526-b88f-4d52-b57f-d31fc3546d0d'
var apiCenterContributorRoleId = '6cba8790-29c5-48e5-bab1-c7541b01cb04'

var apiCenterSettings = inventorySettings.apiCenter

// Optimized: Simplified naming logic using coalesce
var apiCenterName = apiCenterSettings.name ?? '${solutionName}-${apiCenterSuffix}-${uniqueString(resourceGroup().id)}'

resource apiCenter 'Microsoft.ApiCenter/services@2024-06-01-preview' = {
  name: apiCenterName
  location: location
  tags: tags
  identity: (apiCenterSettings.identity.type != 'None')
    ? {
        type: apiCenterSettings.identity.type
        userAssignedIdentities: ((apiCenterSettings.identity.type == 'UserAssigned' || apiCenterSettings.identity.type == 'SystemAssigned, UserAssigned') && !empty(apiCenterSettings.identity.userAssignedIdentities))
          ? toObject(apiCenterSettings.identity.userAssignedIdentities, id => id, id => {})
          : null
      }
    : null
}

// Optimized: Use constants for role definitions
var roles = [
  apiCenterReaderRoleId
  apiCenterContributorRoleId
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
  name: defaultWorkspaceName
  properties: {
    title: defaultWorkspaceTitle
    description: defaultWorkspaceDescription
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
