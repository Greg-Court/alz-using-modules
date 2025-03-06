# This outputs file uses the Terraform one() function to simplify the output structure.
# Without one(), the returned objects would be double-nested maps, requiring references like:
#   module.custom_connectivity_hubs.hub_networks.primary.primary.id
#
# This happens because the underlying Azure modules output maps of maps, where:
# - The first level key is your hub name (e.g., "primary")
# - The second level key is the resource name (which often matches the hub name)
#
# By using one(values()), we extract the single resource from each hub,
# allowing for cleaner references like:
#   module.custom_connectivity_hubs.hub_networks.primary.id

output "hub_networks" {
  description = "The hub virtual networks created by the module"
  value = {
    for k, v in module.hub_networks : k => one(values(v.virtual_networks))
  }
  # Example usage:
  # - Access raw output: module.custom_connectivity_hubs.hub_networks
  # - Access primary hub's VNet ID: module.custom_connectivity_hubs.hub_networks.primary.id
  # - Access secondary hub's VNet name: module.custom_connectivity_hubs.hub_networks.secondary.name
  # - Access a specific subnet in primary hub: module.custom_connectivity_hubs.hub_networks.primary.subnets["GatewaySubnet"].resource_id
}

output "firewalls" {
  description = "The Azure Firewalls created by the module"
  value = {
    for k, v in module.hub_networks : k => one(values(v.firewalls))
    if length(v.firewalls) > 0
  }
  # Example usage (assuming firewalls are enabled):
  # - Access raw output: module.custom_connectivity_hubs.firewalls
  # - Access primary hub's firewall ID: module.custom_connectivity_hubs.firewalls.primary.id
  # - Access primary hub's firewall name: module.custom_connectivity_hubs.firewalls.primary.name
  # - Access primary hub's firewall IP: module.custom_connectivity_hubs.firewalls.primary.ip_configuration[0].private_ip_address
}

output "firewall_policies" {
  description = "The Azure Firewall Policies created by the module"
  value = {
    for k, v in module.hub_networks : k => one(values(v.firewall_policies))
    if length(v.firewall_policies) > 0
  }
  # Example usage (assuming firewall policies are enabled):
  # - Access raw output: module.custom_connectivity_hubs.firewall_policies
  # - Access primary hub's firewall policy ID: module.custom_connectivity_hubs.firewall_policies.primary.id
  # - Access primary hub's firewall policy name: module.custom_connectivity_hubs.firewall_policies.primary.name
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
}

output "resource_groups" {
  description = "Resource groups created by the module"
  value = {
    for k, v in var.hub_virtual_networks : k => {
      hub     = try(module.hub_networks[k].resource_groups, {})
      dns     = try(azurerm_resource_group.dns[k], null)
      bastion = try(azurerm_resource_group.bastion[k], null)
    }
  }
  # Example usage:
  # - Access raw output: module.custom_connectivity_hubs.resource_groups
  # - Access primary hub resource group: module.custom_connectivity_hubs.resource_groups.primary.hub
  # - Access primary DNS resource group: module.custom_connectivity_hubs.resource_groups.primary.dns
  # - Access primary bastion resource group: module.custom_connectivity_hubs.resource_groups.primary.bastion
}