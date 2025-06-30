#!/bin/bash

# Claude Code Starter Template - Template Selector
# This script lists available templates and executes the selected one
# Templates are self-contained setup scripts with embedded content

# Save BASH_SOURCE before enabling strict mode
SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_VERSION="3.0.0"

# Detect if script is being run locally or via curl
if [[ -n "$SCRIPT_SOURCE" ]] && [[ -f "$SCRIPT_SOURCE" ]]; then
    # Local execution
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
    IS_REMOTE=false
else
    # Remote execution (via curl)
    SCRIPT_DIR="."
    IS_REMOTE=true
fi

TEMPLATES_DIR="${SCRIPT_DIR}/templates"
VIBE_DIR=".vibe"
CLAUDE_FILE="CLAUDE.md"

# GitHub repository configuration (update this to your repo)
GITHUB_REPO="check-the-vibe/claude-code-starter-template"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to print section headers
print_header() {
    echo
    print_color "$PURPLE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "$PURPLE" " $1"
    print_color "$PURPLE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to prompt user for confirmation
confirm() {
    local prompt=$1
    local default=${2:-N}
    
    if [[ $default == "Y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Function to archive existing .vibe directory
archive_vibe() {
    if [[ -d "$VIBE_DIR" ]]; then
        print_color "$YELLOW" "⚠️  Found existing $VIBE_DIR directory"
        
        if confirm "Do you want to archive the existing .vibe directory?" "Y"; then
            local archive_name=".vibe_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
            
            print_color "$BLUE" "Creating archive: $archive_name"
            tar -czf "$archive_name" "$VIBE_DIR" 2>/dev/null || {
                print_color "$RED" "Failed to create archive"
                return 1
            }
            
            print_color "$GREEN" "✓ Archived existing .vibe to: $archive_name"
            
            # Remove the old .vibe directory
            rm -rf "$VIBE_DIR"
            print_color "$GREEN" "✓ Removed old .vibe directory"
        elif ! confirm "Do you want to overwrite the existing directory?" "N"; then
            print_color "$RED" "✗ Setup cancelled by user"
            exit 1
        else
            rm -rf "$VIBE_DIR"
            print_color "$YELLOW" "⚠️  Removed existing .vibe directory (not archived)"
        fi
    fi
    
    # Also handle existing CLAUDE.md
    if [[ -f "$CLAUDE_FILE" ]]; then
        if [[ -f ".vibe_backup_$(date +%Y%m%d_%H%M%S).tar.gz" ]]; then
            # Add CLAUDE.md to the existing archive
            local latest_archive=$(ls -t .vibe_backup_*.tar.gz | head -1)
            print_color "$BLUE" "Adding CLAUDE.md to archive..."
            tar -rf "${latest_archive%.gz}" "$CLAUDE_FILE" 2>/dev/null && gzip -f "${latest_archive%.gz}"
        fi
        rm -f "$CLAUDE_FILE"
        print_color "$GREEN" "✓ Removed old CLAUDE.md"
    fi
}

# Function to list available templates
list_templates() {
    local templates=()
    
    if [[ "$IS_REMOTE" == "true" ]]; then
        # When running remotely, use predefined template list
        templates=("default" "nodejs-react" "python-project")
    else
        # Local execution - scan templates directory
        if [[ -d "$TEMPLATES_DIR" ]]; then
            for template_dir in "$TEMPLATES_DIR"/*; do
                if [[ -d "$template_dir" ]] && [[ -f "$template_dir/setup.sh" ]]; then
                    templates+=("$(basename "$template_dir")")
                fi
            done
        fi
        
        if [[ ${#templates[@]} -eq 0 ]]; then
            print_color "$RED" "No templates found in $TEMPLATES_DIR"
            exit 1
        fi
    fi
    
    echo "${templates[@]}"
}

# Function to display template selection menu
select_template() {
    local templates=($1)
    local selected=""
    
    print_header "Available Templates"
    print_color "$CYAN" "Found ${#templates[@]} templates:"
    echo
    
    # Display all templates with descriptions
    local index=1
    for template in "${templates[@]}"; do
        local desc="Template"
        
        # Read description from TEMPLATE.md if it exists (only for local execution)
        if [[ "$IS_REMOTE" == "false" ]] && [[ -f "$TEMPLATES_DIR/$template/TEMPLATE.md" ]]; then
            desc=$(head -n 5 "$TEMPLATES_DIR/$template/TEMPLATE.md" 2>/dev/null | grep -E "^#|Description:" | sed 's/^#\s*//' | sed 's/Description:\s*//' | head -n 1) || desc="No description"
        else
            # Provide descriptions for remote templates
            case "$template" in
                "default")
                    desc="Basic Claude Code setup with .vibe structure"
                    ;;
                "nodejs-react")
                    desc="Node.js + React project template"
                    ;;
                "python-project")
                    desc="Python project template with virtual environment"
                    ;;
                *)
                    desc="Template"
                    ;;
            esac
        fi
        
        print_color "$CYAN" "$index. $template"
        print_color "$BLUE" "   $desc"
        echo
        ((index++))
    done
    
    # Ask user to select
    while true; do
        print_color "$YELLOW" "Enter template number (1-${#templates[@]}) or name:"
        read -p "> " choice
        
        # Check if choice is a number
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [[ $choice -ge 1 && $choice -le ${#templates[@]} ]]; then
                selected="${templates[$((choice-1))]}"
                break
            else
                print_color "$RED" "Invalid number. Please enter a number between 1 and ${#templates[@]}."
                continue
            fi
        else
            # Check if the choice matches a template name
            for template in "${templates[@]}"; do
                if [[ "$template" == "$choice" ]]; then
                    selected="$template"
                    break 2
                fi
            done
            print_color "$RED" "Invalid template name. Please enter a valid template name or number."
        fi
    done
    
    print_color "$GREEN" "✓ Selected template: $selected"
    echo "$selected"
}

# Function to execute template setup
execute_template() {
    local template=$1
    local template_setup="$TEMPLATES_DIR/$template/setup.sh"
    
    if [[ ! -f "$template_setup" ]]; then
        print_color "$RED" "Setup script not found for template: $template"
        exit 1
    fi
    
    print_header "Executing $template Template"
    
    # Check if running locally or remotely
    if [[ "$IS_REMOTE" == "true" ]]; then
        # Remote execution - fetch template from GitHub
        local template_url="${GITHUB_RAW_URL}/templates/${template}/setup.sh"
        print_color "$BLUE" "Fetching template from: $template_url"
        
        if command -v curl &> /dev/null; then
            curl -fsSL "$template_url" | bash
        else
            print_color "$RED" "Error: curl is required for remote template execution"
            exit 1
        fi
    else
        # Local execution
        if [[ ! -f "$template_setup" ]]; then
            print_color "$RED" "Setup script not found for template: $template"
            exit 1
        fi
        
        print_color "$BLUE" "Executing local template setup..."
        bash "$template_setup"
    fi
}

# Function to show usage
show_usage() {
    print_color "$CYAN" "Claude Code Starter Template v$SCRIPT_VERSION"
    print_color "$CYAN" ""
    print_color "$CYAN" "Usage: $0 [OPTIONS]"
    print_color "$CYAN" ""
    print_color "$CYAN" "Options:"
    print_color "$CYAN" "  --list           List available templates"
    print_color "$CYAN" "  --template NAME  Use specific template (bypasses selection)"
    print_color "$CYAN" "  --local          Execute template locally (for development)"
    print_color "$CYAN" "  --help, -h       Show this help message"
    print_color "$CYAN" ""
    print_color "$CYAN" "Examples:"
    print_color "$CYAN" "  $0                     # Interactive template selection"
    print_color "$CYAN" "  $0 --template default  # Use default template"
    print_color "$CYAN" "  $0 --list             # List all templates"
    print_color "$CYAN" ""
    print_color "$CYAN" "Remote execution:"
    print_color "$CYAN" "  curl -sL $GITHUB_RAW_URL/setup.sh | bash"
}

# Main function
main() {
    local template_override=""
    local list_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --template)
                template_override="$2"
                shift 2
                ;;
            --list)
                list_only=true
                shift
                ;;
            --local)
                export LOCAL_EXEC=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_color "$RED" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_header "Claude Code Starter Template v$SCRIPT_VERSION"
    
    # Get available templates
    local templates_str=$(list_templates)
    local templates_array=($templates_str)
    
    # If list only, show templates and exit
    if [[ "$list_only" == "true" ]]; then
        print_header "Available Templates"
        for template in "${templates_array[@]}"; do
            print_color "$CYAN" "  - $template"
        done
        echo
        print_color "$BLUE" "To use a template:"
        print_color "$BLUE" "  $0 --template <name>"
        exit 0
    fi
    
    # Archive existing .vibe directory
    archive_vibe
    
    # Select template
    local selected_template=""
    if [[ -n "$template_override" ]]; then
        # Validate template exists
        local found=false
        for t in "${templates_array[@]}"; do
            if [[ "$t" == "$template_override" ]]; then
                found=true
                selected_template="$template_override"
                break
            fi
        done
        
        if [[ "$found" == "false" ]]; then
            print_color "$RED" "Template not found: $template_override"
            print_color "$YELLOW" "Available templates:"
            for t in "${templates_array[@]}"; do
                print_color "$CYAN" "  - $t"
            done
            exit 1
        fi
    else
        # Interactive selection
        selected_template=$(select_template "${templates_array[*]}")
    fi
    
    # Execute selected template
    execute_template "$selected_template"
    
    print_header "Template Installation Complete!"
    
    print_color "$GREEN" "✅ Successfully installed $selected_template template"
    print_color "$BLUE" ""
    print_color "$BLUE" "Your project is now configured with Claude Code!"
    print_color "$BLUE" "Check the .vibe directory and CLAUDE.md for details."
}

# Run main function
main "$@"