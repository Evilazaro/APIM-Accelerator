#!/bin/bash

#===============================================================================
# Azure API Management Landing Zone Accelerator - Pre-Provision Script
#===============================================================================
# Description: Purges soft-deleted Azure resources (APIM) to enable clean
#              redeployment for demo and testing scenarios
# 
# This script dynamically extracts configuration from YAML files and generates
# resource names following the same naming conventions as the Bicep templates.
# 
# Configuration Sources:
#   - infra/settings.yaml   : General solution configuration
#   - infra/workload.yaml   : APIM-specific configuration  
#   - infra/monitoring.yaml : Monitoring resources configuration
#
# Usage:       ./pre-provision.sh <environment_name> [location]
# Example:     ./pre-provision.sh "dev" "eastus2"
#
# Requirements:
#   - yq (YAML processor) must be installed
#   - Azure CLI must be authenticated
#===============================================================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures
IFS=$'\n\t'       # Set secure Internal Field Separator

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INFRA_DIR="${SCRIPT_DIR}/../../.."
readonly SETTINGS_FILE="${INFRA_DIR}/infra/settings.yaml"
readonly WORKLOAD_FILE="${INFRA_DIR}/infra/workload.yaml"
readonly MONITORING_FILE="${INFRA_DIR}/infra/monitoring.yaml"

# Default values
readonly DEFAULT_ENV_NAME="dev"
readonly DEFAULT_LOCATION="eastus2"

# Global variables
AZURE_ENV_NAME=""
AZURE_LOCATION=""
SOLUTION_NAME=""
AZURE_RESOURCE_GROUP_NAME=""
AZURE_API_MANAGEMENT_NAME=""

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
# Function: validate_prerequisites
# Description: Validates required tools and files are available
#===============================================================================
validate_prerequisites() {
    log_info "Validating prerequisites..."
    
    # Check if yq is installed
    if ! command -v yq >/dev/null 2>&1; then
        log_error "yq (YAML processor) is not installed. Please install yq to continue."
    fi
    
    # Check if Azure CLI is installed
    if ! command -v az >/dev/null 2>&1; then
        log_error "Azure CLI is not installed. Please install Azure CLI to continue."
    fi
    
    # Check if configuration files exist
    local config_files=("${SETTINGS_FILE}" "${WORKLOAD_FILE}" "${MONITORING_FILE}")
    for file in "${config_files[@]}"; do
        if [[ ! -f "${file}" ]]; then
            log_error "Configuration file not found: ${file}"
        fi
    done
    
    # Verify Azure CLI authentication
    if ! az account show >/dev/null 2>&1; then
        log_error "Azure CLI is not authenticated. Please run 'az login' to authenticate."
    fi
    
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
# Function: load_configuration
# Description: Loads configuration from YAML files and validates values
#===============================================================================
load_configuration() {
    log_info "Loading configuration from YAML files..."
    
    # Load solution name from settings.yaml
    SOLUTION_NAME="$(yq -r '.solutionName' "${SETTINGS_FILE}" 2>/dev/null || echo "")"
    if [[ -z "${SOLUTION_NAME}" || "${SOLUTION_NAME}" == "null" ]]; then
        log_error "Solution name not found or is empty in ${SETTINGS_FILE}"
    fi
    log_info "Solution Name: ${SOLUTION_NAME}"
    
    # Load resource group name (with fallback to generated name)
    AZURE_RESOURCE_GROUP_NAME="$(yq -r '.resourceGroup.name' "${SETTINGS_FILE}" 2>/dev/null || echo "")"
    if [[ -z "${AZURE_RESOURCE_GROUP_NAME}" || "${AZURE_RESOURCE_GROUP_NAME}" == "null" ]]; then
        AZURE_RESOURCE_GROUP_NAME="${SOLUTION_NAME}-${AZURE_ENV_NAME}-${AZURE_LOCATION}-rg"
        log_info "Generated Resource Group Name: ${AZURE_RESOURCE_GROUP_NAME}"
    else
        log_info "Configured Resource Group Name: ${AZURE_RESOURCE_GROUP_NAME}"
    fi
    
    # Load API Management name (with fallback to generated name)
    AZURE_API_MANAGEMENT_NAME="$(yq -r '.name' "${WORKLOAD_FILE}" 2>/dev/null || echo "")"
    if [[ -z "${AZURE_API_MANAGEMENT_NAME}" || "${AZURE_API_MANAGEMENT_NAME}" == "null" ]]; then
        AZURE_API_MANAGEMENT_NAME="${SOLUTION_NAME}-apim"
        log_info "Generated API Management Name: ${AZURE_API_MANAGEMENT_NAME}"
    else
        log_info "Configured API Management Name: ${AZURE_API_MANAGEMENT_NAME}"
    fi
}

#===============================================================================
# Function: purge_soft_deleted_apim
# Description: Purges soft-deleted APIM instances to allow clean redeployment
#===============================================================================
purge_soft_deleted_apim() {
    log_info "Checking for soft-deleted API Management instances..."
    
    # Query for soft-deleted APIM instances matching our name
    local deleted_apims
    deleted_apims="$(az apim deletedservice list --query "[?name=='${AZURE_API_MANAGEMENT_NAME}'].name" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${deleted_apims}" ]]; then
        log_info "No soft-deleted API Management instances found for '${AZURE_API_MANAGEMENT_NAME}'"
        return 0
    fi
    
    # Process each soft-deleted instance
    local purge_count=0
    while IFS= read -r apim_name; do
        if [[ -n "${apim_name}" ]]; then
            log_info "Purging soft-deleted API Management instance: ${apim_name}"
            
            if az apim deletedservice purge --service-name "${apim_name}" --location "${AZURE_LOCATION}" --yes >/dev/null 2>&1; then
                log_info "Successfully purged: ${apim_name}"
                ((purge_count++))
            else
                log_error "Failed to purge soft-deleted API Management instance: ${apim_name}"
            fi
        fi
    done <<< "${deleted_apims}"
    
    if [[ ${purge_count} -gt 0 ]]; then
        log_info "Purged ${purge_count} soft-deleted API Management instance(s)"
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
    
    # Load configuration and purge resources
    load_configuration
    purge_soft_deleted_apim
    
    log_info "Pre-provisioning script completed successfully"
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi