metadata name = 'Application Insights'
metadata description = 'This module deploys an Application Insights resource.'

param name string
param location string
param workspaceResourceId string
param tags object

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceResourceId
  }
}

output AZURE_APPLICATION_INSIGHTS_ID string = appInsights.id
output AZURE_APPLICATION_INSIGHTS_NAME string = appInsights.name
output AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = appInsights.properties.InstrumentationKey
