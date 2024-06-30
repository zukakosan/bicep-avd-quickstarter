param suffix string
param location string
param hubVnetCidr string
param shVnetCidr string
param hubVnetSubnetMask int
param shVnetSubnetMask int
param dnsServers array

var hubVnetName = 'hub-vnet-${suffix}'
var shVnetName = 'sh-vnet-${suffix}'
var hubVnetSubnets = [
  'subnet-adds'
  'subnet-xxx'
  'subnet-yyy'
]
var shVnetSubnets = [
  'subnet-sessionhost'
  'subnet-xxx'
  'subnet-yyy'
]

resource hubVnetNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-${hubVnetName}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'nsgRule'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource shVnetNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-${shVnetName}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'nsgRule'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-hub-${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetCidr
      ]
    }
    subnets: [
      for (s, i) in hubVnetSubnets: {
        name: s
        properties: {
          networkSecurityGroup: {
            id: hubVnetNsg.id
          }
          addressPrefix: cidrSubnet(hubVnetCidr, hubVnetSubnetMask, i)
        }
      }
    ]
    dhcpOptions: { dnsServers: dnsServers }
  }
}

resource shVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-sessionhost-${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        shVnetCidr
      ]
    }
    subnets: [
      for (s, i) in shVnetSubnets: {
        name: s
        properties: {
          networkSecurityGroup: {
            id: shVnetNsg.id
          }
          addressPrefix: cidrSubnet(shVnetCidr, shVnetSubnetMask, i)
        }
      }
    ]
    dhcpOptions: { dnsServers: dnsServers }
  }
}

resource hubToShPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peering-hub-to-sh-${suffix}'
  parent: hubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: shVnet.id
    }
  }
}

resource shToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peering-sh-to-hub-${suffix}'
  parent: shVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}

output addsSubnetId string = filter(hubVnet.properties.subnets, s => s.name == 'subnet-adds')[0].id
