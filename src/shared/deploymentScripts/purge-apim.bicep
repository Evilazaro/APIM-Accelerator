@description('Azure region for deployment script execution.')
param location string
param storageAccountName string
@secure()
param storageAccountKey string
param tags object

@description('Creates a user-assigned managed identity for secure, credential-free service authentication.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: 'purge-apim-plat-identity'
  location: location
  tags: tags
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(
    tenant().tenantId,
    subscription().id,
    resourceGroup().id,
    managedIdentity.id,
    '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  )
  scope: resourceGroup()
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '17d1049b-9a84-46fb-8f53-869881c3d3ab'
    )
    principalType: 'ServicePrincipal'
  }
}

@description('Deployment script to purge soft-deleted APIM instances using managed identity authentication.')
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'purge-apim'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: toObject(
      [resourceId(resourceGroup().name, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIdentity.name)],
      arg => arg,
      arg => {}
    )
  }
  tags: tags
  properties: {
    azCliVersion: '2.0.77'
    retentionInterval: 'PT1H'
    arguments: '${subscription().subscriptionId} ${location}'
    storageAccountSettings: {
      storageAccountKey: storageAccountKey
      storageAccountName: storageAccountName
    }
    scriptContent: '''
      #!/bin/bash
      set -euo pipefail

      echo "Starting APIM purge process..."
      
      subscriptionId=$1
      location=$2

      echo "Using Subscription ID: $subscriptionId"
      echo "Using Location: $location"

      // apimName=$(yq -r '.core.apiManagement.name' ../../settings.yaml)
      // RG=$(yq -r '.core.apiManagement.resourceGroup' ../../settings.yaml)

      // echo "Api Management name: $apimName"

      // if az apim show --name $apimName --resource-group $RG >/dev/null 2>&1; then
      //   echo "APIM is still active"
      // else
      //   if az apim deletedservice list --query "[?name=='$apimName']" -o tsv | grep -q "$apimName"; then
      //     echo "APIM is soft-deleted"
      //     az apim deletedservice purge --service-name "$apimName" --location "$location"
      //   else
      //     echo "APIM not found (already purged or never existed)"
      //   fi
      // fi

      // #az apim deletedservice purge --service-name "$apimName" --location "$location"
      // az apim show --name apim-plat-apim11 --resource-group $RG

      echo "APIM purge process completed."
    '''
  }
}
