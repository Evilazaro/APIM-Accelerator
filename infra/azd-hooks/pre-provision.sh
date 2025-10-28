#!/bin/bash

#===============================================================================
# Azure API Management Accelerator - Pre-Provision Script
#===============================================================================
# Description: Purges soft-deleted Azure API Management instances to
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

# Get all soft-deleted APIM resources
get_soft_deleted_apims() {
    az apim deletedservice list --query "[].name" -o tsv 2>/dev/null || true
}

# Purge a soft-deleted APIM resource
purge_soft_deleted_apim() {
    local resource_name="$1"
    local location="$2"
    
    log_message "APIM purge initiated for: $resource_name"
    
    if az apim deletedservice purge --service-name "$resource_name" --location "$location" 2>/dev/null; then
        log_message "APIM purge completed successfully for: $resource_name"
    else
        log_message "APIM purge failed for: $resource_name (may require different location or already purged)"
    fi
}

# Process APIM resource purging
process_apim_purging() {
    local location="$1"
    
    local soft_deleted_apims
    soft_deleted_apims=$(get_soft_deleted_apims)
    
    if [[ -z "$soft_deleted_apims" ]]; then
        log_message "No soft-deleted APIM instances found"
        return
    fi
    
    while IFS= read -r apim_name; do
        if [[ -n "$apim_name" ]]; then
            log_message "Found soft-deleted APIM: $apim_name"
            purge_soft_deleted_apim "$apim_name" "$location"
        fi
    done <<< "$soft_deleted_apims"
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
    
    log_message "Starting APIM resource purging process for location: $location"
    
    # Process APIM purging - find and purge all soft-deleted APIM instances
    process_apim_purging "$location"
    
    log_message "APIM resource purging process completed successfully"
}

# Execute main function with all provided arguments
main "$@"
