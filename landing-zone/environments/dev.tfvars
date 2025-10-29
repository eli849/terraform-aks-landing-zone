# Development Environment Variables

environment          = "dev"
rg_name              = "rg-aks-dev"
location             = "eastus"
sp_name              = "sp-aks-dev"
vnet_cidr            = ["10.0.0.0/16"]
subnet_cidr          = ["10.0.1.0/24"]
aks_cluster_name     = "aks-cluster-dev"
aks_dns_prefix       = "aks-dev"
node_count           = 2
vm_size              = "Standard_D2s_v3"
