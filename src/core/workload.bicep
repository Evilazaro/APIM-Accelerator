metadata name = 'Workload API Management Platform'
metadata description = 'This module deploys the Workload API Management platform.'

param solutionName string
param location string
param tags object

var apimSettings = loadYamlContent('../../infra/workload.yaml')

var apimName = (empty(apimSettings.name)) ? '${solutionName}-apim' : apimSettings.name

module corePlatform 'api-management.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    publisherEmail: apimSettings.publisherEmail
    publisherName: apimSettings.publisherName
    tags: tags
  }
}

output AZURE_API_MANAGEMENT_ID string = corePlatform.outputs.AZURE_API_MANAGEMENT_ID
output AZURE_API_MANAGEMENT_NAME string = corePlatform.outputs.AZURE_API_MANAGEMENT_NAME
