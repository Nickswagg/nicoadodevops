@description('Name of the App Service Plan.')
param name string

@description('Azure region.')
param location string = resourceGroup().location

@description('SKU name, e.g. B1, S1, P1v3.')
param skuName string = 'P1v3'

@description('Number of instances.')
@minValue(1)
param capacity int = 1

@description('Resource tags.')
param tags object = {}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    reserved: true // required for Linux
  }
}

output id string = plan.id
output name string = plan.name
