@description('Location for the Network Security Group')
param location string

@description('Network Security Groups')
param nsgs array

@description('Tags for the Network Security Group')
param tags object

@description('Network Security Group Resource')
resource securityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = [
  for nsg in nsgs: {
    name: nsg.name
    location: location
    tags: tags
  }
]

@description('Network Security Group IDs output')
output AZURE_NETWORK_SECURITY_GROUP_IDs array = [for (item, index) in nsgs: securityGroup[index].id]
