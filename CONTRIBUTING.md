# Contributing to Azure API Management Landing Zone Accelerator

Thank you for your interest in contributing to the Azure API Management Landing Zone Accelerator! This guide will help you understand how to contribute effectively to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Documentation Contributions](#documentation-contributions)
- [Getting Help](#getting-help)

## Code of Conduct

This project adheres to our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [cloudops@contoso.com](mailto:cloudops@contoso.com).

## How to Contribute

We welcome contributions in several forms:

### 🐛 Bug Reports
- Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
- Search existing issues first to avoid duplicates
- Provide clear reproduction steps and environment details

### ✨ Feature Requests
- Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Describe the business value and use case
- Consider if the feature aligns with Azure Landing Zone principles

### 📖 Documentation Improvements
- Use the [Documentation template](.github/ISSUE_TEMPLATE/documentation.md)
- Help improve clarity, accuracy, or completeness
- Add examples, diagrams, or troubleshooting guides

### 🔧 Code Contributions
- Fix bugs, implement features, or improve performance
- Ensure changes align with the architectural principles
- Include comprehensive tests and documentation

## Development Setup

### Prerequisites

Ensure you have the following tools installed:

```bash
# Required tools
az --version          # Azure CLI >= 2.60.0
az bicep version      # Bicep CLI (included with Azure CLI)
git --version         # Git >= 2.30.0

# Optional but recommended
azd version           # Azure Developer CLI
code --version        # VS Code with Bicep extension
```

### Environment Setup

1. **Fork and Clone the Repository**
   ```bash
   git clone https://github.com/[your-username]/APIM-Accelerator.git
   cd APIM-Accelerator
   ```

2. **Set Up Azure Authentication**
   ```bash
   az login
   az account set --subscription "your-dev-subscription-id"
   ```

3. **Configure Development Environment**
   ```bash
   # Copy and customize settings for development
   cp infra/settings.yaml infra/settings.dev.yaml
   # Edit settings.dev.yaml with your development values
   ```

4. **Validate Bicep Templates**
   ```bash
   # Validate main template
   az deployment sub validate \
     --location "East US 2" \
     --template-file infra/main.bicep
   ```

### Development Workflow

1. **Create a Feature Branch**
   ```bash
   git checkout -b feat/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make Changes**
   - Follow the coding standards below
   - Test changes in a development environment
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   # Deploy to development environment
   az deployment sub create \
     --name "dev-test-$(date +%Y%m%d%H%M%S)" \
     --location "East US 2" \
     --template-file infra/main.bicep
   ```

4. **Commit and Push**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   git push origin feat/your-feature-name
   ```

## Coding Standards

### Bicep Best Practices

#### File Organization
- Use consistent file naming: `kebab-case.bicep`
- Organize modules in logical directory structures
- Keep modules focused and single-purpose

#### Documentation Standards
- Include comprehensive file headers:
  ```bicep
  // =================================================================
  // MODULE PURPOSE AND DESCRIPTION
  // =================================================================
  // Brief description of what this module does
  //
  // File: path/to/file.bicep
  // Purpose: Specific purpose of this module
  // Dependencies: List key dependencies
  // =================================================================
  ```

- Document all parameters with `@description`:
  ```bicep
  @description('Detailed description of parameter purpose and constraints')
  param parameterName string
  ```

- Document all resources:
  ```bicep
  @description('Resource purpose and configuration details')
  resource resourceName 'Microsoft.ResourceType@2024-01-01' = {
    // resource definition
  }
  ```

#### Code Quality
- Use meaningful variable and resource names
- Avoid hardcoded values - use parameters or variables
- Implement proper error handling
- Follow Azure naming conventions
- Use latest stable API versions

#### Security Practices
- Never commit secrets or sensitive data
- Use managed identities where possible
- Implement least-privilege access patterns
- Use `@secure()` decorator for sensitive parameters

### Configuration Standards

#### Settings File Structure
```yaml
# Follow consistent structure
solutionName: "descriptive-name"
shared:
  # Shared infrastructure components
core:
  # Core application components  
tags:
  # Consistent tagging strategy
```

#### Naming Conventions
- Use consistent naming patterns across resources
- Include environment indicators where appropriate
- Follow Azure naming best practices
- Ensure names are globally unique where required

## Pull Request Process

### Before Submitting
1. **Self-Review Checklist**
   - [ ] Code follows the style guidelines
   - [ ] Self-review of code completed
   - [ ] Comments added for complex logic
   - [ ] Documentation updated
   - [ ] Tests added for new functionality
   - [ ] No breaking changes (or clearly documented)

2. **Testing Requirements**
   - [ ] Bicep templates validate successfully
   - [ ] Deployment tested in development environment
   - [ ] No regression in existing functionality
   - [ ] Performance impact considered

### Pull Request Template
When creating a PR, use our [Pull Request template](.github/pull_request_template.md) and include:

- **Description**: Clear summary of changes
- **Type of Change**: Bug fix, feature, documentation, etc.
- **Testing**: How you tested the changes
- **Screenshots**: If applicable
- **Breaking Changes**: Any breaking changes
- **Checklist**: Completed items from template

### Review Process
1. **Automatic Checks**: CI/CD pipelines will run automatically
2. **Peer Review**: At least one maintainer review required
3. **Testing**: Changes must be tested in isolation
4. **Documentation**: Ensure documentation is updated
5. **Approval**: Maintainer approval required before merge

### Merge Criteria
- All CI checks pass
- At least one maintainer approval
- No unresolved review comments
- Documentation updated
- No merge conflicts

## Issue Reporting

### Bug Reports
Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md) and include:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details (Azure CLI version, subscription type, etc.)
- Relevant logs or error messages

### Feature Requests
Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md) and include:
- Business problem being solved
- Proposed solution
- Alternative solutions considered
- Additional context or mockups

## Documentation Contributions

### Types of Documentation
- **Code Documentation**: Inline comments, parameter descriptions
- **User Guides**: How-to guides, tutorials, examples
- **Reference Documentation**: API references, configuration schemas
- **Architecture Documentation**: Design decisions, diagrams

### Documentation Standards
- Use clear, concise language
- Include practical examples
- Add diagrams where helpful (Mermaid preferred)
- Test all code examples
- Update table of contents for new sections

### File Organization
```
docs/
├── getting-started/          # New user onboarding
├── user-guide/              # Feature documentation
├── developer-guide/         # Technical implementation
├── architecture/            # Design and architecture
├── troubleshooting/         # Common issues and solutions
└── reference/               # API and configuration reference
```

## Getting Help

### Communication Channels
- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: General questions, ideas
- **Email**: [cloudops@contoso.com](mailto:cloudops@contoso.com) for sensitive issues

### Resources
- [Azure API Management Documentation](https://learn.microsoft.com/azure/api-management/)
- [Azure Landing Zone Guide](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

### Response Times
- **Bug Reports**: 2-3 business days for initial response
- **Feature Requests**: 1 week for initial review
- **Pull Requests**: 3-5 business days for review
- **Questions**: 24-48 hours for response

## Recognition

We value all contributions! Contributors will be:
- Listed in our CONTRIBUTORS.md file
- Mentioned in release notes for significant contributions
- Invited to join our contributor community

## Release Process

### Versioning
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Cycle
- Regular releases every 2-4 weeks
- Hot fixes for critical issues as needed
- Preview releases for major features

Thank you for contributing to make Azure API Management adoption easier and more secure for everyone! 🚀

---

For questions about this contributing guide, please open an issue with the "documentation" label.