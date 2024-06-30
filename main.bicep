param location string
param suffix string

param vmAdminUsername string
@secure()
param vmAdminPassword string

param addsAdminName string
@secure()
param addsAdminPassword string

param tenantId string
param objectId string

var hubVnetCidr = '10.0.0.0/16'
var hubVnetSubnetMask = 24

var shVnetCidr = '10.1.0.0/16'
var shVnetSubnetMask = 24
var addsVmName = 'vm-adds-${suffix}'

module kv './modules/keyvault.bicep' = {
  name: 'kv'
  params: {
    location: location
    suffix: suffix
    tenantId: tenantId
    objectId: objectId
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    addsAdminName: addsAdminName
    addsAdminPassword: addsAdminPassword
  }
}

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


