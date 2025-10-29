# Remote state backend configuration
# Before first use, create the storage account and container:
# See scripts/bootstrap-backend.ps1

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate${var.environment}" # must be globally unique
    container_name       = "tfstate"
    key                  = "landing-zone.tfstate"
    use_oidc             = true
  }
}
