
type LogAnalyticsSettings = {
  name: string
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
