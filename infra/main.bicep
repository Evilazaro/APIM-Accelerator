targetScope = 'subscription'
param environmentName string
param location string

var settings = loadYamlContent('./settings.yaml')

module monitoring '../src/shared/resources/monitoring/monitoring.bicep' = {
  name: 'deploy-monitoring'
  params: {
    solutionName: settings.solutionName
    environmentName: environmentName
    location: location
    tags: settings.tags
  }
}
