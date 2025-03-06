module "custom_connectivity_hubs" {
  source = "./modules/custom-connectivity-hubs"
  hub_virtual_networks = {
    primary = {
      hub_virtual_network = {
        resource_group_name             = "rg-hub-${var.loc}-01"
        resource_group_creation_enabled = true
        name                            = "vnet-hub-${var.loc}-01"
        location                        = var.location
        address_space                   = ["10.0.0.0/16"]
        routing_address_space           = [] # set to empty to prevent routes being automatically created
        # route_table_name_firewall       = "rt-hub-fw-${var.loc}-01"
        # route_table_name_user_subnets   = "rt-hub-std-${var.loc}-01"
        # route_table_entries_firewall = [
        #   {
        #     name                = "test"
        #     address_prefix      = "192.168.0.0/20"
        #     next_hop_type       = "VirtualAppliance"
        #     next_hop_ip_address = "10.0.0.4"
        #   }
        # ]
        # route_table_entries_user_subnets = [
        #   {
        #     name                = "test"
        #     address_prefix      = "192.168.0.0/20"
        #     next_hop_type       = "VirtualAppliance"
        #     next_hop_ip_address = "10.0.0.4"
        #   }
        # ]
        # hub_router_ip_address           = "10.0.0.4"  # required if not deploying firewall!
        ddos_protection_plan_id         = null
        resource_group_lock_enabled     = false
        subnets = {
          "TestSubnet" = {
            name             = "TestSubnet"
            address_prefixes = ["10.0.10.0/26"]
          }
        }
        firewall = {
          subnet_address_prefix = "10.0.0.0/26"
          name                  = "fw-hub-${var.loc}-01"
          sku_name              = "AZFW_VNet"
          sku_tier              = "Basic"
          zones                 = []
          default_ip_configuration = {
            public_ip_config = {
              name  = "pip-fw-hub-${var.loc}-01"
              zones = []
            }
          }
          management_subnet_address_prefix = "10.0.0.192/26" # only required if Basic SKU
          management_ip_configuration = {                    # only required if Basic SKU
            name = "myManagementIp"
            public_ip_config = {
              name  = "pip-fw-hub-mgmt-${var.loc}-01"
              zones = ["1", "2", "3"]
            }
          }
          firewall_policy = {
            name = "fwp-hub-${var.loc}-01"
            sku  = "Basic"
          }
        }
      }

      # virtual_network_gateways = {
      #   subnet_address_prefix = "10.0.0.128/26"
      #   vpn = {
      #     location = var.location
      #     name     = "vgw-hub-vpn-${var.loc}-01"
      #     sku      = "VpnGw1"
      #     ip_configurations = {
      #       active_active_1 = {
      #         public_ip = {
      #           name = "pip-vgw-hub-vpn-${var.loc}-01"
      #           # zones = ["1", "2", "3"]
      #           zones = []
      #         }
      #       }
      #       active_active_2 = {
      #         public_ip = {
      #           name = "pip-vgw-hub-vpn-${var.loc}-02"
      #           # zones = ["1", "2", "3"]
      #           zones = []
      #         }
      #       }
      #     }
      #   }
      #   # express_route = {
      #   #   location = var.location
      #   #   name     = "vgw-hub-er-${var.loc}-01"
      #   #   sku      = "ErGw2AZ"
      #   #   ip_configurations = {
      #   #     default = {
      #   #       public_ip = {
      #   #         name  = "pip-vgw-hub-er-${var.loc}-01"
      #   #         zones = ["1", "2", "3"]
      #   #       }
      #   #     }
      #   #   }
      #   # }
      # }
      private_dns_zones = {
        resource_group_name             = "rg-hub-dns-${var.loc}-01"
        resource_group_creation_enabled = true
        private_dns_zones = [
          "privatelink.blob.core.windows.net",
          "privatelink.file.core.windows.net",
          "privatelink.queue.core.windows.net",
          "privatelink.table.core.windows.net"
        ]
        autoregistration_zone = "az.internal"
      }
      # bastion = {
      #   sku                             = "Basic"
      #   resource_group_name             = "rg-hub-bas-${var.loc}-01"
      #   resource_group_creation_enabled = true
      #   subnet_address_prefix           = "10.0.0.64/26"
      #   bastion_host = {
      #     name = "bas-hub-${var.loc}-01"
      #   }
      #   bastion_public_ip = {
      #     name  = "pip-bas-hub-${var.loc}-01"
      #     zones = []
      #   }
      # }
    }
    secondary = {
      hub_virtual_network = {
        resource_group_name             = "rg-hub-${var.loc_sec}-01"
        resource_group_creation_enabled = true
        name                            = "vnet-hub-${var.loc_sec}-01"
        location                        = var.location_secondary
        address_space                   = ["10.1.0.0/16"]
        routing_address_space           = [] # set to empty to prevent routes being automatically created
        route_table_name_firewall       = "rt-hub-fw-${var.loc_sec}-01"
        route_table_name_user_subnets   = "rt-hub-std-${var.loc_sec}-01"
        ddos_protection_plan_id         = null
        resource_group_lock_enabled     = false
        hub_router_ip_address           = "10.1.0.4"  # required if not deploying firewall!
        subnets = {
          "TestSubnet" = {
            name             = "TestSubnet"
            address_prefixes = ["10.1.10.0/26"]
          }
        }
        # firewall = {
        #   subnet_address_prefix = "10.1.0.0/26"
        #   name                  = "fw-hub-${var.loc_sec}-01"
        #   sku_name              = "AZFW_VNet"
        #   sku_tier              = "Standard"
        #   zones                 = []
        #   default_ip_configuration = {
        #     public_ip_config = {
        #       name  = "pip-fw-hub-${var.loc_sec}-01"
        #       zones = []
        #     }
        #   }
        #   # management_subnet_address_prefix = "10.1.0.192/26" # only required if Basic SKU
        #   # management_ip_configuration = {                    # only required if Basic SKU
        #   #   name = "myManagementIp"
        #   #   public_ip_config = {
        #   #     name  = "fw-hub-mgmt-${var.loc_sec}-01"
        #   #     zones = ["1", "2", "3"]
        #   #   }
        #   # }
        #   firewall_policy = {
        #     name = "fwp-hub-${var.loc_sec}-01"
        #   }
        # }
      }
      virtual_network_gateways = {
        subnet_address_prefix = "10.1.0.128/26"
      }
      private_dns_zones = {
        resource_group_name             = "rg-hub-dns-ukw-01"
        resource_group_creation_enabled = true
        private_dns_zones = [
          "mytest.dns.zone",
          "mytest2.dns.zone"
        ]
      }
    }
  }

  tags = {
    "place" = "holder"
  }

  providers = {
    azurerm = azurerm.connectivity
  }
}

output "primary_network_id" {
  description = "Raw output of the hub networks created by the module"
  value       = module.custom_connectivity_hubs.hub_networks.primary.id
}

output "dns_resource_group" {
  description = "The DNS resource group created by the module"
  value       = module.custom_connectivity_hubs.resource_groups.primary.dns
}


resource "azurerm_route_table" "firewall" {
  name                = "rt-hub-fw-${var.loc}-01-custom"
  location            = var.location
  resource_group_name = "rg-hub-${var.loc}-01"
  
  disable_bgp_route_propagation = false
  
  route {
    name                   = "Internet"
    address_prefix         = "0.0.0.0/20"
    next_hop_type          = "Internet"
  }
  
  tags = var.tags
  
  # Ensure the resource group exists before creating the route table
  depends_on = [module.custom_connectivity_hubs]
}

resource "azurerm_route_table" "user_subnets" {
  name                = "rt-hub-std-${var.loc}-01-custom"
  location            = var.location
  resource_group_name = "rg-hub-${var.loc}-01"
  
  # Optionally disable BGP route propagation
  disable_bgp_route_propagation = false
  
  # Add your routes
  route {
    name                   = "test"
    address_prefix         = "192.168.0.0/20"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"
  }
  
  # Add additional routes as needed
  
  tags = var.tags
  
  # Ensure the resource group exists before creating the route table
  depends_on = [module.custom_connectivity_hubs]
}