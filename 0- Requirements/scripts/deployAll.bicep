// General params
param location string = resourceGroup().location
param sqllocation string = 'eastus2'

// SQL Server params
param serverName string = 'aqsqlserver-${uniqueString(resourceGroup().id)}'
param databaseName string = 'aqaworks'
param adminLogin string = 'arturoqu'
@secure()
param adminPassword string = '@DoNotTryThis.1970!'

// Speech Service params
param SpeechServiceName string = 'aispeech-${uniqueString(resourceGroup().id)}'
param speech_location string = 'eastus'
param vision_location string = 'eastus'

// OpenAI params
param OpenAIServiceName string = 'openai-${uniqueString(resourceGroup().id)}'
param openai_deployments array = [
  {
    name: 'text-embedding-3-large'
	  model_name: 'text-embedding-3-large'
    version: '1'
    raiPolicyName: 'Microsoft.Default'
    sku_capacity: 100
    sku_name: 'Standard'
  }
  {
    name: 'gpt-4o'
	  model_name: 'gpt-4o'
    version: '2024-05-13'
    raiPolicyName: 'Microsoft.Default'
    sku_capacity: 100
    sku_name: 'Standard'
  }
  {
    name: 'dall-e-3'
	  model_name: 'Dalle3'
    version: '3.0'
    raiPolicyName: 'Microsoft.Default'
    sku_capacity: 1
    sku_name: 'Standard'
  }
]

// AI Search params
param aisearch_name string = 'aisearch-${uniqueString(resourceGroup().id)}'

// AI Vision params
param aivision_name string = 'aivision-${uniqueString(resourceGroup().id)}'

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: serverName
  location: sqllocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  parent: sqlServer
  name: 'Allow Azure Services'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: databaseName
  parent: sqlServer
  location: sqllocation
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    sampleName: 'AdventureWorksLT'
  }
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: SpeechServiceName
  location: speech_location
  sku: {
    name: 'S0'
  }
  kind: 'SpeechServices'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

resource openai 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: OpenAIServiceName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

@batchSize(1)
resource model 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in openai_deployments: {
  name: deployment.model_name
  parent: openai
  sku: {
	name: deployment.sku_name
	capacity: deployment.sku_capacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.name
      version: deployment.version
    }
    raiPolicyName: deployment.raiPolicyName
  }
}]

resource search 'Microsoft.Search/searchServices@2020-08-01' = {
  name: aisearch_name
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
  }
}

resource vision 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aivision_name
  location: vision_location
  sku: {
    name: 'S1'
  }
  kind: 'ComputerVision'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}
