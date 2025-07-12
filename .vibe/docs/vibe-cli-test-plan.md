# Vibe CLI Test Plan

This document outlines the comprehensive test plan for the vibe CLI system, covering all major use cases and edge conditions.

## Test Objectives

1. Verify all vibe commands function correctly
2. Test different command execution patterns
3. Validate error handling and edge cases
4. Ensure proper session lifecycle management
5. Confirm logging functionality works as expected

## Test Categories

### 1. Short-lived Command with Immediate Feedback

**Purpose**: Test commands that complete quickly and return immediate results.

**Test Case 1.1: Echo Command**
- Command: `vibe-session echo-test . "echo 'Hello, Vibe!'"`
- Expected Result:
  - Session created successfully
  - Command executes and completes
  - Output captured in log file
  - Session shows as "dead" in vibe-list (command completed)

**Test Case 1.2: Date Command**
- Command: `vibe-session date-test . "date"`
- Expected Result:
  - Current date/time output to log
  - Session completes immediately
  - Log file contains single line with date

**Test Case 1.3: Quick Calculation**
- Command: `vibe-session calc-test . "expr 2 + 2"`
- Expected Result:
  - Output "4" in log
  - Session terminates after completion

### 2. Short-lived Command Where Logs Are Read

**Purpose**: Test the log reading functionality for completed commands.

**Test Case 2.1: Multiple Output Lines**
- Command: `vibe-session multi-line . "for i in 1 2 3 4 5; do echo Line \$i; done"`
- Follow-up: `vibe-logs multi-line`
- Expected Result:
  - Log shows 5 lines of output
  - Each line numbered correctly
  - No active session remains

**Test Case 2.2: Error Output Capture**
- Command: `vibe-session error-test . "ls /nonexistent/directory"`
- Follow-up: `vibe-logs error-test`
- Expected Result:
  - Error message captured in log
  - Session marked as dead
  - Error output visible in logs

**Test Case 2.3: Log with Specific Line Count**
- Command: `vibe-session count-test . "seq 1 100"`
- Follow-up: `vibe-logs count-test -n 10`
- Expected Result:
  - Shows last 10 lines (91-100)
  - Line count parameter works correctly

### 3. Long-running Task Where Claude Polls Until Completion

**Purpose**: Test monitoring of long-running processes and polling patterns.

**Test Case 3.1: Sleep with Progress**
- Command: `vibe-session sleep-progress . "for i in {1..5}; do echo Progress: \$i/5; sleep 1; done; echo COMPLETED"`
- Polling Pattern:
  ```bash
  while tmux has-session -t "vibe-sleep-progress" 2>/dev/null; do
      vibe-logs sleep-progress -n 1
      sleep 1
  done
  ```
- Expected Result:
  - Session remains active for ~5 seconds
  - Progress updates visible in logs
  - "COMPLETED" marker appears at end
  - Session terminates after completion

**Test Case 3.2: File Processing Simulation**
- Command: `vibe-session process-files . "for f in file{1..10}.txt; do echo Processing \$f...; sleep 0.5; done; echo All files processed"`
- Expected Result:
  - Can monitor progress via vibe-logs
  - Session stays active during processing
  - Clean termination after completion

**Test Case 3.3: Build Process Simulation**
- Command: `vibe-session build-sim . "echo 'Starting build...'; sleep 2; echo 'Compiling...'; sleep 2; echo 'Linking...'; sleep 1; echo 'Build successful!'"`
- Expected Result:
  - Status messages appear in real-time
  - Can check progress at any point
  - Session closes after success message

### 4. Long-running Task with User Interaction

**Purpose**: Test scenarios where user needs to interact with running sessions.

**Test Case 4.1: Development Server Simulation**
- Initial: `vibe-session dev-server . "while true; do echo 'Server running on port 3000'; sleep 5; done"`
- User Action: `vibe-attach dev-server` (then Ctrl+C to stop)
- Claude Action: `vibe-kill dev-server`
- Expected Result:
  - Server starts and runs continuously
  - User can attach and see output
  - User can stop server with Ctrl+C
  - Session can be killed cleanly

**Test Case 4.2: Interactive Python Session**
- Command: `vibe-session python-repl . "python3"`
- Interaction:
  1. `vibe-attach python-repl`
  2. Type: `print("Hello from Python")`
  3. Type: `exit()`
- Expected Result:
  - Python REPL accessible
  - Commands execute properly
  - Session terminates on exit

**Test Case 4.3: Watch Command**
- Command: `vibe-session watch-test . "watch -n 1 date"`
- Interaction Pattern:
  1. Let it run for a few seconds
  2. Check logs: `vibe-logs watch-test -f`
  3. Kill when ready: `vibe-kill watch-test -f`
- Expected Result:
  - Date updates every second
  - Logs show continuous updates
  - Clean termination with vibe-kill

## Edge Cases and Error Handling

### Test Case E1: Duplicate Session Names
- Command 1: `vibe-session test . "sleep 10"`
- Command 2: `vibe-session test . "echo 'duplicate'"`
- Expected: Second command fails with "Session 'test' already exists"

### Test Case E2: Invalid Session Names
- Test names: `test@123`, `test space`, `test/slash`
- Expected: All fail with "Invalid session name" error

### Test Case E3: Non-existent Session Operations
- Commands:
  - `vibe-attach nonexistent`
  - `vibe-logs nonexistent`
  - `vibe-kill nonexistent`
- Expected: Appropriate error messages and available session list

### Test Case E4: Concurrent Sessions
- Create 5 sessions simultaneously:
  ```bash
  for i in {1..5}; do
      vibe-session concurrent-$i . "sleep 10" &
  done
  ```
- Expected: All sessions created and visible in vibe-list

## Cleanup and Verification

### Post-Test Cleanup
1. List all sessions: `vibe-list -v`
2. Kill any remaining: `for s in $(vibe-list | grep -v "No active" | awk '{print $1}' | sed 's/vibe-//'); do vibe-kill $s -f; done`
3. Verify logs exist: `ls -la .vibe/logs/`
4. Check for orphaned info files: `ls -la .vibe/sessions/`

### Success Criteria
- All commands execute without unexpected errors
- Logs capture complete output
- Sessions lifecycle managed properly
- Error cases handled gracefully
- No resource leaks or orphaned sessions

## Test Execution Script

```bash
#!/bin/bash
# vibe-test-suite.sh

echo "=== Vibe CLI Test Suite ==="
echo "Initializing vibe environment..."
source .vibe/vibe-init

# Test 1: Short-lived command
echo -e "\n[TEST 1] Short-lived command with immediate feedback"
vibe-session echo-test . "echo 'Test 1 Success'"
sleep 1
vibe-logs echo-test

# Test 2: Multi-line output
echo -e "\n[TEST 2] Short-lived command with log reading"
vibe-session multi-test . "for i in {1..5}; do echo Line \$i; done"
sleep 1
vibe-logs multi-test -n 3

# Test 3: Long-running with polling
echo -e "\n[TEST 3] Long-running task with polling"
vibe-session long-test . "for i in {1..3}; do echo Step \$i; sleep 1; done; echo DONE"
while tmux has-session -t "vibe-long-test" 2>/dev/null; do
    echo "Polling... $(vibe-logs long-test -n 1 2>/dev/null | tail -1)"
    sleep 1
done
echo "Task completed!"

# Test 4: Session management
echo -e "\n[TEST 4] Session management"
vibe-session persist-test . "while true; do echo 'Running...'; sleep 2; done"
sleep 2
vibe-list -v
vibe-kill persist-test -f

# Cleanup
echo -e "\nTest suite completed. Final session status:"
vibe-list

echo -e "\nLog files created:"
ls -la .vibe/logs/ | tail -5
```

## Expected Test Duration

- Individual test cases: 5-30 seconds each
- Complete test suite: ~5 minutes
- Manual interaction tests: Variable based on user actions

## Test Report Template

```
Test Run Date: [DATE]
Tester: [NAME/Claude]

Summary:
- Total Tests: [COUNT]
- Passed: [COUNT]
- Failed: [COUNT]
- Skipped: [COUNT]

Detailed Results:
[Test Case ID]: [PASS/FAIL] - [Notes]

Issues Found:
1. [Issue description]
2. [Issue description]

Recommendations:
- [Improvement suggestion]
- [Improvement suggestion]
```