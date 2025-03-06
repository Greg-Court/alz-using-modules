output "hub_networks" {
  description = "The hub virtual networks created by the module"
  value = {
    for k, v in var.hub_virtual_networks : k => module.hub_networks.virtual_networks["${k}"]
  }
  # Example usage:
  # - Access raw output: module.custom_connectivity_hubs.hub_networks
  # - Access primary hub's VNet ID: module.custom_connectivity_hubs.hub_networks.primary.id
  # - Access secondary hub's VNet name: module.custom_connectivity_hubs.hub_networks.secondary.name
  # - Access a specific subnet in primary hub: module.custom_connectivity_hubs.hub_networks.primary.subnets["GatewaySubnet"].id
  # - Access the CIDR range: module.custom_connectivity_hubs.hub_networks.primary.address_space[0]
}

output "firewalls" {
  description = "The Azure Firewalls created by the module"
  value = {
    for k, v in var.hub_virtual_networks : k => module.hub_networks.firewalls["${k}"]
    if try(v.hub_virtual_network.firewall, null) != null
  }
  # Example usage (assuming firewalls are enabled):
  # - Access raw output: module.custom_connectivity_hubs.firewalls
  # - Access primary hub's firewall ID: module.custom_connectivity_hubs.firewalls.primary.id
  # - Access primary hub's firewall name: module.custom_connectivity_hubs.firewalls.primary.name
  # - Access primary hub's firewall IP: module.custom_connectivity_hubs.firewalls.primary.ip_configuration[0].private_ip_address
  # - Check if firewall exists: contains(keys(module.custom_connectivity_hubs.firewalls), "primary")
}

output "firewall_policies" {
  description = "The Azure Firewall Policies created by the module"
  value = {
    for k, v in var.hub_virtual_networks : k => module.hub_networks.firewall_policies["${k}"]
    if try(v.hub_virtual_network.firewall.firewall_policy, null) != null
  }
  # Example usage (assuming firewall policies are enabled):
  # - Access raw output: module.custom_connectivity_hubs.firewall_policies
  # - Access primary hub's firewall policy ID: module.custom_connectivity_hubs.firewall_policies.primary.id
  # - Access primary hub's firewall policy name: module.custom_connectivity_hubs.firewall_policies.primary.name
  # - Access policy SKU: module.custom_connectivity_hubs.firewall_policies.primary.sku
  # - Check if policy exists: contains(keys(module.custom_connectivity_hubs.firewall_policies), "primary") 
}

output "vpn_gateways" {
  description = "The VPN gateways created by the module"
  value = {
    for k, v in module.vpn_gateways : k => v.virtual_network_gateway
  }
  # Example usage (assuming VPN gateways are enabled):
  # - Access raw output: module.custom_connectivity_hubs.vpn_gateways
  # - Access primary VPN gateway's ID: module.custom_connectivity_hubs.vpn_gateways.primary.id
  # - Access primary VPN gateway's name: module.custom_connectivity_hubs.vpn_gateways.primary.name
  # - Access primary VPN gateway's type: module.custom_connectivity_hubs.vpn_gateways.primary.type
  # - Access primary VPN gateway's SKU: module.custom_connectivity_hubs.vpn_gateways.primary.sku
  # - Check if active-active: module.custom_connectivity_hubs.vpn_gateways.primary.active_active
}

output "expressroute_gateways" {
  description = "The ExpressRoute gateways created by the module"
  value = {
    for k, v in module.expressroute_gateways : k => v.virtual_network_gateway
  }
  # Example usage (assuming ExpressRoute gateways are enabled):
  # - Access raw output: module.custom_connectivity_hubs.expressroute_gateways
  # - Access primary ExpressRoute gateway's ID: module.custom_connectivity_hubs.expressroute_gateways.primary.id
  # - Access primary ExpressRoute gateway's name: module.custom_connectivity_hubs.expressroute_gateways.primary.name
  # - Access primary ExpressRoute gateway's type: module.custom_connectivity_hubs.expressroute_gateways.primary.type
  # - Access primary ExpressRoute gateway's SKU: module.custom_connectivity_hubs.expressroute_gateways.primary.sku
  # - Check gateway existence: contains(keys(module.custom_connectivity_hubs.expressroute_gateways), "primary")
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
  # Example usage:
  # - Access raw output: module.custom_connectivity_hubs.private_dns_zones
  # - Access a specific DNS zone ID: module.custom_connectivity_hubs.private_dns_zones["primary-privatelink.blob.core.windows.net"].id
  # - Access a specific DNS zone name: module.custom_connectivity_hubs.private_dns_zones["primary-privatelink.blob.core.windows.net"].name
  # - Access the VNet link for a DNS zone: module.custom_connectivity_hubs.private_dns_zones["primary-privatelink.blob.core.windows.net"].vnet_links["link-vnet-hub-uks-01"].id
  # - List all DNS zones: keys(module.custom_connectivity_hubs.private_dns_zones)
}

output "bastion_hosts" {
  description = "The Azure Bastion hosts created by the module"
  value = {
    for k, v in module.bastion_hosts : k => {
      name        = v.name
      resource_id = v.resource_id
    }
  }
  # Example usage (assuming bastion hosts are enabled):
  # - Access raw output: module.custom_connectivity_hubs.bastion_hosts
  # - Access primary bastion host's ID: module.custom_connectivity_hubs.bastion_hosts.primary.resource_id
  # - Access primary bastion host's name: module.custom_connectivity_hubs.bastion_hosts.primary.name
  # - Check if bastion exists: contains(keys(module.custom_connectivity_hubs.bastion_hosts), "primary")
}

output "resource_groups" {
  description = "Resource groups created by the module"
  value = {
    for k, v in var.hub_virtual_networks : k => {
      hub     = try({
        for rg_key, rg_val in module.hub_networks.resource_groups : rg_key => rg_val
        if startswith(rg_key, k)
      }, {})
      dns     = try(azurerm_resource_group.dns[k], null)
      bastion = try(azurerm_resource_group.bastion[k], null)
    }
  }
  # Example usage:
  # - Access raw output: module.custom_connectivity_hubs.resource_groups
  # - Access primary hub resource group name: keys(module.custom_connectivity_hubs.resource_groups.primary.hub)[0]
  # - Access primary hub resource group: values(module.custom_connectivity_hubs.resource_groups.primary.hub)[0]
  # - Access primary DNS resource group: module.custom_connectivity_hubs.resource_groups.primary.dns.name
  # - Access primary bastion resource group: module.custom_connectivity_hubs.resource_groups.primary.bastion.name
  # - Check if DNS resource group exists: module.custom_connectivity_hubs.resource_groups.primary.dns != null
}