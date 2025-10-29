# Production Environment Variables

environment          = "prod"
rg_name              = "rg-aks-prod"
location             = "eastus"
sp_name              = "sp-aks-prod"
vnet_cidr            = ["10.2.0.0/16"]
subnet_cidr          = ["10.2.1.0/24"]
aks_cluster_name     = "aks-cluster-prod"
aks_dns_prefix       = "aks-prod"
node_count           = 3
vm_size              = "Standard_D4s_v3"
