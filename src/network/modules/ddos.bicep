@description('Name of the DDoS Protection Plan')
param name string

@description('Location of the DDoS Protection Plan')
param location string

@description('Enable diagnostics for the Azure DDoS Protection Plan')
param enableDiagnostics bool

@description('Log Analytics Workspace ID for diagnostics (optional)')
param logAnalyticsWorkspaceId string

@description('Storage Account ID for diagnostics (optional)')
param diagnosticStorageAccountId string

@description('Tags for the DDoS Protection Plan')
param tags object

@description('DDoS Protection Plan resource')
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-07-01' = {
  name: name
  location: location
  tags: tags
}

@description('DDoS Protection Plan ID output')
output DDOS_PROTECTION_PLAN_ID string = ddosProtectionPlan.id

@description('DDoS Protection Plan Name output')
output DDOS_PROTECTION_PLAN_NAME string = ddosProtectionPlan.name

@description('Diagnostics settings for the Azure DDoS Protection Plan')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: ddosProtectionPlan
  name: '${name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'AllLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
  dependsOn: [
    ddosProtectionPlan
  ]
}
