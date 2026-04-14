// =================================================================
// AZURE BICEP COMMON TYPE DEFINITIONS
// =================================================================
// This module defines reusable type definitions for consistent
// parameter and object structures across the APIM accelerator.
// These types ensure type safety and standardization.
//
// File: src/shared/common-types.bicep
// Purpose: Centralized type definitions for API Management solution
// Dependencies: None (foundational module)
//
// USAGE:
// Import this module in other Bicep files to use the type definitions:
// - import { ApiManagement, Inventory, Monitoring, Shared } from 'common-types.bicep'
//
// EXPORTED TYPES:
// - ApiManagement: Configuration for Azure API Management service
// - Inventory: Configuration for API Center and inventory management
// - Monitoring: Configuration for monitoring infrastructure (Log Analytics + App Insights)
// - Shared: Configuration for shared infrastructure services
//
// INTERNAL TYPES:
// - SystemAssignedIdentity: System or user-assigned managed identity
// - ExtendedIdentity: Extended identity supporting multiple configurations
// - ApimSku: API Management SKU and capacity settings
// - LogAnalytics: Log Analytics workspace configuration
// - ApplicationInsights: Application Insights monitoring configuration
// - ApiCenter: API Center service configuration
// - CorePlatform: Platform configuration placeholder
//
// DESIGN PRINCIPLES:
// - Type safety: Strongly typed configurations prevent runtime errors
// - Reusability: Types can be imported and reused across modules
// - Consistency: Standardized structures across the solution
// - Documentation: Comprehensive descriptions for all properties
// =================================================================

// =================================================================
// IDENTITY TYPE DEFINITIONS
// =================================================================

@description('System-assigned or User-assigned managed identity configuration')
type SystemAssignedIdentity = {
  @description('Type of managed identity - SystemAssigned or UserAssigned')
  type: 'SystemAssigned' | 'UserAssigned'
  @description('Array of user-assigned identity resource IDs (empty for system-assigned)')
  userAssignedIdentities: []
}

@description('Extended identity configuration supporting multiple identity types including None')
type ExtendedIdentity = {
  @description('Type of managed identity including combined and none options')
  type: 'SystemAssigned' | 'UserAssigned' | 'SystemAssigned, UserAssigned' | 'None'
  @description('Array of user-assigned identity resource IDs')
  userAssignedIdentities: []
}

// =================================================================
// SERVICE CONFIGURATION TYPES
// =================================================================

@description('API Management service SKU configuration')
type ApimSku = {
  @description('API Management pricing tier')
  name: 'Basic' | 'BasicV2' | 'Developer' | 'Isolated' | 'Standard' | 'StandardV2' | 'Premium' | 'Consumption'
  @description('Number of scale units for the service')
  capacity: int
}

// =================================================================
// MONITORING SERVICE TYPES
// =================================================================

@description('Log Analytics workspace configuration')
type LogAnalytics = {
  @description('Name of the Log Analytics workspace')
  name: string
  @description('Resource ID of the Log Analytics workspace')
  workSpaceResourceId: string
  @description('Managed identity configuration for Log Analytics')
  identity: SystemAssignedIdentity
}

@description('Application Insights configuration')
type ApplicationInsights = {
  @description('Name of the Application Insights instance')
  name: string
  @description('Resource ID of the associated Log Analytics workspace')
  logAnalyticsWorkspaceResourceId: string
}

// =================================================================
// CORE SERVICE TYPES
// =================================================================

@description('API Management service configuration')
@export()
type ApiManagement = {
  @description('Name of the API Management service')
  name: string
  @description('Publisher email address for API Management')
  publisherEmail: string
  @description('Publisher organization name')
  publisherName: string
  @description('SKU configuration for API Management service')
  sku: ApimSku
  @description('Managed identity configuration')
  identity: SystemAssignedIdentity
  @description('Array of workspace configurations')
  workspaces: array
}

@description('API Center service configuration')
type ApiCenter = {
  @description('Name of the API Center service')
  name: string
  @description('Managed identity configuration for API Center')
  identity: ExtendedIdentity
}

@description('Core platform configuration placeholder')
type CorePlatform = {}

// =================================================================
// COMPOSITE CONFIGURATION TYPES
// =================================================================

@description('Inventory management configuration including API Center settings')
@export()
type Inventory = {
  @description('API Center service configuration')
  apiCenter: ApiCenter
  @description('Resource tags for governance and cost tracking')
  tags: object
}

@description('Monitoring infrastructure configuration')
@export()
type Monitoring = {
  @description('Log Analytics workspace configuration')
  logAnalytics: LogAnalytics
  @description('Application Insights configuration')
  applicationInsights: ApplicationInsights
  @description('Resource tags for governance and cost tracking')
  tags: object
}

@description('Shared infrastructure configuration')
@export()
type Shared = {
  @description('Monitoring services configuration')
  monitoring: Monitoring
  @description('Resource tags for governance and cost tracking')
  tags: object
}
