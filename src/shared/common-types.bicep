// Optimized: Reusable identity type definitions
type SystemAssignedIdentity = {
  type: 'SystemAssigned' | 'UserAssigned'
  userAssignedIdentities: []
}

type ExtendedIdentity = {
  type: 'SystemAssigned' | 'UserAssigned' | 'SystemAssigned, UserAssigned' | 'None'
  userAssignedIdentities: []
}

// Optimized: APIM SKU type definition
type ApimSku = {
  name: 'Basic' | 'BasicV2' | 'Developer' | 'Isolated' | 'Standard' | 'StandardV2' | 'Premium' | 'Consumption'
  capacity: int
}

type LogAnalytics = {
  name: string
  workSpaceResourceId: string
  identity: SystemAssignedIdentity
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
  sku: ApimSku
  identity: SystemAssignedIdentity
  workspaces: array
}

type ApiCenter = {
  name: string
  identity: ExtendedIdentity
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
