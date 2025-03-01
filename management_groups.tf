module "management_groups" {
  source             = "Azure/avm-ptn-alz/azurerm"
  version            = "0.11.0"
  architecture_name  = "alz"
  parent_resource_id = var.root_parent_management_group_id
  location           = var.location
  policy_default_values = {
    ama_change_tracking_data_collection_rule_id = module.management_resources.data_collection_rule_ids["change_tracking"].id
    ama_mdfc_sql_data_collection_rule_id        = module.management_resources.data_collection_rule_ids["defender_sql"].id
    ama_vm_insights_data_collection_rule_id     = module.management_resources.data_collection_rule_ids["vm_insights"].id
    ama_user_assigned_managed_identity_id       = module.management_resources.user_assigned_identity_ids["ama"].id
    # ama_user_assigned_managed_identity_name     = module.management_resources.user_assigned_identity_names["ama"].name # incorrect, unnecessary?
    log_analytics_workspace_id                  = module.management_resources.log_analytics_workspace.id
    ddos_protection_plan_id                     = null
    private_dns_zone_subscription_id            = var.subscription_id_connectivity
    private_dns_zone_region                     = var.location
    private_dns_zone_resource_group_name        = "rg-dns-hub-01" # TBC
  }
  policy_assignments_to_modify = {
    alz = {
      policy_assignments = {
        Deploy-MDFC-Config-H224 = {
          parameters = {
            ascExportResourceGroupName                  = "rg-asc-${var.loc}-01"
            ascExportResourceGroupLocation              = var.location
            emailSecurityContact                        = "replace.me@placeholder.com"
            # change to DeployIfNotExists later
            enableAscForServers                         = "DoNotEnforce"
            enableAscForServersVulnerabilityAssessments = "DoNotEnforce"
            enableAscForSql                             = "DoNotEnforce"
            enableAscForAppServices                     = "DoNotEnforce"
            enableAscForStorage                         = "DoNotEnforce"
            enableAscForContainers                      = "DoNotEnforce"
            enableAscForKeyVault                        = "DoNotEnforce"
            enableAscForSqlOnVm                         = "DoNotEnforce"
            enableAscForArm                             = "DoNotEnforce"
            enableAscForOssDb                           = "DoNotEnforce"
            enableAscForCosmosDbs                       = "DoNotEnforce"
            enableAscForCspm                            = "DoNotEnforce"
          }
        }
      }
    }
    connectivity = {
      policy_assignments = {
        Enable-DDoS-VNET = {
          enforcement_mode = "DoNotEnforce"
        }
      }
    }
    # Example of how to update a policy assignment enforcement mode for Private Link DNS Zones
    # corp = {
    #   policy_assignments = {
    #     Deploy-Private-DNS-Zones = {
    #       enforcement_mode = "DoNotEnforce"
    #     }
    #   }
    # }
  }
  delays                              = try(var.management_group_settings.delays, {})
  enable_telemetry                    = var.enable_telemetry
  management_group_hierarchy_settings = null
  partner_id                          = null
  retries                             = try(var.management_group_settings.retries, local.default_retries)
  subscription_placement = {
    identity = {
      subscription_id       = var.subscription_id_identity
      management_group_name = "identity"
    }
    connectivity = {
      subscription_id       = var.subscription_id_connectivity
      management_group_name = "connectivity"
    }
    management = {
      subscription_id       = var.subscription_id_management
      management_group_name = "management"
    }
  }
  timeouts                                                      = local.management_groups.default_timeouts
  dependencies                                                  = null # TBC
  override_policy_definition_parameter_assign_permissions_set   = null
  override_policy_definition_parameter_assign_permissions_unset = null
}

locals {
  management_groups = {
    default_timeouts = {
      management_group = {
        create = "60m"
        read   = "60m"
      }
      role_definition = {
        create = "60m"
        read   = "60m"
      }
      policy_assignment = {
        create = "60m"
        read   = "60m"
      }
      policy_definition = {
        create = "60m"
        read   = "60m"
      }
      policy_set_definition = {
        create = "60m"
        read   = "60m"
      }
      policy_role_assignment = {
        create = "60m"
        read   = "60m"
      }
    }
  }
}
