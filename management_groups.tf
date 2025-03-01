module "management_groups" {
  source             = "Azure/avm-ptn-alz/azurerm"
  version            = "0.11.1"
  architecture_name  = "alz"
  parent_resource_id = var.root_parent_management_group_id
  location           = var.location
  policy_default_values = { # requires to be json encoded
    for param_name, param_value in local.management_groups.policy_default_values :
    param_name => jsonencode({ value = param_value })
  }
  policy_assignments_to_modify = { for management_group_key, management_group_value in try(var.management_group_settings.policy_assignments_to_modify, {}) : management_group_key => {
    policy_assignments = { for policy_assignment_key, policy_assignment_value in management_group_value.policy_assignments : policy_assignment_key => {
      enforcement_mode        = try(policy_assignment_value.enforcement_mode, null)
      identity                = try(policy_assignment_value.identity, null)
      identity_ids            = try(policy_assignment_value.identity_ids, null)
      parameters              = try({ for parameter_key, parameter_value in policy_assignment_value.parameters : parameter_key => jsonencode({ value = parameter_value }) }, null)
      non_compliance_messages = try(policy_assignment_value.non_compliance_messages, null)
      resource_selectors      = try(policy_assignment_value.resource_selectors, null)
      overrides               = try(policy_assignment_value.overrides, null)
    } }
  } }
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
  timeouts = local.management_groups.default_timeouts
  dependencies = {
    policy_assignments = [
      module.management_resources,
      module.hub_and_spoke_vnet
    ]
    policy_role_assignments = [
      module.management_resources,
      module.hub_and_spoke_vnet
    ]
  }
  override_policy_definition_parameter_assign_permissions_set   = null
  override_policy_definition_parameter_assign_permissions_unset = null
}

locals {
  dcr_change_tracking_name                = "dcr-changetrack-${var.loc}-01"
  dcr_defender_sql_name                   = "dcr-defender-sql-${var.loc}-01"
  dcr_vm_insights_name                    = "dcr-vm-insights-${var.loc}-01"
  ama_user_assigned_managed_identity_name = "uami-ama-${var.loc}-01"
  log_analytics_workspace_name            = "law-mgmt-${var.loc}-01"
  ddos_protection_plan_name               = "ddos-${var.loc}-01"
  management_groups = {
    policy_default_values = {
      ama_change_tracking_data_collection_rule_id = "/subscriptions/${var.subscription_id_management}/providers/Microsoft.Insights/dataCollectionRules/${local.dcr_change_tracking_name}"
      ama_vm_insights_data_collection_rule_id     = "/subscriptions/${var.subscription_id_management}/providers/Microsoft.Insights/dataCollectionRules/${local.dcr_vm_insights_name}"
      ama_user_assigned_managed_identity_id       = "/subscriptions/${var.subscription_id_management}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${local.ama_user_assigned_managed_identity_name}"
      log_analytics_workspace_id                  = "/subscriptions/${var.subscription_id_management}/providers/Microsoft.OperationalInsights/workspaces/${local.log_analytics_workspace_name}"
      ama_mdfc_sql_data_collection_rule_id        = "/subscriptions/${var.subscription_id_management}/providers/Microsoft.Insights/dataCollectionRules/${local.dcr_defender_sql_name}"
      ama_user_assigned_managed_identity_name     = local.ama_user_assigned_managed_identity_name
      # ddos_protection_plan_id                     = "/subscriptions/${var.subscription_id_management}/providers/Microsoft.Network/ddosProtectionPlans/${local.ddos_protection_plan_name}" 
      # private_dns_zone_subscription_id            = var.subscription_id_connectivity
      # private_dns_zone_region                     = var.location
      # private_dns_zone_resource_group_name        = "rg-dns-hub-01"
    }
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

locals {
  policy_assignments_to_modify = {
    alz = {
      policy_assignments = {
        Deploy-MDFC-Config-H224 = {
          parameters = {
            ascExportResourceGroupName     = "rg-asc-${var.loc}-01"
            ascExportResourceGroupLocation = var.location
            emailSecurityContact           = "replace.me@placeholder.com"
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
        Allowed-Locations = { # allowed_locations.alz_policy_assignment.json
          enforcement_mode = "DoNotEnforce"
          parameters = {
            listOfAllowedLocations = [
              "uksouth",
              "ukwest"
            ]
          }
        }
        Allowed-RG-Locations = { # allowed_locations_resource_groups.alz_policy_assignment.json
          enforcement_mode = "DoNotEnforce"
          parameters = {
            listOfAllowedLocations = [
              "uksouth",
              "ukwest"
            ]
          }
        }
      }
    }
    platform = {
      policy_assignments = {
        DenyAction-DeleteUAMIAMA = { enforcement_mode = "DoNotEnforce" }
        Deploy-MDFC-DefSQL-AMA   = { enforcement_mode = "DoNotEnforce" }
        Deploy-VM-ChangeTrack    = { enforcement_mode = "DoNotEnforce" }
        Deploy-VM-Monitoring     = { enforcement_mode = "DoNotEnforce" }
        Deploy-vmArc-ChangeTrack = { enforcement_mode = "DoNotEnforce" }
        Deploy-vmHybr-Monitoring = { enforcement_mode = "DoNotEnforce" }
        Deploy-VMSS-ChangeTrack  = { enforcement_mode = "DoNotEnforce" }
        Deploy-VMSS-Monitoring   = { enforcement_mode = "DoNotEnforce" }
        Enable-AUM-CheckUpdates  = { enforcement_mode = "DoNotEnforce" }
        Enforce-ASR              = { enforcement_mode = "DoNotEnforce" }
        Enforce-GR-KeyVault      = { enforcement_mode = "DoNotEnforce" }
        Enforce-Subnet-Private   = { enforcement_mode = "DoNotEnforce" }
        Inherit-RG-Tags          = { enforcement_mode = "DoNotEnforce" } # Custom Policy
        Enforce-VM-Tags          = { enforcement_mode = "DoNotEnforce" } # Custom Policy
        Enforce-RG-Tags          = { enforcement_mode = "DoNotEnforce" } # Custom Policy
      }
    }
    landingzones = {
      policy_assignments = {
        Audit-AppGW-WAF          = { enforcement_mode = "DoNotEnforce" }
        Deny-IP-forwarding       = { enforcement_mode = "DoNotEnforce" }
        Deny-MgmtPorts-Internet  = { enforcement_mode = "DoNotEnforce" }
        Deny-Priv-Esc-AKS        = { enforcement_mode = "DoNotEnforce" }
        Deny-Privileged-AKS      = { enforcement_mode = "DoNotEnforce" }
        Deny-Storage-http        = { enforcement_mode = "DoNotEnforce" }
        Deny-Subnet-Without-Nsg  = { enforcement_mode = "DoNotEnforce" }
        Deploy-AzSqlDb-Auditing  = { enforcement_mode = "DoNotEnforce" }
        Deploy-MDFC-DefSQL-AMA   = { enforcement_mode = "DoNotEnforce" }
        Deploy-SQL-TDE           = { enforcement_mode = "DoNotEnforce" }
        Deploy-SQL-Threat        = { enforcement_mode = "DoNotEnforce" }
        Deploy-VM-Backup         = { enforcement_mode = "DoNotEnforce" }
        Deploy-VM-ChangeTrack    = { enforcement_mode = "DoNotEnforce" }
        Deploy-VM-Monitoring     = { enforcement_mode = "DoNotEnforce" }
        Deploy-vmArc-ChangeTrack = { enforcement_mode = "DoNotEnforce" }
        Deploy-vmHybr-Monitoring = { enforcement_mode = "DoNotEnforce" }
        Deploy-VMSS-ChangeTrack  = { enforcement_mode = "DoNotEnforce" }
        Deploy-VMSS-Monitoring   = { enforcement_mode = "DoNotEnforce" }
        Enable-AUM-CheckUpdates  = { enforcement_mode = "DoNotEnforce" }
        Enable-DDoS-VNET         = { enforcement_mode = "DoNotEnforce" }
        Enforce-AKS-HTTPS        = { enforcement_mode = "DoNotEnforce" }
        Enforce-ASR              = { enforcement_mode = "DoNotEnforce" }
        Enforce-GR-KeyVault      = { enforcement_mode = "DoNotEnforce" }
        Enforce-Subnet-Private   = { enforcement_mode = "DoNotEnforce" }
        Enforce-TLS-SSL-H224     = { enforcement_mode = "DoNotEnforce" }
        Enforce-TLS-SSL-Q225     = { enforcement_mode = "DoNotEnforce" }
        Inherit-RG-Tags          = { enforcement_mode = "DoNotEnforce" } # Custom Policy
        Enforce-VM-Tags          = { enforcement_mode = "DoNotEnforce" } # Custom Policy
        Enforce-RG-Tags          = { enforcement_mode = "DoNotEnforce" } # Custom Policy
      }
    }
    corp = {
      policy_assignments = {
        Audit-PeDnsZones         = { enforcement_mode = "DoNotEnforce" }
        Deny-HybridNetworking    = { enforcement_mode = "DoNotEnforce" }
        Deny-Public-Endpoints    = { enforcement_mode = "DoNotEnforce" }
        Deny-Public-IP-On-NIC    = { enforcement_mode = "DoNotEnforce" }
        Deploy-Private-DNS-Zones = { enforcement_mode = "DoNotEnforce" }
      }
    }
    online = { # Online archetype has no policy assignments
      policy_assignments = {}
    }
    sandbox = {
      policy_assignments = {
        Enforce-ALZ-Sandbox = { enforcement_mode = "DoNotEnforce" }
      }
    }
    management = { # Management archetype has no policy assignments
      policy_assignments = {}
    }
    connectivity = {
      policy_assignments = {
        Enable-DDoS-VNET = {
          enforcement_mode = "DoNotEnforce"
        }
      }
    }
    identity = {
      policy_assignments = {
        Deny-MgmtPorts-Internet = { enforcement_mode = "DoNotEnforce" }
        Deny-Public-IP          = { enforcement_mode = "DoNotEnforce" }
        Deny-Subnet-Without-Nsg = { enforcement_mode = "DoNotEnforce" }
        Deploy-VM-Backup        = { enforcement_mode = "DoNotEnforce" }
      }
    }
    decommissioned = {
      policy_assignments = {
        Enforce-ALZ-Decomm = { enforcement_mode = "DoNotEnforce" }
      }
    }
  }
}