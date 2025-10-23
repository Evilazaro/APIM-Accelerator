metadata name = 'Workload API Management Platform'
metadata description = 'This module deploys the Workload API Management platform.'

param solutionName string
param location string
param appInsightsInstrumentationKey string
param appInsightsResourceId string
param tags object

var workloadSettings = loadYamlContent('../../infra/workload.yaml')

var apimName = (empty(workloadSettings.apiManagement.name))
  ? '${solutionName}-apim'
  : workloadSettings.apiManagement.name

module corePlatform 'api-management.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    publisherEmail: workloadSettings.apiManagement.publisherEmail
    publisherName: workloadSettings.apiManagement.publisherName
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    appInsightsResourceId: appInsightsResourceId
    tags: tags
  }
}

output AZURE_API_MANAGEMENT_ID string = corePlatform.outputs.AZURE_API_MANAGEMENT_ID
output AZURE_API_MANAGEMENT_NAME string = corePlatform.outputs.AZURE_API_MANAGEMENT_NAME

var apiCenterName = (empty(workloadSettings.apiCenter.name))
  ? '${solutionName}-apicenter'
  : workloadSettings.apiCenter.name

module governance 'api-center.bicep' = {
  name: 'deploy-api-center'
  scope: resourceGroup()
  params: {
    name: apiCenterName
    apiManagementName: corePlatform.outputs.AZURE_API_MANAGEMENT_NAME
    tags: tags
  }
  dependsOn: [
    corePlatform
  ]
}
