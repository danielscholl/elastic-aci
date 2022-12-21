targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Optional. A short identifier for the kind of deployment.')
param serviceShort string = 'elastic'

@description('Location of the Resource Group. It uses the deployment\'s location when not provided.')
param location string = deployment().location

// ============== //
// Test Execution //
// ============== //

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  // name: '${serviceShort}-${uniqueString(deployment().name)}'
  name: '${serviceShort}-rg'
  location: location
}

module container_group './modules/container_group.bicep' = {
  scope: resourceGroup
  // name: '${serviceShort}-instance-${uniqueString(deployment().name)}'
  name: '${serviceShort}-instance'
  params: {
    name: serviceShort
    location: location
    containers: [
      {
        name: 'es-instance'
        properties: {
          image: 'docker.elastic.co/elasticsearch/elasticsearch:8.2.2'
          ports: [
            {
              port: '9200'
              protocol: 'Tcp'
            }
          ]
          resources: {
            requests: {
              cpu: 2
              memoryInGB: 4
            }
          }
          environmentVariables: [
            {
              name: 'DISCOVERY_TYPE'
              value: 'single-node'
            }
            {
              name: 'ES_JAVA_OPTS'
              value: '-Xms1g -Xmx1g'
            }
            {
              name: 'XPACK_SECURITY_ENABLED'
              value: 'false'
            }
          ]
        }
      }
    ]
    ipAddressPorts: [
      {
        protocol: 'Tcp'
        port: 9200
      }
    ]
  }
}


@description('The name of the resource group.')
output resourceGroupName string = resourceGroup.name

@description('The name of the container group.')
output containerGroupName string = container_group.name
