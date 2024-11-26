param keyVaultName string = 'testkv12343'
param existingResourceGroupName string = 'rg11'
param location string = 'eastus2'

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: 'd30c4aef-8002-42af-98d5-56ec3d056daa'
    accessPolicies: [
      {
        objectId: 'f9c2b8f2-d94b-499d-b5f9-f9ab3033ffa5'
        tenantId: 'd30c4aef-8002-42af-98d5-56ec3d056daa'
        permissions: {
          keys: ['get', 'list', 'create', 'delete', 'backup', 'restore', 'recover', 'purge']
          secrets: ['get', 'list', 'set', 'delete', 'backup', 'restore', 'recover', 'purge']
          certificates: ['get', 'list', 'delete', 'create', 'import', 'update', 'managecontacts', 'getissuers', 'listissuers', 'setissuers', 'deleteissuers', 'manageissuers', 'recover', 'purge']
        }
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: []
      ipRules: []
    }
    // publicNetworkAccess: 'Disabled'
  }
}

output keyVaultId string = keyVault.id
