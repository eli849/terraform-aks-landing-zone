# Setup script to configure Azure Federated Identity for Jenkins OIDC authentication
# This allows Jenkins to authenticate to Azure without storing secrets

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$JenkinsUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "jenkins-terraform-sp"
)

$ErrorActionPreference = "Stop"

Write-Host "Setting up Azure Federated Identity for Jenkins..." -ForegroundColor Cyan

# Set subscription
az account set --subscription $SubscriptionId

$TenantId = az account show --query tenantId -o tsv
$SubscriptionName = az account show --query name -o tsv

Write-Host "Subscription: $SubscriptionName ($SubscriptionId)" -ForegroundColor Yellow
Write-Host "Tenant: $TenantId" -ForegroundColor Yellow

# Create Azure AD App Registration
Write-Host "`nCreating App Registration: $AppName" -ForegroundColor Yellow
$AppId = az ad app create `
    --display-name $AppName `
    --query appId -o tsv

if (!$AppId) {
    Write-Error "Failed to create app registration"
    exit 1
}

Write-Host "App (Client) ID: $AppId" -ForegroundColor Green

# Create Service Principal
Write-Host "Creating Service Principal..." -ForegroundColor Yellow
$SpObjectId = az ad sp create --id $AppId --query id -o tsv

# Assign Contributor role at subscription scope
Write-Host "Assigning Contributor role to Service Principal..." -ForegroundColor Yellow
az role assignment create `
    --assignee $AppId `
    --role Contributor `
    --scope "/subscriptions/$SubscriptionId"

# Configure Federated Credential for Jenkins
Write-Host "`nConfiguring Federated Identity Credential..." -ForegroundColor Yellow
$FederatedCredentialName = "jenkins-oidc-$((Get-Date).ToString('yyyyMMdd'))"

# Create federated credential JSON
$FederatedCredential = @{
    name = $FederatedCredentialName
    issuer = "$JenkinsUrl"
    subject = "system:serviceaccount:default:jenkins"
    description = "Jenkins OIDC federation for Terraform"
    audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json

$FederatedCredential | Out-File -FilePath "federated-credential.json" -Encoding utf8

az ad app federated-credential create `
    --id $AppId `
    --parameters '@federated-credential.json'

Remove-Item "federated-credential.json"

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`n=== Jenkins Configuration ===" -ForegroundColor Cyan
Write-Host "Add these as Jenkins credentials (Kind: Secret text):" -ForegroundColor White
Write-Host ""
Write-Host "Credential ID: azure-client-id" -ForegroundColor Yellow
Write-Host "Value: $AppId" -ForegroundColor White
Write-Host ""
Write-Host "Credential ID: azure-subscription-id" -ForegroundColor Yellow
Write-Host "Value: $SubscriptionId" -ForegroundColor White
Write-Host ""
Write-Host "Credential ID: azure-tenant-id" -ForegroundColor Yellow
Write-Host "Value: $TenantId" -ForegroundColor White
Write-Host ""
Write-Host "=== Environment Variables in Jenkinsfile ===" -ForegroundColor Cyan
Write-Host "ARM_CLIENT_ID = credentials('azure-client-id')" -ForegroundColor White
Write-Host "ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')" -ForegroundColor White
Write-Host "ARM_TENANT_ID = credentials('azure-tenant-id')" -ForegroundColor White
Write-Host "ARM_USE_OIDC = 'true'" -ForegroundColor White
Write-Host ""
Write-Host "No client secret needed - using OIDC!" -ForegroundColor Green
