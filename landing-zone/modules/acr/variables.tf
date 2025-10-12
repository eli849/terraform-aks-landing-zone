variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the ACR"
  type        = string
}

variable "location" {
  description = "The Azure region where the ACR should be created"
  type        = string
}

variable "acr_sku" {
  description = "The SKU of the ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Whether to enable the admin account for ACR"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
