import * as APIM from '../shared/apim-types.bicep'

param location string
param apiManagement APIM.Settings
param publicNetworkAccess bool
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
  name: subnetName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

module userAssignedIdentity '../identity/userAssignedIdentity.bicep' = {
  name: 'apim-userAssignedIdentities'
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    userAssignedIdentity: apiManagement.identity.userAssigned
  }
}

// module systemAssignedIdentity '../identity/sytemAssignedIdentity.bicep' = {
//   name: 'apim-systemAssignedIdentities'
//   scope: resourceGroup()
//   params: {
//     principalId: apim.identity.principalId
//     systemAssignedIdentity: apiManagement.identity.systemAssigned
//   }
// }

// resource apim 'Microsoft.ApiManagement/service@2024-05-01' = {
//   name: apiManagement.name
//   location: location
//   tags: tags
//   zones: (apiManagement.sku.name == 'Premium') ? apiManagement.sku.zones : null
//   identity: {
//     type: apiManagement.identity.type
//   }
//   sku: {
//     name: apiManagement.sku.name
//     capacity: apiManagement.sku.capacity
//   }
//   properties: {
//     publisherEmail: apiManagement.publisherEmail
//     publisherName: apiManagement.publisherName
//     virtualNetworkType: publicNetworkAccess ? 'External' : 'Internal'
//     virtualNetworkConfiguration: (!publicNetworkAccess)
//       ? {
//           subnetResourceId: apimSubnet.id
//         }
//       : null
//   }
//   dependsOn: [
//     userAssignedIdentity
//   ]
// }

// resource apimAppInsightsLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
//   parent: apim
//   name: 'AppInsightsLogger'
//   properties: {
//     loggerType: 'applicationInsights'
//     resourceId: appInsights.id
//     credentials: {
//       instrumentationKey: appInsights.properties.InstrumentationKey
//     }
//   }
// }

// resource apimLogAnalyticsLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
//   name: 'LogAnalyticsLogger'
//   parent: apim
//   properties: {
//     loggerType: 'azureMonitor'
//     resourceId: logAnalyticsWorkspace.id
//     credentials: {
//       name: logAnalyticsWorkspace.name
//     }
//   }
// }

// resource apimlogToAnalytics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: apim
//   name: 'logToAnalytics'
//   properties: {
//     workspaceId: logAnalyticsWorkspace.id
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
//       }
//     ]
//   }
// }
