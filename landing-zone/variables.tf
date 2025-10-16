variable "rg_name" {
  description = "Resource group name to create/use"
  type        = string
  default     = "rg-landing-zone"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "westus"
}

variable "sp_name" {
  description = "Service Principal display name"
  type        = string
  default     = "aks-service-principal"
}

variable "vnet_cidr" {
  description = "VNet CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_cidr" {
  description = "Subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# AKS kubeconfig pieces (populated from module output)
variable "kube_host" {
  type = string
  default = ""
}

variable "kube_client_certificate" {
  type = string
  default = ""
}

variable "kube_client_key" {
  type = string
  default = ""
}

variable "kube_cluster_ca_certificate" {
  type = string
  default = ""
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure Client ID (Service Principal)"
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Azure Client Secret (Service Principal)"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}
