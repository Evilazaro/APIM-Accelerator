type LogAnalytics = {
  name: string
  workSpaceResourceId: string
  identity: {
    type: 'SystemAssigned' | 'UserAssigned'
    userAssignedIdentities: []
  }
}

type ApplicationInsights = {
  name: string
  logAnalyticsWorkspaceResourceId: string
}

@export()
type ApiManagement = {
  name: string
  publisherEmail: string
  publisherName: string
  sku: {
    name: 'Basic' | 'BasicV2' | 'Developer' | 'Isolated' | 'Standard' | 'StandardV2' | 'Premium' | 'Consumption'
    capacity: int
  }
  identity: {
    type: 'SystemAssigned' | 'UserAssigned'
    userAssignedIdentities: []
  }
}

type ApiCenter = {
  name: string
  identity: {
    type: 'SystemAssigned' | 'UserAssigned' | 'SystemAssigned, UserAssigned' | 'None'
    userAssignedIdentities: []
  }
}

type CorePlatform = {}

@export()
type Inventory = {
  apiCenter: ApiCenter
  tags: object
}

@export()
type Monitoring = {
  logAnalytics: LogAnalytics
  applicationInsights: ApplicationInsights
  tags: object
}

@export()
type Shared = {
  monitoring: Monitoring
  tags: object
}
