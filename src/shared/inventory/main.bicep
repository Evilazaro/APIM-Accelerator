import { Inventory } from '../common-types.bicep'
param solutionName string
param location string = 'eastus'
param inventorySettings Inventory
param tags object

var apiCenterSettings = inventorySettings.apiCenter

var apiCenterName = apiCenterSettings.name != ''
  ? apiCenterSettings.name
  : '${solutionName}-apicenter-${uniqueString(resourceGroup().id)}'

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
