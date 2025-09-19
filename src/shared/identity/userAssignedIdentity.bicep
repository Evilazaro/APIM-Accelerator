import * as Identity from '../customtypes/identity-types.bicep'

@description('The Azure region where the user-assigned managed identity will be deployed. This should align with the landing zone regional strategy for compliance and data residency requirements.')
param location string

@description('Configuration object defining the user-assigned managed identity properties including name, scope, and RBAC role assignments. This enables fine-grained access control and secure service-to-service authentication within the Azure API Management Landing Zone.')
param userAssignedIdentity Identity.UserAssignedIdentity

@description('Resource tags to be applied to the managed identity for governance, cost management, and operational tracking within the Azure Landing Zone taxonomy.')
param tags object

@description('Creates a user-assigned managed identity that provides secure, credential-free authentication for Azure services. This identity supports zero-trust security principles by eliminating the need for embedded credentials and enabling centralized identity lifecycle management within the landing zone.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentity.name
  location: location
  tags: tags
}

@description('Assigns RBAC roles to the managed identity at subscription scope when configured. This enables subscription-level permissions for cross-resource group operations and centralized governance within the Azure Landing Zone hierarchy.')
module roleAssignmentsSub 'roleAssignmentSub.bicep' = if (userAssignedIdentity.scope.type == 'subscription') {
  name: 'roleAssignmentsSub-${userAssignedIdentity.name}'
  scope: subscription()
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}

@description('Assigns RBAC roles to the managed identity at resource group scope when configured. This provides fine-grained, least-privilege access to specific resource groups, supporting security isolation and workload segregation principles within the landing zone architecture.')
module roleAssignmentsRg 'roleAssignmentRg.bicep' = if (userAssignedIdentity.scope.type == 'resourceGroup') {
  name: 'roleAssignmentsRg-${userAssignedIdentity.name}'
  scope: resourceGroup(userAssignedIdentity.scope.name)
  params: {
    principalId: managedIdentity.properties.principalId
    rbacRoles: userAssignedIdentity.rbacRoleAssignment.roles
  }
}
