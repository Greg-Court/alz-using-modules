module "management_resources" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.6.0"

  automation_account_name                          = "aa-mgmt-${var.loc}-01"
  location                                         = var.location
  log_analytics_workspace_name                     = local.log_analytics_workspace_name
  resource_group_name                              = local.resource_group_name_management
  automation_account_encryption                    = null
  automation_account_identity                      = null
  automation_account_local_authentication_enabled  = true
  automation_account_location                      = null
  automation_account_public_network_access_enabled = true
  automation_account_sku_name                      = null
  data_collection_rules = {
    change_tracking = {
      name = "dcr-changetrack-${var.loc}-01"
    }
    defender_sql = {
      name = "dcr-defender-sql-${var.loc}-01"
    }
    vm_insights = {
      name = "dcr-vm-insights-${var.loc}-01"
    }
  }
  enable_telemetry                                           = true
  linked_automation_account_creation_enabled                 = false
  log_analytics_solution_plans                               = null
  log_analytics_workspace_allow_resource_only_permissions    = true
  log_analytics_workspace_cmk_for_query_forced               = null
  log_analytics_workspace_daily_quota_gb                     = null
  log_analytics_workspace_internet_ingestion_enabled         = true
  log_analytics_workspace_internet_query_enabled             = true
  log_analytics_workspace_local_authentication_disabled      = false
  log_analytics_workspace_reservation_capacity_in_gb_per_day = null
  log_analytics_workspace_retention_in_days                  = null
  log_analytics_workspace_sku                                = null
  resource_group_creation_enabled                            = true
  sentinel_onboarding                                        = null
  tags = {
    "example" = "tag"
  }
  user_assigned_managed_identities = {
    ama = {
      name = "uami-ama-${var.loc}-01"
    }
  }
}

locals {
  resource_group_name_management = "rg-mgmt-${var.loc}-02"
}
