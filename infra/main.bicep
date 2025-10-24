targetScope = 'subscription'
param environmentName string
param location string

var settings = loadYamlContent('./settings.yaml')

var resourceGroupName = (empty(settings.resourceGroup.name))
  ? '${settings.solutionName}-${environmentName}-${location}-rg'
  : settings.resourceGroup.name

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: settings.tags
}

module identity '../src/shared/resources/identity/main.bicep' = {
  name: 'deploy-identity'
  scope: resourceGroup
  params: {
    solutionName: settings.solutionName
    location: location
  }
}

output AZURE_CLIENT_SECRET_ID string = identity.outputs.AZURE_CLIENT_SECRET_ID
output AZURE_CLIENT_SECRET_NAME string = identity.outputs.AZURE_CLIENT_SECRET_NAME
output AZURE_CLIENT_SECRET_PRINCIPAL_ID string = identity.outputs.AZURE_CLIENT_SECRET_PRINCIPAL_ID
output AZURE_CLIENT_SECRET_CLIENT_ID string = identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
output AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID string = identity.outputs.AZURE_API_MANAGEMENT_IDENTITY_PRINCIPAL_ID

module monitoring '../src/shared/resources/monitoring/main.bicep' = {
  name: 'deploy-monitoring'
  scope: resourceGroup
  params: {
    solutionName: settings.solutionName
    location: location
    tags: settings.tags
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
output AZURE_APPLICATION_INSIGHTS_ID string = monitoring.outputs.AZURE_APPLICATION_INSIGHTS_ID
output AZURE_APPLICATION_INSIGHTS_NAME string = monitoring.outputs.AZURE_APPLICATION_INSIGHTS_NAME

module core '../src/core/main.bicep' = {
  name: 'deploy-core'
  scope: resourceGroup
  params: {
    solutionName: settings.solutionName
    location: location
    appInsightsResourceId: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_ID
    appInsightsInstrumentationKey: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
    logAnalyticsWorkspaceId: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    clientSecretClientId: identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    identityProviderClientId: identity.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    tags: settings.tags
  }
}

output AZURE_API_MANAGEMENT_ID string = core.outputs.AZURE_API_MANAGEMENT_ID
output AZURE_API_MANAGEMENT_NAME string = core.outputs.AZURE_API_MANAGEMENT_NAME
