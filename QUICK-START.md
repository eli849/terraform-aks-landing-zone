# Jenkins + Azure + GitHub CI/CD Setup - Quick Reference

## 🚀 Quick Start (5 Steps)

### Step 1: Create Remote State Storage
```powershell
cd c:\Users\v-elijahmay\Desktop\DevOps
.\scripts\bootstrap-backend.ps1 -Environment "dev" -Location "eastus" -SubscriptionId "<your-sub-id>"
```
**Save the output** - you'll need the ARM_* values for Jenkins.

---

### Step 2: Set Up Azure OIDC Federation
```powershell
.\scripts\setup-jenkins-oidc.ps1 -SubscriptionId "<your-sub-id>" -JenkinsUrl "https://jenkins.example.com"
```
**Save the three values** from the output:
- `ARM_CLIENT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

---

### Step 3: Add Jenkins Credentials

In Jenkins: **Manage Jenkins** → **Manage Credentials** → **(global)** → **Add Credentials**

Add 3 credentials (Type: **Secret text**):

| ID | Value |
|----|-------|
| `azure-client-id` | `<ARM_CLIENT_ID from Step 2>` |
| `azure-subscription-id` | `<ARM_SUBSCRIPTION_ID from Step 2>` |
| `azure-tenant-id` | `<ARM_TENANT_ID from Step 2>` |

---

### Step 4: Push to GitHub
```powershell
cd c:\Users\v-elijahmay\Desktop\DevOps
git init
git add .
git commit -m "Initial commit: Terraform AKS landing zone with Jenkins CI/CD"
git remote add origin https://github.com/<your-username>/<your-repo>.git
git branch -M main
git push -u origin main
```

---

### Step 5: Create Jenkins Pipeline

1. **New Item** → Name: `Terraform-AKS-Landing-Zone` → **Pipeline** → **OK**

2. **Configure Pipeline:**
   - ✅ Check "This project is parameterized"
   - Add **Choice Parameter**:
     - Name: `ACTION`
     - Choices (one per line):
       ```
       plan
       apply
       destroy
       ```
   - Add **Choice Parameter**:
     - Name: `ENVIRONMENT`
     - Choices (one per line):
       ```
       dev
       test
       prod
       ```

3. **Pipeline Section:**
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/<your-username>/<your-repo>.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

4. **Save**

---

## ✅ Test Your Pipeline

### First Run: Plan (Dry Run)
1. Click **Build with Parameters**
2. Select:
   - ACTION: **plan**
   - ENVIRONMENT: **dev**
3. Click **Build**
4. Check console output - should show Terraform plan

### Second Run: Apply (Create Infrastructure)
1. **Build with Parameters**
2. Select:
   - ACTION: **apply**
   - ENVIRONMENT: **dev**
3. Pipeline will pause at "Approval" stage
4. Review the plan, then click **Proceed**
5. Infrastructure will be created in Azure!

---

## 📁 What You Have

### Project Structure
```
DevOps/
├── Jenkinsfile                          # CI/CD pipeline definition
├── SETUP-GUIDE.md                       # Detailed setup guide
├── QUICK-START.md                       # This file
├── landing-zone/
│   ├── main.tf                          # Root module
│   ├── variables.tf                     # Root variables
│   ├── outputs.tf                       # Root outputs
│   ├── providers.tf                     # Provider configuration (OIDC enabled)
│   ├── backend.tf                       # Remote state configuration
│   ├── terraform.tfvars                 # Default values (gitignored)
│   ├── terraform.tfvars.example         # Example values (committed)
│   ├── environments/
│   │   ├── dev.tfvars                   # Dev environment config
│   │   ├── test.tfvars                  # Test environment config
│   │   └── prod.tfvars                  # Prod environment config
│   └── modules/
│       ├── aks/                         # AKS cluster module
│       ├── keyvault/                    # Key Vault module
│       ├── network/                     # VNet/Subnet module
│       ├── service_principal/           # Azure AD SP module
│       └── monitoring/                  # Prometheus/Grafana (optional)
└── scripts/
    ├── bootstrap-backend.ps1            # Create Azure Storage for state
    └── setup-jenkins-oidc.ps1           # Configure OIDC federation
```

### What Gets Created in Azure (per environment)

**Dev Environment (`dev.tfvars`):**
- Resource Group: `rg-aks-dev`
- Virtual Network: `10.0.0.0/16`
- Subnet: `10.0.1.0/24`
- AKS Cluster: `aks-cluster-dev`
  - Node Count: 2
  - VM Size: `Standard_D2s_v3`
- Key Vault: Stores service principal secret
- Service Principal: `sp-aks-dev` with Contributor role (scoped to RG)

**Test/Prod:** Similar structure with different names and specs.

---

## 🔒 Security Features

✅ **OIDC Authentication** - No secrets stored in Jenkins  
✅ **Remote State** - Azure Storage with versioning and locking  
✅ **Approval Gates** - Manual approval required for apply/destroy  
✅ **Least Privilege** - Service principal scoped to resource group  
✅ **TLS 1.2 Minimum** - Enforced on storage account  
✅ **Private Blob Access** - No public access to state files  

---

## 🛠️ Common Commands

### Get AKS Credentials
```powershell
az aks get-credentials --resource-group rg-aks-dev --name aks-cluster-dev
kubectl get nodes
```

### View Key Vault Secret
```powershell
az keyvault secret show --vault-name <kv-name> --name sp-secret
```

### Terraform Commands (Local Testing)
```powershell
cd landing-zone
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

---

## 🚨 Troubleshooting

### "No OIDC token available"
→ Install Jenkins OIDC plugin or re-run `setup-jenkins-oidc.ps1`

### "Backend initialization required"
→ Run `bootstrap-backend.ps1` first to create storage account

### "Unauthorized" / "403 Forbidden"
→ Check role assignments: `az role assignment list --assignee <client-id>`  
→ Wait 5-10 minutes for Azure AD propagation

### Pipeline fails at Init
→ Verify Jenkins credentials are named correctly:
  - `azure-client-id`
  - `azure-subscription-id`
  - `azure-tenant-id`

---

## 📚 Full Documentation

See **SETUP-GUIDE.md** for:
- Detailed architecture diagrams
- Step-by-step troubleshooting
- Security best practices
- Advanced configuration options
- Monitoring setup (Prometheus/Grafana)

---

## 🎯 Next Steps After Deployment

1. **Verify AKS is running:**
   ```powershell
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

2. **Set up GitHub webhook for auto-triggers:**
   - GitHub Repo → Settings → Webhooks
   - Add webhook: `https://jenkins.example.com/github-webhook/`

3. **Deploy monitoring (optional):**
   - Uncomment monitoring module in `landing-zone/main.tf`
   - Re-run pipeline with ACTION=apply

4. **Configure branch protection:**
   - Require PR reviews for `main` branch
   - Prevent direct pushes to production

---

**Need Help?** Check SETUP-GUIDE.md or review the Jenkins console output for detailed error messages.
