terraform {
  required_version = "~> 1.9"
  required_providers {
    alz = {
      source  = "Azure/alz"
      version = "~> 0.16"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
  # backend "azurerm" {}
}

provider "alz" {
  library_overwrite_enabled = false
  library_references = [
    {
      path = "platform/alz"
      ref  = "2025.02.0" # find latest ref here https://github.com/Azure/Azure-Landing-Zones-Library
    },
    {
      custom_url = "${path.root}/lib"
    }
  ]
}

provider "azapi" {
  skip_provider_registration = true
  subscription_id            = var.subscription_id_management
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id_management
}

provider "azurerm" {
  resource_provider_registrations = "none"
  alias                           = "management"
  subscription_id                 = var.subscription_id_management
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  alias                           = "connectivity"
  subscription_id                 = var.subscription_id_connectivity
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
