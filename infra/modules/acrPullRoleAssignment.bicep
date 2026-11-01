targetScope = 'resourceGroup'

@description('Name of the Azure Container Registry.')
param registryName string

@description('Name of the App Service whose managed identity will pull images.')
param appName string

@description('Principal ID of the App Service managed identity.')
param principalId string

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: registryName
}

var acrPullRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, appName, acrPullRoleDefinitionId)
  scope: registry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
