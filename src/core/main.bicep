import { ApiManagement } from '../shared/common-types.bicep'
import { generateUniqueSuffix } from '../shared/constants.bicep'

param solutionName string
param location string
param apiManagementSettings ApiManagement
param logAnalyticsWorkspaceId string
param storageAccountResourceId string
param applicationInsIghtsResourceId string
param tags object

// Optimized: Use centralized unique suffix function
var uniqueSuffix = generateUniqueSuffix(subscription().id, resourceGroup().id, resourceGroup().name, solutionName, location)

// Optimized: Constant for API Management suffix
var apimSuffix = 'apim'

// Optimized: Simplified naming logic using coalesce
var apimName = apiManagementSettings.name ?? '${solutionName}-${uniqueSuffix}-${apimSuffix}'

module apim 'apim.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    tags: tags
    applicationInsIghtsResourceId: applicationInsIghtsResourceId
    identityType: apiManagementSettings.identity.type
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    storageAccountResourceId: storageAccountResourceId
    publisherEmail: apiManagementSettings.publisherEmail
    publisherName: apiManagementSettings.publisherName
    skuCapacity: apiManagementSettings.sku.capacity
    skuName: apiManagementSettings.sku.name
    userAssignedIdentities: apiManagementSettings.identity.userAssignedIdentities
  }
}

output API_MANAGEMENT_RESOURCE_ID string = apim.outputs.API_MANAGEMENT_RESOURCE_ID
output API_MANAGEMENT_NAME string = apim.outputs.API_MANAGEMENT_NAME

module providers 'workspaces.bicep' = [
  for item in apiManagementSettings.workspaces: {
    name: item.name
    scope: resourceGroup()
    params: {
      name: item.name
      apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    }
  }
]

module devPortal 'developer-portal.bicep' = {
  name: 'deploy-developer-portal'
  scope: resourceGroup()
  params: {
    apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    clientId: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    clientSecret: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
  }
}
