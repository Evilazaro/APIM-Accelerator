# Network Configuration Validation

This directory contains the network configuration files and validation tools for the APIM Accelerator project.

## Files

- **`network.yaml`** - Main network configuration file containing VNet, security, and infrastructure settings
- **`network.schema.json`** - JSON Schema file for validating the network configuration
- **`validate-network-config.js`** - Node.js validation script
- **`package.json`** - Node.js dependencies for validation tools

## Configuration Structure

The `network.yaml` file defines:

### Core Settings
- **name**: Virtual network name
- **description**: Configuration description
- **resourceGroup**: Azure Resource Group configuration

### IP Addressing
- **addressSpaces**: Virtual network CIDR blocks
- **subnets**: Subnet definitions with names and address prefixes

### Security Components
- **encryption**: Virtual network encryption settings
- **azureBastion**: Azure Bastion host configuration
- **azureFirewall**: Azure Firewall settings
- **ddosProtection**: DDoS Protection plan configuration

## Validation

### Prerequisites

1. Install Node.js (version 14 or higher)
2. Install dependencies:
   ```bash
   npm run install-deps
   ```

### Running Validation

To validate the network configuration:

```bash
npm run validate
```

Or run directly:

```bash
node validate-network-config.js
```

### Validation Features

The validation script provides:

- ✅ **Comprehensive validation** against JSON Schema
- 📊 **Configuration summary** with key settings
- 🐛 **Detailed error reporting** with specific issues and suggestions
- 🔍 **Azure naming convention validation**
- 🌐 **CIDR notation validation**
- 📏 **Length and format constraints**

## Schema Best Practices Applied

The JSON Schema follows industry best practices:

### Structure & Organization
- **Clear property organization** with logical groupings
- **Consistent naming conventions** following Azure standards
- **Proper nesting** reflecting the configuration hierarchy

### Validation Rules
- **Required field validation** for critical properties
- **Data type enforcement** (strings, booleans, objects, arrays)
- **Format validation** using regex patterns for Azure resources
- **Length constraints** respecting Azure limits
- **Enumerated values** for SKUs and tiers

### Azure-Specific Validation
- **Resource naming patterns** following Azure conventions
- **CIDR notation validation** for IP address ranges
- **Subnet naming requirements** (e.g., AzureFirewallSubnet, AzureBastionSubnet)
- **SKU and tier validation** for Azure services

### Documentation & Usability
- **Comprehensive descriptions** for all properties
- **Examples** showing valid configurations
- **Title attributes** for better tooling support
- **Error-friendly structure** for debugging

### Conditional Logic
- **Dynamic requirements** based on enabled features
- **Cross-field validation** ensuring configuration consistency
- **Optional property handling** for disabled features

## Example Configuration

```yaml
name: apim-virtual-network
description: Configuration settings for the network infrastructure

resourceGroup:
  name: apim-network-rg

ipAddresses:
  addressSpaces:
    - 10.0.0.0/16
  subnets:
    - name: AzureFirewallSubnet
      addressPrefix: 10.0.1.0/24
    - name: AzureBastionSubnet
      addressPrefix: 10.0.2.0/24

security:
  encryption:
    enabled: true
  azureBastion:
    enabled: true
    name: apim-bastion
    sku: Basic
    publicIPAddressName: bastion-public-ip
    subnetName: AzureBastionSubnet
  azureFirewall:
    enabled: true
    name: apim-firewall
    sku: AZFW_VNet
    tier: Standard
    subnetName: AzureFirewallSubnet
    publicIPAddressName: firewall-public-ip
  ddosProtection:
    enabled: true
    name: apim-ddos-plan
```

## Integration with Bicep

The configuration is used by `src/network/network.bicep` via:

```bicep
var settings = loadYamlContent('../../infra/settings/network.yaml')
```

This ensures the Bicep templates use validated, consistent configuration data.

## Troubleshooting

### Common Issues

1. **Invalid CIDR notation**: Ensure IP addresses follow the format `x.x.x.x/xx`
2. **Invalid resource names**: Azure resource names must start/end with alphanumeric characters
3. **Missing required subnets**: Azure Firewall requires `AzureFirewallSubnet`, Bastion requires `AzureBastionSubnet`
4. **SKU/Tier mismatches**: Verify supported combinations in Azure documentation

### Validation Output

The validator provides detailed feedback:

```
✅ Configuration is valid!

📊 Configuration Summary:
   • Network Name: apim-virtual-network
   • Resource Group: apim-network-rg
   • Address Spaces: 1
   • Subnets: 2
   • Encryption Enabled: true
   • Azure Bastion: Enabled
   • Azure Firewall: Enabled
   • DDoS Protection: Enabled
```

For errors, you'll see specific paths and descriptions:

```
❌ Configuration validation failed!

🐛 Validation Errors:
   1. /security/azureFirewall/tier: must be equal to one of the allowed values
      Additional info: {"allowedValues":["Standard","Premium","Basic"]}
```
