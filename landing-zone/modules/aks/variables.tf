variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "sp_app_id" {
  type = string
}

variable "sp_secret" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS cluster"
  type        = string
  default     = "aks"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}
