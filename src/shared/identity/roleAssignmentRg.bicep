import * as Identity from '../customtypes/identity-types.bicep'

@description('The unique identifier (Object ID) of the managed identity principal that will receive the role assignments. This enables the identity to authenticate and access Azure resources within the specific resource group scope, supporting workload isolation and fine-grained access control.')
param principalId string

@description('Array of RBAC roles to be assigned to the managed identity at resource group scope. These roles provide least-privilege access to specific resources within the resource group, supporting security isolation and workload segregation principles in the Azure Landing Zone architecture.')
param rbacRoles Identity.RBACRoleAssignment.roles

@description('Creates RBAC role assignments at resource group scope for the managed identity. These assignments provide fine-grained, least-privilege access to resources within the specific resource group, enabling workload isolation and supporting the defense-in-depth security strategy of Azure Landing Zones.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [
  for role in rbacRoles: {
    name: guid(tenant().tenantId, subscription().id, resourceGroup().id, principalId, role.roleName)
    scope: resourceGroup()
    properties: {
      description: 'Role assignment for APIM Accelerator. Role: ${role.roleName}'
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.id)
    }
  }
]
