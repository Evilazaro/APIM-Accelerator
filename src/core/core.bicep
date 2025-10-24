metadata name = 'Workload API Management Platform'
metadata description = 'This module deploys the Workload API Management platform.'

param solutionName string
param location string
param appInsightsResourceId string
param appInsightsInstrumentationKey string
param logAnalyticsWorkspaceId string
param tags object

var workloadSettings = loadYamlContent('../../infra/workload.yaml')

var apimName = (empty(workloadSettings.apiManagement.name))
  ? '${solutionName}-${uniqueString(subscription().id, resourceGroup().id, resourceGroup().name, solutionName,location)}-apim'
  : workloadSettings.apiManagement.name

module platform 'api-management.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    publisherEmail: workloadSettings.apiManagement.publisherEmail
    publisherName: workloadSettings.apiManagement.publisherName
    appInsightsResourceId: appInsightsResourceId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    tags: tags
  }
}

output AZURE_API_MANAGEMENT_ID string = platform.outputs.AZURE_API_MANAGEMENT_ID
output AZURE_API_MANAGEMENT_NAME string = platform.outputs.AZURE_API_MANAGEMENT_NAME

// var apiCenterName = (empty(workloadSettings.apiCenter.name))
//   ? '${solutionName}-${uniqueString(subscription().id, resourceGroup().id, resourceGroup().name, solutionName,location)}-apicenter'
//   : workloadSettings.apiCenter.name

// module inventory 'api-center.bicep' = {
//   name: 'deploy-api-center'
//   scope: resourceGroup()
//   params: {
//     name: apiCenterName
//     apiManagementName: platform.outputs.AZURE_API_MANAGEMENT_NAME
//     apiManagementResourceId: platform.outputs.AZURE_API_MANAGEMENT_ID
//     tags: tags
//   }
//   dependsOn: [
//     platform
//   ]
// }

// output AZURE_API_CENTER_ID string = inventory.outputs.AZURE_API_CENTER_ID
// output AZURE_API_CENTER_NAME string = inventory.outputs.AZURE_API_CENTER_NAME
