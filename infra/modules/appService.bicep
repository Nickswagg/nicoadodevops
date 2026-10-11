@description('Globally unique name of the Web App.')
param name string

@description('Azure region.')
param location string = resourceGroup().location

@description('Resource ID of the App Service Plan.')
param appServicePlanId string

@description('Java version.')
@allowed(['8', '11', '17', '21'])
param javaVersion string = '17'

@description('Java web container: JAVA (embedded, e.g. Spring Boot jar) or TOMCAT (war).')
@allowed(['JAVA', 'TOMCAT'])
param javaContainer string = 'JAVA'

@description('Tomcat version (used only when javaContainer is TOMCAT).')
param tomcatVersion string = '10.1'

@description('Additional app settings.')
param appSettings array = []

@description('Health check path.')
param healthCheckPath string = '/'

@description('Resource tags.')
param tags object = {}

var linuxFxVersion = javaContainer == 'TOMCAT'
  ? 'TOMCAT|${tomcatVersion}-java${javaVersion}'
  : 'JAVA|${javaVersion}-java${javaVersion}'

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
      linuxFxVersion: linuxFxVersion
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
