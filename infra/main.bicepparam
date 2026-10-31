using 'main.bicep'

param baseName = 'nicoshop'
param environment = '#{environment}#'
param resourceGroupName = 'rg-nicoshop-#{environment}#'
param location = 'centralus'
param skuName = 'B1'
param javaVersion = '17'
param javaContainer = 'JAVA'
