import * as Identity from 'identity-types.bicep'

type LogAnalyticsSettings = {
  name: string
  identity: Identity.Identity
}

type AppInsightsSettings = {
  name: string
}

@export() 
type Settings = {
  createNew: bool
  resourceGroup: string
  subscriptionId: string
  logAnalytics: LogAnalyticsSettings
  applicationInsights: AppInsightsSettings
}
