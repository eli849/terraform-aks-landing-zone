# Bootstrap script to create Azure Storage backend for Terraform state
# Run this ONCE before first terraform init with backend

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$true)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId
)

$ErrorActionPreference = "Stop"

# Set subscription
az account set --subscription $SubscriptionId

# Variables
$ResourceGroupName = "rg-terraform-state"
$StorageAccountName = "sttfstate$Environment" # must be globally unique, lowercase, no hyphens
$ContainerName = "tfstate"

Write-Host "Creating Terraform state backend in Azure..." -ForegroundColor Cyan

# Create resource group
Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --tags "purpose=terraform-state" "environment=$Environment"

# Create storage account with secure defaults
Write-Host "Creating storage account: $StorageAccountName" -ForegroundColor Yellow
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false `
    --https-only true `
    --tags "purpose=terraform-state" "environment=$Environment"

# Enable versioning for state file protection
Write-Host "Enabling blob versioning..." -ForegroundColor Yellow
az storage account blob-service-properties update `
    --account-name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --enable-versioning true

# Create blob container
Write-Host "Creating blob container: $ContainerName" -ForegroundColor Yellow
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login

Write-Host "`nBackend created successfully!" -ForegroundColor Green
Write-Host "`nAdd this to your backend.tf:" -ForegroundColor Cyan
Write-Host @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$ResourceGroupName"
    storage_account_name = "$StorageAccountName"
    container_name       = "$ContainerName"
    key                  = "$Environment-landing-zone.tfstate"
    use_oidc             = true
  }
}
"@ -ForegroundColor White

Write-Host "`nFor Jenkins, set these environment variables or credentials:" -ForegroundColor Cyan
Write-Host "ARM_SUBSCRIPTION_ID=$SubscriptionId" -ForegroundColor White
Write-Host "ARM_TENANT_ID=$(az account show --query tenantId -o tsv)" -ForegroundColor White
Write-Host "ARM_USE_OIDC=true" -ForegroundColor White
