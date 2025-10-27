import { ApiManagement } from '../shared/common-types.bicep'

param solutionName string
param location string
param apiManagementSettings ApiManagement
param logAnalyticsWorkspaceId string
param ApplicationInsightsResourceId string
param tags object

var apimName = (!empty(apiManagementSettings.name))
  ? apiManagementSettings.name
  : '${solutionName}-${uniqueString(subscription().id, resourceGroup().id,resourceGroup().name, solutionName, location)}-apim'

module apim 'apim.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    tags: tags
    ApplicationInsightsResourceId: ApplicationInsightsResourceId
    identityType: apiManagementSettings.identity.type
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    publisherEmail: apiManagementSettings.publisherEmail
    publisherName: apiManagementSettings.publisherName
    skuCapacity: apiManagementSettings.sku.capacity
    skuName: apiManagementSettings.sku.name
    userAssignedIdentities: apiManagementSettings.identity.userAssignedIdentities
  }
}

output API_MANAGEMENT_RESOURCE_ID string = apim.outputs.API_MANAGEMENT_RESOURCE_ID
output API_MANAGEMENT_NAME string = apim.outputs.API_MANAGEMENT_NAME

module workspaces 'workspaces.bicep' = [
  for item in apiManagementSettings.workspaces: {
    name: item.name
    scope: resourceGroup()
    params: {
      name: item.name
      apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    }
  }
]

module developerPortal 'developer-portal.bicep' = {
  name: 'deploy-developer-portal'
  scope: resourceGroup()
  params: {
    tags: tags
    apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    clientId: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    clientSecret: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
  }
  dependsOn: [
    apim
  ]
}
