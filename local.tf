locals {

  regions = toset(var.regions)

  azure_regions = {
    "centralus"      = { cidr = "10.0.1.0/24" }
    "eastus"         = { cidr = "10.0.2.0/24" }
    "eastus2"        = { cidr = "10.0.3.0/24" }
    "northcentralus" = { cidr = "10.0.4.0/24" }
    "southcentralus" = { cidr = "10.0.5.0/24" }
    "westus"         = { cidr = "10.0.6.0.24" }
    "westus2"        = { cidr = "10.0.7.0/24" }
    "westus3"        = { cidr = "10.0.8.0/24" }
  }

  peers = [for peers in setproduct(local.regions, local.regions) : peers if length(distinct(peers)) > 1]
  peer_map = { for peer in local.peers :
    "${peer.0}-${peer.1}" => {
      local  = peer.0
      remote = peer.1
    }
  }

  vms = merge(values({ for reg in local.regions :
    reg => { for az in [1, 2, 3] :
      "${reg}-${az}" => { region = reg, zone = az }
    }
  })...)

  tags = merge(var.tags)

  ssh_commands = { for region in local.regions :
    region => merge({
      bastion = "ssh -i bastion.pem adminuser@${azurerm_public_ip.bastion[region].ip_address}"
    },
    { for zone in [1,2,3] :
      "zone${zone}" => "ssh -i vm.pem -o 'ProxyCommand ssh -W %h:%p -i bastion.pem adminuser@${azurerm_public_ip.bastion[region].ip_address}' adminuser@zone${zone}.${region}.test.com"
    })
  }

}
