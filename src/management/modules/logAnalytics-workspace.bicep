@description('Name of the Log Analytics Workspace')
@minLength(3)
@maxLength(63)
param name string

@description('Location for all resources.')
param location string

@description('Tags to be applied to all resources.')
param tags object

@description('Log Analytics Workspace resource')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
}

@description('Log Analytics Workspace ID output')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace Name output')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.name
