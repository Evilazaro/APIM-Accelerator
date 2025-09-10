targetScope = 'subscription'

@description('Location for all resources')
param location string

param dateTime string = utcNow('yyyyMMddHHmmss')

@description('Deploy the network resources')
module network '../src/network/network.bicep' = {
  name: 'network-${dateTime}'
  params: {
    location: location
  }
}
