#!/bin/bash

# Claude Code Default Template - Standalone Setup Script
# This script contains all template content embedded directly
# Can be run via: curl -sL <url> | bash

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
TEMPLATE_NAME="default"
TEMPLATE_VERSION="1.0.0"
VIBE_DIR=".vibe"
CLAUDE_FILE="CLAUDE.md"

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
    
    if [[ $default == "Y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
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

# Main setup function
main() {
    print_header "Claude Code Default Template Setup v$TEMPLATE_VERSION"
    
    # Setup git
    setup_git
    
    # Check for existing .vibe directory
    check_existing_vibe
    
    print_header "Creating Directory Structure"
    
    # Create directory structure
    mkdir -p "$VIBE_DIR/docs"
    mkdir -p "$VIBE_DIR/backups"
    print_color "$GREEN" "✓ Created directory structure"
    
    print_header "Creating Configuration Files"
    
    # Get system information
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
    create_file "$VIBE_DIR/LOG.txt" "[$timestamp] Project initialized with Claude Code $TEMPLATE_NAME template v$TEMPLATE_VERSION
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
    
    # Create clean.sh script
    create_file "clean.sh" '#!/bin/bash

# Clean script to remove .vibe directory and CLAUDE.md
# This helps reset the project to a clean state

set -e

# Colors for output
GREEN='\''\033[0;32m'\''
RED='\''\033[0;31m'\''
YELLOW='\''\033[1;33m'\''
BLUE='\''\033[0;34m'\''
NC='\''\033[0m'\'' # No Color

echo -e "${BLUE}Claude Code Starter Template - Clean Script${NC}"
echo "=========================================="
echo

# Check what exists
FILES_TO_REMOVE=()

if [[ -d ".vibe" ]]; then
    FILES_TO_REMOVE+=(".vibe/")
fi

if [[ -f "CLAUDE.md" ]]; then
    FILES_TO_REMOVE+=("CLAUDE.md")
fi

# If nothing to remove, exit
if [[ ${#FILES_TO_REMOVE[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ Already clean - no .vibe/ or CLAUDE.md found${NC}"
    exit 0
fi

# Show what will be removed
echo -e "${YELLOW}The following will be removed:${NC}"
for item in "${FILES_TO_REMOVE[@]}"; do
    echo "  - $item"
done
echo

# Confirm with user
read -p "Are you sure you want to remove these files? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Remove files
    for item in "${FILES_TO_REMOVE[@]}"; do
        rm -rf "$item"
        echo -e "${GREEN}✓ Removed $item${NC}"
    done
    echo
    echo -e "${GREEN}✓ Cleanup complete!${NC}"
    echo -e "${BLUE}You can now run setup.sh to create a fresh configuration.${NC}"
else
    echo -e "${RED}✗ Cleanup cancelled${NC}"
    exit 1
fi' "clean.sh"
    
    # Make clean.sh executable
    chmod +x clean.sh
    
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
    
    print_header "Setup Complete!"
    
    print_color "$GREEN" "✅ Successfully created Claude Code $TEMPLATE_NAME template!"
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
        echo "  ├── backups/"
        echo "  └── docs/"
        echo "      └── README.md"
    }
    echo "  $CLAUDE_FILE"
    echo "  clean.sh"
    
    echo
    print_color "$YELLOW" "🚀 Next steps:"
    echo "  1. Review and customize $VIBE_DIR/PERSONA.md for your project"
    echo "  2. Add your specific tasks to $VIBE_DIR/TASKS.md"
    echo "  3. Update $CLAUDE_FILE with project-specific guidelines"
    echo "  4. Start developing with Claude Code!"
    
    echo
    print_color "$CYAN" "💡 Pro tips:"
    echo "  - Reset to start fresh: ./clean.sh"
    echo "  - Check out other templates at: https://github.com/check-the-vibe/claude-code-starter-template"
    
    # Prompt for git operations
    if check_git_repo && confirm "Would you like to create an initial commit?" "Y"; then
        git add .
        git commit -m "feat: Initialize Claude Code starter template

- Add .vibe directory structure
- Create CLAUDE.md configuration
- Set up development workflow
- Add documentation templates
- Template: $TEMPLATE_NAME

Generated with Claude Code $TEMPLATE_NAME template v$TEMPLATE_VERSION"
        print_color "$GREEN" "✓ Created initial commit"
        
        if [[ $(git branch --show-current) == "main" ]] || [[ $(git branch --show-current) == "master" ]]; then
            print_color "$YELLOW" "💡 Tip: Consider creating a feature branch for your development:"
            echo "     git checkout -b feature/your-feature-name"
        fi
    fi
}

# Run main function
main "$@"