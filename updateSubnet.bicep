metadata title='Advanced Subnet Module'
metadata description= 'This module wil modify some parameters for the subnet'
metadata version= '1.0.0'

@description('Changes or assings a subnet Delegation. Expected input similar to "Microsoft.Web/serverFarms"')
param delegationServiceName string = ''

@description('Subnet name. Required')
param subnetName string

@description('Virtual Network Name. Required.')
param vnetName string

@description('Network security group id')
param nsgId string = ''

@description('Array of Azure Service Endpoints. Example:[Microsoft.Storage, Microsoft.Keyvault]')
param endPoints array = [] 

@description('Route Table Id to be associated with the subnet. If empty, the route table association will not be changed.')
param routeTableId string = ''


@description('Decide what to do with the service endpoints. REPLACE will replace the endpoints with the endPoint array. APPEND will add to the existing endpoints')
@allowed([
    'REPLACE'
    'APPEND'
])
param endPointsMode string = 'APPEND'

var delegationsObj= {
    name: 'delegation-${subnetName}'
    properties: {
        serviceName: delegationServiceName
    }
    type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
}    

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
    name: vnetName
}


var snet= filter(vnet.properties.subnets, s => s.name == subnetName) [0]

var endPointsObj=[for item in endPoints: {
        service: item
    }]

var appendEndPoints=union(snet.properties.serviceEndpoints,endPointsObj)

resource subnetUpdate 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' ={
name: subnetName
parent: vnet
properties: {
    delegations: empty(delegationServiceName)?[]: [delegationsObj]
    addressPrefix: snet.properties.addressPrefix
    networkSecurityGroup: (empty(nsgId))?null: {id: nsgId}
    serviceEndpoints: (endPointsMode=='APPEND')? appendEndPoints: endPointsObj
    routeTable: (empty(routeTableId))?null: {id: routeTableId}
 }
} 


output vnetName string = vnet.name
output subnetName string = subnetUpdate.name
output subnetId string = subnetUpdate.id
