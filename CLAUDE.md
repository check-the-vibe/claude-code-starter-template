# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a starter template for Claude Code projects. The template uses a structured approach with the .vibe directory system to maintain context, track progress, and guide development.

### Key Components

The following files in the .vibe directory guide development:
- **instructions/PERSONA.md**: Defines Claude's role and approach
- **instructions/TASKS.md**: Tracks project tasks and progress
- **instructions/ERRORS.md**: Logs and tracks errors for iterative improvement
- **docs/LINKS.csv**: External documentation and resources
- **instructions/ENVIRONMENT.md**: System and project context
- **docs/**: Additional project documentation
  - **vibe-cli-internal.md**: Technical documentation for the vibe CLI system

### Vibe Session Management System

The .vibe directory includes a tmux-based session management system for running shell commands:
- **session**: Create and manage tmux sessions with automatic logging
- **list**: List all active vibe sessions
- **attach**: Attach to existing sessions
- **logs**: View session logs (with follow mode)
- **kill**: Terminate sessions
- **init**: Initialize aliases for easy access

## IMPORTANT: Shell Command Execution

**ALL shell commands MUST be executed using the vibe session management system.** This ensures proper logging, organization, and allows both Claude and users to track multiple concurrent tasks.

For detailed technical information about the vibe CLI system, including implementation details, design decisions, and advanced usage patterns, see `.vibe/docs/vibe-cli-internal.md`.

### Required Usage Pattern:
1. Create a session: `vibe-session <name> [directory] [command]`
2. Check session status: `vibe-list`
3. View output: `vibe-logs <name>`
4. Attach if needed: `vibe-attach <name>`
5. Clean up: `vibe-kill <name>`

### Examples:
```bash
# Instead of: npm install
vibe-session install . "npm install"
vibe-logs install -f

# Instead of: npm run dev
vibe-session dev-server . "npm run dev"
vibe-logs dev-server -f

# Instead of: python script.py
vibe-session python-task . "python script.py"
vibe-logs python-task
```

## Workflow Guidelines

### 1. Initial Setup
- Source vibe commands: `source .vibe/init`
- Read instructions/ENVIRONMENT.md to understand the execution context
- Review instructions/PERSONA.md to assume the appropriate role
- Check instructions/ERRORS.md for any previous issues
- Examine instructions/TASKS.md for current objectives

### 2. Task Execution
- Break complex tasks into subtasks (max 5 steps)
- Update task status in instructions/TASKS.md as you progress
- Document findings in .vibe/docs/ as needed

### 3. Error Handling
- Log errors in instructions/ERRORS.md with context
- Prioritize fixing errors before new tasks
- Clear instructions/ERRORS.md after resolution

### 4. Documentation
- Add useful web resources to docs/LINKS.csv
- Store relevant documentation in .vibe/docs/

### 5. Git Best Practices
- Ensure .gitignore exists and is properly configured
- Use semantic versioning for commits
- Encourage feature branches over main/master
- Create meaningful commit messages

## Development Commands

Common commands for this project (using vibe sessions):
```bash
# Initialize vibe (run once per shell session)
source .vibe/init

# NPM projects
vibe-session install . "npm install"       # Install dependencies
vibe-session dev . "npm run dev"           # Start development server
vibe-session build . "npm run build"       # Build for production
vibe-session test . "npm run test"         # Run tests
vibe-session lint . "npm run lint"         # Run linter

# Python projects
vibe-session pip-install . "pip install -r requirements.txt"  # Install dependencies
vibe-session python-main . "python main.py"                   # Run main script
vibe-session pytest . "pytest"                                # Run tests
vibe-session format . "black ."                               # Format code

# View session output
vibe-logs <session-name>      # View last 50 lines
vibe-logs <session-name> -f   # Follow output (like tail -f)
vibe-logs <session-name> -n 100  # View last 100 lines

# Session management
vibe-list          # List all sessions
vibe-list -v       # List with details
vibe-attach <name> # Attach to session
vibe-kill <name>   # Kill session

# Short aliases (after sourcing init)
vs  # vibe-session
vl  # vibe-list
va  # vibe-attach
vlog # vibe-logs
vk  # vibe-kill

# Git commands (can be run directly without sessions)
git status
git add .
git commit -m "message"
git push
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
3. Begin work according to instructions/TASKS.md
4. Update progress regularly
5. Commit changes when reaching logical stopping points
