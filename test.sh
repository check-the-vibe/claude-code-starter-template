#!/bin/bash

# Simple test script for setup.sh
# Tests by creating temp folders and running setup.sh

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Create test directory
TEST_DIR="test-runs/test-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$TEST_DIR"

echo "Running setup.sh tests in $TEST_DIR"
echo "======================================"

# Function to run a test
run_test() {
    local test_name="$1"
    local test_dir="$TEST_DIR/$2"
    local test_cmd="$3"
    
    echo -n "Testing $test_name... "
    
    # Create test directory
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Copy setup.sh
    cp ../../../setup.sh .
    
    # Initialize git if needed
    git init -q
    
    # Run test
    if eval "$test_cmd" > output.log 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Error: Check $test_dir/output.log"
        ((FAILED++))
    fi
    
    # Return to original directory
    cd - > /dev/null
}

# Test 1: List templates
run_test "list-templates command" "test-list" "./setup.sh --list-templates"

# Test 2: Help command
run_test "help command" "test-help" "./setup.sh --help"

# Test 3: Default template
run_test "default template" "test-default" "echo '' | ./setup.sh --non-interactive"

# Test 4: Specific template (python)
run_test "python template" "test-python" "./setup.sh --template python-project --non-interactive"

# Test 5: Specific template (nodejs)
run_test "nodejs template" "test-nodejs" "./setup.sh --template nodejs-react --non-interactive"

# Test 6: Invalid template (should use default)
run_test "invalid template fallback" "test-invalid" "./setup.sh --template nonexistent --non-interactive"

# Test 7: Check if .vibe directory is created
echo -n "Checking .vibe directory creation... "
if [ -d "$TEST_DIR/test-default/.vibe" ]; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    ((FAILED++))
fi

# Test 8: Check if CLAUDE.md is created
echo -n "Checking CLAUDE.md creation... "
if [ -f "$TEST_DIR/test-default/CLAUDE.md" ]; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    ((FAILED++))
fi

# Summary
echo "======================================"
echo -e "Tests completed: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi