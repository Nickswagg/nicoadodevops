targetScope = 'subscription'

@description('Base name for resources, e.g. nicoshop.')
param baseName string

@description('Environment name.')
param environment string = 'dev'

@description('Name of the resource group to create.')
param resourceGroupName string = 'rg-${baseName}-${environment}'

@description('Azure region for the resource group and app resources.')
param location string = 'centralus'

@description('App Service Plan SKU.')
param skuName string = 'B1'

@description('Container image reference used by the App Service. The initial deployment uses the public .NET 8 runtime image until the pipeline pushes the application image.')
param containerImage string = 'mcr.microsoft.com/dotnet/aspnet:8.0'

var suffix = uniqueString(subscription().subscriptionId, resourceGroupName)
var tags = {
  app: baseName
  environment: environment
}

module resourceGroupDeployment 'modules/resourceGroup.bicep' = {
  name: 'resourceGroup'
  params: {
    name: resourceGroupName
    location: location
    tags: tags
  }
}

module plan 'modules/appServicePlan.bicep' = {
  dependsOn: [resourceGroupDeployment]
  name: 'appServicePlan'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'asp-${baseName}-${environment}'
    location: location
    skuName: skuName
    tags: tags
  }
}

module devopsACR 'modules/containerRegistry.bicep' = {
  dependsOn: [resourceGroupDeployment]
  name: 'containerRegistry'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'devopsacr${suffix}'
    location: location
    tags: tags
  }
}

module app 'modules/appService.bicep' = {
  name: 'appService'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'app-${baseName}-${environment}-${suffix}'
    location: location
    appServicePlanId: plan.outputs.id
    containerImage: containerImage
    tags: tags
    appSettings: [
      { name: 'ASPNETCORE_ENVIRONMENT', value: environment }
      { name: 'WEBSITES_PORT', value: '8080' }
    ]
  }
}

module acrPullRole 'modules/acrPullRoleAssignment.bicep' = {
  name: 'acrPullRoleAssignment'
  scope: resourceGroup(resourceGroupName)
  params: {
    registryName: devopsACR.outputs.name
    appName: app.outputs.name
    principalId: app.outputs.principalId
  }
}

output resourceGroupName string = resourceGroupDeployment.outputs.name
output webAppName string = app.outputs.name
output webAppUrl string = 'https://${app.outputs.defaultHostName}'
output containerRegistryName string = devopsACR.outputs.name
output containerRegistryLoginServer string = devopsACR.outputs.loginServer
