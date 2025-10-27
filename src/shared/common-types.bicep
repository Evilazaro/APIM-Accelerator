@export()
type LogAnalytics = {
  name: string
  workSpaceResourceId: string
  identity: {
    type: 'SystemAssigned' | 'UserAssigned'
    userAssignedIdentities: []
  }
}

@export()
type ApplicationInsights = {
  name: string
  logAnalyticsWorkspaceResourceId: string
}
