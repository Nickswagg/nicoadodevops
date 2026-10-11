targetScope = 'subscription'

@description('Base name for resources, e.g. nicoshop.')
param baseName string

@description('Environment name.')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Name of the resource group to create.')
param resourceGroupName string = 'rg-${baseName}-${environment}'

@description('Azure region for the resource group and app resources.')
param location string = deployment().location

@description('App Service Plan SKU.')
param skuName string = 'B1'

@allowed(['8', '11', '17', '21'])
param javaVersion string = '17'

@allowed(['JAVA', 'TOMCAT'])
param javaContainer string = 'JAVA'

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

module app 'modules/appService.bicep' = {
  dependsOn:[plan]
  name: 'appService'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'app-${baseName}-${environment}-${suffix}'
    location: location
    appServicePlanId: plan.outputs.id
    javaVersion: javaVersion
    javaContainer: javaContainer
    tags: tags
    appSettings: [
      { name: 'SPRING_PROFILES_ACTIVE', value: environment }
      { name: 'WEBSITES_PORT', value: '8080' }
    ]
  }
}

output resourceGroupName string = resourceGroupDeployment.outputs.name
output webAppName string = app.outputs.name
output webAppUrl string = 'https://${app.outputs.defaultHostName}'
