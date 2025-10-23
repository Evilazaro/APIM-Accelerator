#!/usr/bin/env bash

#===============================================================================
# Azure Deployment Cancellation and Cleanup Script
#===============================================================================
# Description: Cancels all running Azure deployments and deletes deployment 
#              history across subscription and resource group scopes.
#              Used for cleanup operations in demo and testing scenarios.
# 
# This script performs the following operations:
#   1. Cancels all running subscription-level deployments
#   2. Cancels all running resource group-level deployments
#   3. Deletes all subscription deployment history
#   4. Deletes all resource group deployment history
#
# Usage:       ./cancel-deployments.sh
# 
# Requirements:
#   - Azure CLI must be installed and authenticated
#   - Appropriate permissions for deployment management
#===============================================================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures
IFS=$'\n\t'       # Set secure Internal Field Separator

# Script configuration
readonly SCRIPT_NAME="$(basename "${0}")"

# Global counters for reporting
CANCELLED_SUB_DEPLOYMENTS=0
CANCELLED_RG_DEPLOYMENTS=0
DELETED_SUB_DEPLOYMENTS=0
DELETED_RG_DEPLOYMENTS=0

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
# Description: Validates required tools and authentication
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
# Function: cancel_subscription_deployments
# Description: Cancels all running subscription-level deployments
#===============================================================================
cancel_subscription_deployments() {
    log_info "Checking for running subscription deployments..."
    
    local running_deployments
    running_deployments="$(az deployment sub list --query "[?properties.provisioningState=='Running'].name" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${running_deployments}" ]]; then
        log_info "No running subscription deployments found"
        return 0
    fi
    
    log_info "Found running subscription deployments, proceeding with cancellation..."
    
    # Process each running deployment
    while IFS= read -r deployment_name; do
        if [[ -n "${deployment_name}" ]]; then
            log_info "Cancelling subscription deployment: ${deployment_name}"
            
            if az deployment sub cancel --name "${deployment_name}" >/dev/null 2>&1; then
                log_info "Successfully cancelled: ${deployment_name}"
                ((CANCELLED_SUB_DEPLOYMENTS++))
            else
                log_warning "Failed to cancel subscription deployment: ${deployment_name}"
            fi
        fi
    done <<< "${running_deployments}"
    
    log_info "Cancelled ${CANCELLED_SUB_DEPLOYMENTS} subscription deployment(s)"
}

#===============================================================================
# Function: cancel_resource_group_deployments
# Description: Cancels all running resource group-level deployments
#===============================================================================
cancel_resource_group_deployments() {
    log_info "Checking for running resource group deployments..."
    
    # Get all resource groups
    local resource_groups
    resource_groups="$(az group list --query "[].name" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${resource_groups}" ]]; then
        log_info "No resource groups found"
        return 0
    fi
    
    # Process each resource group
    while IFS= read -r rg_name; do
        if [[ -n "${rg_name}" ]]; then
            log_info "Checking resource group: ${rg_name}"
            
            local running_deployments
            running_deployments="$(az deployment group list --resource-group "${rg_name}" --query "[?properties.provisioningState=='Running'].name" -o tsv 2>/dev/null || echo "")"
            
            if [[ -n "${running_deployments}" ]]; then
                # Cancel deployments in this resource group
                while IFS= read -r deployment_name; do
                    if [[ -n "${deployment_name}" ]]; then
                        log_info "Cancelling deployment: ${deployment_name} in resource group: ${rg_name}"
                        
                        if az deployment group cancel --name "${deployment_name}" --resource-group "${rg_name}" >/dev/null 2>&1; then
                            log_info "Successfully cancelled: ${deployment_name}"
                            ((CANCELLED_RG_DEPLOYMENTS++))
                        else
                            log_warning "Failed to cancel deployment: ${deployment_name} in resource group: ${rg_name}"
                        fi
                    fi
                done <<< "${running_deployments}"
            fi
        fi
    done <<< "${resource_groups}"
    
    log_info "Cancelled ${CANCELLED_RG_DEPLOYMENTS} resource group deployment(s)"
}

#===============================================================================
# Function: delete_subscription_deployments
# Description: Deletes all subscription deployment history
#===============================================================================
delete_subscription_deployments() {
    log_info "Deleting subscription deployment history..."
    
    local all_deployments
    all_deployments="$(az deployment sub list --query "[].name" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${all_deployments}" ]]; then
        log_info "No subscription deployments found to delete"
        return 0
    fi
    
    # Process each deployment for deletion
    while IFS= read -r deployment_name; do
        if [[ -n "${deployment_name}" ]]; then
            log_info "Deleting subscription deployment: ${deployment_name}"
            
            if az deployment sub delete --name "${deployment_name}" >/dev/null 2>&1; then
                log_info "Successfully deleted: ${deployment_name}"
                ((DELETED_SUB_DEPLOYMENTS++))
            else
                log_warning "Failed to delete subscription deployment: ${deployment_name}"
            fi
        fi
    done <<< "${all_deployments}"
    
    log_info "Deleted ${DELETED_SUB_DEPLOYMENTS} subscription deployment(s)"
}

#===============================================================================
# Function: delete_resource_group_deployments
# Description: Deletes all resource group deployment history
#===============================================================================
delete_resource_group_deployments() {
    log_info "Deleting resource group deployment history..."
    
    # Get all resource groups
    local resource_groups
    resource_groups="$(az group list --query "[].name" -o tsv 2>/dev/null || echo "")"
    
    if [[ -z "${resource_groups}" ]]; then
        log_info "No resource groups found"
        return 0
    fi
    
    # Process each resource group
    while IFS= read -r rg_name; do
        if [[ -n "${rg_name}" ]]; then
            log_info "Processing resource group: ${rg_name}"
            
            local all_deployments
            all_deployments="$(az deployment group list --resource-group "${rg_name}" --query "[].name" -o tsv 2>/dev/null || echo "")"
            
            if [[ -n "${all_deployments}" ]]; then
                # Delete deployments in this resource group
                while IFS= read -r deployment_name; do
                    if [[ -n "${deployment_name}" ]]; then
                        log_info "Deleting deployment: ${deployment_name} from resource group: ${rg_name}"
                        
                        if az deployment group delete --name "${deployment_name}" --resource-group "${rg_name}" >/dev/null 2>&1; then
                            log_info "Successfully deleted: ${deployment_name}"
                            ((DELETED_RG_DEPLOYMENTS++))
                        else
                            log_warning "Failed to delete deployment: ${deployment_name} from resource group: ${rg_name}"
                        fi
                    fi
                done <<< "${all_deployments}"
            fi
        fi
    done <<< "${resource_groups}"
    
    log_info "Deleted ${DELETED_RG_DEPLOYMENTS} resource group deployment(s)"
}

#===============================================================================
# Function: print_summary
# Description: Prints a summary of all operations performed
#===============================================================================
print_summary() {
    log_info "Operation Summary:"
    log_info "=================="
    log_info "Cancelled subscription deployments: ${CANCELLED_SUB_DEPLOYMENTS}"
    log_info "Cancelled resource group deployments: ${CANCELLED_RG_DEPLOYMENTS}"
    log_info "Deleted subscription deployments: ${DELETED_SUB_DEPLOYMENTS}"
    log_info "Deleted resource group deployments: ${DELETED_RG_DEPLOYMENTS}"
    log_info "Total operations: $((CANCELLED_SUB_DEPLOYMENTS + CANCELLED_RG_DEPLOYMENTS + DELETED_SUB_DEPLOYMENTS + DELETED_RG_DEPLOYMENTS))"
}

#===============================================================================
# Function: main
# Description: Main script execution function
#===============================================================================
main() {
    log_info "Starting Azure deployment cancellation and cleanup"
    log_info "=================================================="
    
    # Validate prerequisites
    validate_prerequisites
    
    # Cancel running deployments
    cancel_subscription_deployments
    cancel_resource_group_deployments
    
    # Delete deployment history
    delete_subscription_deployments
    delete_resource_group_deployments
    
    # Print summary
    print_summary
    
    log_info "Deployment cancellation and cleanup completed successfully"
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi