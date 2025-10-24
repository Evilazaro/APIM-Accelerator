#!/bin/bash

#===============================================================================
# Azure API Management Landing Zone Accelerator - Pre-Provision Script
#===============================================================================
# Description: Purges soft-deleted Azure API Management instances and cleans up
#              Azure API Center instances to enable clean redeployment for demo 
#              and testing scenarios
# 
# This script queries the entire subscription for:
# - Soft-deleted APIM instances and purges them to prevent naming conflicts
# - Existing API Center instances and provides cleanup options
#
# Usage:       ./pre-provision.sh [environment_name] [location]
# Example:     ./pre-provision.sh "dev" "eastus2"
#
# Requirements:
#   - Azure CLI must be installed and authenticated
#===============================================================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures
IFS=$'\n\t'       # Set secure Internal Field Separator

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
readonly DEFAULT_ENV_NAME="dev"
readonly DEFAULT_LOCATION="eastus2"

# Global variables
AZURE_ENV_NAME=""
AZURE_LOCATION=""

#===============================================================================
# Function: log_info
# Description: Logs informational messages with timestamp
# Arguments: $1 - Message to log
#===============================================================================
log_info() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: ${message}"
}

#===============================================================================
# Function: log_error
# Description: Logs error messages with timestamp and exits
# Arguments: $1 - Error message to log
#===============================================================================
log_error() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: ${message}" >&2
    exit 1
}

#===============================================================================
# Function: log_warning
# Description: Logs warning messages with timestamp
# Arguments: $1 - Warning message to log
#===============================================================================
log_warning() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: ${message}" >&2
}

#===============================================================================
# Function: validate_prerequisites
# Description: Validates required tools and files are available
#===============================================================================
validate_prerequisites() {
    log_info "Validating prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az >/dev/null 2>&1; then
        log_error "Azure CLI is not installed. Please install Azure CLI to continue."
    fi
    
    # Verify Azure CLI authentication
    if ! az account show >/dev/null 2>&1; then
        log_error "Azure CLI is not authenticated. Please run 'az login' to authenticate."
    fi
    
    # Get current subscription info for logging
    local subscription_name
    subscription_name="$(az account show --query name -o tsv 2>/dev/null || echo "Unknown")"
    log_info "Operating on subscription: ${subscription_name}"
    
    log_info "Prerequisites validation completed successfully"
}

#===============================================================================
# Function: parse_arguments
# Description: Parses and validates command line arguments
# Arguments: $@ - All script arguments
#===============================================================================
parse_arguments() {
    AZURE_ENV_NAME="${1:-${DEFAULT_ENV_NAME}}"
    AZURE_LOCATION="${2:-${DEFAULT_LOCATION}}"
    
    # Validate environment name format (alphanumeric and hyphens only)
    if [[ ! "${AZURE_ENV_NAME}" =~ ^[a-zA-Z0-9-]+$ ]]; then
        log_error "Invalid environment name format: '${AZURE_ENV_NAME}'. Only alphanumeric characters and hyphens are allowed."
    fi
    
    # Validate location format (lowercase, no spaces)
    if [[ ! "${AZURE_LOCATION}" =~ ^[a-z0-9]+$ ]]; then
        log_error "Invalid location format: '${AZURE_LOCATION}'. Use lowercase format without spaces (e.g., 'eastus2')."
    fi
    
    log_info "Environment: ${AZURE_ENV_NAME}"
    log_info "Location: ${AZURE_LOCATION}"
}



#===============================================================================
# Function: normalize_location
# Description: Converts display location names to programmatic location names
# Arguments: $1 - Display location name (e.g., "East US 2")
# Returns: Normalized location name (e.g., "eastus2")
#===============================================================================
normalize_location() {
    local display_location="$1"
    local normalized_location
    
    # Convert common display names to programmatic names
    case "${display_location}" in
        "East US 2") normalized_location="eastus2" ;;
        "East US") normalized_location="eastus" ;;
        "West US 2") normalized_location="westus2" ;;
        "West US") normalized_location="westus" ;;
        "West US 3") normalized_location="westus3" ;;
        "Central US") normalized_location="centralus" ;;
        "North Central US") normalized_location="northcentralus" ;;
        "South Central US") normalized_location="southcentralus" ;;
        "West Central US") normalized_location="westcentralus" ;;
        "Canada Central") normalized_location="canadacentral" ;;
        "Canada East") normalized_location="canadaeast" ;;
        "Brazil South") normalized_location="brazilsouth" ;;
        "North Europe") normalized_location="northeurope" ;;
        "West Europe") normalized_location="westeurope" ;;
        "UK South") normalized_location="uksouth" ;;
        "UK West") normalized_location="ukwest" ;;
        "France Central") normalized_location="francecentral" ;;
        "Germany West Central") normalized_location="germanywestcentral" ;;
        "Norway East") normalized_location="norwayeast" ;;
        "Switzerland North") normalized_location="switzerlandnorth" ;;
        "UAE North") normalized_location="uaenorth" ;;
        "South Africa North") normalized_location="southafricanorth" ;;
        "Australia East") normalized_location="australiaeast" ;;
        "Australia Southeast") normalized_location="australiasoutheast" ;;
        "Southeast Asia") normalized_location="southeastasia" ;;
        "East Asia") normalized_location="eastasia" ;;
        "Japan East") normalized_location="japaneast" ;;
        "Japan West") normalized_location="japanwest" ;;
        "Korea Central") normalized_location="koreacentral" ;;
        "Central India") normalized_location="centralindia" ;;
        "South India") normalized_location="southindia" ;;
        "West India") normalized_location="westindia" ;;
        *) 
            # If no match found, try to normalize by removing spaces and converting to lowercase
            normalized_location="$(echo "${display_location}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
            ;;
    esac
    
    echo "${normalized_location}"
}

#===============================================================================
# Function: purge_soft_deleted_apim
# Description: Purges all soft-deleted APIM instances in the subscription to allow clean redeployment
#===============================================================================
purge_soft_deleted_apim() {
    log_info "Checking for all soft-deleted API Management instances in subscription..."
    
    # Query for all soft-deleted APIM instances in the subscription
    local deleted_apims_data
    deleted_apims_data="$(az apim deletedservice list --query "[].[name,location]" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${deleted_apims_data}" ]]; then
        log_info "No soft-deleted API Management instances found in subscription"
        return 0
    fi
    
    # Count total instances found
    local total_instances
    total_instances="$(echo "${deleted_apims_data}" | wc -l | tr -d '[:space:]')"
    log_info "Found ${total_instances} soft-deleted API Management instance(s) to purge"
    
    # Process each soft-deleted instance
    local purge_count=0
    local failed_count=0
    while IFS=$'\t' read -r apim_name apim_location; do
        if [[ -n "${apim_name}" && -n "${apim_location}" ]]; then
            # Normalize the location name for the purge command
            local normalized_location
            normalized_location="$(normalize_location "${apim_location}")"
            
            log_info "Purging soft-deleted API Management instance: ${apim_name}"
            log_info "Display location: ${apim_location} -> Normalized: ${normalized_location}"
            
            # Try with normalized location first
            if echo 'y' | az apim deletedservice purge --service-name "${apim_name}" --location "${normalized_location}" >/dev/null 2>&1; then
                log_info "Successfully purged: ${apim_name} using normalized location"
                ((purge_count++))
            else
                log_warning "Failed with normalized location, trying original location format..."
                
                # Try with original location format as fallback
                if echo 'y' | az apim deletedservice purge --service-name "${apim_name}" --location "${apim_location}" >/dev/null 2>&1; then
                    log_info "Successfully purged: ${apim_name} using original location format"
                    ((purge_count++))
                else
                    log_warning "Failed to purge soft-deleted API Management instance: ${apim_name}"
                    log_warning "Location tried: '${normalized_location}' and '${apim_location}'"
                    ((failed_count++))
                fi
            fi
        fi
    done <<< "${deleted_apims_data}"
    
    # Report results
    if [[ ${purge_count} -gt 0 ]]; then
        log_info "Successfully purged ${purge_count} soft-deleted API Management instance(s)"
    fi
    
    if [[ ${failed_count} -gt 0 ]]; then
        log_warning "Failed to purge ${failed_count} soft-deleted API Management instance(s)"
        log_warning "Some instances may require manual cleanup or additional permissions"
        log_warning "You can try manual purge using: az apim deletedservice purge --service-name <name> --location <location> --yes"
        
        # Don't exit with error code - continue with deployment
        log_info "Continuing with deployment despite purge failures..."
    fi
    
    if [[ ${purge_count} -eq 0 && ${failed_count} -eq 0 ]]; then
        log_info "No soft-deleted API Management instances required purging"
    fi
}

#===============================================================================
# Function: cleanup_api_center_instances
# Description: Lists and optionally cleans up Azure API Center instances that might conflict with deployment
# Note: API Center instances do not have soft-delete functionality, so this function
#       focuses on listing existing instances for manual cleanup decisions
#===============================================================================
cleanup_api_center_instances() {
    log_info "Checking for Azure API Center instances in subscription..."
    
    # Check if API Center extension is available
    if ! az extension list --query "[?name=='apic'].name" -o tsv | grep -q "apic"; then
        log_info "Azure API Center CLI extension not installed. Skipping API Center cleanup."
        log_info "To install: az extension add --name apic"
        return 0
    fi
    
    # Query for all API Center instances in the subscription
    local api_center_instances
    api_center_instances="$(az apic list --query "[].[name,resourceGroup,location]" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${api_center_instances}" ]]; then
        log_info "No Azure API Center instances found in subscription"
        return 0
    fi
    
    # Count total instances found
    local total_instances
    total_instances="$(echo "${api_center_instances}" | wc -l | tr -d '[:space:]')"
    log_info "Found ${total_instances} Azure API Center instance(s) in subscription"
    log_info "Note: API Center instances do not support soft-delete functionality"
    
    # List instances for visibility
    local instance_count=0
    while IFS=$'\t' read -r apic_name apic_rg apic_location; do
        if [[ -n "${apic_name}" && -n "${apic_rg}" && -n "${apic_location}" ]]; then
            ((instance_count++))
            log_info "API Center ${instance_count}: ${apic_name} (Resource Group: ${apic_rg}, Location: ${apic_location})"
        fi
    done <<< "${api_center_instances}"
    
    # Provide manual cleanup instructions
    if [[ ${instance_count} -gt 0 ]]; then
        log_info "API Center instances found. If cleanup is needed, use:"
        log_info "  az apic delete --name <instance-name> --resource-group <resource-group> --yes"
        log_info "Continuing with deployment as API Center instances don't block APIM deployment..."
    fi
}

#===============================================================================
# Function: main
# Description: Main script execution function
# Arguments: $@ - All script arguments
#===============================================================================
main() {
    log_info "Starting Azure API pre-provisioning cleanup script"
    log_info "=================================================="
    
    # Validate prerequisites and parse arguments
    validate_prerequisites
    parse_arguments "$@"
    
    # Purge all soft-deleted APIM instances
    purge_soft_deleted_apim
    
    # Check and provide info about API Center instances
    cleanup_api_center_instances
    
    log_info "Pre-provisioning cleanup script completed successfully"
    
    # Explicitly exit with success code
    exit 0
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
