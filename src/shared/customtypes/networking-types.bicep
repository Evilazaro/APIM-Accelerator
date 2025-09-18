@export()
type Subnet = {
  name: string
  addressPrefix: string
  networkSecurityGroup: NetworkSecurityGroup
}

type NetworkSecurityGroup = {
  name: string
  rules: array
}

type VirtualNetwork = {
  name: string
  addressPrefixes: string[]
  subnets: Subnet[]
}

@export()
type Settings = {
  resourceGroup: string
  publicNetworkAccess: bool
  virtualNetwork: VirtualNetwork
}
