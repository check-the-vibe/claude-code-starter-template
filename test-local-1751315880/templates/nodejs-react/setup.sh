#!/bin/bash

# Claude Code Node.js React Template - Standalone Setup Script
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
TEMPLATE_NAME="nodejs-react"
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
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
.nyc_output/

# Production build
dist/
build/
out/
*.production

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Parcel cache
.cache
.parcel-cache

# Next.js
.next/
out/

# Nuxt.js
.nuxt
dist/

# Gatsby
.cache/
public

# VuePress
.vuepress/dist

# Temporary files
*.tmp
*.temp

# TypeScript
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

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
    print_header "Claude Code Node.js React Template Setup v$TEMPLATE_VERSION"
    
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
    create_file "$VIBE_DIR/PERSONA.md" "<!-- JavaScript/React Developer Persona -->

# Full-Stack JavaScript Developer

You are an experienced JavaScript developer specializing in:
- React with modern hooks and functional components
- Node.js/Express backend development
- TypeScript for type safety
- Modern JavaScript (ES6+) features
- RESTful and GraphQL APIs

## Technical Expertise
- **Frontend**: React, Redux/Context API, React Router, CSS-in-JS
- **Backend**: Node.js, Express, NestJS, Fastify
- **Testing**: Jest, React Testing Library, Cypress
- **Tools**: npm/yarn, Webpack, Vite, ESLint, Prettier
- **Database**: MongoDB, PostgreSQL, Redis

## Development Approach
1. Component-driven development
2. Test-driven development (TDD)
3. Responsive and accessible UI
4. Performance optimization
5. Clean, modular code architecture" "PERSONA.md"
    
    # Create TASKS.md
    create_file "$VIBE_DIR/TASKS.md" "# Project Tasks - Node.js React Application

## Current Sprint
_Add your current tasks here_

### 🔍 Research Phase
- [ ] Define application requirements
- [ ] Choose state management solution
- [ ] Plan component architecture
- [ ] Design API structure

### 📐 Setup Phase
- [ ] Initialize React application
- [ ] Set up Node.js backend
- [ ] Configure development environment
- [ ] Set up linting and formatting

### 💻 Development Phase
- [ ] Create React components
- [ ] Implement routing
- [ ] Build API endpoints
- [ ] Set up database connections
- [ ] Implement authentication

### 🧪 Testing Phase
- [ ] Write unit tests
- [ ] Create integration tests
- [ ] Set up E2E testing
- [ ] Performance testing

### 🚀 Deployment Phase
- [ ] Build optimization
- [ ] Environment configuration
- [ ] CI/CD setup
- [ ] Production deployment

## Completed Tasks
_Move completed tasks here with timestamps_

## Backlog
_Future features and improvements_" "TASKS.md"
    
    # Create ERRORS.md
    create_file "$VIBE_DIR/ERRORS.md" "<!-- Errors from the previous run go in this file. Use this, and the chat context to determine what the best next course of action would be. If there are no errors, assume this is the first run, or the previous run (if available) was successful -->

# Error Log

_No errors recorded yet. Errors will be logged here with timestamps and context._

## Common JavaScript/React Errors to Watch For:
- Module not found errors
- React hook violations
- CORS issues
- Async/await errors
- TypeScript type errors
- Build/compilation errors

## Error Format Example:
\`\`\`
[2024-01-01 10:30:00] Error Type: Module Not Found
Description: Cannot find module 'react-router-dom'
Context: Attempting to set up routing
Solution: npm install react-router-dom
\`\`\`" "ERRORS.md"
    
    # Create LINKS.csv
    create_file "$VIBE_DIR/LINKS.csv" "title,url
Claude Documentation,https://docs.anthropic.com/en/docs/claude-code/overview
React Documentation,https://react.dev/
Node.js Documentation,https://nodejs.org/docs/
Express Documentation,https://expressjs.com/
TypeScript Documentation,https://www.typescriptlang.org/docs/
Create React App,https://create-react-app.dev/
Vite Documentation,https://vitejs.dev/
Jest Documentation,https://jestjs.io/docs/getting-started
React Testing Library,https://testing-library.com/docs/react-testing-library/intro/
ESLint Documentation,https://eslint.org/docs/latest/
npm Documentation,https://docs.npmjs.com/" "LINKS.csv"
    
    # Create LOG.txt
    create_file "$VIBE_DIR/LOG.txt" "[$timestamp] Project initialized with Claude Code $TEMPLATE_NAME template v$TEMPLATE_VERSION
[$timestamp] Created .vibe directory structure and configuration files
[$timestamp] Ready for Node.js/React development" "LOG.txt"
    
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
- **Template**: Node.js React Full-Stack

## Required Tools
- Node.js (v16+ recommended)
- npm or yarn
- Git
- Modern web browser
- Code editor (VS Code recommended)

## Project Structure (Recommended)
\`\`\`
project-root/
├── client/          # React frontend
│   ├── src/
│   ├── public/
│   └── package.json
├── server/          # Node.js backend
│   ├── src/
│   ├── tests/
│   └── package.json
├── shared/          # Shared types/utilities
├── .vibe/           # Claude Code configuration
├── CLAUDE.md
└── package.json     # Root package.json
\`\`\`

## Available Tools
- React DevTools
- Node.js debugging
- npm/yarn package management
- ESLint/Prettier formatting
- Jest/React Testing Library
- TypeScript (optional)

## Notes
_Add any environment-specific notes or configurations_" "ENVIRONMENT.md"
    
    # Create CLAUDE.md
    create_file "$CLAUDE_FILE" "# CLAUDE.md - Node.js React Project

This file provides guidance to Claude Code for JavaScript/React development.

## Project Overview

Modern full-stack JavaScript application using React and Node.js.

## Development Commands

\`\`\`bash
# Frontend (React)
cd client
npm install
npm start       # Dev server
npm test        # Run tests  
npm run build   # Production build

# Backend (Node.js)
cd server
npm install
npm run dev     # Development
npm test        # Run tests
npm start       # Production

# Root commands
npm run dev     # Start both frontend and backend
npm run test    # Test all
npm run lint    # Lint all
\`\`\`

## Key Guidelines
- Use functional components with hooks
- Implement proper error boundaries
- Follow React best practices
- Use TypeScript when possible
- Write comprehensive tests" "CLAUDE.md"
    
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

echo -e "${BLUE}Claude Code Node.js React Template - Clean Script${NC}"
echo "================================================="
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
    create_file "$VIBE_DIR/docs/README.md" "# Project Documentation - Node.js React Application

This directory contains project-specific documentation for the full-stack JavaScript application.

## Structure
- Frontend architecture documentation
- Backend API documentation
- Component library documentation
- State management patterns
- Testing strategies
- Deployment guides

## Key Areas
- **components/**: React component documentation
- **api/**: API endpoint documentation
- **architecture/**: System design documents
- **guides/**: How-to guides and tutorials

## Adding Documentation
When documenting JavaScript/React code:
1. Include JSDoc comments in code
2. Document component props and state
3. Provide API usage examples
4. Keep dependencies documented
5. Note any browser compatibility issues" "docs/README.md"
    
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
    echo "  1. Create project structure (client/ and server/ directories)"
    echo "  2. Initialize React app: npx create-react-app client"
    echo "  3. Set up Node.js backend in server/"
    echo "  4. Configure your development environment"
    echo "  5. Start building with Claude Code!"
    
    echo
    print_color "$CYAN" "💡 Pro tips:"
    echo "  - Use 'npm run dev' from root to start both frontend and backend"
    echo "  - Set up Prettier and ESLint early for consistent code style"
    echo "  - Consider TypeScript for better type safety"
    echo "  - Reset to start fresh: ./clean.sh"
    
    # Prompt for git operations
    if check_git_repo && confirm "Would you like to create an initial commit?" "Y"; then
        git add .
        git commit -m "feat: Initialize Claude Code Node.js React template

- Add .vibe directory structure  
- Create CLAUDE.md with React/Node.js guidelines
- Set up full-stack JavaScript workflow
- Add relevant documentation and links
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