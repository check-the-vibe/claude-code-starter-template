# Environment Variable Support Design

## Overview
Add the ability to pass environment variables to vibe sessions, either through direct specification or by loading from a .env file.

## Design Approach

### 1. Command Interface
Add optional parameters to vibe-session:
```bash
# Load from .env file
vibe-session name . "command" --env-file .env

# Or shorter syntax
vibe-session name . "command" -e .env

# Multiple env files
vibe-session name . "command" -e .env -e .env.local
```

### 2. Implementation Strategy

#### Option A: Source in Session (Chosen)
- When creating the tmux session, prepend the command with env file sourcing
- Use `set -a` to auto-export all variables
- Advantages:
  - Simple implementation
  - Variables are set in the session's shell
  - Works with any command
  - Supports shell variable expansion

#### Option B: tmux set-environment
- Use tmux's built-in environment commands
- Disadvantages:
  - More complex parsing needed
  - Limited to simple KEY=VALUE format

### 3. Technical Implementation

1. Modify the session script to:
   - Accept `-e` or `--env-file` parameters
   - Validate env files exist
   - Build a command prefix that sources env files
   - Prepend to user's command

2. Command construction:
   ```bash
   # If env files provided:
   COMMAND="set -a; source file1.env; source file2.env; set +a; $USER_COMMAND"
   ```

### 4. Security Considerations

- Validate env file paths (no directory traversal)
- Check file exists and is readable
- Warn about sensitive data in logs
- Document that env vars will be visible in session

### 5. Edge Cases

- Non-existent env files: Error and exit
- Empty env files: Continue normally
- Malformed env files: Shell will handle errors
- Multiple env files: Load in order (later overrides earlier)
- Relative vs absolute paths: Support both

### 6. Future Enhancements

- Support inline env vars: `-e KEY=VALUE`
- Template env files in .vibe/templates/
- Mask sensitive values in logs
- Integration with secret managers