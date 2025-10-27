param apiManagementName string
param providersSettings array

module providers '../providers/apim-workspace.bicep' = [
  for provider in providersSettings: {
    name: 'deploy-workspace-${provider.name}'
    scope: resourceGroup()
    params: {
      name: provider.name
      description: provider.description
      displayName: provider.displayName
      apiManagementName: apiManagementName
    }
  }
]
