param name string
param description string
param displayName string
param apiManagementName string

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

resource workspace 'Microsoft.ApiManagement/service/workspaces@2024-10-01-preview' = {
  parent: apim
  name: name
  properties: {
    description: description
    displayName: displayName
  }
}
