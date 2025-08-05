param name string
param location string = resourceGroup().location
param tags object = {}

param containerRegistryName string
param identityName string
param containerAppsEnvironmentName string
param backendApiUrl string

resource frontendIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

var env = [
  {
    name: 'AZURE_CLIENT_ID'
    value: frontendIdentity.properties.clientId
  }
  {
    name: 'API_BASE_URL'
    value: backendApiUrl
  }
  {
    name: 'ENVIRONMENT'
    value: 'production'
  }
]

module containerApp 'core/host/container-app.bicep' = {
  name: '${name}-container-app'
  params: {
    name: name
    location: location
    tags: union(tags, {
      'azd-service-name': 'frontend'
    })
    identityName: frontendIdentity.name
    imageName: ''
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    env: env
    targetPort: 80
    external: true
  }
}

output SERVICE_FRONTEND_IDENTITY_PRINCIPAL_ID string = frontendIdentity.properties.principalId
output SERVICE_FRONTEND_NAME string = containerApp.outputs.name
output SERVICE_FRONTEND_URI string = containerApp.outputs.uri
