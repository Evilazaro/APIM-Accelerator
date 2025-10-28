# Prerequisites

Before deploying the Azure API Management Accelerator, ensure you have the required tools, permissions, and environment setup.

## 📋 Required Tools

### Azure Developer CLI
The Azure Developer CLI (azd) is the recommended tool for all deployment scenarios.

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

**Authentication:**
```bash
azd auth login
```

### Bicep CLI
Bicep is included with Azure CLI but can be updated separately.

Bicep is handled automatically by Azure Developer CLI during deployment.

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
# Service principals are automatically created by azd during deployment
```

### Permission Verification
Verify your permissions before deployment:

```bash
# Check authentication status
azd auth login --check-status
```

## 🏢 Azure Subscription Requirements

### Subscription Type
- **Supported:** Enterprise Agreement, Pay-As-You-Go, Microsoft Partner Agreement
- **Not Supported:** Free Trial, Student subscriptions (due to resource limitations)

### Resource Quotas
Ensure sufficient quotas for the following resources:

| Resource Type | Minimum Required | Recommended | Notes |
|---------------|------------------|-------------|-------|
| Resource Groups | 1 | 3 | Single RG per environment (dev/test/prod) |
| API Management Services | 1 | 2 | Premium tier recommended for production |
| Log Analytics Workspaces | 1 | 2 | One per environment or shared |
| Application Insights | 1 | 2 | Integrated with Log Analytics |
| Storage Accounts | 1 | 2 | For diagnostic logs storage |
| API Center Services | 1 | 2 | For API inventory and governance |

Resource quotas and provider registration are automatically handled during `azd up` deployment.

### Regional Availability
Verify that your chosen region supports all required services:

| Service | Check Availability | Notes |
|---------|-------------------|-------|
| API Management Premium | [Regional Availability](https://azure.microsoft.com/global-infrastructure/services/?products=api-management) | Premium tier required for full features |
| Log Analytics | [Regional Availability](https://azure.microsoft.com/global-infrastructure/services/?products=monitor) | Available in most regions |
| Application Insights | [Regional Availability](https://azure.microsoft.com/global-infrastructure/services/?products=monitor) | Workspace-based mode required |
| API Center | [Regional Availability](https://learn.microsoft.com/azure/api-center/overview#supported-regions) | Preview service, limited regions |

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
- Configure proxy settings for Azure Developer CLI
- Add certificate exceptions
- Work with IT to allowlist Azure endpoints

**Configure Proxy (if needed):**
Configure proxy settings for Azure Developer CLI as needed for your corporate environment.

## 🔧 Environment Validation

### Pre-deployment Checklist
Run these commands to validate your environment:

```bash
# 1. Clone the repository
git clone https://github.com/Evilazaro/APIM-Accelerator.git
cd APIM-Accelerator

# 2. Authenticate with Azure
azd auth login

# 3. Validate deployment configuration
azd provision --preview
```

### Common Issues and Solutions

#### Issue: "Insufficient privileges to complete the operation"
**Solution:**
- Request Owner or Contributor + User Access Administrator permissions
- Verify authentication: `azd auth login --check-status`

#### Issue: "Bicep CLI not found"
**Solution:**
Bicep is automatically handled by Azure Developer CLI during deployment.

#### Issue: "Resource provider not registered"
**Solution:**
Resource providers are automatically registered during `azd up` deployment.

#### Issue: "Quota exceeded for resource type"
**Solution:**
- Request quota increase through Azure portal
- Choose a different region with available capacity
- Use smaller SKU sizes for testing

## 📊 Environment Readiness Scorecard

Use this checklist to ensure you're ready for deployment:

### Tools Installation
- [ ] Azure Developer CLI >= 1.10.0 installed and working
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
- [ ] Azure authentication working (`azd auth login --check-status`)
- [ ] Service principal created (if using automation)

### Validation
- [ ] Template validation passes (`azd provision --preview`)
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