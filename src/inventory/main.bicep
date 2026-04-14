/*
  ==================================================================================
  Module: API Inventory Management
  ==================================================================================
  
  Description: 
    Deploys and configures Azure API Center with API Management integration to
    provide centralized API catalog, governance, and inventory management capabilities.
  
  Purpose: 
    This module establishes a comprehensive API governance solution by:
    - Creating an Azure API Center service with configurable managed identity
    - Setting up a default workspace for API organization and collaboration
    - Integrating API Management service as an API source for automatic discovery
    - Assigning necessary RBAC roles for API Center operations
  
  Resources Created:
    1. Azure API Center Service (Microsoft.ApiCenter/services)
       - Centralized API catalog and governance platform
       - Configurable identity: None, SystemAssigned, UserAssigned, or both
       
    2. API Center Workspace (Microsoft.ApiCenter/services/workspaces)
       - Default workspace for organizing APIs
       - Provides collaboration and organizational structure
       
    3. API Source Integration (Microsoft.ApiCenter/services/workspaces/apiSources)
       - Links APIM service to API Center
       - Enables automatic API discovery and synchronization
       
    4. Role Assignments (Microsoft.Authorization/roleAssignments)
       - Grants API Center Data Reader role
       - Grants API Center Compliance Manager role
       - Enables service principal to access and manage inventory
  
  Dependencies:
    - Requires existing API Management service (resourceId must be provided)
    - Uses Inventory type from '../shared/common-types.bicep'
    - Requires resource group scope for deployment
  
  Security Considerations:
    - Managed identity configuration supports multiple identity types
    - RBAC roles are scoped to resource group level
    - Role assignments use deterministic GUIDs for idempotency
  
  Usage Example:
    module inventory './main.bicep' = {
      name: 'api-inventory-deployment'
      params: {
        solutionName: 'myapi'
        location: 'eastus'
        inventorySettings: inventoryConfig
        apiManagementName: 'myapi-apim'
        apiManagementResourceId: apimService.id
        tags: commonTags
      }
    }
  
  Version: 1.0.0
  Last Updated: 2024
  ==================================================================================
*/

import { Inventory } from '../shared/common-types.bicep'

// =================================================================
// PARAMETERS
// =================================================================
// Input parameters define the configuration for the API Center deployment.
// These values are provided by the calling module or deployment script.

@description('Solution name used for resource naming and identification. This serves as the base name for generated resource names.')
param solutionName string

@description('Azure region where API Center resources will be deployed. Default: eastus. Should match or be close to APIM location for optimal performance.')
param location string = 'eastus'

@description('Configuration settings for API inventory management. Contains nested apiCenter settings including identity configuration and custom naming.')
param inventorySettings Inventory

@description('Name of the API Management service to integrate with API Center. Used to name the API source resource.')
param apiManagementName string

@description('Resource ID of the API Management service for integration. Full ARM resource ID in format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ApiManagement/service/{name}')
param apiManagementResourceId string

@description('Tags to be applied to API Center resources for governance, cost tracking, and organization. Inherited from parent deployment.')
param tags object

// =================================================================
// These constants define fixed values used throughout the module for
// consistent naming, workspace configuration, and RBAC assignments.

// Resource naming and configuration constants
var apiCenterSuffix = 'apicenter' // Suffix appended to solution name for API Center naming (e.g., 'myapi-apicenter')
var defaultWorkspaceName = 'default' // Name of the default workspace created in API Center - standard naming convention
var defaultWorkspaceTitle = 'Default workspace' // Display title for the default workspace shown in portal
var defaultWorkspaceDescription = 'Default workspace' // Description for the default workspace providing context to users

// Azure RBAC role definition IDs for API Center access
// These are Azure built-in roles required for API Center operations.
// Role GUIDs are constant across all Azure subscriptions and regions.
var apiCenterReaderRoleId = '71522526-b88f-4d52-b57f-d31fc3546d0d' // API Center Data Reader - Allows reading API definitions and metadata
var apiCenterContributorRoleId = '6cba8790-29c5-48e5-bab1-c7541b01cb04' // API Center Compliance Manager - Allows managing compliance and governance

// =================================================================
// VARIABLES
// =================================================================
// Variables compute derived values from parameters and constants.
// They provide convenient references and implement naming logic.

// Extract nested API Center settings for cleaner code
// This provides a convenient reference to the nested settings object
var apiCenterSettings = inventorySettings.apiCenter

// Generate unique API Center name with fallback logic
// If a custom name is provided in settings, use it; otherwise, construct from solution name and suffix
// Pattern: {solutionName}-{apiCenterSuffix} (e.g., 'myapi-apicenter')
// Custom names override this pattern when explicitly provided
var apiCenterName = !empty(apiCenterSettings.?name) ? apiCenterSettings.name : '${solutionName}-${apiCenterSuffix}'
// The API Center service is the core resource that provides centralized
// API catalog, governance, and inventory management capabilities.

// =================================================================
// RESOURCES
// =================================================================

@description('Azure API Center service - Provides centralized API catalog and governance capabilities for discovering, managing, and governing APIs across the organization')
resource apiCenter 'Microsoft.ApiCenter/services@2024-06-01-preview' = {
  name: apiCenterName
  location: location
  tags: tags

  // Configure managed identity based on settings
  // Identity is required for the API Center to access APIM and other Azure resources
  // Supports four types:
  //   - None: No managed identity (role assignments will fail)
  //   - SystemAssigned: Azure creates and manages the identity automatically
  //   - UserAssigned: Uses pre-existing user-assigned managed identities
  //   - SystemAssigned, UserAssigned: Combines both types for flexibility
  identity: (apiCenterSettings.identity.type != 'None')
    ? {
        type: apiCenterSettings.identity.type
        userAssignedIdentities: (apiCenterSettings.identity.type == 'UserAssigned' || apiCenterSettings.identity.type == 'SystemAssigned, UserAssigned')
          ? (empty(apiCenterSettings.identity.userAssignedIdentities)
              ? null
              : apiCenterSettings.identity.userAssignedIdentities)
          : null
      }
    : null
}

// Define roles required for API Center operations
// These roles enable the API Center to read and manage API inventory across the resource group
var roles = [
  apiCenterReaderRoleId // Allows reading API definitions, metadata, and catalog information
  apiCenterContributorRoleId // Allows managing compliance, governance policies, and API lifecycle
]

@description('Role assignments for API Center service principal - Grants necessary permissions for API inventory operations, compliance management, and API discovery')
resource apimRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    // Generate deterministic GUID for idempotent role assignment
    // Uses subscription, resource group, API Center resource, and role ID to ensure uniqueness
    // Same inputs always produce same GUID, enabling idempotent deployments
    name: guid(subscription().id, resourceGroup().id, resourceGroup().name, apiCenter.id, apiCenter.name, role)
    scope: resourceGroup()
    properties: {
      principalId: apiCenter.identity.principalId // System-assigned managed identity's principal ID
      principalType: 'ServicePrincipal' // Indicates this is a service principal (managed identity)
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role) // Full resource ID of the role definition
    }
  }
]

// Workspaces organize APIs and provide collaboration spaces within API Center.
// API sources connect external API providers (like APIM) for automatic discovery.

@description('Default workspace for API Center - Organizes APIs and provides collaboration space for teams to discover, document, and govern APIs')
resource apiCenterWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenter
  name: defaultWorkspaceName
  properties: {
    title: defaultWorkspaceTitle // User-friendly display name shown in portal
    description: defaultWorkspaceDescription // Descriptive text explaining workspace purpose
  }
}

@description('API source integration - Links API Management service to API Center for automated inventory discovery and synchronization. Enables automatic import of APIs from APIM.')
resource apiResource 'Microsoft.ApiCenter/services/workspaces/apiSources@2024-06-01-preview' = {
  name: apiManagementName // Name of API source (matches APIM service name for clarity)
  parent: apiCenterWorkspace // Nested under the default workspace
  properties: {
    // Configure APIM as the source for automatic API discovery and inventory synchronization
    // API Center will automatically discover and import APIs from the specified APIM instance
    azureApiManagementSource: {
      resourceId: apiManagementResourceId // Full ARM resource ID of the APIM instance to integrate
    }
  }
}
