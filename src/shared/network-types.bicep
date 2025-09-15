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
  privateEndpoint: Subnet
  apiManagement: Subnet
  applicationGateway: Subnet
  azureFirewall: Subnet
}

@export()
type VirtualNetwork = {
  name: string
  addressPrefixes: string[]
  subnets: Subnets
}
