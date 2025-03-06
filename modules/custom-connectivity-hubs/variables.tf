variable "hub_virtual_networks" {
  description = "Configuration for hub virtual networks and their components"
  type = map(object({
    hub_virtual_network = object({
      name                          = string
      resource_group_name           = string
      resource_group_creation_enabled = optional(bool, false)
      location                      = string
      address_space                 = list(string)
      routing_address_space         = optional(list(string), [])
      route_table_name_firewall     = optional(string)
      route_table_name_user_subnets = optional(string)
      ddos_protection_plan_id       = optional(string)
      mesh_peering_enabled          = optional(bool)
      resource_group_lock_enabled   = optional(bool)
      hub_router_ip_address         = optional(string)
      subnets                       = optional(map(object({
        name             = string
        address_prefixes = list(string)
      })), {})
      firewall = optional(object({
        subnet_address_prefix            = string
        name                             = optional(string)
        sku_name                         = string
        sku_tier                         = string
        zones                            = optional(list(string))
        management_subnet_address_prefix = optional(string)
        management_ip_configuration = optional(object({
          name = optional(string)
          public_ip_config = optional(object({
            name  = optional(string)
            zones = optional(list(string))
          }))
        }))
        default_ip_configuration = optional(object({
          name = optional(string)
          public_ip_config = optional(object({
            name  = optional(string)
            zones = optional(list(string))
          }))
        }))
        firewall_policy = optional(object({
          name = optional(string)
          sku  = optional(string)
        }))
        firewall_policy_id = optional(string)
      }))
    })
    virtual_network_gateways = optional(object({
      subnet_address_prefix = string
      vpn = optional(object({
        location = string
        name     = string
        sku      = string
        ip_configurations = map(object({
          public_ip = object({
            name  = string
            zones = list(string)
          })
        }))
      }))
      express_route = optional(object({
        location = string
        name     = string
        sku      = string
        ip_configurations = map(object({
          public_ip = object({
            name  = string
            zones = list(string)
          })
        }))
      }))
    }))
    private_dns_zones = optional(object({
      resource_group_name           = string
      resource_group_creation_enabled = optional(bool, false)
      private_dns_zones             = list(string)
      autoregistration_zone         = optional(string)
    }))
    bastion = optional(object({
      sku                           = string
      resource_group_name           = string
      resource_group_creation_enabled = optional(bool, false)
      subnet_address_prefix         = string
      bastion_host = object({
        name = string
      })
      bastion_public_ip = object({
        name  = string
        zones = list(string)
      })
    }))
  }))
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}