@description('Globally unique name of the Web App.')
param name string

@description('Azure region.')
param location string = resourceGroup().location

@description('Resource ID of the App Service Plan.')
param appServicePlanId string

@description('Container image reference, including registry hostname and tag.')
param containerImage string

@description('Additional app settings.')
param appSettings array = []

@description('Health check path.')
param healthCheckPath string = '/'

@description('Resource tags.')
param tags object = {}

resource app 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}'
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      healthCheckPath: healthCheckPath
      appSettings: appSettings
    }
  }
}

output id string = app.id
output name string = app.name
output defaultHostName string = app.properties.defaultHostName
output principalId string = app.identity.principalId
