targetScope = 'resourceGroup'

@description('Base name for resources, e.g. nicoshop.')
param baseName string

@description('Environment name.')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

param location string = resourceGroup().location

@description('App Service Plan SKU.')
param skuName string = 'P1v3'

@allowed(['8', '11', '17', '21'])
param javaVersion string = '17'

@allowed(['JAVA', 'TOMCAT'])
param javaContainer string = 'JAVA'

var suffix = uniqueString(resourceGroup().id)
var tags = {
  app: baseName
  environment: environment
}

module plan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: 'asp-${baseName}-${environment}'
    location: location
    skuName: skuName
    tags: tags
  }
}

module app 'modules/appService.bicep' = {
  name: 'appService'
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

output webAppName string = app.outputs.name
output webAppUrl string = 'https://${app.outputs.defaultHostName}'
