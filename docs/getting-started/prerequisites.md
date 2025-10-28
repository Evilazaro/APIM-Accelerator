# Prerequisites

Before deploying the Azure API Management Landing Zone Accelerator, ensure you have the required tools, permissions, and environment setup.

## 📋 Required Tools

### Azure CLI
The Azure CLI is required for all deployment scenarios.

**Installation:**
```bash
# Windows (using winget)
winget install Microsoft.AzureCLI

# macOS (using Homebrew)
brew install azure-cli

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Verify Installation:**
```bash
az --version
# Should show version >= 2.60.0
```

**Login and Set Subscription:**
```bash
az login
az account list --output table
az account set --subscription "your-subscription-id"
```

### Bicep CLI
Bicep is included with Azure CLI but can be updated separately.

**Verify Bicep:**
```bash
az bicep version
# Should show latest version
```

**Update Bicep (if needed):**
```bash
az bicep upgrade
```

### Git
Required for cloning the repository and version control.

**Installation:**
```bash
# Windows (using winget)
winget install Git.Git

# macOS (using Homebrew)
brew install git

# Linux (Ubuntu/Debian)
sudo apt-get install git
```

**Verify Installation:**
```bash
git --version
# Should show version >= 2.30.0
```

### Optional: Azure Developer CLI (azd)
Recommended for simplified deployment workflow.

**Installation:**
```bash
# Windows (PowerShell)
winget install microsoft.azd

# macOS/Linux
curl -fsSL https://aka.ms/install-azd.sh | bash
```

**Verify Installation:**
```bash
azd version
```

## 🔐 Azure Permissions

### Required Permissions
You need the following permissions in your Azure subscription:

| Permission | Scope | Purpose |
|------------|-------|---------|
| **Owner** or **Contributor** + **User Access Administrator** | Subscription | Create resources and manage role assignments |
| **Resource Group Contributor** | Subscription | Create and manage resource groups |
| **Managed Identity Contributor** | Subscription | Create and manage managed identities |

### Service Principal (Alternative)
If using a service principal for automation:

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "apim-accelerator-sp" \
  --role "Owner" \
  --scopes "/subscriptions/your-subscription-id"
```

### Permission Verification
Verify your permissions before deployment:

```bash
# Check current user permissions
az role assignment list --assignee $(az ad signed-in-user show --query id --output tsv) --all

# Check subscription access
az account show --query "user.name"
```

## 🏢 Azure Subscription Requirements

### Subscription Type
- **Supported:** Enterprise Agreement, Pay-As-You-Go, Microsoft Partner Agreement
- **Not Supported:** Free Trial, Student subscriptions (due to resource limitations)

### Resource Quotas
Ensure sufficient quotas for the following resources:

| Resource Type | Minimum Required | Recommended |
|---------------|------------------|-------------|
| Resource Groups | 5 | 10 |
| API Management Services | 1 | 2 |
| Log Analytics Workspaces | 1 | 2 |
| Application Insights | 1 | 2 |
| Storage Accounts | 1 | 2 |
| Virtual Networks | 1 | 2 |

**Check Quotas:**
```bash
# Check API Management quota
az apim list --query "length(@)"

# Check resource group quota
az group list --query "length(@)"
```

### Regional Availability
Verify that your chosen region supports all required services:

| Service | Check Availability |
|---------|-------------------|
| API Management Premium | [Regional Availability](https://azure.microsoft.com/global-infrastructure/services/?products=api-management) |
| Log Analytics | [Regional Availability](https://azure.microsoft.com/global-infrastructure/services/?products=monitor) |
| Application Insights | [Regional Availability](https://azure.microsoft.com/global-infrastructure/services/?products=monitor) |

## 🖥️ Development Environment

### Recommended IDE
**Visual Studio Code** with extensions:
```bash
# Install VS Code extensions
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.azure-account
code --install-extension ms-azuretools.vscode-azureresourcegroups
```

### PowerShell (Windows)
For Windows users, PowerShell 7+ is recommended:
```powershell
# Install PowerShell 7
winget install Microsoft.PowerShell

# Verify version
$PSVersionTable
```

### Bash (macOS/Linux)
Ensure bash is up to date:
```bash
# Check bash version
bash --version

# Should be version 4.0 or higher
```

## 🌐 Network Requirements

### Outbound Connectivity
Ensure your environment can reach:

| Service | Purpose | Ports |
|---------|---------|-------|
| `management.azure.com` | Azure Resource Manager | 443 |
| `login.microsoftonline.com` | Azure Authentication | 443 |
| `graph.microsoft.com` | Microsoft Graph API | 443 |
| `*.vault.azure.net` | Azure Key Vault | 443 |

### Corporate Firewall
If behind a corporate firewall, you may need to:
- Configure proxy settings for Azure CLI
- Add certificate exceptions
- Work with IT to allowlist Azure endpoints

**Configure Proxy (if needed):**
```bash
# Set proxy for Azure CLI
az config set core.proxy_url=http://proxy.company.com:8080
```

## 🔧 Environment Validation

### Pre-deployment Checklist
Run these commands to validate your environment:

```bash
# 1. Verify Azure CLI and authentication
az account show --output table

# 2. Check Bicep installation
az bicep version

# 3. Verify subscription permissions
az role assignment list --assignee $(az ad signed-in-user show --query id --output tsv) --all --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor']"

# 4. Test resource creation (creates and deletes a test resource group)
az group create --name "test-permissions-rg" --location "East US 2"
az group delete --name "test-permissions-rg" --yes --no-wait

# 5. Validate Bicep template syntax
git clone https://github.com/Evilazaro/APIM-Accelerator.git
cd APIM-Accelerator
az deployment sub validate --location "East US 2" --template-file infra/main.bicep
```

### Common Issues and Solutions

#### Issue: "Insufficient privileges to complete the operation"
**Solution:**
- Request Owner or Contributor + User Access Administrator permissions
- Verify you're in the correct subscription: `az account show`

#### Issue: "Bicep CLI not found"
**Solution:**
```bash
# Update Azure CLI to latest version
az upgrade

# Or install Bicep manually
az bicep install
```

#### Issue: "Resource provider not registered"
**Solution:**
```bash
# Register required resource providers
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.Storage
```

#### Issue: "Quota exceeded for resource type"
**Solution:**
- Request quota increase through Azure portal
- Choose a different region with available capacity
- Use smaller SKU sizes for testing

## 📊 Environment Readiness Scorecard

Use this checklist to ensure you're ready for deployment:

### Tools Installation
- [ ] Azure CLI >= 2.60.0 installed and working
- [ ] Bicep CLI installed and up to date  
- [ ] Git installed and configured
- [ ] Code editor with Bicep support (recommended)
- [ ] PowerShell 7+ (Windows) or Bash 4+ (macOS/Linux)

### Azure Environment
- [ ] Azure subscription access verified
- [ ] Appropriate permissions assigned (Owner/Contributor + UAA)
- [ ] Resource quotas sufficient for deployment
- [ ] Target region supports all required services
- [ ] Required resource providers registered

### Network Access
- [ ] Outbound connectivity to Azure endpoints verified
- [ ] Proxy configuration completed (if applicable)
- [ ] Corporate firewall rules configured (if applicable)

### Authentication
- [ ] Azure CLI authentication working (`az account show`)
- [ ] Correct subscription selected
- [ ] Service principal created (if using automation)

### Validation
- [ ] Template validation passes (`az deployment sub validate`)
- [ ] Test resource group creation/deletion successful
- [ ] All prerequisite tools functioning correctly

## 🚀 Next Steps

Once you've completed all prerequisites:

1. **[Quick Start](quick-start.md)** - Deploy your first APIM platform
2. **[Configuration](configuration.md)** - Understand configuration options
3. **[Installation Guide](installation.md)** - Detailed deployment steps

## 📞 Getting Help

If you encounter issues with prerequisites:

1. Check our [Troubleshooting Guide](../troubleshooting/common-issues.md)
2. Search [existing issues](https://github.com/Evilazaro/APIM-Accelerator/issues)
3. Create a [question issue](https://github.com/Evilazaro/APIM-Accelerator/issues/new?template=question.md)

---

**Next:** [Quick Start Guide →](quick-start.md)