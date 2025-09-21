@export()
@description('Subnet configuration with address space and network security group association.')
type Subnet = {
  name: string
  addressPrefix: string
  networkSecurityGroup: NetworkSecurityGroup
}

@description('Network security group configuration with security rules for traffic control.')
type NetworkSecurityGroup = {
  name: string
}

@description('Virtual network configuration with address spaces and subnet definitions.')
type VirtualNetwork = {
  name: string
  addressPrefixes: string[]
  subnets: {
    apiManagement: Subnet
    applicationGateway: Subnet
  }
}

@export()
@description('Networking configuration settings for APIM Landing Zone network topology.')
type Settings = {
  resourceGroup: string
  publicNetworkAccess: bool
  virtualNetwork: VirtualNetwork
}
