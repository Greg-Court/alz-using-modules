locals {
  connectivity_resource_groups = {
    # ddos = {
    #   name     = "rg-hub-ddos-${var.loc}-01"
    #   location = var.location
    # }
    vnet_primary = {
      name     = "rg-hub-${var.loc}-01"
      location = var.location
    }
    dns = {
      name     = "rg-hub-dns-${var.loc}-01"
      location = var.location
    }
  }
  default_retries = {
    management_groups = {
      error_message_regex = ["AuthorizationFailed", "Permission to Microsoft.Management/managementGroups on resources of type 'Write' is required on the management group or its ancestors."]
    }
    role_definitions = {
      error_message_regex = ["AuthorizationFailed"]
    }
    policy_definitions = {
      error_message_regex = ["AuthorizationFailed"]
    }
    policy_set_definitions = {
      error_message_regex = ["AuthorizationFailed"]
    }
    policy_assignments = {
      error_message_regex = ["AuthorizationFailed", "The policy definition specified in policy assignment '.+' is out of scope"]
    }
    policy_role_assignments = {
      error_message_regex = ["AuthorizationFailed", "ResourceNotFound", "RoleAssignmentNotFound"]
    }
    hierarchy_settings = {
      error_message_regex = ["AuthorizationFailed"]
    }
    subscription_placement = {
      error_message_regex = ["AuthorizationFailed"]
    }
  }
}