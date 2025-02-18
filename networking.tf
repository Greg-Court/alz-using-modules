module "hub_and_spoke_vnet" {
  source = "./modules/hub-and-spoke-vnet"

  hub_and_spoke_networks_settings = local.hub_and_spoke_vnet_settings
  hub_virtual_networks = {
    primary = {
      hub_virtual_network = {
        name                          = "$${primary_virtual_network_name}"
        resource_group_name           = "$${connectivity_hub_primary_resource_group_name}"
        location                      = "$${starter_location_01}"
        address_space                 = ["$${primary_hub_virtual_network_address_space}"]
        routing_address_space         = ["$${primary_hub_address_space}"]
        route_table_name_firewall     = "$${primary_route_table_firewall_name}"
        route_table_name_user_subnets = "$${primary_route_table_user_subnets_name}"
        ddos_protection_plan_id       = "$${ddos_protection_plan_id}"
        subnets                       = {}
        firewall = {
          subnet_address_prefix = "$${primary_firewall_subnet_address_prefix}"
          name                  = "$${primary_firewall_name}"
          sku_name              = "AZFW_VNet"
          sku_tier              = "Basic"
          zones                 = "$${starter_location_01_availability_zones}"
          default_ip_configuration = {
            public_ip_config = {
              name  = "$${primary_firewall_public_ip_name}"
              zones = "$${starter_location_01_availability_zones}"
            }
          }
          firewall_policy = {
            name = "$${primary_firewall_policy_name}"
          }
        }
      }
      virtual_network_gateways = {
        subnet_address_prefix = "$${primary_gateway_subnet_address_prefix}"
        express_route = {
          location = "$${starter_location_01}"
          name     = "$${primary_virtual_network_gateway_express_route_name}"
          sku      = "$${starter_location_01_virtual_network_gateway_sku_express_route}"
          ip_configurations = {
            default = {
              public_ip = {
                name  = "$${primary_virtual_network_gateway_express_route_public_ip_name}"
                zones = "$${starter_location_01_availability_zones}"
              }
            }
          }
        }
        vpn = {
          location = "$${starter_location_01}"
          name     = "$${primary_virtual_network_gateway_vpn_name}"
          sku      = "$${starter_location_01_virtual_network_gateway_sku_vpn}"
          ip_configurations = {
            active_active_1 = {
              public_ip = {
                name  = "$${primary_virtual_network_gateway_vpn_public_ip_name_1}"
                zones = "$${starter_location_01_availability_zones}"
              }
            }
            active_active_2 = {
              public_ip = {
                name  = "$${primary_virtual_network_gateway_vpn_public_ip_name_2}"
                zones = "$${starter_location_01_availability_zones}"
              }
            }
          }
        }
      }
      private_dns_zones = {
        resource_group_name            = "$${dns_resource_group_name}"
        is_primary                     = true
        auto_registration_zone_enabled = true
        auto_registration_zone_name    = "$${primary_auto_registration_zone_name}"
        subnet_address_prefix          = "$${primary_private_dns_resolver_subnet_address_prefix}"
        private_dns_resolver = {
          name = "$${primary_private_dns_resolver_name}"
        }
      }
      bastion = {
        subnet_address_prefix = "$${primary_bastion_subnet_address_prefix}"
        bastion_host = {
          name = "$${primary_bastion_host_name}"
        }
        bastion_public_ip = {
          name  = "$${primary_bastion_host_public_ip_name}"
          zones = "$${starter_location_01_availability_zones}"
        }
      }
    }
  }
  enable_telemetry = true
  tags = {
    "place" = "holder"
  }

  providers = {
    azurerm = azurerm.connectivity
  }
}
