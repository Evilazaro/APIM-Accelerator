param name string
param apiManagementName string

resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

resource apimWorkspaces 'Microsoft.ApiManagement/service/workspaces@2024-10-01-preview' = {
  name: name
  parent: apim
  properties: {
    displayName: name
    description: name
  }
}
