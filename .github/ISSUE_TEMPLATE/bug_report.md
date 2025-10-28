---
name: Bug Report
about: Create a report to help us improve the Azure API Management Accelerator
title: '[BUG] '
labels: 'bug'
assignees: ''

---

## Bug Description
**Describe the bug**
A clear and concise description of what the bug is.

**Expected behavior**
A clear and concise description of what you expected to happen.

**Actual behavior**
A clear and concise description of what actually happened.

## Reproduction Steps
**To Reproduce**
Steps to reproduce the behavior:
1. Configure settings.yaml with '...'
2. Run deployment command '...'
3. Navigate to resource '...'
4. See error

**Minimal Reproduction**
If possible, provide a minimal configuration that reproduces the issue:
```yaml
# settings.yaml snippet that causes the issue
solutionName: "minimal-repro"
# ... other minimal settings
```

## Environment Information
**Deployment Environment:**
- OS: [e.g. Windows 11, Ubuntu 22.04, macOS 13]
- Azure CLI Version: [run `az --version`]
- Bicep Version: [run `az bicep version`]
- Azure Developer CLI Version (if used): [run `azd version`]
- PowerShell/Bash Version: [version info]

**Azure Environment:**
- Azure Cloud: [Public, Government, China, etc.]
- Subscription Type: [Pay-as-you-go, Enterprise, etc.]
- Region: [e.g. East US 2, West Europe]
- Deployment Method: [Azure CLI, azd, Azure DevOps, GitHub Actions]

**Template Information:**
- Accelerator Version: [e.g. v1.0.0, main branch, commit hash]
- Modified Templates: [Yes/No - if yes, describe modifications]
- Custom Settings: [Describe any custom configuration]

## Error Information
**Error Messages**
```
Paste the complete error message here
```

**Deployment Logs**
```
Paste relevant deployment logs here (remove sensitive information)
```

**Azure Portal Errors**
If applicable, include screenshots or error messages from the Azure Portal.

**Resource State**
Describe the state of Azure resources after the failed deployment:
- Which resources were created successfully?
- Which resources failed to deploy?
- Any resources in a failed state?

## Additional Context
**Screenshots**
If applicable, add screenshots to help explain your problem.

**Configuration Files**
```yaml
# Relevant portions of your settings.yaml (remove sensitive data)
```

**Previous Working Version**
- Was this working in a previous version? If so, which version?
- What changed between the working and non-working versions?

**Impact Assessment**
- Severity: [Critical/High/Medium/Low]
- Workaround Available: [Yes/No - if yes, describe]
- Blocking Deployment: [Yes/No]

**Related Issues**
- Link to any related issues or discussions
- Similar problems found in other repositories

## Investigation Done
**Troubleshooting Steps Attempted:**
- [ ] Checked Azure service health
- [ ] Verified subscription permissions
- [ ] Validated Bicep template syntax
- [ ] Tested with minimal configuration
- [ ] Checked Azure CLI authentication
- [ ] Reviewed deployment logs
- [ ] Searched existing issues
- [ ] Consulted documentation

**Root Cause Analysis:**
Any initial investigation or suspected root cause.

## Additional Information
**Would you like to work on fixing this bug?** [Yes/No]

**Additional context**
Add any other context about the problem here.

---

### For Maintainers
**Triage Information:**
- [ ] Bug confirmed
- [ ] Severity assessed
- [ ] Labels applied
- [ ] Milestone assigned
- [ ] Related issues linked