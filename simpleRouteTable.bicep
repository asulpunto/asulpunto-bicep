metadata title='Simple Route Table Module'
metadata description= 'Create a route table for Azure Service tags with endpoint internet'
metadata version= '1.0.0'

@description('Changes or assings a subnet Delegation. Expected input similar to "Microsoft.Web/serverFarms"')
param routeTableName string = ''

@description('Location of the route table. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Array of Azure Service Tags to be included in the route table. Example: ["ApiManagement", "AzureFrontDoor"]. Required.')
param serviceTags array 

resource routeTable 'Microsoft.Network/routeTables@2024-07-01' = {
  name: routeTableName
  location: location
  properties: {
    routes:[for item in serviceTags: {
        name: 'route-${item}'
        properties: {
          addressPrefix: item // Use your ApiManagement subnet or IP range here
          nextHopType: 'Internet'
        }
      }
    ]
  }
}

output routeTableId string = routeTable.id
output routeTableName string = routeTable.name
