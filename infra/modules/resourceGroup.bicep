targetScope = 'subscription'

@description('Name of the resource group.')
param name string

@description('Azure region for the resource group.')
param location string = deployment().location

@description('Resource group tags.')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: name
  location: location
  tags: tags
}

output id string = resourceGroup.id
output name string = resourceGroup.name
