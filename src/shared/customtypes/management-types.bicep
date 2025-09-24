@description('Settings object referencing a Log Analytics workspace used for centralized platform and APIM telemetry queries.')
type LogAnalyticsSettings = {
  name: string
}

@description('Settings object referencing an Application Insights resource used for APIM request, dependency, and performance telemetry.')
type AppInsightsSettings = {
  name: string
}

@export()
@description('Composite observability settings grouping resource group and references to Log Analytics and Application Insights for the APIM Landing Zone.')
type Settings = {
  resourceGroup: {
    createNew: bool
    name: string
  }
  logAnalytics: LogAnalyticsSettings
  applicationInsights: AppInsightsSettings
}
