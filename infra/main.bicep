targetScope = 'subscription'

param solutionName string
param envName string
param location string

var rgName = '${solutionName}-${envName}-${location}-rg'
var settings = loadYamlContent('settings.yaml')
var monitoringSettings = settings.shared.monitoring

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
}

module monitoring '../src/shared/monitoring/main.bicep' = {
  name: 'deploy-shared-monitoring'
  scope: rg
  params: {
    location: location
    tags: settings.shared.monitoring.tags
    applicationInsightsSettings: monitoringSettings.applicationInsights
    logAnalyticsSettings: monitoringSettings.logAnalytics
  }
}
