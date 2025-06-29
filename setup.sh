#!/bin/bash

# Claude Code Starter Template Setup Script
# Supports multiple templates and curl-to-bash installation

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
SCRIPT_VERSION="2.1.0"
# Determine script directory, handling both normal execution and curl-to-bash
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "/dev/stdin" ]] && [[ -e "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEMPLATES_DIR="${SCRIPT_DIR}/templates"
else
    # Running via curl-to-bash, templates will be downloaded
    SCRIPT_DIR=""
    TEMPLATES_DIR=""
fi
VIBE_DIR=".vibe"
CLAUDE_FILE="CLAUDE.md"

# GitHub repository for curl-to-bash (update this to your repo)
GITHUB_REPO="check-the-vibe/claude-code-starter-template"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"

# Predefined list of available templates
AVAILABLE_TEMPLATES=(
    "default"
    "nodejs-react"
    "python-project"
)

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

# Function to check if running via curl
is_curl_bash() {
    [[ "${BASH_SOURCE[0]:-}" != "${0}" ]] || [[ "${BASH_SOURCE[0]:-}" == "/dev/stdin" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]
}

# Function to download templates if running via curl
download_templates() {
    print_color "$BLUE" "Downloading templates from GitHub..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download templates using predefined list
    if command -v curl &> /dev/null; then
        # Use predefined list of templates
        for template in "${AVAILABLE_TEMPLATES[@]}"; do
            print_color "$CYAN" "  Downloading template: $template"
            mkdir -p "templates/$template"
            
            # Download template files
            curl -sL "${GITHUB_RAW_URL}/templates/${template}/TEMPLATE.md" -o "templates/${template}/TEMPLATE.md" 2>/dev/null || true
            curl -sL "${GITHUB_RAW_URL}/templates/${template}/.vibe.tar.gz" -o "templates/${template}/.vibe.tar.gz" 2>/dev/null || true
            curl -sL "${GITHUB_RAW_URL}/templates/${template}/CLAUDE.md" -o "templates/${template}/CLAUDE.md" 2>/dev/null || true
        done
    else
        print_color "$RED" "Error: curl is required for downloading templates"
        exit 1
    fi
    
    TEMPLATES_DIR="${temp_dir}/templates"
}

# Function to check if running in a git repository
check_git_repo() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to create a file with content and report status
create_file() {
    local file_path=$1
    local content=$2
    local description=$3
    
    if echo "$content" > "$file_path"; then
        print_color "$GREEN" "  ✓ Created: $description"
    else
        print_color "$RED" "  ✗ Failed to create: $description"
        return 1
    fi
}

# Function to prompt user for confirmation
confirm() {
    local prompt=$1
    local default=${2:-N}
    
    # Skip in non-interactive mode
    if [[ "${skip_interactive:-false}" == "true" ]]; then
        [[ "$default" =~ ^[Yy]$ ]]
        return $?
    fi
    
    if [[ $default == "Y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Function to list available templates
list_templates() {
    local templates=()
    
    if [[ -d "$TEMPLATES_DIR" ]]; then
        for template_dir in "$TEMPLATES_DIR"/*; do
            if [[ -d "$template_dir" ]]; then
                templates+=("$(basename "$template_dir")")
            fi
        done
    fi
    
    if [[ ${#templates[@]} -eq 0 ]]; then
        print_color "$YELLOW" "No templates found. Using built-in default template."
        echo "default"
        return 1
    fi
    
    echo "${templates[@]}"
    return 0
}

# Function to search templates with autocomplete
search_templates() {
    local templates=($1)
    local search_term=""
    local filtered_templates=()
    
    print_header "Search Templates"
    print_color "$BLUE" "Enter a search term to filter templates, or press Enter to see all:"
    echo
    
    # Read search term
    read -p "Search: " search_term
    
    # Filter templates based on search term (case-insensitive)
    if [[ -z "$search_term" ]]; then
        filtered_templates=("${templates[@]}")
    else
        # Use grep for case-insensitive matching (more portable)
        for template in "${templates[@]}"; do
            if echo "$template" | grep -qi "$search_term"; then
                filtered_templates+=("$template")
            fi
        done
    fi
    
    # Return filtered list
    echo "${filtered_templates[@]}"
}

# Function to display template selection menu
select_template() {
    local templates=($1)
    local selected=""
    local filtered_templates=()
    
    # If only one template, select it automatically
    if [[ ${#templates[@]} -eq 1 ]]; then
        echo "${templates[0]}"
        return
    fi
    
    print_color "$CYAN" "Found ${#templates[@]} templates available."
    echo
    
    # Search interface is now the primary method
    while true; do
        # Get filtered templates from search
        local filtered=$(search_templates "${templates[*]}")
        filtered_templates=($filtered)
        
        # Check if any templates match
        if [[ ${#filtered_templates[@]} -eq 0 ]]; then
            print_color "$RED" "No templates found matching your search."
            if ! confirm "Would you like to search again?" "Y"; then
                print_color "$RED" "✗ Template selection cancelled"
                exit 1
            fi
            continue
        fi
        
        # If only one template matches, select it automatically
        if [[ ${#filtered_templates[@]} -eq 1 ]]; then
            selected="${filtered_templates[0]}"
            print_color "$GREEN" "✓ Selected template: $selected"
            break
        fi
        
        # Show filtered templates
        print_header "Available Templates"
        
        for template in "${filtered_templates[@]}"; do
            local desc="Default template"
            
            # Read description from TEMPLATE.md if it exists
            if [[ -f "$TEMPLATES_DIR/$template/TEMPLATE.md" ]]; then
                desc=$(head -n 3 "$TEMPLATES_DIR/$template/TEMPLATE.md" 2>/dev/null | grep -E "^#|Description:" | sed 's/^#\s*//' | sed 's/Description:\s*//' | head -n 1) || desc="No description"
            fi
            
            print_color "$CYAN" "• $template"
            print_color "$BLUE" "  $desc"
            echo
        done
        
        # Ask user to select by name
        print_color "$YELLOW" "Type the exact template name to select it, or 's' to search again:"
        read -p "> " choice
        
        if [[ "$choice" == "s" || "$choice" == "S" ]]; then
            # Search again
            continue
        fi
        
        # Check if the choice matches one of the filtered templates
        for template in "${filtered_templates[@]}"; do
            if [[ "$template" == "$choice" ]]; then
                selected="$template"
                break 2
            fi
        done
        
        # If no exact match, show error
        print_color "$RED" "Invalid selection. Please type the exact template name or 's' to search again."
    done
    
    echo "$selected"
}

# Function to check for existing .vibe directory
check_existing_vibe() {
    if [[ -d "$VIBE_DIR" ]]; then
        print_color "$YELLOW" "⚠️  Warning: $VIBE_DIR directory already exists!"
        
        if confirm "Do you want to backup the existing directory?"; then
            # Create backups directory if it doesn't exist
            mkdir -p "${VIBE_DIR}/backups"
            
            local backup_name="backups/backup_$(date +%Y%m%d_%H%M%S)"
            local backup_path="${VIBE_DIR}/${backup_name}"
            
            # Create the specific backup directory
            mkdir -p "$backup_path"
            
            # Copy all files except the backups directory itself
            find "$VIBE_DIR" -maxdepth 1 -mindepth 1 ! -name 'backups' -exec cp -r {} "$backup_path/" \;
            
            print_color "$GREEN" "✓ Backed up to: $backup_path"
        elif ! confirm "Do you want to overwrite the existing directory?" "N"; then
            print_color "$RED" "✗ Setup cancelled by user"
            exit 1
        fi
    fi
}

# Function to apply template
apply_template() {
    local template_name=$1
    local template_path="$TEMPLATES_DIR/$template_name"
    
    print_header "Applying Template: $template_name"
    
    # Check if template exists
    if [[ ! -d "$template_path" ]]; then
        print_color "$YELLOW" "Template not found. Using built-in default."
        apply_default_template
        return
    fi
    
    # Create directory structure
    mkdir -p "$VIBE_DIR/docs"
    
    # Copy template files
    if [[ -f "$template_path/.vibe.tar.gz" ]]; then
        # Extract archived template
        tar -xzf "$template_path/.vibe.tar.gz" -C . 2>/dev/null || {
            print_color "$YELLOW" "Failed to extract template archive. Using built-in default."
            apply_default_template
            return
        }
    else
        # Copy individual files
        for file in "$template_path"/.vibe/*; do
            if [[ -f "$file" ]]; then
                cp "$file" "$VIBE_DIR/" 2>/dev/null || true
            fi
        done
        
        # Copy docs if they exist
        if [[ -d "$template_path/.vibe/docs" ]]; then
            cp -r "$template_path/.vibe/docs"/* "$VIBE_DIR/docs/" 2>/dev/null || true
        fi
    fi
    
    # Copy CLAUDE.md if it exists
    if [[ -f "$template_path/CLAUDE.md" ]]; then
        cp "$template_path/CLAUDE.md" .
    fi
    
    # Update timestamps and environment info
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local os_info=$(uname -s)
    local current_dir=$(pwd)
    local user_name=$(whoami)
    
    # Update ENVIRONMENT.md with current info
    if [[ -f "$VIBE_DIR/ENVIRONMENT.md" ]]; then
        sed -i.bak "s/Date Initialized:.*/Date Initialized: $timestamp/" "$VIBE_DIR/ENVIRONMENT.md" 2>/dev/null || true
        sed -i.bak "s/Operating System:.*/Operating System: $os_info/" "$VIBE_DIR/ENVIRONMENT.md" 2>/dev/null || true
        sed -i.bak "s/Current Directory:.*/Current Directory: ${current_dir//\//\\/}/" "$VIBE_DIR/ENVIRONMENT.md" 2>/dev/null || true
        sed -i.bak "s/User:.*/User: $user_name/" "$VIBE_DIR/ENVIRONMENT.md" 2>/dev/null || true
        rm -f "$VIBE_DIR/ENVIRONMENT.md.bak" 2>/dev/null || true
    fi
    
    print_color "$GREEN" "✓ Template applied successfully"
}

# Function to apply built-in default template
apply_default_template() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local os_info=$(uname -s)
    local current_dir=$(pwd)
    local user_name=$(whoami)
    
    # Create PERSONA.md
    create_file "$VIBE_DIR/PERSONA.md" "<!-- This file contains your persona. It defines who you are, how you should act, how you think about the world, what you know, what you are great at. Follow all of the instructions here when defining how you should respond and act to user requests. -->

# Developer Persona

You are an experienced software developer who specializes in:
- Helping developers get up and running with demonstration projects
- \"Showing by doing\" - practical, hands-on software development
- Accelerating projects through strategic pair programming
- Writing clean, maintainable, and well-documented code

## Technical Expertise
- **Languages**: NodeJS, Python, Bash, Shell scripting, and other relevant languages
- **Platforms**: Linux, macOS, Windows
- **Best Practices**: Git workflows, testing, documentation, code organization
- **Teaching Style**: Clear, patient, and thorough explanations with practical examples

## Approach
1. Always understand the context and requirements before acting
2. Break complex tasks into manageable steps
3. Explain your reasoning and decisions
4. Anticipate potential issues and address them proactively
5. Follow established patterns and conventions in the codebase" "PERSONA.md"
    
    # Create TASKS.md
    create_file "$VIBE_DIR/TASKS.md" "# Project Tasks

## Current Sprint
_Add your current tasks here_

### 🔍 Research Phase
- [ ] Understand project requirements
- [ ] Research necessary technologies
- [ ] Identify potential challenges

### 📐 Design Phase
- [ ] Plan architecture
- [ ] Create component structure
- [ ] Define data flow

### 💻 Development Phase
- [ ] Implement core functionality
- [ ] Add error handling
- [ ] Write documentation

### 🧪 Testing Phase
- [ ] Write unit tests
- [ ] Perform integration testing
- [ ] User acceptance testing

### ✅ Confirmation Phase
- [ ] Code review
- [ ] Performance optimization
- [ ] Final deployment checks

## Completed Tasks
_Move completed tasks here with timestamps_

## Backlog
_Future tasks and ideas_" "TASKS.md"
    
    # Create ERRORS.md
    create_file "$VIBE_DIR/ERRORS.md" "<!-- Errors from the previous run go in this file. Use this, and the chat context to determine what the best next course of action would be. If there are no errors, assume this is the first run, or the previous run (if available) was successful -->

# Error Log

_No errors recorded yet. Errors will be logged here with timestamps and context._

## Error Format Example:
\`\`\`
[2024-01-01 10:30:00] Error Type: Build Failed
Description: npm build failed with exit code 1
Context: Attempting to build the project after adding new dependencies
Solution: [Document the solution once resolved]
\`\`\`" "ERRORS.md"
    
    # Create LINKS.csv
    create_file "$VIBE_DIR/LINKS.csv" "title,url
Claude Documentation,https://docs.anthropic.com/en/docs/claude-code/overview
Claude Code Quickstart,https://docs.anthropic.com/en/docs/claude-code/quickstart
Common Workflows,https://docs.anthropic.com/en/docs/claude-code/common-workflows
Memory Management,https://docs.anthropic.com/en/docs/claude-code/memory
IDE Integrations,https://docs.anthropic.com/en/docs/claude-code/ide-integrations
MCP Tools,https://docs.anthropic.com/en/docs/claude-code/mcp
Troubleshooting,https://docs.anthropic.com/en/docs/claude-code/troubleshooting" "LINKS.csv"
    
    # Create LOG.txt
    create_file "$VIBE_DIR/LOG.txt" "[$timestamp] Project initialized with Claude Code starter template v$SCRIPT_VERSION
[$timestamp] Created .vibe directory structure and configuration files" "LOG.txt"
    
    # Create ENVIRONMENT.md
    create_file "$VIBE_DIR/ENVIRONMENT.md" "<!-- This file gives specific information about the environment that Claude is running in -->

# Environment Information

## System Details
- **Operating System**: $os_info
- **Current Directory**: $current_dir
- **User**: $user_name
- **Date Initialized**: $timestamp

## Project Context
- **Git Repository**: $(if check_git_repo; then echo "Yes"; else echo "No"; fi)
- **Platform**: Local Development Environment

## Available Tools
- Shell/Bash scripting
- File system access (read/write)
- Git operations
- Web fetch capabilities
- Code execution

## Constraints
_Add any specific constraints or limitations here_

## Notes
_Add any environment-specific notes or configurations_" "ENVIRONMENT.md"
    
    # Create CLAUDE.md
    create_file "$CLAUDE_FILE" "# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a starter template for Claude Code projects. The template uses a structured approach with the .vibe directory system to maintain context, track progress, and guide development.

### Key Components

The following files in the .vibe directory guide development:
- **PERSONA.md**: Defines Claude's role and approach
- **TASKS.md**: Tracks project tasks and progress
- **ERRORS.md**: Logs and tracks errors for iterative improvement
- **LINKS.csv**: External documentation and resources
- **LOG.txt**: Development history and actions taken
- **ENVIRONMENT.md**: System and project context
- **docs/**: Additional project documentation

## Workflow Guidelines

### 1. Initial Setup
- Read ENVIRONMENT.md to understand the execution context
- Review PERSONA.md to assume the appropriate role
- Check ERRORS.md for any previous issues
- Examine TASKS.md for current objectives

### 2. Task Execution
- Log each action in LOG.txt before performing it
- Break complex tasks into subtasks (max 5 steps)
- Update task status in TASKS.md as you progress
- Document findings in .vibe/docs/ as needed

### 3. Error Handling
- Log errors in ERRORS.md with context
- Prioritize fixing errors before new tasks
- Clear ERRORS.md after resolution

### 4. Documentation
- Add useful web resources to LINKS.csv
- Store relevant documentation in .vibe/docs/
- Keep LOG.txt updated with concise summaries

### 5. Git Best Practices
- Ensure .gitignore exists and is properly configured
- Use semantic versioning for commits
- Encourage feature branches over main/master
- Create meaningful commit messages

## Development Commands

Common commands for this project:
\`\`\`bash
# NPM projects
npm install       # Install dependencies
npm run dev       # Start development server
npm run build     # Build for production
npm run test      # Run tests
npm run lint      # Run linter

# Python projects
pip install -r requirements.txt  # Install dependencies
python main.py                   # Run main script
pytest                          # Run tests
black .                         # Format code

# General
git status        # Check git status
git add .         # Stage changes
git commit -m \"\" # Commit changes
\`\`\`

## Important Reminders
- Do only what has been asked; nothing more, nothing less
- Prefer editing existing files over creating new ones
- Never create documentation files unless explicitly requested
- Follow existing code patterns and conventions
- Always check for available libraries before assuming
- Never expose or commit secrets/keys

## Getting Started

1. Review all .vibe files to understand context
2. Check for any pending tasks or errors
3. Begin work according to TASKS.md
4. Update progress regularly
5. Commit changes when reaching logical stopping points" "CLAUDE.md"
    
    # Create docs/README.md
    create_file "$VIBE_DIR/docs/README.md" "# Project Documentation

This directory contains project-specific documentation gathered during development.

## Structure
- Technical documentation
- API references
- Architecture decisions
- Implementation notes
- Troubleshooting guides

## Adding Documentation
When you discover useful information during development:
1. Create appropriately named files here
2. Use clear, descriptive filenames
3. Include source links when applicable
4. Keep documentation up to date" "docs/README.md"
}

# Function to save current .vibe as template
save_as_template() {
    local template_name=$1
    
    if [[ -z "$template_name" ]]; then
        read -p "Enter template name: " template_name
    fi
    
    # Validate template name
    if [[ ! "$template_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_color "$RED" "Error: Template name must contain only letters, numbers, hyphens, and underscores"
        return 1
    fi
    
    print_header "Saving Current Configuration as Template: $template_name"
    
    # Create template directory
    local template_path="$TEMPLATES_DIR/$template_name"
    mkdir -p "$template_path"
    
    # Archive .vibe directory
    if [[ -d "$VIBE_DIR" ]]; then
        tar -czf "$template_path/.vibe.tar.gz" "$VIBE_DIR" 2>/dev/null || {
            print_color "$RED" "Error: Failed to archive .vibe directory"
            return 1
        }
        print_color "$GREEN" "✓ Archived .vibe directory"
    fi
    
    # Copy CLAUDE.md
    if [[ -f "$CLAUDE_FILE" ]]; then
        cp "$CLAUDE_FILE" "$template_path/"
        print_color "$GREEN" "✓ Copied CLAUDE.md"
    fi
    
    # Create TEMPLATE.md
    print_color "$CYAN" "Please provide a description for this template:"
    read -p "> " description
    
    create_file "$template_path/TEMPLATE.md" "# $template_name Template

Description: $description

## Purpose
This template was created from a working Claude Code project configuration.

## Features
- Custom PERSONA.md configuration
- Pre-configured TASKS.md structure
- Project-specific CLAUDE.md guidelines
- Relevant documentation and links

## Usage
Select this template during setup to apply these configurations to a new project.

Created: $(date '+%Y-%m-%d %H:%M:%S')" "TEMPLATE.md"
    
    print_color "$GREEN" "✅ Template '$template_name' saved successfully!"
    print_color "$BLUE" "   Location: $template_path"
}

# Function to handle git setup
setup_git() {
    if check_git_repo; then
        print_color "$GREEN" "✓ Git repository detected"
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        print_color "$BLUE" "  Current branch: $branch"
    else
        print_color "$YELLOW" "⚠️  Not in a git repository"
        
        if confirm "Would you like to initialize a git repository?"; then
            git init
            print_color "$GREEN" "✓ Git repository initialized"
        fi
    fi
    
    # Create or update .gitignore
    if [[ ! -f .gitignore ]]; then
        cat > .gitignore << 'EOF'
# OS files
.DS_Store
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~

# Logs
logs/
*.log

# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# Environment files
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
out/

# Claude Code backups
.vibe/backups/
EOF
        print_color "$GREEN" "✓ Created .gitignore"
    else
        # Ensure .vibe/backups/ is in gitignore
        if ! grep -q "^\.vibe/backups/" .gitignore 2>/dev/null; then
            echo -e "\n# Claude Code backups\n.vibe/backups/" >> .gitignore
            print_color "$GREEN" "✓ Added .vibe/backups/ to .gitignore"
        fi
    fi
}

# Global variable for non-interactive mode
skip_interactive=false

# Main setup function
main() {
    print_header "Claude Code Starter Template Setup v$SCRIPT_VERSION"
    
    # Parse command line arguments first
    local template_override=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --template)
                template_override="$2"
                shift 2
                ;;
            --save-template)
                if [[ ! -d "$VIBE_DIR" ]]; then
                    print_color "$RED" "Error: No .vibe directory found to save as template"
                    exit 1
                fi
                save_as_template "${2:-}"
                exit 0
                ;;
            --non-interactive)
                skip_interactive=true
                shift
                ;;
            --list-templates)
                print_header "Available Templates"
                if is_curl_bash; then
                    # Show predefined list when running via curl
                    for template in "${AVAILABLE_TEMPLATES[@]}"; do
                        print_color "$CYAN" "  - $template"
                    done
                else
                    # Show actual templates from directory
                    local temps=$(list_templates)
                    if [[ -n "$temps" ]]; then
                        for template in $temps; do
                            print_color "$CYAN" "  - $template"
                        done
                    fi
                fi
                exit 0
                ;;
            --help|-h)
                print_color "$CYAN" "Usage: $0 [OPTIONS]"
                print_color "$CYAN" "Options:"
                print_color "$CYAN" "  --template NAME         Use specific template (bypasses selection)"
                print_color "$CYAN" "  --save-template [name]  Save current .vibe as a template"
                print_color "$CYAN" "  --non-interactive      Skip all prompts (use defaults)"
                print_color "$CYAN" "  --list-templates       List available templates"
                print_color "$CYAN" "  --help, -h             Show this help message"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Check if running via curl and download templates
    if is_curl_bash; then
        download_templates
    fi
    
    # Setup git
    setup_git
    
    # Check for existing .vibe directory
    check_existing_vibe
    
    # Get available templates
    local templates_str=$(list_templates)
    local templates_array=($templates_str)
    
    # Select template
    local selected_template=""
    if [[ -n "$template_override" ]]; then
        # Check if override template exists
        local found=false
        for t in "${templates_array[@]}"; do
            if [[ "$t" == "$template_override" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "true" ]] || [[ "$template_override" == "default" ]]; then
            selected_template="$template_override"
            print_color "$BLUE" "Using template: $selected_template"
        else
            print_color "$YELLOW" "Template '$template_override' not found. Using default."
            selected_template="default"
        fi
    elif [[ ${#templates_array[@]} -gt 1 ]] && [[ "$skip_interactive" != "true" ]]; then
        selected_template=$(select_template "${templates_array[*]}")
    else
        selected_template="${templates_array[0]:-default}"
        if [[ "$selected_template" != "default" ]]; then
            print_color "$BLUE" "Using template: $selected_template"
        fi
    fi
    
    print_header "Creating Directory Structure"
    
    # Create directory structure
    mkdir -p "$VIBE_DIR/docs"
    print_color "$GREEN" "✓ Created directory structure"
    
    # Apply selected template
    if [[ "$selected_template" == "default" ]] || [[ -z "$selected_template" ]]; then
        print_header "Creating Configuration Files"
        apply_default_template
    else
        apply_template "$selected_template"
    fi
    
    print_header "Setup Complete!"
    
    print_color "$GREEN" "✅ Successfully created Claude Code starter template!"
    echo
    print_color "$BLUE" "📁 Created structure:"
    tree -a "$VIBE_DIR" 2>/dev/null || {
        echo "  $VIBE_DIR/"
        echo "  ├── PERSONA.md"
        echo "  ├── TASKS.md"
        echo "  ├── ERRORS.md"
        echo "  ├── LINKS.csv"
        echo "  ├── LOG.txt"
        echo "  ├── ENVIRONMENT.md"
        echo "  └── docs/"
        echo "      └── README.md"
    }
    echo "  $CLAUDE_FILE"
    
    echo
    print_color "$YELLOW" "🚀 Next steps:"
    echo "  1. Review and customize $VIBE_DIR/PERSONA.md for your project"
    echo "  2. Add your specific tasks to $VIBE_DIR/TASKS.md"
    echo "  3. Update $CLAUDE_FILE with project-specific guidelines"
    echo "  4. Start developing with Claude Code!"
    
    echo
    print_color "$CYAN" "💡 Pro tip: Save your configuration as a template:"
    echo "     ./setup.sh --save-template my-template"
    
    # Prompt for git operations
    if check_git_repo && [[ "$skip_interactive" != "true" ]] && confirm "Would you like to create an initial commit?" "Y"; then
        git add .
        git commit -m "feat: Initialize Claude Code starter template

- Add .vibe directory structure
- Create CLAUDE.md configuration
- Set up development workflow
- Add documentation templates
- Template: $selected_template

Generated with setup.sh v$SCRIPT_VERSION"
        print_color "$GREEN" "✓ Created initial commit"
        
        if [[ $(git branch --show-current) == "main" ]] || [[ $(git branch --show-current) == "master" ]]; then
            print_color "$YELLOW" "💡 Tip: Consider creating a feature branch for your development:"
            echo "     git checkout -b feature/your-feature-name"
        fi
    fi
    
    # Clean up temp directory if curl-to-bash
    if is_curl_bash && [[ -d "${temp_dir:-}" ]]; then
        rm -rf "$temp_dir"
    fi
}

# Run main function
main "$@"