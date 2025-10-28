// =================================================================
// AZURE API MANAGEMENT WORKSPACES
// =================================================================
// This module creates API Management workspaces for organizing APIs
// and enabling collaborative development workflows.
//
// File: src/core/workspaces.bicep
// Purpose: Creates isolated workspaces within API Management service
// Dependencies: API Management service (existing resource)
// =================================================================

// =================================================================
// PARAMETERS
// =================================================================

@description('Name of the workspace to create - used for both resource name and display name')
param name string

@description('Name of the existing API Management service where workspace will be created')
param apiManagementName string

// =================================================================
// EXISTING RESOURCES
// =================================================================

@description('Reference to existing API Management service')
resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

// =================================================================
// API MANAGEMENT WORKSPACE
// =================================================================

@description('API Management workspace - Provides isolated environment for API development and management')
resource apimWorkspaces 'Microsoft.ApiManagement/service/workspaces@2024-10-01-preview' = {
  name: name
  parent: apim
  properties: {
    // Workspace display configuration
    displayName: name
    description: name
  }
}
