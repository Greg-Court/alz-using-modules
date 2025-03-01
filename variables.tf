variable "root_parent_management_group_id" {
  type        = string
  description = "Parent Management Group ID for the ALZ hierarchy."
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID for Management resources."
}

variable "subscription_id_identity" {
  type        = string
  description = "Subscription ID for Identity resources."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID for Connectivity resources."
}

variable "loc" {
  type        = string
  description = "Short location code, e.g. 'uk' or 'use'"
}

variable "location" {
  type        = string
  description = "Azure Region name, e.g. 'uksouth'"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Default tags to apply to all resources."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Enable telemetry for all resources."
}

variable "management_group_settings" {
  type        = any
  default     = {}
  description = "Settings for the Management Group module."
}