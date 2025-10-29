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

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-cluster"
}

variable "aks_dns_prefix" {
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
