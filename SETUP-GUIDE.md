# Jenkins + Azure + GitHub Integration Setup Guide

This guide walks you through setting up a secure CI/CD pipeline using Jenkins, Azure (with OIDC authentication), and GitHub.

## Prerequisites

- Azure subscription (you're using "GSL research dev test")
- Jenkins server with Azure CLI installed
- GitHub repository
- Azure CLI installed locally for setup

## Architecture Overview

```
GitHub Repo → Jenkins Pipeline → Azure (OIDC Auth) → Terraform → AKS + Resources
                                 ↓
                      Azure Storage (Remote State)
```

**Security Features:**
- ✅ OIDC authentication (no secrets stored)
- ✅ Remote state in Azure Storage with versioning
- ✅ Approval gates for apply/destroy
- ✅ Least privilege RBAC
- ✅ Environment-specific configurations

---

## Step 1: Bootstrap Remote State Storage

Run this script to create the Azure Storage account for Terraform state:

```powershell
cd c:\Users\v-elijahmay\Desktop\DevOps
.\scripts\bootstrap-backend.ps1 `
    -Environment "dev" `
    -Location "eastus" `
    -SubscriptionId "<your-subscription-id>"
```

**What this creates:**
- Resource Group: `rg-terraform-state`
- Storage Account: `sttfstatedev` (with TLS 1.2, blob versioning, private access)
- Container: `tfstate`

**Outputs:** Backend configuration snippet and environment variables (save these for later)

---

## Step 2: Configure Azure Federated Identity (OIDC)

This allows Jenkins to authenticate to Azure without storing secrets.

### 2.1 Get Your Jenkins OIDC Issuer URL

In Jenkins, go to **Manage Jenkins** → **Configure System** → Find your Jenkins URL (e.g., `https://jenkins.example.com`)

### 2.2 Run the Setup Script

```powershell
.\scripts\setup-jenkins-oidc.ps1 `
    -SubscriptionId "<your-subscription-id>" `
    -JenkinsUrl "https://jenkins.example.com" `
    -AppName "jenkins-terraform-sp"
```

**What this creates:**
- Azure AD App Registration: `jenkins-terraform-sp`
- Service Principal with Contributor role at subscription scope
- Federated Identity Credential for OIDC trust with Jenkins

**Important:** The script outputs three values you'll need for Jenkins:
- `ARM_CLIENT_ID` (App/Client ID)
- `ARM_SUBSCRIPTION_ID` (Your subscription ID)
- `ARM_TENANT_ID` (Your tenant ID)

---

## Step 3: Configure Jenkins Credentials

In Jenkins, go to **Manage Jenkins** → **Manage Credentials** → **(global)** → **Add Credentials**

Add these three credentials (Kind: **Secret text**):

| ID | Secret Value | Description |
|----|--------------|-------------|
| `azure-client-id` | `<ARM_CLIENT_ID from Step 2>` | Azure App Client ID |
| `azure-subscription-id` | `<ARM_SUBSCRIPTION_ID from Step 2>` | Azure Subscription ID |
| `azure-tenant-id` | `<ARM_TENANT_ID from Step 2>` | Azure Tenant ID |

---

## Step 4: Configure GitHub Repository

### 4.1 Commit Your Code

```powershell
cd c:\Users\v-elijahmay\Desktop\DevOps

# Initialize git if not already done
git init
git add .
git commit -m "Initial Terraform landing zone with Jenkins pipeline"

# Add your GitHub remote and push
git remote add origin https://github.com/<your-username>/<your-repo>.git
git branch -M main
git push -u origin main
```

### 4.2 Required Files in Repository

Make sure these are committed:
- `Jenkinsfile` (root)
- `landing-zone/` (all Terraform files)
- `scripts/bootstrap-backend.ps1`
- `landing-zone/environments/*.tfvars`

---

## Step 5: Create Jenkins Pipeline Job

### 5.1 Create New Job

1. In Jenkins, click **New Item**
2. Enter name: `Terraform-AKS-Landing-Zone`
3. Select **Pipeline**
4. Click **OK**

### 5.2 Configure Pipeline

**General:**
- ✅ Check "This project is parameterized"
- Add two **Choice Parameters**:
  
  **Parameter 1:**
  - Name: `ACTION`
  - Choices: `plan`, `apply`, `destroy`
  - Description: `Terraform action to perform`
  
  **Parameter 2:**
  - Name: `ENVIRONMENT`
  - Choices: `dev`, `test`, `prod`
  - Description: `Target environment`

**Pipeline:**
- Definition: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/<your-username>/<your-repo>.git`
- Credentials: (Add your GitHub credentials if private repo)
- Branch: `*/main`
- Script Path: `Jenkinsfile`

Click **Save**

---

## Step 6: Test the Pipeline

### 6.1 Run First Plan (Dry Run)

1. Click **Build with Parameters**
2. Select:
   - ACTION: `plan`
   - ENVIRONMENT: `dev`
3. Click **Build**

**Expected Result:** Pipeline should:
- Checkout code from GitHub
- Run `terraform init` (with backend configuration)
- Run `terraform validate`
- Run `terraform plan` with dev.tfvars
- Archive the plan output

### 6.2 Review Plan and Apply

1. Review the plan output in Jenkins console log
2. If plan looks good, run again with:
   - ACTION: `apply`
   - ENVIRONMENT: `dev`
3. Pipeline will pause at **Approval** stage
4. Click **Proceed** to apply changes

---

## Environment-Specific Configuration

The pipeline uses environment-specific variable files:

| Environment | File | Network | Node Count | VM Size |
|-------------|------|---------|------------|---------|
| Dev | `landing-zone/environments/dev.tfvars` | `10.0.0.0/16` | 2 | Standard_D2s_v3 |
| Test | `landing-zone/environments/test.tfvars` | `10.1.0.0/16` | 2 | Standard_D2s_v3 |
| Prod | `landing-zone/environments/prod.tfvars` | `10.2.0.0/16` | 3 | Standard_D4s_v3 |

**To customize:** Edit the respective `.tfvars` file in `landing-zone/environments/`

---

## Troubleshooting

### Issue: "No OIDC token available"

**Cause:** Jenkins doesn't have OIDC plugin or federated credential not configured

**Solution:**
1. Install Jenkins OIDC plugin: **Manage Jenkins** → **Plugins** → Search "OIDC"
2. Re-run `setup-jenkins-oidc.ps1` with correct Jenkins URL

### Issue: "Backend initialization required"

**Cause:** Remote state storage not created or backend.tf not configured

**Solution:**
1. Verify `rg-terraform-state` resource group exists in Azure
2. Verify storage account `sttfstatedev` exists
3. Check `landing-zone/backend.tf` has correct storage account name

### Issue: "Unauthorized" or "403 Forbidden"

**Cause:** Service principal doesn't have permissions

**Solution:**
1. Verify role assignment: `az role assignment list --assignee <client-id>`
2. Ensure Contributor role is assigned at subscription scope
3. Wait 5-10 minutes for role propagation

### Issue: Pipeline fails at Terraform Init

**Cause:** Backend configuration mismatch or credentials not set

**Solution:**
1. Verify Jenkins credentials are configured correctly (Step 3)
2. Check `ARM_USE_OIDC = 'true'` is set in Jenkinsfile environment block
3. Verify backend.tf has `use_oidc = true`

---

## Security Best Practices

✅ **Implemented:**
- OIDC authentication (no long-lived secrets)
- Remote state with versioning and locking
- Least privilege RBAC (Contributor at subscription scope)
- Approval gates for destructive actions
- TLS 1.2 minimum for storage
- Private blob access only

⚠️ **Additional Recommendations:**
- Restrict Jenkins network access with NSG/firewall rules
- Enable Azure AD integration for Jenkins authentication
- Use branch protection rules in GitHub (require PR reviews)
- Implement terraform state locking (Azure Storage provides this automatically)
- Rotate federated credentials periodically (every 90 days)
- Enable Azure Monitor alerts for resource changes

---

## Next Steps

After successful deployment:

1. **Verify AKS Cluster:**
   ```powershell
   az aks get-credentials --resource-group rg-aks-dev --name aks-cluster-dev
   kubectl get nodes
   ```

2. **Access Key Vault Secret:**
   ```powershell
   az keyvault secret show --vault-name <keyvault-name> --name sp-secret
   ```

3. **Set Up Monitoring (Optional):**
   - Uncomment monitoring module in `landing-zone/main.tf`
   - Configure Kubernetes/Helm providers
   - Re-run pipeline to deploy Prometheus/Grafana

4. **Configure GitHub Webhooks:**
   - GitHub Repo → Settings → Webhooks → Add webhook
   - Payload URL: `https://jenkins.example.com/github-webhook/`
   - Triggers: "Just the push event"
   - This enables automatic pipeline runs on commits

---

## Pipeline Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Push Event                        │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Jenkins Pipeline Start (with ACTION + ENVIRONMENT params)  │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 1: Checkout (from GitHub)                            │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 2: Terraform Init (with backend config)              │
│  - Connects to Azure Storage for remote state               │
│  - Downloads provider plugins                               │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 3: Terraform Validate                                │
│  - Checks syntax and configuration validity                 │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 4: Terraform Plan                                    │
│  - Uses environment-specific .tfvars                        │
│  - Archives plan output                                     │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
            ┌──────────┴──────────┐
            │   ACTION = apply    │   ACTION = destroy
            │   or destroy?       │
            └──────────┬──────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 5: Approval (Manual Gate)                            │
│  - Requires human approval to proceed                       │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 6: Terraform Apply/Destroy                           │
│  - Creates/destroys infrastructure in Azure                 │
│  - Uses OIDC for authentication (no secrets)                │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  Post Actions: Archive outputs + Cleanup workspace          │
└─────────────────────────────────────────────────────────────┘
```

---

## Support & Resources

- **Terraform Azure Provider:** https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Azure OIDC Workload Identity:** https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation
- **Jenkins Pipeline Syntax:** https://www.jenkins.io/doc/book/pipeline/syntax/
- **Terraform Remote State:** https://developer.hashicorp.com/terraform/language/settings/backends/azurerm

---

**Created:** $(Get-Date -Format "yyyy-MM-dd")
**Last Updated:** $(Get-Date -Format "yyyy-MM-dd")
