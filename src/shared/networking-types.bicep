type Subnet = {
  name: string
  addressPrefix: string
  networkSecurityGroup: NetworkSecurityGroup
}

type NetworkSecurityGroup = {
  name: string
}

@export()
type Subnets = {
  apiManagement: Subnet
  applicationGateway: Subnet
}

type VirtualNetwork = {
  name: string
  addressPrefixes: string[]
  subnets: Subnets
}

@export()
type Settings = {
  resourceGroup: string
  subscriptionId: string
  publicNetworkAccess: bool
  virtualNetwork: VirtualNetwork
}
