# Vibe CLI Internal Documentation

This document provides technical details about the vibe CLI system for Claude Code. It covers implementation details, design decisions, and guidance for working with the vibe system programmatically.

## System Architecture

### Overview
The vibe CLI is a collection of bash scripts that wrap tmux functionality to provide session management with automatic logging. The system consists of six main scripts and maintains state through filesystem artifacts.

### Core Components

1. **vibe-session**: Session creation and initialization
2. **vibe-list**: Session enumeration and status reporting
3. **vibe-attach**: Session attachment interface
4. **vibe-logs**: Log viewing and streaming
5. **vibe-kill**: Session termination and cleanup
6. **vibe-init**: Environment setup and alias creation

### Directory Structure
```
.vibe/
├── vibe-session      # Main session creation script
├── vibe-list         # List sessions script
├── vibe-attach       # Attach to sessions script
├── vibe-logs         # View logs script
├── vibe-kill         # Kill sessions script
├── vibe-init         # Initialize environment
├── logs/             # Session log files (created on first use)
│   └── vibe-<name>_<timestamp>.log
└── sessions/         # Session metadata (created on first use)
    └── vibe-<name>.info
```

## Implementation Details

### Session Naming Convention
- All tmux sessions are prefixed with `vibe-` to namespace them
- User provides short names, system prepends `vibe-` automatically
- Valid names: alphanumeric characters, hyphens, and underscores
- Regex validation: `^[a-zA-Z0-9_-]+$`

### Session Metadata
Each session stores metadata in `.vibe/sessions/vibe-<name>.info`:
```
SESSION_NAME=example
CREATED_AT=2024-01-15 10:30:45
WORKING_DIR=/home/user/project
COMMAND=npm run dev
```

### Logging Mechanism
- Uses tmux's pipe-pane feature to capture all terminal output
- Log files: `.vibe/logs/vibe-<name>_<timestamp>.log`
- Timestamp format: `YYYYMMDD_HHMMSS`
- Logs include ANSI escape codes for color preservation
- Real-time streaming capability via `tail -f`

### Session Lifecycle

1. **Creation** (`vibe-session`)
   - Validates session name
   - Creates directories if needed
   - Starts tmux session with logging enabled
   - Saves metadata to info file
   - Optionally executes initial command

2. **Runtime**
   - Session runs independently in tmux
   - All output continuously logged
   - Can be attached/detached without disruption
   - Multiple sessions can run concurrently

3. **Termination** (`vibe-kill`)
   - Kills tmux session
   - Removes info file
   - Log files are preserved

## Design Decisions

### Why tmux?
- Persistent sessions that survive SSH disconnections
- Built-in session management capabilities
- Universal availability on Unix-like systems
- Minimal dependencies

### Why Automatic Logging?
- Complete audit trail of all commands and outputs
- Enables async monitoring without attachment
- Facilitates debugging and error analysis
- Preserves context for future reference

### Why Separate Scripts?
- Unix philosophy: do one thing well
- Easier testing and maintenance
- Flexible composition in workflows
- Clear separation of concerns

## Working with Vibe Programmatically

### Creating Sessions
```bash
# Basic usage
vibe-session <name> <directory> "<command>"

# Return codes:
# 0 - Success
# 1 - Invalid session name
# 2 - Session already exists
# 3 - tmux command failed
```

### Checking Session Status
```bash
# Check if specific session exists
tmux has-session -t "vibe-<name>" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Session exists"
fi

# Parse vibe-list output
vibe-list | grep "vibe-<name>" | awk '{print $2}'
# Returns: "attached", "detached", or "dead"
```

### Reading Logs
```bash
# Get log file path
LOG_FILE=$(ls -t .vibe/logs/vibe-<name>_*.log 2>/dev/null | head -1)

# Read last N lines
tail -n 50 "$LOG_FILE"

# Stream logs
tail -f "$LOG_FILE"

# Search logs
grep "ERROR" "$LOG_FILE"
```

### Session Information
```bash
# Read metadata
source .vibe/sessions/vibe-<name>.info
echo "Created: $CREATED_AT"
echo "Directory: $WORKING_DIR"
echo "Command: $COMMAND"
```

## Error Handling

### Common Error Scenarios

1. **Session Name Conflicts**
   - Detection: Check tmux session list
   - Resolution: Suggest alternative name or kill existing

2. **Missing Log Files**
   - Fallback: Capture current pane content
   - Alternative: Check for older log files

3. **Orphaned Info Files**
   - Detection: Info file exists but session doesn't
   - Resolution: Clean up during list operation

4. **Permission Issues**
   - Ensure write access to .vibe directory
   - Create directories with appropriate permissions

### Error Codes
- Scripts use consistent exit codes:
  - 0: Success
  - 1: Invalid arguments or validation failure
  - 2: Resource already exists
  - 3: External command failure
  - 4: Resource not found

## Best Practices for Claude Code

### When to Use Vibe Sessions

1. **Always use for shell commands that:**
   - Take more than a few seconds
   - Produce significant output
   - Run in the background
   - Need monitoring

2. **Specific use cases:**
   - Development servers (`npm run dev`, `python manage.py runserver`)
   - Build processes (`npm run build`, `make`)
   - Test suites (`pytest`, `npm test`)
   - Long-running scripts
   - System monitoring commands

### Naming Conventions
- Use descriptive, hyphenated names
- Include task type: `build-frontend`, `test-unit`, `server-dev`
- Avoid generic names: `test`, `run`, `command`

### Session Management Patterns

**Sequential Tasks:**
```bash
vibe-session compile . "make"
# Wait for completion
while tmux has-session -t "vibe-compile" 2>/dev/null; do
    sleep 1
done
vibe-session test . "make test"
```

**Parallel Tasks:**
```bash
vibe-session frontend . "npm run build:frontend" &
vibe-session backend . "npm run build:backend" &
vibe-session assets . "npm run optimize:assets" &
wait
```

**Monitoring Pattern:**
```bash
vibe-session long-task . "python process.py"
# Poll for completion
while tmux has-session -t "vibe-long-task" 2>/dev/null; do
    # Check last log line for completion marker
    if vibe-logs long-task -n 1 | grep -q "COMPLETED"; then
        break
    fi
    sleep 5
done
```

### Integration with Task Management

When working with multiple vibe sessions:
1. Create sessions with systematic names
2. Track session names in todo items
3. Monitor multiple sessions with `vibe-list -v`
4. Clean up completed sessions promptly

### Performance Considerations

- Log files can grow large; consider rotation for long-running sessions
- Multiple sessions consume system resources
- Limit concurrent sessions based on system capacity
- Kill idle sessions to free resources

## Maintenance and Troubleshooting

### Cleanup Operations
```bash
# Remove all dead sessions
for session in $(vibe-list | grep "dead" | awk '{print $1}' | sed 's/vibe-//'); do
    vibe-kill "$session" -f
done

# Archive old logs
find .vibe/logs -name "*.log" -mtime +30 -exec gzip {} \;

# Remove orphaned info files
for info in .vibe/sessions/*.info; do
    session=$(basename "$info" .info)
    if ! tmux has-session -t "$session" 2>/dev/null; then
        rm "$info"
    fi
done
```

### Debugging Sessions
```bash
# Check tmux server
tmux list-sessions

# Verify logging is active
tmux pipe-pane -t "vibe-<name>" -p

# Check session environment
tmux show-environment -t "vibe-<name>"

# Manual attachment (bypassing vibe-attach)
tmux attach -t "vibe-<name>"
```

## Security Considerations

1. **Command Injection**: Always quote user inputs
2. **Log Exposure**: Logs may contain sensitive data
3. **Session Hijacking**: Tmux sessions can be attached by any user with access
4. **Resource Limits**: Implement guards against resource exhaustion

## Future Enhancements

Potential improvements to consider:
- Log rotation and compression
- Session templates for common tasks
- Integration with system notifications
- Resource usage monitoring
- Session groups for related tasks
- Automatic cleanup policies