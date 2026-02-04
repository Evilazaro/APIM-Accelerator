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

/// The name parameter defines the workspace identifier.
/// This value is used for both the resource name and display name.
/// Requirements:
/// - Must be unique within the API Management service
/// - Should follow naming conventions for Azure resources
/// - Recommended format: lowercase with hyphens (e.g., 'dev-workspace')
@description('Name of the workspace to create - used for both resource name and display name')
param name string

/// The apiManagementName parameter references the parent APIM service.
/// This must be an existing API Management service in the same subscription.
/// The workspace will be created as a child resource of this service.
@description('Name of the existing API Management service where workspace will be created')
param apiManagementName string

// =================================================================
// EXISTING RESOURCES
// =================================================================

/// References the existing API Management service resource.
/// This symbolic name is used to establish the parent-child relationship
/// between the APIM service and the workspace being created.
/// The 'existing' keyword indicates this resource already exists in Azure.
@description('Reference to existing API Management service')
resource apim 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementName
}

/// Creates an API Management workspace resource.
/// Workspaces provide isolated environments for organizing APIs and enabling
/// collaborative development workflows within a single APIM instance.
/// 
/// Key benefits:
/// - Logical separation of APIs and resources
/// - Team-based access control and collaboration
/// - Independent lifecycle management for different API sets
/// - Multi-tenant scenarios within a single APIM service
///
/// The workspace is created as a child resource of the APIM service,
/// inheriting the service's region and configuration settings.
@description('API Management workspace - Provides isolated environment for API development and management')
resource apimWorkspaces 'Microsoft.ApiManagement/service/workspaces@2025-03-01-preview' = {
  name: name
  parent: apim
  properties: {
    /// The displayName appears in the Azure portal and APIM developer portal.
    /// Using the same value as 'name' for consistency.
    displayName: name

    /// The description provides additional context about the workspace purpose.
    /// Consider customizing this in future iterations to be more descriptive.
    description: 'Workspace for API development and management'
  }
}
