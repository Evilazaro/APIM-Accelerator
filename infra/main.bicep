targetScope = 'subscription'

@description('Location for all resources')
var location = 'East US'

@description('Deploy the network resources')
module network '../src/network/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
  }
}
