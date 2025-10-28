# Changelog

All notable changes to the Azure API Management Landing Zone Accelerator will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation structure following GitHub best practices
- Enhanced Bicep template documentation with @description decorators
- Detailed architecture documentation and diagrams
- Contributing guidelines and issue templates
- Security policy and code of conduct
- Troubleshooting guides and FAQ section

### Changed
- Improved README.md with better structure and examples
- Enhanced parameter documentation across all Bicep modules
- Reorganized documentation for better user experience

### Security
- Added security best practices documentation
- Enhanced secure parameter handling in Bicep templates

## [1.0.0] - 2025-01-15

### Added
- Initial release of Azure API Management Landing Zone Accelerator
- Core APIM deployment with Premium SKU support
- Comprehensive monitoring integration (Log Analytics, Application Insights)
- Managed identity configuration for secure access
- API Center integration for inventory management
- Azure Developer CLI (azd) support
- Landing Zone aligned architecture
- Modular Bicep template structure
- Centralized configuration via settings.yaml
- Resource tagging strategy for governance
- Developer portal configuration
- Workspace management capabilities

### Infrastructure Components
- **Core Platform**: API Management service deployment
- **Shared Services**: Monitoring, identity, and networking foundations
- **Inventory Management**: API Center integration for governance
- **Security**: Managed identity and RBAC configuration
- **Observability**: Comprehensive logging and monitoring setup

### Documentation
- Detailed README with quick start guide
- Configuration examples and best practices
- Deployment options (Azure CLI, azd, pipelines)
- Architecture alignment with Azure Landing Zones
- Troubleshooting guide

### Configuration
- Flexible settings.yaml for environment customization
- Support for multiple deployment methods
- Extensible tagging strategy
- Role-based access control configuration

---

## Template for Future Releases

### Added
- New features and capabilities

### Changed
- Improvements to existing functionality
- Updated dependencies or requirements

### Deprecated
- Features marked for removal in future versions

### Removed
- Features removed in this version

### Fixed
- Bug fixes and issue resolutions

### Security
- Security improvements and vulnerability fixes

---

## Release Notes Guidelines

When contributing to releases, please:

1. **Follow the format**: Use the categories above
2. **Be descriptive**: Explain what changed and why
3. **Include breaking changes**: Clearly mark any breaking changes
4. **Reference issues**: Link to relevant GitHub issues
5. **Update unreleased**: Add new items to [Unreleased] section first

### Example Entry Format
```markdown
### Added
- New feature X that enables Y functionality ([#123](https://github.com/Evilazaro/APIM-Accelerator/issues/123))
- Support for Z configuration option in settings.yaml

### Changed
- **BREAKING**: Parameter `oldName` renamed to `newName` in module A ([#456](https://github.com/Evilazaro/APIM-Accelerator/issues/456))
- Improved error handling in deployment scripts

### Fixed
- Fixed issue where X would fail under Y conditions ([#789](https://github.com/Evilazaro/APIM-Accelerator/issues/789))
```

### Migration Guides

For breaking changes, include migration guidance:

```markdown
### Migration from v1.x to v2.0

#### Breaking Changes
1. **Parameter Rename**: `oldParam` → `newParam`
   - Update your `settings.yaml` files
   - Old: `oldParam: value`
   - New: `newParam: value`

2. **Module Structure Change**
   - The `shared/monitoring` module has been restructured
   - Update module references in custom templates
```

For more information about contributing to releases, see [CONTRIBUTING.md](CONTRIBUTING.md).