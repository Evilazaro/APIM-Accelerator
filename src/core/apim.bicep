import * as APIM from '../shared/customtypes/apim-types.bicep'

param location string
param apiManagement APIM.Settings
param publicNetworkAccess bool
param virtualNetworkName string
param virtualNetworkResourceGroup string
param appInsightsName string
param logAnalyticsWorkspaceName string
param monitoringResourceGroupName string
param subnetName string
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitoringResourceGroupName)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup(monitoringResourceGroupName)
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

var apiManagementIdentityResourceIds = [
  for identity in apiManagement.identity.usersAssigned.identities: resourceId(
    apiManagement.identity.usersAssigned.resourceGroup,
    'Microsoft.ManagedIdentity/userAssignedIdentities',
    identity.name
  )
]

resource apim 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: apiManagement.name
  location: location
  tags: tags
  zones: (apiManagement.sku.name == 'Premium') ? apiManagement.sku.zones : null
  identity: {
    type: apiManagement.identity.type
    userAssignedIdentities: toObject(apiManagementIdentityResourceIds, arg => arg, arg => {})
  }
  sku: {
    name: apiManagement.sku.name
    capacity: apiManagement.sku.capacity
  }
  properties: {
    publisherEmail: apiManagement.publisherEmail
    publisherName: apiManagement.publisherName
    virtualNetworkType: publicNetworkAccess ? 'External' : 'Internal'
    virtualNetworkConfiguration: (!publicNetworkAccess)
      ? {
          subnetResourceId: apimSubnet.id
        }
      : null
  }
}

resource apimAppInsightsLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
  parent: apim
  name: 'AppInsightsLogger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsights.id
    credentials: {
      instrumentationKey: appInsights.properties.InstrumentationKey
    }
  }
}

resource apimlogToAnalytics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apim
  name: 'logToAnalytics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
