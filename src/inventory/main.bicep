// =================================================================
// AZURE API CENTER INVENTORY MANAGEMENT
// =================================================================
// This module deploys Azure API Center for API inventory and governance.
// It creates a centralized API catalog that integrates with API Management
// to provide comprehensive API lifecycle management.
//
// File: src/inventory/main.bicep
// Purpose: Deploys API Center service for API catalog and governance
// Dependencies: API Management service, shared common types
// =================================================================

import { Inventory } from '../shared/common-types.bicep'

// =================================================================
// PARAMETERS
// =================================================================

@description('Solution name used for resource naming and identification')
param solutionName string

@description('Azure region where API Center resources will be deployed')
param location string = 'eastus'

@description('Configuration settings for API inventory management')
param inventorySettings Inventory

@description('Name of the API Management service to integrate with API Center')
param apiManagementName string

@description('Resource ID of the API Management service for integration')
param apiManagementResourceId string

@description('Tags to be applied to API Center resources for governance')
param tags object

// =================================================================
// CONFIGURATION CONSTANTS
// =================================================================

// Resource naming and configuration constants
var apiCenterSuffix = 'apicenter'
var defaultWorkspaceName = 'default'
var defaultWorkspaceTitle = 'Default workspace'
var defaultWorkspaceDescription = 'Default workspace'

// Azure RBAC role definition IDs for API Center access
var apiCenterReaderRoleId = '71522526-b88f-4d52-b57f-d31fc3546d0d'
var apiCenterContributorRoleId = '6cba8790-29c5-48e5-bab1-c7541b01cb04'

// =================================================================
// VARIABLES AND COMPUTED VALUES
// =================================================================

// Extract API Center settings from inventory configuration
var apiCenterSettings = inventorySettings.apiCenter

// Generate unique API Center name with fallback logic
var apiCenterName = (!empty(apiCenterSettings.name)
  ? apiCenterSettings.name
  : '${solutionName}-${apiCenterSuffix}')

// =================================================================
// AZURE API CENTER SERVICE
// =================================================================

@description('Azure API Center service - Provides centralized API catalog and governance capabilities')
resource apiCenter 'Microsoft.ApiCenter/services@2024-06-01-preview' = {
  name: apiCenterName
  location: location
  tags: tags
  identity: (apiCenterSettings.identity.type != 'None')
    ? {
        type: apiCenterSettings.identity.type
        userAssignedIdentities: ((apiCenterSettings.identity.type == 'UserAssigned' || apiCenterSettings.identity.type == 'SystemAssigned, UserAssigned') && !empty(apiCenterSettings.identity.userAssignedIdentities))
          ? toObject(apiCenterSettings.identity.userAssignedIdentities, id => id, id => {})
          : null
      }
      : null
}

// =================================================================
// ROLE ASSIGNMENTS AND PERMISSIONS
// =================================================================

// Define required roles for API Center service principal
var roles = [
  apiCenterReaderRoleId
  apiCenterContributorRoleId
]

@description('Role assignments for API Center service principal - Grants necessary permissions for API inventory operations')
resource apimRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(
      subscription().id,
      resourceGroup().id,
      resourceGroup().name,
      apiCenter.id,
      apiCenter.name,
      role
    )
    scope: resourceGroup()
    properties: {
      principalId: apiCenter.identity.principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    }
  }
]

// =================================================================
// API CENTER WORKSPACE AND INTEGRATION
// =================================================================

@description('Default workspace for API Center - Organizes APIs and provides collaboration space')
resource apiCenterWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenter
  name: defaultWorkspaceName
  properties: {
    title: defaultWorkspaceTitle
    description: defaultWorkspaceDescription
  }
}

@description('API source integration - Links API Management service to API Center for automated inventory')
resource apiResource 'Microsoft.ApiCenter/services/workspaces/apiSources@2024-06-01-preview' = {
  name: apiManagementName
  parent: apiCenterWorkspace
  properties: {
    azureApiManagementSource: {
      resourceId: apiManagementResourceId
    }
  }
}
