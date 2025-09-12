@description('Azure region where all network infrastructure resources will be deployed')
param location string

@description('Key-value pairs of metadata tags to apply to all network resources')
param tags object

param enableDiagnostics bool

@description('Resource identifier of Log Analytics Workspace for collecting VNet diagnostic logs and metrics')
param logAnalyticsWorkspaceId string

@description('Resource identifier of Storage Account for archiving VNet diagnostic data')
param diagnosticStorageAccountId string

// Load network settings from the external YAML file
var settings = loadYamlContent('../../infra/settings/network.yaml')

@description('Static public IP address with zone redundancy for Azure Firewall and Application Gateway frontend access')
resource publicIP 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${settings.name}-pip'
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: ['1', '2', '3']
}

@description('Azure DDoS Protection Plan resource to protect the Virtual Network against DDoS attacks')
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-07-01' = if (settings.security.ddosProtection.enable) {
  name: settings.security.ddosProtection.name
  location: location
  tags: tags
}

@description('Network security rules for private endpoint subnet traffic control')
var privateEndPointNsgRules = loadJsonContent('../../infra/settings/nsgrules/private-endpoint-nsg-rules.json')

@description('Network Security Group for Private Endpoint subnet to control inbound and outbound traffic for private connectivity')
resource privateEndPointNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: settings.connectivity.ipAddresses.subnets.privateEndpoint.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: privateEndPointNsgRules
  }
}

@description('Network security rules for API Management subnet enabling required APIM service communication')
var apiManagementNsgRules = loadJsonContent('../../infra/settings/nsgrules/apim-nsg-rules.json')

@description('Network Security Group for API Management subnet with rules for APIM service communication and dependencies')
resource apiManagementNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: settings.connectivity.ipAddresses.subnets.apiManagement.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: apiManagementNsgRules
  }
}

@description('Network security rules for Application Gateway subnet enabling web traffic and health probe access')
var applicationGatewayNsgRules = loadJsonContent('../../infra/settings/nsgrules/application-gateway-nsg-rules.json')

@description('Custom security rules for Application Gateway allowing client traffic to subnet and frontend IP')
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
      destinationAddressPrefix: settings.connectivity.ipAddresses.subnets.applicationGateway.addressPrefix
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
      destinationAddressPrefix: '${publicIP.properties.ipAddress}/32'
      access: 'Allow'
      priority: 111
      direction: 'Inbound'
    }
  }
]

@description('Network Security Group for Application Gateway subnet with rules for web traffic and health probes')
resource applicationGatewayNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: settings.connectivity.ipAddresses.subnets.applicationGateway.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: union(applicationGatewayNsgRules, customRules)
  }
}

@description('Virtual Network resource with encryption, DDoS protection, and multiple subnets for APIM infrastructure')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: settings.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: settings.connectivity.ipAddresses.addressSpaces
    }
    encryption: (settings.security.encryption.enable)
      ? {
          enabled: settings.security.encryption.enable
          enforcement: 'AllowUnencrypted'
        }
      : null
    ddosProtectionPlan: {
      id: settings.security.ddosProtection.enable ? ddosProtectionPlan.id : null
    }
  }
  dependsOn: [
    privateEndPointNsg
    applicationGatewayNsg
    apiManagementNsg
  ]
}

output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.id
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.name

@description('Private Endpoint subnet resource with dedicated address space and associated Network Security Group')
resource privateNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: settings.connectivity.ipAddresses.subnets.privateEndpoint.name
  parent: virtualNetwork
  properties: {
    addressPrefix: settings.connectivity.ipAddresses.subnets.privateEndpoint.addressPrefix
    networkSecurityGroup: {
      id: privateEndPointNsg.id
      properties: {
        securityRules: privateEndPointNsgRules
      }
    }
  }
  dependsOn: [
    privateEndPointNsg
    virtualNetwork
  ]
}

output AZURE_PRIVATE_NETWORK_SUBNET_ID string = privateNetworkSubnet.id
output AZURE_PRIVATE_NETWORK_SUBNET_NAME string = privateNetworkSubnet.name

@description('API Management subnet resource with dedicated address space and associated Network Security Group for APIM service')
resource apiManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: settings.connectivity.ipAddresses.subnets.apiManagement.name
  parent: virtualNetwork
  properties: {
    addressPrefix: settings.connectivity.ipAddresses.subnets.apiManagement.addressPrefix
    networkSecurityGroup: {
      id: apiManagementNsg.id
      properties: {
        securityRules: apiManagementNsgRules
      }
    }
  }
  dependsOn: [
    apiManagementNsg
    virtualNetwork
  ]
}

@description('Application Gateway subnet resource with dedicated address space and associated Network Security Group for web traffic routing')
resource applicationGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: settings.connectivity.ipAddresses.subnets.applicationGateway.name
  parent: virtualNetwork
  properties: {
    addressPrefix: settings.connectivity.ipAddresses.subnets.applicationGateway.addressPrefix
    networkSecurityGroup: {
      id: applicationGatewayNsg.id
      properties: {
        securityRules: applicationGatewayNsgRules
      }
    }
  }
  dependsOn: [
    applicationGatewayNsg
    virtualNetwork
  ]
}

@description('Azure Firewall subnet resource with dedicated address space')
resource azureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: settings.connectivity.ipAddresses.subnets.azureFirewall.name
  parent: virtualNetwork
  properties: {
    addressPrefix: settings.connectivity.ipAddresses.subnets.azureFirewall.addressPrefix
  }
  dependsOn: [
    apiManagementNsg
    privateEndPointNsg
    applicationGatewayNsg
    virtualNetwork
  ]
}

@description('Diagnostic settings resource to enable logging and monitoring for the Virtual Network')
resource vnetDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: virtualNetwork
  name: '${settings.name}-diagnostics'
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

@description('Azure Firewall with Standard tier for network security, traffic filtering, and centralized network protection')
resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-07-01' = {
  name: settings.security.azureFirewall.name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'firewallPubIPConfig'
        id: publicIP.id
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: azureFirewallSubnet.id
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    azureFirewallSubnet
  ]
}

@description('Diagnostic settings to route Azure Firewall logs and metrics to Log Analytics workspace and storage account for security monitoring')
resource firewallDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: azureFirewall
  name: '${azureFirewall.name}-diagnostics'
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
    azureFirewall
  ]
}


