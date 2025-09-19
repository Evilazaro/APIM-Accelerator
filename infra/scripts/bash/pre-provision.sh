#!/bin/bash

#===============================================================================
# Azure API Management Landing Zone Accelerator - Pre-Provision Script
#===============================================================================
# Description: Purges soft-deleted Azure resources (APIM and Key Vault) to
#              enable clean redeployment for demo and testing scenarios
# Usage:       ./pre-provision.sh <location>
# Example:     ./pre-provision.sh "East US"
#===============================================================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

#===============================================================================
# FUNCTIONS
#===============================================================================

# Display script usage information
show_usage() {
    echo "Usage: $0 <location>"
    echo "Example: $0 'East US'"
    echo ""
    echo "This script purges soft-deleted Azure resources to enable clean redeployment."
    exit 1
}

# Log messages with timestamp for better traceability
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if a resource is currently active
is_resource_active() {
    local resource_type="$1"
    local resource_name="$2"
    local resource_group="$3"
    
    case "$resource_type" in
        "apim")
            az apim show --name "$resource_name" --resource-group "$resource_group" >/dev/null 2>&1
            ;;
        "keyvault")
            az keyvault show --name "$resource_name" --resource-group "$resource_group" >/dev/null 2>&1
            ;;
        *)
            echo "Error: Unknown resource type: $resource_type" >&2
            return 1
            ;;
    esac
}

# Check if a resource is soft-deleted
is_resource_soft_deleted() {
    local resource_type="$1"
    local resource_name="$2"
    
    case "$resource_type" in
        "apim")
            az apim deletedservice list --query "[?name=='$resource_name']" -o tsv | grep -q "$resource_name"
            ;;
        "keyvault")
            az keyvault list-deleted --query "[?name=='$resource_name']" -o tsv | grep -q "$resource_name"
            ;;
        *)
            echo "Error: Unknown resource type: $resource_type" >&2
            return 1
            ;;
    esac
}

# Purge a soft-deleted resource
purge_soft_deleted_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local location="$3"
    
    log_message "${resource_type^^} purge initiated"
    
    case "$resource_type" in
        "apim")
            az apim deletedservice purge --service-name "$resource_name" --location "$location"
            ;;
        "keyvault")
            az keyvault purge --name "$resource_name" --location "$location"
            ;;
        *)
            echo "Error: Unknown resource type: $resource_type" >&2
            return 1
            ;;
    esac
    
    log_message "${resource_type^^} purge completed"
}

# Process resource purging for a given resource type
process_resource_purging() {
    local resource_type="$1"
    local resource_name="$2"
    local resource_group="$3"
    local location="$4"
    
    if is_resource_active "$resource_type" "$resource_name" "$resource_group"; then
        log_message "${resource_type^^} is still active"
    else
        if is_resource_soft_deleted "$resource_type" "$resource_name"; then
            log_message "${resource_type^^} is soft-deleted"
            purge_soft_deleted_resource "$resource_type" "$resource_name" "$location"
        else
            log_message "${resource_type^^} not found (already purged or never existed)"
        fi
    fi
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

main() {
    # Validate input parameters
    if [[ $# -ne 1 ]]; then
        echo "Error: Invalid number of arguments" >&2
        show_usage
    fi
    
    local location="$1"
    
    # Validate location parameter is not empty
    if [[ -z "$location" ]]; then
        echo "Error: Location parameter cannot be empty" >&2
        show_usage
    fi
    
    log_message "Starting Azure resource purging process for location: $location"
    
    # Extract APIM configuration using yq -r (keeping original command format)
    local apim_name
    local apim_resource_group
    apim_name=$(yq -r '.core.apiManagement.name' ../../settings.yaml)
    apim_resource_group=$(yq -r '.core.apiManagement.resourceGroup' ../../settings.yaml)
    
    # Validate APIM configuration values
    if [[ -z "$apim_name" || "$apim_name" == "null" ]]; then
        echo "Error: APIM name not found in settings.yaml" >&2
        exit 1
    fi
    
    if [[ -z "$apim_resource_group" || "$apim_resource_group" == "null" ]]; then
        echo "Error: APIM resource group not found in settings.yaml" >&2
        exit 1
    fi
    
    log_message "Api Management name: $apim_name"
    
    # Process APIM purging
    process_resource_purging "apim" "$apim_name" "$apim_resource_group" "$location"
    
    # Extract Key Vault configuration using yq -r (keeping original command format)
    local key_vault_name
    local key_vault_resource_group
    key_vault_name=$(yq -r '.shared.security.keyVault.name' ../../settings.yaml)
    key_vault_resource_group=$(yq -r '.shared.security.resourceGroup' ../../settings.yaml)
    
    # Validate Key Vault configuration values
    if [[ -z "$key_vault_name" || "$key_vault_name" == "null" ]]; then
        echo "Error: Key Vault name not found in settings.yaml" >&2
        exit 1
    fi
    
    if [[ -z "$key_vault_resource_group" || "$key_vault_resource_group" == "null" ]]; then
        echo "Error: Key Vault resource group not found in settings.yaml" >&2
        exit 1
    fi
    
    # Process Key Vault purging
    process_resource_purging "keyvault" "$key_vault_name" "$key_vault_resource_group" "$location"
    
    log_message "Azure resource purging process completed successfully"
}

# Execute main function with all provided arguments
main "$@"
