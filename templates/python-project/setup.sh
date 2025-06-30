#!/bin/bash

# Claude Code Python Project Template - Standalone Setup Script
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
TEMPLATE_NAME="python-project"
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

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv
pip-log.txt
pip-delete-this-directory.txt
.eggs/
*.egg-info/
*.egg
MANIFEST

# Distribution / packaging
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/

# PyInstaller
*.manifest
*.spec

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.env.local
.env.*.local

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

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
    print_header "Claude Code Python Project Template Setup v$TEMPLATE_VERSION"
    
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
    local python_version=$(python3 --version 2>/dev/null || echo "Python not found")
    
    # Create PERSONA.md
    create_file "$VIBE_DIR/PERSONA.md" "<!-- Python Developer Persona -->

# Python Developer

You are an experienced Python developer who specializes in:
- Building robust Python applications
- Writing clean, Pythonic code
- Test-driven development with pytest
- Type hints and static typing
- Modern Python best practices

## Technical Expertise
- **Core Python**: Python 3.8+, standard library mastery
- **Frameworks**: Flask, FastAPI, Django, Streamlit
- **Data Science**: NumPy, Pandas, Scikit-learn, Matplotlib
- **Testing**: pytest, unittest, mock, coverage
- **Tools**: pip, poetry, black, ruff, mypy
- **Databases**: SQLAlchemy, PostgreSQL, MongoDB, Redis

## Development Approach
1. Virtual environment isolation
2. Test-driven development (TDD)
3. Type hints for clarity and safety
4. Clean architecture principles
5. PEP 8 compliance
6. Comprehensive documentation" "PERSONA.md"
    
    # Create TASKS.md
    create_file "$VIBE_DIR/TASKS.md" "# Project Tasks - Python Project

## Current Sprint
_Add your current tasks here_

### 🔍 Research Phase
- [ ] Define project requirements
- [ ] Choose appropriate frameworks/libraries
- [ ] Design data models
- [ ] Plan API structure (if applicable)

### 📐 Setup Phase
- [ ] Create virtual environment
- [ ] Set up project structure
- [ ] Configure development tools
- [ ] Initialize testing framework

### 💻 Development Phase
- [ ] Implement core modules
- [ ] Add error handling
- [ ] Create data models
- [ ] Build API endpoints (if applicable)
- [ ] Add logging

### 🧪 Testing Phase
- [ ] Write unit tests
- [ ] Add integration tests
- [ ] Check code coverage
- [ ] Performance testing

### 📦 Packaging Phase
- [ ] Update requirements.txt
- [ ] Create setup.py/pyproject.toml
- [ ] Write documentation
- [ ] Prepare for deployment

## Completed Tasks
_Move completed tasks here with timestamps_

## Backlog
_Future features and improvements_" "TASKS.md"
    
    # Create ERRORS.md
    create_file "$VIBE_DIR/ERRORS.md" "<!-- Errors from the previous run go in this file. Use this, and the chat context to determine what the best next course of action would be. If there are no errors, assume this is the first run, or the previous run (if available) was successful -->

# Error Log

_No errors recorded yet. Errors will be logged here with timestamps and context._

## Common Python Errors to Watch For:
- ImportError/ModuleNotFoundError
- IndentationError
- TypeError (type mismatches)
- ValueError (invalid values)
- AttributeError (missing attributes)
- KeyError (missing dictionary keys)
- FileNotFoundError
- Virtual environment issues

## Error Format Example:
\`\`\`
[2024-01-01 10:30:00] Error Type: ModuleNotFoundError
Description: No module named 'requests'
Context: Attempting to import requests library
Solution: pip install requests
\`\`\`" "ERRORS.md"
    
    # Create LINKS.csv
    create_file "$VIBE_DIR/LINKS.csv" "title,url
Claude Documentation,https://docs.anthropic.com/en/docs/claude-code/overview
Python Documentation,https://docs.python.org/3/
Python Package Index (PyPI),https://pypi.org/
Real Python Tutorials,https://realpython.com/
Python PEP 8 Style Guide,https://pep8.org/
pytest Documentation,https://docs.pytest.org/
Black Code Formatter,https://black.readthedocs.io/
Ruff Linter,https://docs.astral.sh/ruff/
mypy Documentation,https://mypy.readthedocs.io/
Flask Documentation,https://flask.palletsprojects.com/
FastAPI Documentation,https://fastapi.tiangolo.com/
Django Documentation,https://docs.djangoproject.com/
Poetry Documentation,https://python-poetry.org/docs/
Sphinx Documentation,https://www.sphinx-doc.org/" "LINKS.csv"
    
    # Create LOG.txt
    create_file "$VIBE_DIR/LOG.txt" "[$timestamp] Project initialized with Claude Code $TEMPLATE_NAME template v$TEMPLATE_VERSION
[$timestamp] Created .vibe directory structure and configuration files
[$timestamp] Python version: $python_version
[$timestamp] Ready for Python development" "LOG.txt"
    
    # Create ENVIRONMENT.md
    create_file "$VIBE_DIR/ENVIRONMENT.md" "<!-- This file gives specific information about the environment that Claude is running in -->

# Environment Information

## System Details
- **Operating System**: $os_info
- **Current Directory**: $current_dir
- **User**: $user_name
- **Date Initialized**: $timestamp
- **Python Version**: $python_version

## Project Context
- **Git Repository**: $(if check_git_repo; then echo "Yes"; else echo "No"; fi)
- **Platform**: Local Development Environment
- **Template**: Python Project

## Required Tools
- Python 3.8 or higher
- pip (Python package manager)
- virtualenv or venv
- Git
- Code editor (VS Code, PyCharm recommended)

## Project Structure (Recommended)
\`\`\`
project-root/
├── src/                 # Source code
│   ├── __init__.py
│   └── main.py
├── tests/              # Test files
│   ├── __init__.py
│   └── test_main.py
├── docs/               # Documentation
├── .vibe/              # Claude Code configuration
├── venv/               # Virtual environment (git-ignored)
├── requirements.txt    # Production dependencies
├── requirements-dev.txt # Development dependencies
├── setup.py            # Package configuration
├── README.md
├── CLAUDE.md
└── .gitignore
\`\`\`

## Python-Specific Configuration
- **Virtual Environment**: venv/
- **Package Manager**: pip
- **Test Framework**: pytest
- **Code Formatter**: black
- **Linter**: ruff
- **Type Checker**: mypy

## Available Tools
- Virtual environment management
- Package dependency resolution
- Testing and coverage tools
- Code formatting and linting
- Type checking
- Documentation generation (Sphinx)

## Notes
_Add any environment-specific notes or configurations_" "ENVIRONMENT.md"
    
    # Create CLAUDE.md (embedded from the file we read earlier)
    create_file "$CLAUDE_FILE" "# CLAUDE.md - Python Project

This file provides guidance to Claude Code when working with Python code in this repository.

## Project Overview

This is a Python project following modern Python development practices including virtual environments, testing, type hints, and code formatting.

### Key Components

The following files in the .vibe directory guide development:
- **PERSONA.md**: Python developer expertise and approach
- **TASKS.md**: Python-specific development workflow
- **ERRORS.md**: Common Python errors and solutions
- **LINKS.csv**: Python documentation and resources
- **LOG.txt**: Development history
- **ENVIRONMENT.md**: Python environment setup
- **docs/**: Project documentation

## Python Development Guidelines

### 1. Environment Setup
- Always work within a virtual environment
- Check Python version compatibility
- Verify all dependencies are in requirements.txt
- Use requirements-dev.txt for development dependencies

### 2. Code Style
- Follow PEP 8 strictly
- Use black for automatic formatting
- Add type hints to all function signatures
- Write descriptive docstrings for all public functions/classes

### 3. Testing
- Write tests before or alongside implementation
- Use pytest for all testing
- Aim for >80% code coverage
- Use fixtures for test data
- Mock external dependencies

### 4. Project Structure
\`\`\`
src/
├── __init__.py
├── module1/
│   ├── __init__.py
│   └── core.py
└── module2/
    ├── __init__.py
    └── utils.py

tests/
├── __init__.py
├── test_module1/
│   └── test_core.py
└── test_module2/
    └── test_utils.py
\`\`\`

## Development Commands

\`\`\`bash
# Virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\\Scripts\\activate     # Windows

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Run tests
pytest
pytest --cov=src  # with coverage
pytest -v         # verbose

# Code quality
black .           # format code
ruff check .      # lint code
mypy src/         # type check

# Documentation
sphinx-build -b html docs/ docs/_build/
\`\`\`

## Python-Specific Reminders

### Import Organization
\`\`\`python
# Standard library imports
import os
import sys
from typing import List, Optional

# Third-party imports
import numpy as np
import pandas as pd
from flask import Flask

# Local imports
from .module1 import function1
from .module2 import Class2
\`\`\`

### Error Handling
\`\`\`python
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f\"Operation failed: {e}\")
    raise
except Exception as e:
    logger.exception(\"Unexpected error\")
    # Handle gracefully
finally:
    cleanup()
\`\`\`

### Type Hints Example
\`\`\`python
from typing import List, Dict, Optional, Union

def process_data(
    items: List[Dict[str, Any]], 
    filter_key: Optional[str] = None
) -> Union[List[str], None]:
    \"\"\"Process data items and return filtered results.
    
    Args:
        items: List of dictionaries containing data
        filter_key: Optional key to filter by
        
    Returns:
        List of processed strings or None if no results
    \"\"\"
    pass
\`\`\`

## Important Python Patterns

1. **Context Managers**: Use for resource management
2. **Generators**: Use for memory-efficient iteration
3. **Decorators**: Use for cross-cutting concerns
4. **Dataclasses**: Use for data structures
5. **Pathlib**: Use for file path operations

## Security Considerations

- Never hardcode secrets or API keys
- Use environment variables for configuration
- Validate all user inputs
- Use parameterized queries for databases
- Keep dependencies updated

## Getting Started

1. Set up virtual environment
2. Install dependencies
3. Run tests to verify setup
4. Review existing code structure
5. Check TASKS.md for current objectives" "CLAUDE.md"
    
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

echo -e "${BLUE}Claude Code Python Project Template - Clean Script${NC}"
echo "=================================================="
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
    create_file "$VIBE_DIR/docs/README.md" "# Project Documentation - Python Project

This directory contains project-specific documentation for the Python application.

## Structure
- Architecture documentation
- API documentation
- Module documentation
- Setup and deployment guides
- Development workflows

## Key Areas
- **api/**: API endpoint documentation
- **modules/**: Module-specific documentation  
- **guides/**: How-to guides and tutorials
- **examples/**: Code examples and snippets

## Documentation Standards
- Use docstrings for all public functions and classes
- Follow Google or NumPy docstring style
- Include type hints in function signatures
- Provide usage examples
- Document edge cases and exceptions

## Generating Documentation
To generate HTML documentation using Sphinx:
\`\`\`bash
cd docs
sphinx-quickstart  # First time only
sphinx-build -b html . _build
\`\`\`" "docs/README.md"
    
    # Create basic requirements files
    create_file "requirements.txt" "# Production dependencies
# Add your project dependencies here
# Example:
# requests>=2.28.0
# flask>=2.3.0
# sqlalchemy>=2.0.0" "requirements.txt"
    
    create_file "requirements-dev.txt" "# Development dependencies
-r requirements.txt

# Testing
pytest>=7.3.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0

# Code quality
black>=23.3.0
ruff>=0.0.261
mypy>=1.2.0

# Documentation
sphinx>=6.1.0
sphinx-rtd-theme>=1.2.0" "requirements-dev.txt"
    
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
    echo "  requirements.txt"
    echo "  requirements-dev.txt"
    echo "  clean.sh"
    
    echo
    print_color "$YELLOW" "🚀 Next steps:"
    echo "  1. Create and activate virtual environment:"
    echo "     python -m venv venv"
    echo "     source venv/bin/activate  # Linux/Mac"
    echo "     venv\\Scripts\\activate     # Windows"
    echo "  2. Install dependencies:"
    echo "     pip install -r requirements-dev.txt"
    echo "  3. Create your project structure (src/, tests/)"
    echo "  4. Start developing with Claude Code!"
    
    echo
    print_color "$CYAN" "💡 Pro tips:"
    echo "  - Run 'black .' to format your code"
    echo "  - Use 'pytest' to run tests"
    echo "  - Add type hints for better code clarity"
    echo "  - Reset to start fresh: ./clean.sh"
    
    # Prompt for git operations
    if check_git_repo && confirm "Would you like to create an initial commit?" "Y"; then
        git add .
        git commit -m "feat: Initialize Claude Code Python project template

- Add .vibe directory structure
- Create CLAUDE.md with Python guidelines
- Set up Python development workflow
- Add testing and code quality tools
- Include requirements files
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