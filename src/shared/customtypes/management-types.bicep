@description('Log Analytics workspace configuration for centralized logging and monitoring.')
type LogAnalyticsSettings = {
  name: string
}

@description('Application Insights configuration for performance monitoring and telemetry.')
type AppInsightsSettings = {
  name: string
}

@export()
@description('Management and monitoring configuration settings for APIM Landing Zone observability.')
type Settings = {
  resourceGroup: string
  logAnalytics: LogAnalyticsSettings
  applicationInsights: AppInsightsSettings
}
