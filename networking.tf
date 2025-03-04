resource "azurerm_resource_group" "hub_primary" {
  name     = "rg-hub-${var.loc}-01"
  location = var.location
  provider = azurerm.connectivity
}

resource "azurerm_resource_group" "dns" {
  name     = "rg-hub-dns-${var.loc}-01"
  location = var.location
  provider = azurerm.connectivity
}

resource "azurerm_resource_group" "bastion_primary" {
  name     = "rg-hub-bas-${var.loc}-01"
  location = var.location
  provider = azurerm.connectivity
}

module "hub_and_spoke_vnet" {
  source = "./modules/connectivity-hub"
  hub_virtual_networks = {
    primary = {
      hub_virtual_network = {
        name                          = "vnet-hub-${var.loc}-01"
        resource_group_name           = azurerm_resource_group.hub_primary.name
        location                      = var.location
        address_space                 = ["10.0.0.0/16"]
        routing_address_space         = ["10.0.0.0/16"]
        route_table_name_firewall     = "rt-hub-fw-${var.loc}-01"
        route_table_name_user_subnets = "rt-hub-std-${var.loc}-01"
        ddos_protection_plan_id       = null
        subnets                       = {}
        # firewall = {
        #   subnet_address_prefix = "10.0.0.0/26"
        #   name                  = "fw-hub-${var.loc}-01"
        #   sku_name              = "AZFW_VNet"
        #   sku_tier              = "Standard"
        #   zones                 = ["1", "2", "3"]
        #   default_ip_configuration = {
        #     public_ip_config = {
        #       name  = "pip-fw-hub-${var.loc}-01"
        #       zones = ["1", "2", "3"]
        #     }
        #   }
        #   # management_subnet_address_prefix = "10.0.0.192/26" # only required if Basic SKU
        #   # management_ip_configuration = {                    # only required if Basic SKU
        #   #   name = "myManagementIp"
        #   #   public_ip_config = {
        #   #     name  = "fw-hub-mgmt-${var.loc}-01"
        #   #     zones = ["1", "2", "3"]
        #   #   }
        #   # }
        #   firewall_policy = {
        #     name = "fwp-hub-${var.loc}-01"
        #   }
        # }
      }

      virtual_network_gateways = {
        subnet_address_prefix = "10.0.0.128/26"
        # vpn = {
        #   location = var.location
        #   name     = "vgw-hub-vpn-${var.loc}-01"
        #   sku      = "VpnGw1"
        #   ip_configurations = {
        #     active_active_1 = {
        #       public_ip = {
        #         name  = "pip-vgw-hub-vpn-${var.loc}-01"
        #         # zones = ["1", "2", "3"]
        #         zones = []
        #       }
        #     }
        #     active_active_2 = {
        #       public_ip = {
        #         name  = "pip-vgw-hub-vpn-${var.loc}-02"
        #         # zones = ["1", "2", "3"]
        #         zones = []
        #       }
        #     }
        #   }
        # }
        # express_route = {
        #   location = var.location
        #   name     = "vgw-hub-er-${var.loc}-01"
        #   sku      = "ErGw2AZ"
        #   ip_configurations = {
        #     default = {
        #       public_ip = {
        #         name  = "pip-vgw-hub-er-${var.loc}-01"
        #         zones = ["1", "2", "3"]
        #       }
        #     }
        #   }
        # }
      }
      private_dns_zones = {
        resource_group_name = azurerm_resource_group.dns.name
        private_dns_zones = [
          "privatelink.blob.core.windows.net",
          "privatelink.file.core.windows.net",
          "privatelink.queue.core.windows.net",
          "privatelink.table.core.windows.net"
        ]
        autoregistration_zone = "az.internal"
      }
      # azure_dns_private_resolver = { # TODO!
      #   name = "pdr-hub-${var.loc}-01"
      #   subnet_address_prefix = "10.0.1.0/26"
      # }
      # bastion = {
      #   sku                   = "Basic"
      #   resource_group_name   = azurerm_resource_group.bastion_primary.name
      #   subnet_address_prefix = "10.0.0.64/26"
      #   bastion_host = {
      #     name = "bas-hub-${var.loc}-01"
      #   }
      #   bastion_public_ip = {
      #     name  = "pip-bas-hub-${var.loc}-01"
      #     zones = []
      #   }
      # }
    }
  }

  tags = {
    "place" = "holder"
  }

  providers = {
    azurerm = azurerm.connectivity
  }
}