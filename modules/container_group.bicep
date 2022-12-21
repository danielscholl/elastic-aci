@description('Required. Name for the container group.')
param name string

@description('Required. The containers and their respective config within the container group.')
param containers array

@description('Optional. Ports to open on the public IP address. Must include all ports assigned on container level.')
param ipAddressPorts array = []

@description('Optional. The operating system type required by the containers in the container group. - Windows or Linux.')
param osType string = 'Linux'

@description('Optional. Restart policy for all containers within the container group. - Always: Always restart. OnFailure: Restart on failure. Never: Never restart. - Always, OnFailure, Never.')
param restartPolicy string = 'Always'

@description('Optional. Specifies if the IP is exposed to the public internet or private VNET. - Public or Private.')
param ipAddressType string = 'Public'

@description('Optional. The image registry credentials by which the container group is created from.')
param imageRegistryCredentials array = []

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Tags of the resource.')
param tags object = {}

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource containergroup 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: name
  location: location
  identity: identity
  tags: tags
  properties: {
    containers: containers
    imageRegistryCredentials: imageRegistryCredentials
    restartPolicy: restartPolicy
    osType: osType
    ipAddress: {
      type: ipAddressType
      ports: ipAddressPorts
    }
  }
}

@description('The name of the container group.')
output name string = containergroup.name

@description('The resource ID of the container group.')
output resourceId string = containergroup.id

@description('The resource group the container group was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The IPv4 address of the container group.')
output iPv4Address string = containergroup.properties.ipAddress.ip

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(containergroup.identity, 'principalId') ? containergroup.identity.principalId : ''

@description('The location the resource was deployed into.')
output location string = containergroup.location
