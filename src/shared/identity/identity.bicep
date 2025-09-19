import * as Identity from '../customtypes/identity-types.bicep'

@description('The Azure region where identity resources will be deployed. This should align with the landing zone regional strategy for compliance and latency requirements.')
param location string

@description('Configuration object containing shared identity settings including resource group and user-assigned managed identities. These identities enable secure, granular access control across Azure API Management and related services within the landing zone.')
param identity Identity.SharedIdentity

@description('Resource tags to be applied to all identity resources for governance, cost management, and operational tracking within the Azure Landing Zone taxonomy.')
param tags object

@description('Deploys user-assigned managed identities for the Azure API Management Landing Zone. These identities provide secure, principle-based access to Azure resources without storing credentials in code, supporting zero-trust security architecture and centralized identity governance.')
module userAssignedIdentities 'userAssignedIdentity.bicep' = [
  for userAssigned in identity.usersAssigned: {
    name: 'userAssignedIdentities-${userAssigned.name}'
    scope: resourceGroup()
    params: {
      location: location
      tags: tags
      userAssignedIdentity: userAssigned
    }
  }
]
