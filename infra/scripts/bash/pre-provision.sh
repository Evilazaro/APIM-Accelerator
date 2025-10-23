#!/bin/bash

#===============================================================================
# Azure API Management Landing Zone Accelerator - Pre-Provision Script
#===============================================================================
# Description: Purges all soft-deleted Azure API Management instances in the
#              subscription to enable clean redeployment for demo and testing scenarios
# 
# This script queries the entire subscription for soft-deleted APIM instances
# and purges them all to prevent naming conflicts during new deployments.
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
            log_info "Purging soft-deleted API Management instance: ${apim_name} in location: ${apim_location}"
            
            if az apim deletedservice purge --service-name "${apim_name}" --location "${apim_location}" --yes >/dev/null 2>&1; then
                log_info "Successfully purged: ${apim_name}"
                ((purge_count++))
            else
                log_warning "Failed to purge soft-deleted API Management instance: ${apim_name} in ${apim_location}"
                ((failed_count++))
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
    fi
    
    if [[ ${purge_count} -eq 0 && ${failed_count} -eq 0 ]]; then
        log_info "No soft-deleted API Management instances required purging"
    fi
}

#===============================================================================
# Function: main
# Description: Main script execution function
# Arguments: $@ - All script arguments
#===============================================================================
main() {
    log_info "Starting Azure APIM pre-provisioning script"
    log_info "============================================="
    
    # Validate prerequisites and parse arguments
    validate_prerequisites
    parse_arguments "$@"
    
    # Purge all soft-deleted APIM instances
    purge_soft_deleted_apim
    
    log_info "Pre-provisioning script completed successfully"
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
