output "hub_networks" {
  description = "The hub virtual networks created by the module"
  value = {
    for k, v in module.hub_networks : k => v.virtual_networks
  }
}

output "firewalls" {
  description = "The Azure Firewalls created by the module"
  value = {
    for k, v in module.hub_networks : k => v.firewalls
    if length(v.firewalls) > 0
  }
}

output "firewall_policies" {
  description = "The Azure Firewall Policies created by the module"
  value = {
    for k, v in module.hub_networks : k => v.firewall_policies
    if length(v.firewall_policies) > 0
  }
}

output "vpn_gateways" {
  description = "The VPN gateways created by the module"
  value = {
    for k, v in module.vpn_gateways : k => v.virtual_network_gateway
  }
}

output "expressroute_gateways" {
  description = "The ExpressRoute gateways created by the module"
  value = {
    for k, v in module.expressroute_gateways : k => v.virtual_network_gateway
  }
}

output "private_dns_zones" {
  description = "The Private DNS zones created by the module"
  value = {
    for k, v in module.private_dns_zones : k => {
      id         = v.resource_id
      name       = v.name
      resource   = v.resource
      vnet_links = v.virtual_network_link_outputs
    }
  }
}

output "bastion_hosts" {
  description = "The Azure Bastion hosts created by the module"
  value = {
    for k, v in module.bastion_hosts : k => {
      name        = v.name
      resource_id = v.resource_id
    }
  }
}

output "debug_hub_networks_raw" {
  description = "Raw output of the hub_networks module for debugging"
  value = module.hub_networks
}