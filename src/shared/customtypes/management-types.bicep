type LogAnalyticsSettings = {
  name: string
}

type AppInsightsSettings = {
  name: string
}

@export()
type Settings = {
  resourceGroup: string
  logAnalytics: LogAnalyticsSettings
  applicationInsights: AppInsightsSettings
}
