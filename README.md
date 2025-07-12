# Vibe CLI - Claude Code Session Management

A powerful tmux-based session management system designed for Claude Code, providing automatic logging, organized workflows, and seamless command execution tracking.

## 🚀 Quick Start

### Installation

Clone this repository to get started:

```bash
git clone https://github.com/check-the-vibe/claude-code-starter-template.git
cd claude-code-starter-template
```

### Initialize Vibe

```bash
# Initialize vibe commands for your current shell session
source .vibe/init

# Or add to your shell profile for persistent access
echo "[ -f $(pwd)/.vibe/init ] && source $(pwd)/.vibe/init" >> ~/.bashrc
```

## 🛡️ What is Vibe?

Vibe is a session management system that wraps tmux to provide:

- **Automatic Logging**: Every command and its output is logged with timestamps
- **Session Management**: Run multiple commands concurrently in organized sessions
- **Easy Monitoring**: Check status and view logs of any session
- **Persistent History**: All command outputs are saved for later review
- **Clean Organization**: Sessions and logs are structured systematically

## 📚 Commands Overview

### Core Commands

- `vibe-session` - Create new tmux sessions with automatic logging
- `vibe-list` - List all active sessions with their status
- `vibe-logs` - View or tail session logs (uses `.vibe/tail`)
- `vibe-attach` - Attach to running sessions
- `vibe-kill` - Terminate sessions cleanly
- `vibe-clear` - Kill all active sessions at once

### Quick Aliases

After sourcing `.vibe/init`, you can use these shortcuts:

- `vs` → `vibe-session`
- `vl` → `vibe-list`
- `va` → `vibe-attach`
- `vlog` → `vibe-logs`
- `vk` → `vibe-kill`
- `vc` → `vibe-clear`

## 💡 Common Use Cases

### Development Server

```bash
# Start a development server
vibe-session dev . "npm run dev"

# Monitor the output
vibe-logs dev -f

# Attach to interact
vibe-attach dev
```

### Running Tests

```bash
# Run tests with monitoring
vibe-session test . "npm test"
vibe-logs test -f
```

### Environment Variables

```bash
# Load environment from .env file
vibe-session api . "npm start" -e .env

# Load multiple env files (later files override earlier ones)
vibe-session prod . "./server" -e .env -e .env.prod

# Check environment in session
vibe-attach prod
env | grep MY_VAR
```

### Parallel Tasks

```bash
# Run multiple builds concurrently
vibe-session frontend . "npm run build:frontend"
vibe-session backend . "npm run build:backend"

# Check all statuses
vibe-list -v
```

## 📁 Project Structure

```
.vibe/
├── init              # Initialize vibe commands
├── session           # Create new sessions
├── list              # List sessions
├── attach            # Attach to sessions
├── tail              # View/tail logs
├── kill              # Terminate sessions
├── clear             # Kill all sessions
├── instructions/     # Project documentation
├── docs/             # Technical documentation
├── logs/             # Session log files
└── sessions/         # Session metadata
```

## 🔧 Advanced Usage

### Session Naming

Use descriptive names for your sessions:
- `dev-server`, `test-unit`, `build-prod`
- Names must be alphanumeric with hyphens/underscores

### Log Management

Logs are stored in `.vibe/logs/` with timestamps:
```bash
# View specific number of lines
vibe-logs session-name -n 100

# Follow logs in real-time
vibe-logs session-name -f
```

### Session Lifecycle

1. Create: `vibe-session name`
2. Monitor: `vibe-logs name`
3. Interact: `vibe-attach name`
4. Terminate: `vibe-kill name`
5. Clear all: `vibe-clear` (when starting fresh)

## 📖 Documentation

- **User Guide**: This README
- **Technical Details**: `.vibe/docs/vibe-cli-internal.md`
- **Claude Integration**: `.vibe/instructions/CLAUDE.md`

## 🤝 Working with Claude Code

This project is optimized for use with Claude Code. The `.vibe` directory contains:
- Instructions for Claude's behavior and approach
- Task tracking and error management
- Documentation and reference materials

When working with Claude Code, all shell commands should be executed through the vibe system to ensure proper logging and tracking.

## 🛠️ Troubleshooting

### Session Won't Create
Check if the name already exists: `vibe-list`

### Can't See Logs
Ensure the session was created with vibe-session

### Session Shows as "Dead"
The command finished or crashed. Check logs for details:
```bash
vibe-logs session-name -n 200
```

## 📄 License

This project is open source and available under the MIT License.