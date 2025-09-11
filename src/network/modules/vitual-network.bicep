@description('Name of the Virtual Network that will host APIM and related networking resources')
@minLength(3)
@maxLength(80)
param name string

@description('Azure region where the Virtual Network and all related resources will be deployed')
param location string

@description('Array of IPv4 CIDR address ranges that define the Virtual Network address space')
param addressPrefixes array

@description('Object containing subnet definitions for private endpoints, API Management, and Application Gateway')
param subnets object

@description('Boolean flag to enable Virtual Network encryption for enhanced security')
param enableEncryption bool

@description('Boolean flag to enable diagnostic logging and monitoring for the Virtual Network')
param enableDiagnostics bool

@description('Configuration object for DDoS Protection Plan including enablement flag and resource name')
param ddosProtectionConfig DdosProtection

param publicIpAddress string

@description('Resource identifier of the Log Analytics Workspace for collecting diagnostic logs and metrics')
param logAnalyticsWorkspaceId string

@description('Resource identifier of the Storage Account for archiving diagnostic data')
param diagnosticStorageAccountId string

@description('Key-value pairs of metadata tags to apply to all Virtual Network resources')
param tags object

type DdosProtection = {
  enabled: bool
  name: string
}

@description('Azure DDoS Protection Plan resource to protect the Virtual Network against DDoS attacks')
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-07-01' = if (ddosProtectionConfig.enabled) {
  name: ddosProtectionConfig.name
  location: location
  tags: tags
}

var privateEndPointNsgRules = loadJsonContent('../../../infra/settings/nsgrules/private-endpoint-nsg-rules.json')

@description('Network Security Group for Private Endpoint subnet with rules loaded from external JSON configuration')
resource privateEndPointNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: subnets.privateEndpoint.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: privateEndPointNsgRules
  }
}

var apiManagementNsgRules = loadJsonContent('../../../infra/settings/nsgrules/apim-nsg-rules.json')

@description('Network Security Group for API Management subnet with rules for APIM service communication and dependencies')
resource apiManagementNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: subnets.apiManagement.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: apiManagementNsgRules
  }
}

var applicationGatewayNsgRules = loadJsonContent('../../../infra/settings/nsgrules/application-gateway-nsg-rules.json')
var customRules = [
  {
    name: 'AllowClientTrafficToSubnet'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRanges: [
        '80'
        '443'
      ]
      sourceAddressPrefix: '*'
      destinationAddressPrefix: subnets.applicationGateway.addressPrefix
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowClientTrafficToFrontendIP'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRanges: [
        '80'
        '443'
      ]
      sourceAddressPrefix: '*'
      destinationAddressPrefix: publicIpAddress
      access: 'Allow'
      priority: 111
      direction: 'Inbound'
    }
  }
]

@description('Network Security Group for Application Gateway subnet with rules for web traffic and health probes')
resource applicationGatewayNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: subnets.applicationGateway.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: union(applicationGatewayNsgRules, customRules)
  }
}

@description('Virtual Network resource with encryption, DDoS protection, and multiple subnets for APIM infrastructure')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    encryption: (enableEncryption)
      ? {
          enabled: enableEncryption
          enforcement: 'AllowUnencrypted'
        }
      : null
    ddosProtectionPlan: {
      id: ddosProtectionConfig.enabled ? ddosProtectionPlan.id : null
    }
  }
}

@description('Name of the deployed Virtual Network resource for reference by other modules')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.name

@description('Resource identifier of the deployed Virtual Network for subnet and resource association')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.id

@description('Private Endpoint subnet resource with dedicated address space and associated Network Security Group')
resource privateNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: subnets.privateEndpoint.name
  parent: virtualNetwork
  properties: {
    addressPrefix: subnets.privateEndpoint.addressPrefix
    networkSecurityGroup: {
      id: privateEndPointNsg.id
      properties: {
        securityRules: privateEndPointNsgRules
      }
    }
  }
}

@description('API Management subnet resource with dedicated address space and associated Network Security Group for APIM service')
resource apiManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: subnets.apiManagement.name
  parent: virtualNetwork
  properties: {
    addressPrefix: subnets.apiManagement.addressPrefix
    networkSecurityGroup: {
      id: apiManagementNsg.id
      properties: {
        securityRules: apiManagementNsgRules
      }
    }
  }
}

@description('Application Gateway subnet resource with dedicated address space and associated Network Security Group for web traffic routing')
resource applicationGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: subnets.applicationGateway.name
  parent: virtualNetwork
  properties: {
    addressPrefix: subnets.applicationGateway.addressPrefix
    networkSecurityGroup: {
      id: applicationGatewayNsg.id
      properties: {
        securityRules: applicationGatewayNsgRules
      }
    }
  }
}

@description('Diagnostic settings resource to enable logging and monitoring for the Virtual Network')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: virtualNetwork
  name: '${name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
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
  dependsOn: [
    virtualNetwork
  ]
}
