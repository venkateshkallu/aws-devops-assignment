#!/bin/bash

# Workflow Synchronization Script
# This script manages synchronization between pipeline/ workflows and .github/workflows/
# Supports cross-platform compatibility with fallback mechanisms

set -e

# Configuration
PIPELINE_DIR="pipeline"
GITHUB_WORKFLOWS_DIR=".github/workflows"
LOG_FILE="pipeline/sync.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if running on Windows (Git Bash, WSL, etc.)
is_windows() {
    [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]
}

# Check if symbolic links are supported
supports_symlinks() {
    if is_windows; then
        # On Windows, check if we have symlink privileges
        if command -v fsutil >/dev/null 2>&1; then
            fsutil behavior query SymlinkEvaluation >/dev/null 2>&1
            return $?
        else
            return 1
        fi
    else
        # On Unix-like systems, symlinks are generally supported
        return 0
    fi
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log "INFO" "Created directory: $dir"
    fi
}

# Validate YAML syntax
validate_yaml() {
    local file=$1
    
    if command -v yamllint >/dev/null 2>&1; then
        if yamllint "$file" >/dev/null 2>&1; then
            log "INFO" "YAML validation passed for: $file"
            return 0
        else
            log "ERROR" "YAML validation failed for: $file"
            return 1
        fi
    elif command -v python3 >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" >/dev/null 2>&1; then
            log "INFO" "YAML validation passed for: $file"
            return 0
        else
            log "ERROR" "YAML validation failed for: $file"
            return 1
        fi
    else
        log "WARN" "No YAML validator found, skipping validation for: $file"
        return 0
    fi
}

# Create symbolic link
create_symlink() {
    local source=$1
    local target=$2
    local relative_source=$3
    
    # Remove existing file/link if it exists
    if [[ -e "$target" || -L "$target" ]]; then
        rm "$target"
        log "INFO" "Removed existing file: $target"
    fi
    
    # Create symbolic link
    if ln -s "$relative_source" "$target" 2>/dev/null; then
        log "INFO" "Created symbolic link: $target -> $relative_source"
        return 0
    else
        log "ERROR" "Failed to create symbolic link: $target -> $relative_source"
        return 1
    fi
}

# Copy file as fallback
copy_file() {
    local source=$1
    local target=$2
    
    # Remove existing file if it exists
    if [[ -e "$target" ]]; then
        rm "$target"
        log "INFO" "Removed existing file: $target"
    fi
    
    # Copy file
    if cp "$source" "$target"; then
        log "INFO" "Copied file: $source -> $target"
        return 0
    else
        log "ERROR" "Failed to copy file: $source -> $target"
        return 1
    fi
}

# Sync a single workflow file
sync_workflow() {
    local workflow_file=$1
    local source_path="${PIPELINE_DIR}/${workflow_file}"
    local target_path="${GITHUB_WORKFLOWS_DIR}/${workflow_file}"
    local relative_source="../../${source_path}"
    
    # Check if source file exists
    if [[ ! -f "$source_path" ]]; then
        log "ERROR" "Source workflow file not found: $source_path"
        return 1
    fi
    
    # Validate YAML syntax
    if ! validate_yaml "$source_path"; then
        log "ERROR" "YAML validation failed for: $source_path"
        return 1
    fi
    
    # Ensure target directory exists
    ensure_directory "$GITHUB_WORKFLOWS_DIR"
    
    # Try symbolic link first, fallback to copy
    if supports_symlinks && create_symlink "$source_path" "$target_path" "$relative_source"; then
        print_status "$GREEN" "✓ Synced $workflow_file using symbolic link"
        return 0
    elif copy_file "$source_path" "$target_path"; then
        print_status "$YELLOW" "✓ Synced $workflow_file using file copy (fallback)"
        log "WARN" "Used file copy fallback for: $workflow_file"
        return 0
    else
        print_status "$RED" "✗ Failed to sync $workflow_file"
        return 1
    fi
}

# Check sync status
check_sync_status() {
    local workflow_file=$1
    local source_path="${PIPELINE_DIR}/${workflow_file}"
    local target_path="${GITHUB_WORKFLOWS_DIR}/${workflow_file}"
    
    if [[ ! -f "$source_path" ]]; then
        print_status "$RED" "✗ Source missing: $source_path"
        return 1
    fi
    
    if [[ ! -f "$target_path" ]]; then
        print_status "$RED" "✗ Target missing: $target_path"
        return 1
    fi
    
    if [[ -L "$target_path" ]]; then
        local link_target=$(readlink "$target_path")
        if [[ "$link_target" == "../../${source_path}" ]]; then
            print_status "$GREEN" "✓ $workflow_file (symbolic link)"
        else
            print_status "$YELLOW" "⚠ $workflow_file (broken symbolic link)"
            return 1
        fi
    else
        # Check if files are identical
        if cmp -s "$source_path" "$target_path"; then
            print_status "$GREEN" "✓ $workflow_file (file copy - in sync)"
        else
            print_status "$YELLOW" "⚠ $workflow_file (file copy - out of sync)"
            return 1
        fi
    fi
    
    return 0
}

# Repair broken links
repair_workflow() {
    local workflow_file=$1
    print_status "$BLUE" "Repairing $workflow_file..."
    sync_workflow "$workflow_file"
}

# Main sync function
sync_all_workflows() {
    print_status "$BLUE" "Starting workflow synchronization..."
    log "INFO" "Starting workflow synchronization"
    
    local failed_count=0
    
    # Find all .yml and .yaml files in pipeline directory
    for workflow_file in "${PIPELINE_DIR}"/*.yml "${PIPELINE_DIR}"/*.yaml; do
        if [[ -f "$workflow_file" ]]; then
            local filename=$(basename "$workflow_file")
            if ! sync_workflow "$filename"; then
                ((failed_count++))
            fi
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        print_status "$GREEN" "✓ All workflows synchronized successfully"
        log "INFO" "All workflows synchronized successfully"
    else
        print_status "$RED" "✗ $failed_count workflow(s) failed to synchronize"
        log "ERROR" "$failed_count workflow(s) failed to synchronize"
        return 1
    fi
}

# Check status of all workflows
check_all_status() {
    print_status "$BLUE" "Checking workflow synchronization status..."
    
    local failed_count=0
    
    for workflow_file in "${PIPELINE_DIR}"/*.yml "${PIPELINE_DIR}"/*.yaml; do
        if [[ -f "$workflow_file" ]]; then
            local filename=$(basename "$workflow_file")
            if ! check_sync_status "$filename"; then
                ((failed_count++))
            fi
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        print_status "$GREEN" "✓ All workflows are properly synchronized"
    else
        print_status "$YELLOW" "⚠ $failed_count workflow(s) need attention"
        return 1
    fi
}

# Repair all workflows
repair_all_workflows() {
    print_status "$BLUE" "Repairing all workflow synchronization..."
    
    for workflow_file in "${PIPELINE_DIR}"/*.yml "${PIPELINE_DIR}"/*.yaml; do
        if [[ -f "$workflow_file" ]]; then
            local filename=$(basename "$workflow_file")
            repair_workflow "$filename"
        fi
    done
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  sync     Synchronize all workflows from pipeline/ to .github/workflows/"
    echo "  status   Check synchronization status of all workflows"
    echo "  repair   Repair broken or out-of-sync workflows"
    echo "  help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 sync          # Sync all workflows"
    echo "  $0 status        # Check sync status"
    echo "  $0 repair        # Repair all workflows"
}

# Main script logic
main() {
    local command=${1:-sync}
    
    # Create log file directory if it doesn't exist
    ensure_directory "$(dirname "$LOG_FILE")"
    
    case "$command" in
        "sync")
            sync_all_workflows
            ;;
        "status")
            check_all_status
            ;;
        "repair")
            repair_all_workflows
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            print_status "$RED" "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"