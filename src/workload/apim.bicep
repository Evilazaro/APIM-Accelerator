import * as IdentityTypes from '../shared/identity-types.bicep'
param location string
param apiManagement ApiManagementSettings
param publicNetworkAccess bool
param virtualNetworkName string
param virtualNetworkResourceGroup string
param appInsightsName string
param logAnalyticsWorkspaceName string
param monitoringResourceGroupName string
param subnetName string
param tags object

type ApiManagementSettings = {
  resourceGroup: string
  name: string
  identity: IdentityTypes.Identity
  sku: {
    name: 'Developer' | 'Basic' | 'Standard' | 'Premium' | 'Consumption'
    capacity: int
    zones: array
  }
  publisherEmail: string
  publisherName: string
}

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

resource apim 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: apiManagement.name
  location: location
  tags: tags
  zones: (apiManagement.sku.name == 'Premium') ? apiManagement.sku.zones : null
  identity: {
    type: apiManagement.identity.type
  }
  sku: {
    name: apiManagement.sku.name
    capacity: apiManagement.sku.capacity
  }
  properties: {
    publisherEmail: apiManagement.publisherEmail
    publisherName: apiManagement.publisherName
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
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

resource apimLogAnalyticsLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
  name: 'LogAnalyticsLogger'
  parent: apim
  properties: {
    loggerType: 'azureMonitor'
    resourceId: logAnalyticsWorkspace.id
  }
}

resource apimlogToAnalytics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apim
  name: 'logToAnalytics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'GatewayLogs'
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
