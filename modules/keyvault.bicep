param location string
param suffix string
param tenantId string
param objectId string
param vmAdminUsername string
@secure()
param vmAdminPassword string
param addsAdminName string
@secure()
param addsAdminPassword string

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'kv-${suffix}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource kvSecretVmAdminUsername 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'vmAdminUsername'
  properties: {
    value: vmAdminUsername
  }
}

resource kvSecretVmAdminPassword 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'vmAdminPassword'
  properties: {
    value: vmAdminPassword
  }
}

resource kvSecretAddsAdminName 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'addsAdminName'
  properties: {
    value: addsAdminName
  }
}

resource kvSecretAddsAdminPassword 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'addsAdminPassword'
  properties: {
    value: addsAdminPassword
  }
}
