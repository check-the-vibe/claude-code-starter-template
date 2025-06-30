# Claude Code Starter Template - Template Selector (PowerShell Version)
# This script lists available templates and executes the selected one
# Templates are self-contained setup scripts with embedded content

param(
    [string]$Template,
    [switch]$List,
    [switch]$Help
)

# Script configuration
$SCRIPT_VERSION = "3.0.0"
$VIBE_DIR = ".vibe"
$CLAUDE_FILE = "CLAUDE.md"

# GitHub repository configuration
$GITHUB_REPO = "check-the-vibe/claude-code-starter-template"
$GITHUB_RAW_URL = "https://raw.githubusercontent.com/$GITHUB_REPO/main"

# Detect if script is being run locally or remotely
$IS_REMOTE = $false
if (-not (Test-Path $PSCommandPath)) {
    $IS_REMOTE = $true
    $SCRIPT_DIR = "."
} else {
    $SCRIPT_DIR = Split-Path -Parent $PSCommandPath
}

$TEMPLATES_DIR = Join-Path $SCRIPT_DIR "templates"

# Function to print colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to print section headers
function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Magenta"
    Write-ColorOutput " $Title" "Magenta"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Magenta"
}

# Function to show usage
function Show-Usage {
    Write-ColorOutput "Claude Code Starter Template v$SCRIPT_VERSION" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Usage: setup.ps1 [OPTIONS]" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Options:" "Cyan"
    Write-ColorOutput "  -List           List available templates" "Cyan"
    Write-ColorOutput "  -Template NAME  Use specific template (bypasses selection)" "Cyan"
    Write-ColorOutput "  -Help           Show this help message" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:" "Cyan"
    Write-ColorOutput "  .\setup.ps1                     # Interactive template selection" "Cyan"
    Write-ColorOutput "  .\setup.ps1 -Template default   # Use default template" "Cyan"
    Write-ColorOutput "  .\setup.ps1 -List              # List all templates" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Remote execution:" "Cyan"
    Write-ColorOutput "  irm $GITHUB_RAW_URL/setup.ps1 | iex" "Cyan"
}

# Function to list available templates
function Get-Templates {
    $templates = @()
    
    if ($IS_REMOTE) {
        # When running remotely, use predefined template list
        $templates = @("default", "nodejs-react", "python-project")
    } else {
        # Local execution - scan templates directory
        if (Test-Path $TEMPLATES_DIR) {
            Get-ChildItem -Path $TEMPLATES_DIR -Directory | ForEach-Object {
                if (Test-Path (Join-Path $_.FullName "setup.sh")) {
                    $templates += $_.Name
                }
            }
        }
        
        if ($templates.Count -eq 0) {
            Write-ColorOutput "No templates found in $TEMPLATES_DIR" "Red"
            exit 1
        }
    }
    
    return $templates
}

# Function to display template selection menu
function Select-Template {
    param([array]$Templates)
    
    Write-Header "Available Templates"
    Write-ColorOutput "Found $($Templates.Count) templates:" "Cyan"
    Write-Host ""
    
    # Display all templates with descriptions
    $index = 1
    foreach ($template in $Templates) {
        $desc = "Template"
        
        # Provide descriptions for templates
        switch ($template) {
            "default" { $desc = "Basic Claude Code setup with .vibe structure" }
            "nodejs-react" { $desc = "Node.js + React project template" }
            "python-project" { $desc = "Python project template with virtual environment" }
        }
        
        Write-ColorOutput "$index. $template" "Cyan"
        Write-ColorOutput "   $desc" "Blue"
        Write-Host ""
        $index++
    }
    
    # Ask user to select
    while ($true) {
        Write-ColorOutput "Enter template number (1-$($Templates.Count)) or name:" "Yellow"
        $choice = Read-Host "> "
        
        # Check if choice is a number
        if ($choice -match '^\d+$') {
            $num = [int]$choice
            if ($num -ge 1 -and $num -le $Templates.Count) {
                $selected = $Templates[$num - 1]
                break
            } else {
                Write-ColorOutput "Invalid number. Please enter a number between 1 and $($Templates.Count)." "Red"
                continue
            }
        } else {
            # Check if the choice matches a template name
            if ($Templates -contains $choice) {
                $selected = $choice
                break
            }
            Write-ColorOutput "Invalid template name. Please enter a valid template name or number." "Red"
        }
    }
    
    Write-ColorOutput "✓ Selected template: $selected" "Green"
    return $selected
}

# Function to archive existing .vibe directory
function Archive-Vibe {
    if (Test-Path $VIBE_DIR) {
        Write-ColorOutput "⚠️  Found existing $VIBE_DIR directory" "Yellow"
        
        $response = Read-Host "Do you want to archive the existing .vibe directory? [Y/n]"
        if ($response -eq '' -or $response -match '^[Yy]$') {
            $archiveName = ".vibe_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').tar.gz"
            
            Write-ColorOutput "Creating archive: $archiveName" "Blue"
            # Note: PowerShell doesn't have native tar support on older versions
            # For now, just rename the directory
            $backupName = ".vibe_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Rename-Item -Path $VIBE_DIR -NewName $backupName
            
            Write-ColorOutput "✓ Backed up existing .vibe to: $backupName" "Green"
        } else {
            Remove-Item -Path $VIBE_DIR -Recurse -Force
            Write-ColorOutput "⚠️  Removed existing .vibe directory (not archived)" "Yellow"
        }
    }
    
    # Also handle existing CLAUDE.md
    if (Test-Path $CLAUDE_FILE) {
        Remove-Item -Path $CLAUDE_FILE -Force
        Write-ColorOutput "✓ Removed old CLAUDE.md" "Green"
    }
}

# Function to execute template
function Execute-Template {
    param([string]$TemplateName)
    
    Write-Header "Executing $TemplateName Template"
    
    if ($IS_REMOTE) {
        # Remote execution - fetch template from GitHub
        $templateUrl = "$GITHUB_RAW_URL/templates/$TemplateName/setup.ps1"
        Write-ColorOutput "Fetching template from: $templateUrl" "Blue"
        
        try {
            $scriptContent = Invoke-WebRequest -Uri $templateUrl -UseBasicParsing | Select-Object -ExpandProperty Content
            Invoke-Expression $scriptContent
        } catch {
            # If PowerShell script doesn't exist, try bash script
            $bashUrl = "$GITHUB_RAW_URL/templates/$TemplateName/setup.sh"
            Write-ColorOutput "PowerShell template not found, trying bash template..." "Yellow"
            Write-ColorOutput "Note: Full PowerShell support coming soon. Using bash compatibility mode." "Yellow"
            
            # For now, we'll create the basic structure
            # In a full implementation, this would parse and convert the bash script
            Create-BasicTemplate -TemplateName $TemplateName
        }
    } else {
        # Local execution
        $psScript = Join-Path $TEMPLATES_DIR "$TemplateName\setup.ps1"
        $bashScript = Join-Path $TEMPLATES_DIR "$TemplateName\setup.sh"
        
        if (Test-Path $psScript) {
            Write-ColorOutput "Executing local PowerShell template..." "Blue"
            & $psScript
        } elseif (Test-Path $bashScript) {
            Write-ColorOutput "PowerShell template not found, using bash compatibility mode..." "Yellow"
            Create-BasicTemplate -TemplateName $TemplateName
        } else {
            Write-ColorOutput "Setup script not found for template: $TemplateName" "Red"
            exit 1
        }
    }
}

# Function to create basic template structure (fallback)
function Create-BasicTemplate {
    param([string]$TemplateName)
    
    Write-ColorOutput "Creating $TemplateName template structure..." "Blue"
    
    # Create .vibe directory structure
    New-Item -ItemType Directory -Path $VIBE_DIR -Force | Out-Null
    New-Item -ItemType Directory -Path "$VIBE_DIR\docs" -Force | Out-Null
    
    # Create basic files based on template type
    switch ($TemplateName) {
        "default" {
            # Create default template files
            @'
# Project Tasks

## Current Sprint
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
_Future tasks and ideas_
'@ | Set-Content -Path "$VIBE_DIR\TASKS.md" -Force
        }
        "nodejs-react" {
            # Node.js specific tasks
            @'
# Node.js + React Project Tasks

## Setup Phase
- [ ] Initialize package.json
- [ ] Set up React application
- [ ] Configure build tools
- [ ] Set up development server

## Development Phase
- [ ] Create component structure
- [ ] Implement routing
- [ ] Set up state management
- [ ] Add API integration

## Testing & Deployment
- [ ] Write component tests
- [ ] Set up CI/CD pipeline
- [ ] Configure production build
'@ | Set-Content -Path "$VIBE_DIR\TASKS.md" -Force
        }
        "python-project" {
            # Python specific tasks
            @'
# Python Project Tasks

## Setup Phase
- [ ] Create virtual environment
- [ ] Set up requirements.txt
- [ ] Configure project structure
- [ ] Initialize git repository

## Development Phase
- [ ] Implement core modules
- [ ] Add error handling
- [ ] Write documentation
- [ ] Create CLI interface

## Testing & Deployment
- [ ] Write unit tests
- [ ] Set up pytest configuration
- [ ] Create setup.py
- [ ] Package for distribution
'@ | Set-Content -Path "$VIBE_DIR\TASKS.md" -Force
        }
    }
    
    # Create common files
    @'
<!-- Errors from the previous run go in this file. Use this, and the chat context to determine what the best next course of action would be. If there are no errors, assume this is the first run, or the previous run (if available) was successful -->
'@ | Set-Content -Path "$VIBE_DIR\ERRORS.md" -Force
    
    @'
title,url
Claude Documentation,https://docs.anthropic.com/en/docs/claude-code
'@ | Set-Content -Path "$VIBE_DIR\LINKS.csv" -Force
    
    New-Item -ItemType File -Path "$VIBE_DIR\LOG.txt" -Force | Out-Null
    
    # Create PERSONA.md
    @'
# Development Persona

You are an experienced software developer who helps other developers build and improve their projects. You have deep expertise in modern development practices, testing, and deployment strategies.

## Core Competencies
- Full-stack development
- Test-driven development
- DevOps and CI/CD
- Code review and refactoring
- Documentation and technical writing

## Approach
- Write clean, maintainable code
- Follow best practices for the technology stack
- Provide clear explanations for technical decisions
- Focus on practical, working solutions
'@ | Set-Content -Path "$VIBE_DIR\PERSONA.md" -Force
    
    # Create ENVIRONMENT.md
    @'
# Development Environment

This project was initialized using the Claude Code Starter Template.

## Setup Information
- Template: {0}
- Date: {1}
- Platform: Windows/PowerShell

## Available Tools
- Git for version control
- Package managers (npm, pip, etc.) as needed
- Testing frameworks appropriate to the stack
'@ -f $TemplateName, (Get-Date -Format "yyyy-MM-dd") | Set-Content -Path "$VIBE_DIR\ENVIRONMENT.md" -Force
    
    # Create README in docs
    @'
# Project Documentation

This directory contains additional documentation for the project.

## Structure
- Technical specifications
- API documentation  
- Architecture decisions
- Development guides
'@ | Set-Content -Path "$VIBE_DIR\docs\README.md" -Force
    
    # Create CLAUDE.md
    @'
# CLAUDE.md

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
```bash
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
git commit -m "" # Commit changes
```

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
5. Commit changes when reaching logical stopping points
'@ | Set-Content -Path $CLAUDE_FILE -Force
    
    # Create .gitignore
    @'
# Dependencies
node_modules/
__pycache__/
*.pyc
venv/
env/
.env

# Build outputs
dist/
build/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Testing
coverage/
.coverage
.pytest_cache/

# Temporary
*.tmp
*.temp
.cache/
'@ | Set-Content -Path ".gitignore" -Force
    
    Write-ColorOutput "✓ Template structure created successfully!" "Green"
}

# Main execution
function Main {
    if ($Help) {
        Show-Usage
        return
    }
    
    Write-Header "Claude Code Starter Template v$SCRIPT_VERSION"
    
    # Get available templates
    $templates = Get-Templates
    
    # If list only, show templates and exit
    if ($List) {
        Write-Header "Available Templates"
        foreach ($template in $templates) {
            Write-ColorOutput "  - $template" "Cyan"
        }
        Write-Host ""
        Write-ColorOutput "To use a template:" "Blue"
        Write-ColorOutput "  .\setup.ps1 -Template <name>" "Blue"
        return
    }
    
    # Archive existing .vibe directory
    Archive-Vibe
    
    # Select template
    $selectedTemplate = ""
    if ($Template) {
        # Validate template exists
        if ($templates -contains $Template) {
            $selectedTemplate = $Template
        } else {
            Write-ColorOutput "Template not found: $Template" "Red"
            Write-ColorOutput "Available templates:" "Yellow"
            foreach ($t in $templates) {
                Write-ColorOutput "  - $t" "Cyan"
            }
            exit 1
        }
    } else {
        # Interactive selection
        $selectedTemplate = Select-Template -Templates $templates
    }
    
    # Execute selected template
    Execute-Template -TemplateName $selectedTemplate
    
    Write-Header "Template Installation Complete!"
    
    Write-ColorOutput "✅ Successfully installed $selectedTemplate template" "Green"
    Write-ColorOutput "" "Blue"
    Write-ColorOutput "Your project is now configured with Claude Code!" "Blue"
    Write-ColorOutput "Check the .vibe directory and CLAUDE.md for details." "Blue"
}

# Run main function
Main