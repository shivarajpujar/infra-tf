@description('Location to give only East US and East US2')
@allowed([
  'East US'
  'East US2'
])
param location string = 'East US'

@minLength(4)
@maxLength(24)
param staccountname string = 'storageac1q1'

 var stdeploy = '${toLower(staccountname)}$uniqueString(resourceGroup().id)}'

param kindvalue string = 'BlobStorage'

param skuproperties object = {
  name: 'Standard_GRS'
}

param stproperties object ={
  accessTier: 'Cool'
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01'= {
  name:stdeploy
  kind:kindvalue
  location:location
  sku:skuproperties
  properties:stproperties

}
