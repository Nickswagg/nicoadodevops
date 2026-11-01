using 'main.bicep'

param baseName = 'nicoshop'
param environment = '#{environment}#'
param resourceGroupName = 'rg-nicoshop-#{environment}#'
param location = 'centralus'
param skuName = 'B1'
param containerImage = 'mcr.microsoft.com/dotnet/aspnet:8.0'
