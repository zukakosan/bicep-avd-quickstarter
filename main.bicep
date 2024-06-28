param location string
param suffix string

param vmAdminUsername string
@secure()
param vmAdminPassword string

var hubVnetCidr = '10.0.0.0/16'
var hubVnetSubnetMask = 24

var shVnetCidr = '10.1.0.0/16'
var shVnetSubnetMask = 24


var addsVmName = 'vm-adds-${suffix}'

module network './modules/network.bicep' = {
  name: 'network'
  params: {
    suffix: suffix
    location: location
    hubVnetCidr: hubVnetCidr
    shVnetCidr: shVnetCidr
    hubVnetSubnetMask: hubVnetSubnetMask
    shVnetSubnetMask: shVnetSubnetMask
    dnsServers: [cidrHost(hubVnetCidr, 4)]
  }
}

module adds './modules/vm-windows.bicep' = {
  name: 'adds'
  params: {
    location: location
    subnetId: network.outputs.addsSubnetId
    vmName: addsVmName
    privateIpAddress: cidrHost(hubVnetCidr, 4)
    vmAdminUserName: vmAdminUsername
    vmAdminPassword: vmAdminPassword
  }
}

resource hostpool 'Microsoft.DesktopVirtualization/hostpools@2021-07-12' = {
  name: 'hostpool-${suffix}'
  location: location
  properties: {
    friendlyName: 'hostpool-${suffix}'
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationgroups@2021-07-12' = {
  name: 'desktop-app-multi-session-${suffix}'
  location: location
  properties: {
    friendlyName: 'desktop-app-multi-session-${suffix}'
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostpool.id
  }
}

resource workSpace 'Microsoft.DesktopVirtualization/workspaces@2021-07-12' = {
  name: 'avd-ws-${suffix}'
  location: location
  properties: {
    friendlyName: 'avd-ws-${suffix}'
  }
}

//セッションホストの作成 -> ADDS のイメージを作るのが先
//resource symbolicname 'Microsoft.DesktopVirtualization/hostPools/sessionHostConfigurations@2023-11-01-preview' = {
//  name: 'default'
//  parent: resourceSymbolicName
//  properties: {
//    availabilityZones: [
//      int
//    ]
//    bootDiagnosticsInfo: {
//      enabled: bool
//      storageUri: 'string'
//    }
//    customConfigurationScriptUrl: 'string'
//    diskInfo: {
//      type: 'string'
//    }
//    domainInfo: {
//      activeDirectoryInfo: {
//        domainCredentials: {
//          passwordKeyVaultSecretUri: 'string'
//          usernameKeyVaultSecretUri: 'string'
//        }
//        domainName: 'string'
//        ouPath: 'string'
//      }
//      azureActiveDirectoryInfo: {
//        mdmProviderGuid: 'string'
//      }
//      joinType: 'string'
//    }
//    friendlyName: 'string'
//    imageInfo: {
//      customInfo: {
//        resourceId: 'string'
//      }
//      marketplaceInfo: {
//        exactVersion: 'string'
//        offer: 'string'
//        publisher: 'string'
//        sku: 'string'
//      }
//      type: 'string'
//    }
//    networkInfo: {
//      securityGroupId: 'string'
//      subnetId: 'string'
//    }
//    securityInfo: {
//      secureBootEnabled: bool
//      type: 'string'
//      vTpmEnabled: bool
//    }
//    vmAdminCredentials: {
//      passwordKeyVaultSecretUri: 'string'
//      usernameKeyVaultSecretUri: 'string'
//    }
//    vmLocation: 'string'
//    vmNamePrefix: 'string'
//    vmResourceGroup: 'string'
//    vmSizeId: 'string'
//    vmTags: {
//      {customized property}: 'string'
//    }
//  }
//}

// ANF の作成
