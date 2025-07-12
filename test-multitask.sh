#!/bin/bash

# Test script for multi-tasking vibe sessions

echo "=== Vibe Multi-Tasking Test ==="
echo "This test will create multiple parallel sessions"
echo ""

# Initialize vibe
source .vibe/init

# Clear any existing sessions
echo "Clearing existing sessions..."
.vibe/clear -f
echo ""

# Create multiple test sessions in parallel
echo "Starting 4 parallel test sessions..."

# Session 1: Count to 10 slowly
.vibe/session count-slow . "for i in {1..10}; do echo \"Slow count: \$i\"; sleep 1; done; echo 'Slow count complete!'"

# Session 2: Count to 20 quickly  
.vibe/session count-fast . "for i in {1..20}; do echo \"Fast count: \$i\"; sleep 0.5; done; echo 'Fast count complete!'"

# Session 3: Calculate fibonacci
.vibe/session fibonacci . "echo 'Calculating Fibonacci...'; a=0; b=1; for i in {1..10}; do c=\$((a+b)); echo \"Fib[\$i]: \$c\"; a=\$b; b=\$c; sleep 0.8; done; echo 'Fibonacci complete!'"

# Session 4: System info
.vibe/session sysinfo . "echo 'Gathering system info...'; sleep 1; echo \"Date: \$(date)\"; sleep 1; echo \"Uptime: \$(uptime)\"; sleep 1; echo \"Disk usage:\"; df -h | head -5; echo 'System info complete!'"

echo ""
echo "All sessions started! They are running in parallel."
echo ""

# Show active sessions
echo "Active sessions:"
.vibe/list -v
echo ""

# Monitor progress
echo "Monitoring progress (will check every 3 seconds for 15 seconds)..."
for check in {1..5}; do
    echo ""
    echo "=== Check $check of 5 (at $(date +%H:%M:%S)) ==="
    
    # Check each session
    for session in count-slow count-fast fibonacci sysinfo; do
        echo ""
        echo "--- $session status ---"
        # Get last 3 lines of each session
        .vibe/tail $session -n 3 2>/dev/null || echo "Session not found or no output yet"
    done
    
    # Wait before next check
    if [ $check -lt 5 ]; then
        sleep 3
    fi
done

echo ""
echo "=== Final Status ==="
.vibe/list -v

echo ""
echo "Test complete! Use 'vibe-clear' to clean up sessions."