#!/bin/bash

#===============================================================================
# Script: pre-provision.sh
# Purpose: Purge soft-deleted Azure API Management (APIM) resources before provisioning
# Usage: ./pre-provision.sh <location>
# Example: ./pre-provision.sh 'East US'
#
# Description:
#   This pre-provisioning hook script is executed before Azure resource deployment.
#   It identifies and purges all soft-deleted APIM instances in the specified
#   Azure location to prevent naming conflicts and enable clean redeployment.
#
# Prerequisites:
#   - Azure CLI (az) must be installed and configured
#   - User must be authenticated with appropriate Azure permissions
#   - Permissions required: Microsoft.ApiManagement/deletedservices/delete
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments or usage error
#===============================================================================

#-------------------------------------------------------------------------------
# Function: show_usage
# Description: Displays script usage information and exits with error code
# Parameters: None
# Returns: Exits with code 1
#-------------------------------------------------------------------------------
show_usage() {
    echo "Usage: $0 <location>"
    echo "Example: $0 'East US'"
 -------------------------------------------------------------------------------
# Function: log_message
# Description: Outputs a timestamped log message for traceability
# Parameters:
#   $1 - Message string to log
#-------------------------------------------------------------------------------
# Function: get_soft_deleted_apims
# Description: Retrieves a list of all soft-deleted APIM service names
# Parameters: None
# Returns: Tab-separated list of soft-deleted APIM service names (via stdout)
#-------------------------------------------------------------------------------
# Function: purge_soft_deleted_apim
# Description: Permanently purges a soft-deleted APIM service instance
# Parameters:
#   $1 - resource_name: Name of the APIM service to purge
#   $2 - location: Azure region where the resource was originally deployed
# Returns: None
# Notes:
#   - Purging is irreversible and permanently deletes the resource
#   - Location must match the original deployment location
#   - Failures are logged but don't halt script execution
#-------------------------------------------------------------------------------
#   - Errors are suppressed (redirected to /dev/null)
#   - Returns empty string if no soft-deleted instances found
#   - Uses JMESPath query to extract only the 'name' field
#-------------------------------------------------------------------------------
# Example: log_message "Process started"
#-------------------------------------------------------------------------------
    echo "This script purges soft-deleted Azure resources to enable clean redeployment."
 -------------------------------------------------------------------------------
# Function: process_apim_purging
# Description: Orchestrates the discovery and purging of all soft-deleted APIM instances
# Parameters:
#   $1 - location: Azure region to target for purging operations
# Returns: None
# Process Flow:
#   1. Retrieves list of all soft-deleted APIM instances
#   2. Iterates through each instance
#   3. Initiates purge operation for each found instance
#   4. Logs all operations for audit trail
#-------------------------------------------------------------------------------
}

# Log messages with timestamp for better traceability
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Get all soft-deleted APIM resources
get_soft_deleted_apims() {
    az apim deletedservice list --query "[].name" -o tsv 2>/dev/null || true
}
#-------------------------------------------------------------------------------
# Function: main
# Description: Main entry point for the script - validates inputs and orchestrates purging
# Parameters:
#   $1 - location: Azure region (e.g., 'East US', 'westus2')
# Returns: 
#   Exit code 0 on success
#   Exit code 1 on validation failure
# Validation:
#   - Ensures exactly one argument is provided
#   - Verifies location parameter is not empty
# Execution Flow:
#   1. Validate command-line arguments
#   2. Log process initiation
#   3. Invoke APIM purging process
#   4. Log completion status
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
# Script Entry Point
# Execute main function with all provided command-line arguments
#------------------------------------------------------------------------------- found"
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
