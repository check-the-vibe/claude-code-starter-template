# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Core Principles (Based on Anthropic Best Practices)

### 1. Be Clear and Direct
- Respond best to clear, direct instructions
- Remember: You have no context aside from what is literally provided
- Follow the Golden Rule: If a human would be confused by the instructions, you will be too

### 2. Use XML Tags for Organization
- Always use XML tags to separate data from instructions
- Common tags: `<data>`, `<instructions>`, `<example>`, `<output>`, `<thinking>`
- XML tags help clearly delineate different types of content

### 3. Think Step-by-Step
- For complex tasks, work through problems systematically before providing final answers
- Use a `<thinking>` section when breaking down problems
- Show your reasoning process

### 4. Output Formatting
- Be explicit about output format requirements
- Use XML tags to structure responses when appropriate
- Follow any provided examples exactly

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

### Required Development Pattern:

When starting any task that requires shell commands:

1. **Initialize vibe**: Always start with `source .vibe/init`

2. **Create a named session**: When asked to execute commands or tasks:
   - Create a descriptive session name (e.g., `build-frontend`, `test-api`, `debug-issue`)
   - Inform the user of the session name
   - Example: "I'll create a session called 'install-deps' to install the dependencies"

3. **Execute all commands in that session**:
   ```bash
   vibe-session install-deps . "npm install"
   ```

4. **Monitor progress**: Use `tail` or read from `.vibe/logs/` directory:
   ```bash
   # Check output after commands
   .vibe/tail install-deps
   
   # Or directly read the log file
   cat .vibe/logs/install-deps-*.log
   ```

5. **Continue based on output**: Read the session logs to determine next actions

### Example Workflow:
```bash
# User asks to build and test a project
source .vibe/init
vibe-session build-test . "npm install && npm run build && npm test"
# Wait a moment for execution
sleep 2
# Check the output
.vibe/tail build-test
# Based on results, take next action
```

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

# With environment variables
vibe-session api-dev . "python app.py" -e .env.dev           # Load dev environment
vibe-session db-migrate . "alembic upgrade head" -e .env     # Run migrations with env

# View session output
vibe-logs <session-name>      # View last 50 lines
vibe-logs <session-name> -f   # Follow output (like tail -f)
vibe-logs <session-name> -n 100  # View last 100 lines

# Session management
vibe-list          # List all sessions
vibe-list -v       # List with details
vibe-attach <name> # Attach to session
vibe-kill <name>   # Kill session
vibe-clear         # Kill all sessions (prompts for confirmation)
vibe-clear -f      # Kill all sessions without confirmation

# Short aliases (after sourcing init)
vs  # vibe-session
vl  # vibe-list
va  # vibe-attach
vlog # vibe-logs
vk  # vibe-kill
vc  # vibe-clear

# Git commands (can be run directly without sessions)
git status
git add .
git commit -m "message"
git push
```

## Complex Task Structure

When handling complex tasks, follow this structure:

1. **Understand the Context**
   - <thinking>Break down what's being asked</thinking>
   - Identify all requirements and constraints
   - Note any ambiguities that need clarification

2. **Plan the Approach**
   - List steps needed to complete the task
   - Consider edge cases and potential issues
   - Identify what tools/commands will be needed

3. **Execute Systematically**
   - Work through each step methodically
   - Verify each step before proceeding
   - Use vibe sessions for all shell commands

4. **Validate Results**
   - Check that all requirements are met
   - Test the implementation
   - Document any issues or limitations

## Role Context

When working on this project, you are:
- A skilled software engineer familiar with modern development practices
- Detail-oriented and careful about following instructions exactly
- Proactive about identifying potential issues but conservative about making changes
- Focused on code quality, clarity, and maintainability

## Avoiding Hallucinations

- Only reference files and functions that you've verified exist
- When unsure, check first rather than assuming
- If something cannot be done, explain why clearly
- Always read file contents before making claims about them
- Put questions/analysis AFTER reading relevant files

## Using Few-Shot Examples

When users need specific formats or patterns:

1. **Provide Clear Examples**
   ```
   <example>
   Input: process_data.py
   Output: ProcessData (PascalCase)
   </example>
   
   <example>
   Input: user_authentication_handler.py
   Output: UserAuthenticationHandler
   </example>
   ```

2. **Include Edge Cases**
   - Show how to handle errors
   - Demonstrate boundary conditions
   - Include both positive and negative examples

3. **Match Exact Format**
   - Follow the example structure precisely
   - Maintain consistent spacing and delimiters
   - Replicate any special formatting

## Important Reminders
- Do only what has been asked; nothing more, nothing less
- Prefer editing existing files over creating new ones
- Never create documentation files unless explicitly requested
- Follow existing code patterns and conventions
- Always check for available libraries before assuming
- Never expose or commit secrets/keys
- Small details matter - check for typos and formatting errors
- Be explicit and direct in all instructions and responses

## Working with Environment Variables

### Finding Existing .env Files

When working on a project, always check for existing environment files:

```bash
# Search for .env files in the project
source .vibe/init
vibe-session env-search . "find . -name '.env*' -type f | grep -v node_modules"
sleep 1
.vibe/tail env-search

# Or use grep to find environment variable references
vibe-session env-refs . "grep -r 'process.env' --include='*.js' --include='*.ts' ."
.vibe/tail env-refs
```

### Creating New .env Files

When the user needs environment variables:

1. **Check for existing .env.example or similar**:
   ```bash
   vibe-session check-env . "ls -la .env*"
   .vibe/tail check-env
   ```

2. **Create .env file based on requirements**:
   ```bash
   # If .env.example exists, copy it
   cp .env.example .env
   
   # Or create new .env file
   cat > .env << 'EOF'
   # Application Configuration
   NODE_ENV=development
   PORT=3000
   
   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=myapp
   
   # API Keys (replace with actual values)
   API_KEY=your-api-key-here
   SECRET_KEY=your-secret-key-here
   EOF
   ```

3. **Add to .gitignore** (if not already present):
   ```bash
   # Check if .env is already ignored
   grep "^\.env$" .gitignore || echo ".env" >> .gitignore
   ```

### Using .env Files in Sessions

```bash
# Single .env file
vibe-session dev-server . "npm run dev" -e .env

# Multiple env files (for different environments)
vibe-session prod-test . "npm start" -e .env -e .env.production

# Check if environment variables are loaded
vibe-session check-vars . "env | grep -E 'API_KEY|DB_HOST|PORT'" -e .env
.vibe/tail check-vars
```

### Adding Environment Variables to Running Sessions

For sessions that are already running, you can:

1. **Attach and source the .env file manually**:
   ```bash
   vibe-attach dev-server
   # Inside the session:
   set -a
   source .env
   set +a
   # Press Ctrl-b d to detach
   ```

2. **Send commands to load env file**:
   ```bash
   # Send source command to running session
   tmux send-keys -t vibe-dev-server "set -a; source .env; set +a" C-m
   ```

3. **Restart the session with env files**:
   ```bash
   # Kill the old session
   vibe-kill dev-server
   # Start new session with env files
   vibe-session dev-server . "npm run dev" -e .env
   ```

### Best Practices for .env Files

1. **Never commit .env files with secrets**:
   - Always add `.env` to `.gitignore`
   - Create `.env.example` with dummy values for documentation

2. **Use descriptive variable names**:
   ```
   # Good
   DATABASE_CONNECTION_STRING=postgresql://...
   STRIPE_SECRET_KEY=sk_test_...
   
   # Avoid
   DB=postgresql://...
   KEY=sk_test_...
   ```

3. **Document required variables**:
   - Create `.env.example` with all required variables
   - Add comments explaining each variable's purpose

4. **Environment-specific files**:
   ```
   .env                # Default/development
   .env.local          # Local overrides (gitignored)
   .env.production     # Production settings
   .env.test           # Test environment
   ```

### Troubleshooting Environment Variables

If environment variables aren't working:

```bash
# Debug session to check variables
vibe-session debug-env . "echo 'Checking environment...'; env | sort" -e .env
.vibe/tail debug-env

# Test specific variable
vibe-session test-var . "echo \"MY_VAR is: \$MY_VAR\"" -e .env
.vibe/tail test-var

# Check file syntax (common issues)
vibe-session check-syntax . "cat .env | grep -E '^\s*[A-Z_]+=' | head -10"
.vibe/tail check-syntax
```

### Common Workflow Example

When a user asks to work with a Node.js application that needs environment variables:

```bash
# 1. Initialize and search for existing env files
source .vibe/init
vibe-session env-check . "ls -la .env* && echo '---' && cat .env.example 2>/dev/null || echo 'No .env.example found'"
sleep 1
.vibe/tail env-check

# 2. Create .env based on findings
cat > .env << 'EOF'
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
API_KEY=development-key-12345
EOF

# 3. Ensure .env is gitignored
grep "^\.env$" .gitignore || echo ".env" >> .gitignore

# 4. Start development with env vars
vibe-session dev . "npm install && npm run dev" -e .env
vibe-logs dev -f
```

## Getting Started

1. Review all .vibe files to understand context
2. Check for any pending tasks or errors
3. Begin work according to instructions/TASKS.md
4. Update progress regularly
5. Commit changes when reaching logical stopping points
