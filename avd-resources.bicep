// This bicep file has to be executed after the ADDS VM is configured manually.
param location string
param suffix string
//param nsgId string
param subnetId string
//param vaultName string
param addsPrivateIp string

param domainUsernameKeyVaultSecretUri string
param domainPasswordKeyVaultSecretUri string
param vmUsernameKeyVaultSecretUri string
param vmPasswordKeyVaultSecretUri string

var location2 = 'eastus2'
var localDomainName = 'kedama.local'
var ouPath = 'OU=AVD,DC=kedama,DC=local'

resource hostpool 'Microsoft.DesktopVirtualization/hostpools@2023-11-01-preview' = {
  name: 'hostpool-${suffix}'
  location: location2
  properties: {
    friendlyName: 'hostpool-${suffix}'
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    managementType: 'Automated'
  }
}

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationgroups@2021-07-12' = {
  name: 'desktop-app-multi-session-${suffix}'
  location: location2
  properties: {
    friendlyName: 'desktop-app-multi-session-${suffix}'
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostpool.id
  }
}

resource workSpace 'Microsoft.DesktopVirtualization/workspaces@2021-07-12' = {
  name: 'avd-ws-${suffix}'
  location: location2
  properties: {
    friendlyName: 'avd-ws-${suffix}'
  }
}

//セッションホストの作成 -> ドメインに参加する必要があるので ADDS のイメージを作るのが先
resource sessionHostConfig 'Microsoft.DesktopVirtualization/hostPools/sessionHostConfigurations@2023-11-01-preview' = {
  name: 'default'
  parent: hostpool
  properties: {
    availabilityZones: [ 1,2,3 ]
      bootDiagnosticsInfo: {
      enabled: false
    }
    //customConfigurationScriptUrl: 'string'
    diskInfo: {
      type: 'StandardSSD_LRS'
    }
    domainInfo: {
      activeDirectoryInfo: {
        domainCredentials: {
          passwordKeyVaultSecretUri: domainPasswordKeyVaultSecretUri
          usernameKeyVaultSecretUri: domainUsernameKeyVaultSecretUri
        }
        domainName: localDomainName
        ouPath: ouPath
      }
      //azureActiveDirectoryInfo: {
      //  mdmProviderGuid: 'string'
      //}
      joinType: 'ActiveDirectory'
    }
    friendlyName: 'sh-${suffix}'
    imageInfo: {
      marketplaceInfo: {
        exactVersion: '22631.3155.240210'
        offer: 'windows-11'
        publisher: 'microsoftwindowsdesktop'
        sku: 'win11-23h2-avd'
      }
      type: 'Marketplace'
    }
    networkInfo: {
      //securityGroupId: nsgId
      subnetId: subnetId
    }
    //securityInfo: {
    //  secureBootEnabled: false
    //  type: 'TrustedLaunch'
    //  vTpmEnabled: false
    //}
    vmAdminCredentials: {
      passwordKeyVaultSecretUri: vmPasswordKeyVaultSecretUri
      usernameKeyVaultSecretUri: vmUsernameKeyVaultSecretUri
    }
    vmLocation: location
    vmNamePrefix: 'sh-${suffix}'
    vmResourceGroup: resourceGroup().name
    vmSizeId: 'Standard_D8ds_v5'
  }
}


// ANF の作成
