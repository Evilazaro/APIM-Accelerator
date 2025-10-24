metadata name = 'API Management'
metadata description = 'This module deploys an API Management resource.'

param name string
param location string
param publisherEmail string
param publisherName string
param appInsightsResourceId string
param appInsightsInstrumentationKey string
param logAnalyticsWorkspaceId string
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    developerPortalStatus: 'Enabled'
  }
}

output AZURE_API_MANAGEMENT_ID string = apim.id
output AZURE_API_MANAGEMENT_NAME string = apim.name
output AZURE_API_MANAGEMENT_PRINCIPAL_ID string = apim.identity.principalId

module identity '../shared/resources/identity/main.bicep' = {
  name: 'deploy-apim-identity'
  scope: resourceGroup()
  params: {
    apiManagementName: apim.name
  }
}

output AZURE_CLIENT_SECRET_ID string = identity.outputs.AZURE_CLIENT_SECRET_ID
output AZURE_CLIENT_SECRET_NAME string = identity.outputs.AZURE_CLIENT_SECRET_NAME
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = identity.outputs.AZURE_CLIENT_SECRET_PRINCIPAL_ID
output AZURE_CLIENT_SECRET_CLIENT_ID string = identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = identity.outputs.AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID

module developerPortal 'apim-developer-portal.bicep' = {
  name: 'deploy-apim-developer-portal'
  scope: resourceGroup()
  params: {
    apiManagementName: apim.name
    clientSecretClientId: identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    identityProviderClientId: identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
  }
}

// resource apimDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: '${apim.name}-diag'
//   scope: apim
//   properties: {
//     workspaceId: logAnalyticsWorkspaceId

//     logAnalyticsDestinationType: 'Dedicated'

//     logs: [
//       {
//         categoryGroup: 'allLogs'
//         enabled: true
//       }
//     ]

//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//         timeGrain: null
//       }
//     ]
//   }
// }

// resource apimLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
//   name: '${apim.name}-logger'
//   parent: apim
//   properties: {
//     loggerType: 'applicationInsights'
//     description: 'Application Insights logger'
//     resourceId: appInsightsResourceId
//     isBuffered: true

//     credentials: {
//       instrumentationKey: appInsightsInstrumentationKey
//     }
//   }
// }
