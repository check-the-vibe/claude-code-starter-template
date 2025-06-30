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
