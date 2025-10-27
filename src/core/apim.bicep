param name string

param location string
@allowed([
  'Basic'
  'BasicV2'
  'Developer'
  'Isolated'
  'Standard'
  'StandardV2'
  'Premium'
  'Consumption'
])
param skuName string
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'None'
])
param identityType string
param userAssignedIdentities array
param skuCapacity int
param publisherEmail string
param publisherName string
param logAnalyticsWorkspaceId string
param ApplicationInsightsResourceId string
param enableDeveloperPortal bool = true
param publicNetworkAccess bool = true
@allowed([
  'External'
  'Internal'
  'None'
])
param virtualNetworkType string = 'None'
param subnetResourceId string = ''
param tags object

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  identity: (identityType != 'None')
    ? {
        type: identityType
        userAssignedIdentities: (identityType == 'UserAssigned' && !empty(userAssignedIdentities))
          ? toObject(userAssignedIdentities, id => id, id => {})
          : null
      }
    : null
  tags: tags
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    developerPortalStatus: (enableDeveloperPortal) ? 'Enabled' : 'Disabled'
    publicNetworkAccess: (publicNetworkAccess) ? 'Enabled' : 'Disabled'
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: (virtualNetworkType != 'None' && !empty(subnetResourceId))
      ? {
          subnetResourceId: subnetResourceId
        }
      : null
  }
}

output API_MANAGEMENT_RESOURCE_ID string = apim.id
output API_MANAGEMENT_NAME string = apim.name

var roles = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, resourceGroup().name, apim.id, apim.name, role)
    scope: resourceGroup()
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      principalId: apim.identity.principalId
      principalType: 'ServicePrincipal'
    }
    dependsOn: [
      apim
    ]
  }
]

resource clientSecret 'Microsoft.ManagedIdentity/identities@2025-01-31-preview' existing = {
  scope: apim
  name: 'default'
  dependsOn: [
    apim
  ]
}

output AZURE_CLIENT_SECRET_ID string = clientSecret.id
output AZURE_CLIENT_SECRET_NAME string = clientSecret.name
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = clientSecret.properties.principalId
output AZURE_CLIENT_SECRET_CLIENT_ID string = clientSecret.properties.clientId
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = apim.identity.principalId

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${apim.name}-diag'
  scope: apim
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource appInsightsDiagnostic 'Microsoft.ApiManagement/service/diagnostics@2024-10-01-preview' = {
  name: 'name'
  parent: apim
  properties: {
    loggerId: logAnalyticsWorkspaceId
  }
}

resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2024-10-01-preview' = {
  name: 'looger'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    resourceId: ApplicationInsightsResourceId
    credentials: {
      instrumentationKey: reference(ApplicationInsightsResourceId, '2020-02-02').properties.InstrumentationKey
    }
  }
}
