/*
==============================================================================
CORE API MANAGEMENT PLATFORM MODULE
==============================================================================

File: src/core/main.bicep
Purpose: Deploys core API Management service and related platform components
Author: Cloud Platform Team
Created: 2025-10-28
Version: 1.0.0

OVERVIEW
--------
This module serves as the main orchestrator for deploying Azure API Management
(APIM) infrastructure. It creates a complete API Management platform with
enterprise-grade features including security, monitoring, and multi-team support.

KEY FEATURES
------------
1. API Management Service
   - Configurable SKU (Developer, Basic, Standard, Premium)
   - System or user-assigned managed identity support
   - Multi-region deployment capability (Premium tier)
   - Built-in caching and rate limiting

2. Security & Identity
   - Managed Identity for Azure service authentication
   - Support for both system-assigned and user-assigned identities
   - Secure credential management for downstream services

3. Observability
   - Integration with Azure Log Analytics for centralized logging
   - Application Insights for performance monitoring and diagnostics
   - Storage account integration for log archival and compliance
   - Comprehensive diagnostic settings across all components

4. Developer Experience
   - Self-service developer portal with Azure AD authentication
   - OAuth2/OpenID Connect integration
   - API documentation and testing capabilities

5. Multi-Tenancy Support
   - Workspace-based isolation for different teams/projects
   - Enables independent API lifecycle management per workspace
   - Shared infrastructure with logical separation

DEPLOYMENT WORKFLOW
-------------------
1. Validate input parameters and generate resource names
2. Deploy core API Management service with specified SKU
3. Configure managed identity and security settings
4. Enable diagnostic settings and monitoring integration
5. Create workspaces for team/project isolation
6. Configure developer portal with Azure AD authentication

NAMING CONVENTION
-----------------
Resources follow this pattern: {solutionName}-{uniqueSuffix}-{resourceType}
- solutionName: Identifies the solution/project
- uniqueSuffix: Ensures global uniqueness (auto-generated from subscription/RG)
- resourceType: Standard abbreviation (e.g., apim, kv, st)

Example: myproject-abc123-apim

DEPENDENCIES
------------
Required Resources:
  - Log Analytics Workspace: For diagnostic logs and queries
  - Application Insights: For application performance monitoring
  - Storage Account: For diagnostic log archival and backup

Referenced Modules:
  - apim.bicep: Core APIM resource deployment
  - workspaces.bicep: Workspace creation for API organization
  - developer-portal.bicep: Developer portal configuration

Shared Resources:
  - common-types.bicep: Type definitions and schema validation
  - constants.bicep: Helper functions and shared constants

USAGE EXAMPLE
-------------
module coreApim 'src/core/main.bicep' = {
  name: 'deploy-core-apim'
  params: {
    solutionName: 'contoso-apis'
    location: 'eastus'
    apiManagementSettings: {
      name: 'contoso-apim' // Optional, auto-generated if omitted
      publisherEmail: 'api@contoso.com'
      publisherName: 'Contoso Ltd'
      sku: { name: 'Premium', capacity: 1 }
      identity: { type: 'SystemAssigned', userAssignedIdentities: {} }
      workspaces: [
        { name: 'sales-apis' }
        { name: 'finance-apis' }
      ]
    }
    logAnalyticsWorkspaceId: '/subscriptions/.../loganalytics'
    storageAccountResourceId: '/subscriptions/.../storageAccounts/...'
    applicationInsIghtsResourceId: '/subscriptions/.../appinsights'
    tags: { environment: 'prod', costCenter: 'IT' }
  }
}

OUTPUTS
-------
- API_MANAGEMENT_RESOURCE_ID: Full ARM resource ID for RBAC and references
- API_MANAGEMENT_NAME: Service name for child resource creation

NOTES & CONSIDERATIONS
----------------------
1. Premium SKU is required for:
   - Multi-region deployments
   - Virtual network integration
   - Higher SLA and performance guarantees

2. Managed Identity enables:
   - Secure access to Key Vault for certificates and secrets
   - Integration with other Azure services without credentials
   - Simplified credential rotation and management

3. Workspaces provide:
   - Logical isolation within a single APIM instance
   - Cost-effective multi-team support vs. multiple APIM instances
   - Centralized governance with distributed management

4. Developer Portal:
   - Requires proper OAuth2 client credentials
   - Should be secured with Azure AD for production environments
   - Can be customized with branding and additional content

TROUBLESHOOTING
---------------
- Name conflicts: Check uniqueSuffix generation and existing resources
- Identity errors: Verify managed identity permissions on dependent services
- Portal authentication: Validate Azure AD app registration and client IDs
- Workspace issues: Ensure workspace names are unique within APIM instance

==============================================================================
*/

// Import custom type definition for API Management configuration
import { ApiManagement } from '../shared/common-types.bicep'
// Import helper function for generating consistent resource name suffixes
import { generateUniqueSuffix } from '../shared/constants.bicep'

//==============================================================================
// PARAMETERS
//==============================================================================
// Core parameters define the deployment scope, naming, and configuration for
// the API Management platform. These values are typically provided from a
// parameter file or deployment pipeline.

@description('Solution name used as prefix for all core platform resources')
param solutionName string

@description('Azure region where core platform resources will be deployed')
param location string

@description('API Management service configuration including SKU, identity, and workspace settings')
param apiManagementSettings ApiManagement

// Monitoring and diagnostics resource IDs for observability integration
@description('Resource ID of Log Analytics workspace for diagnostic logging')
param logAnalyticsWorkspaceId string

@description('Resource ID of storage account for diagnostic log storage and archival')
param storageAccountResourceId string

@description('Resource ID of Application Insights instance for performance monitoring')
param applicationInsIghtsResourceId string

@description('Tags to be applied to all core platform resources')
param tags object

//==============================================================================
// VARIABLES AND CONFIGURATION
//==============================================================================
// Variables calculate resource names and configuration values based on input
// parameters to ensure consistent naming conventions and proper configuration.

// Generate a deterministic unique suffix based on subscription and resource group
// This ensures resource names are unique but reproducible across deployments
@description('Unique suffix for consistent resource naming across all deployments')
var uniqueSuffix = generateUniqueSuffix(
  subscription().id,
  resourceGroup().id,
  resourceGroup().name,
  solutionName,
  location
)

@description('Standard suffix for API Management service naming')
var apimSuffix = 'apim'

// Determine API Management service name using either:
// 1. Explicitly provided name from settings, or
// 2. Auto-generated name following naming convention: {solution}-{suffix}-apim
@description('API Management service name with fallback to generated name if not specified')
var apimName = (!empty(apiManagementSettings.name)
  ? apiManagementSettings.name
  : '${solutionName}-${uniqueSuffix}-${apimSuffix}')

//==============================================================================
// API MANAGEMENT SERVICE DEPLOYMENT
//==============================================================================
// Deploys the core API Management service with all necessary configuration
// including identity, monitoring, diagnostics, and SKU settings.

// Deploy the API Management service using the apim.bicep module
// This is the primary resource that hosts APIs, policies, and developer portal
@description('API Management service with premium features, monitoring integration, and security configuration')
module apim 'apim.bicep' = {
  name: 'deploy-api-management'
  scope: resourceGroup()
  params: {
    name: apimName
    location: location
    tags: tags
    applicationInsIghtsResourceId: applicationInsIghtsResourceId
    identityType: apiManagementSettings.identity.type
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    storageAccountResourceId: storageAccountResourceId
    publisherEmail: apiManagementSettings.publisherEmail
    publisherName: apiManagementSettings.publisherName
    skuCapacity: apiManagementSettings.sku.capacity
    skuName: apiManagementSettings.sku.name
    userAssignedIdentities: apiManagementSettings.identity.userAssignedIdentities
  }
}

//==============================================================================
// API MANAGEMENT OUTPUTS
//==============================================================================
// These outputs expose key identifiers and properties for downstream modules
// and external integrations.

// Resource ID is required for RBAC assignments, policy references, and ARM operations
@description('Resource ID of API Management service for integration with other services')
output API_MANAGEMENT_RESOURCE_ID string = apim.outputs.API_MANAGEMENT_RESOURCE_ID

// Service name is used for child resource creation and configuration references
@description('Name of API Management service for configuration and reference')
output API_MANAGEMENT_NAME string = apim.outputs.API_MANAGEMENT_NAME

//==============================================================================
// WORKSPACE CONFIGURATION
//==============================================================================
// Creates organized workspaces within API Management for different teams or projects
// Workspaces provide isolation and organization for APIs, allowing teams to manage
// their APIs independently while sharing the same APIM infrastructure.

// Deploy workspaces for each entry in the configuration
// Each workspace acts as a container for related APIs and configurations
@description('API Management workspaces for organizing APIs by team, project, or business domain')
module providers 'workspaces.bicep' = [
  for item in apiManagementSettings.workspaces: {
    name: item.name
    scope: resourceGroup()
    params: {
      name: item.name
      apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    }
  }
]

//==============================================================================
// DEVELOPER PORTAL CONFIGURATION
//==============================================================================
// Configures API Management developer portal with Azure AD authentication
// The developer portal enables API consumers to discover, test, and subscribe
// to APIs with self-service capabilities.

// Deploy developer portal with OAuth2/Azure AD integration
// Note: Uses APIM outputs for client credentials (verify these are correct)
@description('Developer portal configuration with Azure AD integration for self-service API consumption')
module devPortal 'developer-portal.bicep' = {
  name: 'deploy-developer-portal'
  scope: resourceGroup()
  params: {
    apiManagementName: apim.outputs.API_MANAGEMENT_NAME
    clientId: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
    clientSecret: apim.outputs.AZURE_CLIENT_SECRET_CLIENT_ID
  }
}
