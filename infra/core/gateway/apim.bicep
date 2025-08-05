metadata description = 'Creates an Azure API Management instance.'

@description('The name of the API Management service instance')
param name string

@description('The location of the API Management service instance')
param location string = resourceGroup().location

@description('The tags to apply to the API Management service instance')
param tags object = {}

@description('The email address of the owner of the service')
param publisherEmail string

@description('The name of the owner of the service')
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Consumption'

@description('The instance size of this API Management service')
param capacity int = 0

@description('The backend API base URL')
param backendApiUrl string

@description('Enable CORS policy')
param enableCors bool = true

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: capacity
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: publisherEmail
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Create backend for the FastAPI service
resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apim
  name: 'fastapi-backend'
  properties: {
    description: 'FastAPI Backend Service'
    url: backendApiUrl
    protocol: 'http'
  }
}

// Create the API
resource api 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apim
  name: 'agents-api'
  properties: {
    displayName: 'AI Agents API'
    description: 'API for AI Agents service'
    path: 'api'
    protocols: ['https']
    subscriptionRequired: false
    serviceUrl: backendApiUrl
  }
}

// Create operations for each FastAPI endpoint
resource chatOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: api
  name: 'chat'
  properties: {
    displayName: 'Chat with Agent'
    method: 'POST'
    urlTemplate: '/chat'
    description: 'Send a message to the AI agent'
    request: {
      headers: [
        {
          name: 'Content-Type'
          type: 'string'
          defaultValue: 'application/json'
          required: true
        }
      ]
    }
    responses: [
      {
        statusCode: 200
        description: 'Successful response'
        headers: [
          {
            name: 'Content-Type'
            type: 'string'
            defaultValue: 'text/event-stream'
          }
        ]
      }
    ]
  }
}

resource historyOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: api
  name: 'chat-history'
  properties: {
    displayName: 'Get Chat History'
    method: 'GET'
    urlTemplate: '/chat/history'
    description: 'Get chat history for the current session'
  }
}

resource agentOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: api
  name: 'get-agent'
  properties: {
    displayName: 'Get Agent Details'
    method: 'GET'
    urlTemplate: '/agent'
    description: 'Get agent configuration details'
  }
}

resource azureConfigOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: api
  name: 'azure-config'
  properties: {
    displayName: 'Get Azure Configuration'
    method: 'GET'
    urlTemplate: '/config/azure'
    description: 'Get Azure configuration for frontend'
  }
}

// Create CORS policy if enabled
resource corsPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = if (enableCors) {
  parent: api
  name: 'policy'
  properties: {
    value: '''
<policies>
  <inbound>
    <cors allow-credentials="false">
      <allowed-origins>
        <origin>*</origin>
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
        <method>PUT</method>
        <method>DELETE</method>
        <method>OPTIONS</method>
      </allowed-methods>
      <allowed-headers>
        <header>*</header>
      </allowed-headers>
    </cors>
    <set-backend-service backend-id="fastapi-backend" />
    <base />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
'''
  }
}

output id string = apim.id
output name string = apim.name
output gatewayUrl string = apim.properties.gatewayUrl ?? ''
output portalUrl string = apim.properties.portalUrl ?? ''
output managementApiUrl string = apim.properties.managementApiUrl ?? ''
output scmUrl string = apim.properties.scmUrl ?? ''
output systemAssignedIdentityPrincipalId string = apim.identity.principalId
