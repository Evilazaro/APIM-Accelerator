@export()
@description('Subnet definition including CIDR prefix and associated Network Security Group for traffic filtering.')
type Subnet = {
  name: string
  addressPrefix: string
  networkSecurityGroup: NetworkSecurityGroup
}

@description('Network Security Group reference used to apply ingress and egress rules to attached subnets.')
type NetworkSecurityGroup = {
  name: string
}

@description('Virtual Network configuration specifying address space and required subnets (APIM and Application Gateway).')
type VirtualNetwork = {
  name: string
  addressPrefixes: string[]
  subnets: {
    apiManagement: Subnet
    applicationGateway: Subnet
  }
}

@export()
@description('Composite networking settings model (resource group, public access flag, and virtual network definition) for the APIM Landing Zone.')
type Settings = {
  resourceGroup: {
    createNew: bool
    name: string
  }
  publicNetworkAccess: bool
  virtualNetwork: VirtualNetwork
}
