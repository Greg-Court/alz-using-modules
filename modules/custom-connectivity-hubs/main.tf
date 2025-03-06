module "hub_networks" {
  source  = "Azure/avm-ptn-hubnetworking/azurerm"
  version = "0.5.2"
  
  hub_virtual_networks = {
    for k, v in var.hub_virtual_networks : k => {
      name                            = v.hub_virtual_network.name
      address_space                   = v.hub_virtual_network.address_space
      location                        = v.hub_virtual_network.location
      resource_group_name             = v.hub_virtual_network.resource_group_name
      resource_group_creation_enabled = lookup(v.hub_virtual_network, "resource_group_creation_enabled", false)
      route_table_name_firewall       = lookup(v.hub_virtual_network, "route_table_name_firewall", null)
      route_table_name_user_subnets   = lookup(v.hub_virtual_network, "route_table_name_user_subnets", null)
      routing_address_space           = lookup(v.hub_virtual_network, "routing_address_space", [])
      ddos_protection_plan_id         = lookup(v.hub_virtual_network, "ddos_protection_plan_id", null)
      mesh_peering_enabled            = lookup(v.hub_virtual_network, "mesh_peering_enabled", true)
      firewall                        = lookup(v.hub_virtual_network, "firewall", null)
      resource_group_lock_enabled     = lookup(v.hub_virtual_network, "resource_group_lock_enabled", null)
      hub_router_ip_address           = lookup(v.hub_virtual_network, "hub_router_ip_address", null)
      subnets = merge(
        lookup(v.hub_virtual_network, "subnets", {}),
        lookup(v, "virtual_network_gateways", null) != null ? {
          GatewaySubnet = {
            name             = "GatewaySubnet"
            address_prefixes = [v.virtual_network_gateways.subnet_address_prefix]
            route_table = {
              assign_generated_route_table = false
            }
          }
        } : {},
        lookup(v, "bastion", null) != null ? {
          AzureBastionSubnet = {
            name             = "AzureBastionSubnet"
            address_prefixes = [v.bastion.subnet_address_prefix]
            route_table = {
              assign_generated_route_table = false
            }
          }
        } : {}
      )
      tags = var.tags
    }
  }
}

locals {
  # Process hub networks to get their IDs and subnets
  hub_networks = {
    for hub_key, v in var.hub_virtual_networks : hub_key => {
      # Get the virtual network from the map
      virtual_network = {
        for attr_key, attr_val in module.hub_networks.virtual_networks : attr_key => attr_val
        if startswith(attr_key, hub_key)
      }[hub_key]
    }
  }
}

# Deploy VPN gateways where configured
module "vpn_gateways" {
  source  = "Azure/avm-ptn-vnetgateway/azurerm"
  version = "0.6.3"
  
  # Create VPN gateways only where configured
  for_each = {
    for k, v in var.hub_virtual_networks : k => v.virtual_network_gateways.vpn
    if try(v.virtual_network_gateways.vpn, null) != null
  }
  
  name                    = each.value.name
  location                = each.value.location
  virtual_network_id      = module.hub_networks.virtual_networks["${each.key}"].id
  type                    = "Vpn"
  vpn_type                = "RouteBased"
  sku                     = each.value.sku
  subnet_creation_enabled = false # Subnet already created by hub_networks module
  ip_configurations       = each.value.ip_configurations
  vpn_active_active_enabled = length(each.value.ip_configurations) > 1 ? true : false
  tags                    = var.tags
  
  depends_on = [module.hub_networks]
}

# Deploy ExpressRoute gateways where configured
module "expressroute_gateways" {
  source  = "Azure/avm-ptn-vnetgateway/azurerm"
  version = "0.6.3"
  
  # Create ExpressRoute gateways only where configured
  for_each = {
    for k, v in var.hub_virtual_networks : k => v.virtual_network_gateways.express_route
    if try(v.virtual_network_gateways.express_route, null) != null
  }
  
  name                    = each.value.name
  location                = each.value.location
  virtual_network_id      = module.hub_networks.virtual_networks["${each.key}"].id
  type                    = "ExpressRoute"
  sku                     = each.value.sku
  subnet_creation_enabled = false # Subnet already created by hub_networks module
  ip_configurations       = each.value.ip_configurations
  tags                    = var.tags
  
  depends_on = [module.hub_networks]
}

# Create public IPs for bastion hosts
resource "azurerm_public_ip" "bastion" {
  for_each = {
    for k, v in var.hub_virtual_networks : k => v.bastion
    if try(v.bastion, null) != null
  }
  
  name                = each.value.bastion_public_ip.name
  location            = var.hub_virtual_networks[each.key].hub_virtual_network.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = length(each.value.bastion_public_ip.zones) > 0 ? each.value.bastion_public_ip.zones : null
  
  tags = var.tags
  
  depends_on = [
    azurerm_resource_group.bastion
  ]
}

# Create resource groups for bastion where needed
resource "azurerm_resource_group" "bastion" {
  for_each = {
    for k, v in var.hub_virtual_networks : k => v
    if try(v.bastion, null) != null && 
       try(v.bastion.resource_group_creation_enabled, false) == true
  }
  
  name     = each.value.bastion.resource_group_name
  location = each.value.hub_virtual_network.location
  tags     = var.tags
}

# Deploy bastion hosts
module "bastion_hosts" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.4.0"
  
  for_each = {
    for k, v in var.hub_virtual_networks : k => v.bastion
    if try(v.bastion, null) != null
  }
  
  name                = each.value.bastion_host.name
  location            = var.hub_virtual_networks[each.key].hub_virtual_network.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  
  ip_configuration = {
    name                 = try(each.value.bastion_host.ip_configuration_name, "configuration")
    subnet_id            = "${module.hub_networks.virtual_networks["${each.key}"].id}/subnets/AzureBastionSubnet"
    public_ip_address_id = azurerm_public_ip.bastion[each.key].id
  }
  
  tags = var.tags
  
  depends_on = [module.hub_networks, azurerm_public_ip.bastion]
}

resource "azurerm_resource_group" "dns" {
  for_each = {
    for k, v in var.hub_virtual_networks : k => v
    if try(v.private_dns_zones, null) != null && 
       try(v.private_dns_zones.resource_group_creation_enabled, false) == true
  }
  
  name     = each.value.private_dns_zones.resource_group_name
  location = each.value.hub_virtual_network.location
  tags     = var.tags
}

# Deploy private DNS zones and link to ALL hub networks
module "private_dns_zones" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"
  
  for_each = {
    for item in flatten([
      for hub_key, hub_config in var.hub_virtual_networks : [
        for zone in try(hub_config.private_dns_zones.private_dns_zones, []) : {
          key                = "${hub_key}-${zone}"
          zone_name          = zone
          hub_key            = hub_key
          resource_group_name = hub_config.private_dns_zones.resource_group_name
        }
      ]
      if try(hub_config.private_dns_zones, null) != null
    ]) : item.key => item
  }
  
  domain_name         = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  
  # Create links to ALL hub networks, not just the one where the zone is defined
  virtual_network_links = {
    for hub_key, hub_config in var.hub_virtual_networks : 
      "link-${module.hub_networks.virtual_networks[hub_key].name}" => {
        vnetlinkname     = "link-${module.hub_networks.virtual_networks[hub_key].name}"
        vnetid           = module.hub_networks.virtual_networks[hub_key].id
        autoregistration = false
        tags             = var.tags
      }
  }
  
  tags = var.tags
  
  depends_on = [module.hub_networks, azurerm_resource_group.dns]
}

# Deploy a private DNS zone with autoregistration for each hub
module "private_dns_autoregistration_zones" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"
  
  for_each = {
    for hub_key, hub_config in var.hub_virtual_networks : hub_key => hub_config.private_dns_zones
    if try(hub_config.private_dns_zones.autoregistration_zone, null) != null
  }
  
  domain_name         = each.value.autoregistration_zone
  resource_group_name = each.value.resource_group_name
  
  # Create links to ALL hub networks, but with autoregistration only for the owning hub
  virtual_network_links = {
    for link_hub_key, link_hub_config in var.hub_virtual_networks : 
      "link-${module.hub_networks.virtual_networks[link_hub_key].name}" => {
        vnetlinkname     = "link-${module.hub_networks.virtual_networks[link_hub_key].name}"
        vnetid           = module.hub_networks.virtual_networks[link_hub_key].id
        # Only enable autoregistration for the hub that owns this zone
        autoregistration = link_hub_key == each.key
        tags             = var.tags
      }
  }
  
  tags = var.tags
  
  depends_on = [module.hub_networks]
}