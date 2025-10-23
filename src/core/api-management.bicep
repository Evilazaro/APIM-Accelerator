metadata name = 'API Management'
metadata description = 'This module deploys an API Management resource.'

param name string
param location string
param publisherEmail string
param publisherName string
param tags object

resource apiManagement 'Microsoft.ApiManagement/service@2024-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    developerPortalStatus: 'Enabled'
  }
}

output AZURE_API_MANAGEMENT_ID string = apiManagement.id
output AZURE_API_MANAGEMENT_NAME string = apiManagement.name
