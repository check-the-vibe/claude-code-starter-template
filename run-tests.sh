#!/bin/bash

# Simple test runner for setup.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/setup.sh"
TEST_BASE="${SCRIPT_DIR}/test-runs"

# Counter
PASSED=0
FAILED=0

# Helper functions
pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗ $1: $2${NC}"
    ((FAILED++))
}

header() {
    echo -e "\n${BLUE}Testing: $1${NC}"
}

# Ensure setup script is executable
chmod +x "$SETUP_SCRIPT"

# Clean test directory
rm -rf "$TEST_BASE"
mkdir -p "$TEST_BASE"

echo -e "${BLUE}Claude Code Setup Script - Test Runner${NC}\n"

# Test 1: Help output
header "Help command"
# Strip color codes when checking output
HELP_OUTPUT=$(bash "$SETUP_SCRIPT" --help 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
if echo "$HELP_OUTPUT" | grep -q "Usage:" && \
   echo "$HELP_OUTPUT" | grep -q -- "--template"; then
    pass "Help displays correctly"
else
    fail "Help command" "Missing expected output"
fi

# Test 2: Basic setup
header "Basic setup with default template"
TEST_DIR="$TEST_BASE/test-default"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
if bash "$SETUP_SCRIPT" --non-interactive --template default >/dev/null 2>&1; then
    if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]] && [[ -f ".vibe/PERSONA.md" ]]; then
        pass "Default template setup"
    else
        fail "Default template" "Missing expected files"
    fi
else
    fail "Default template" "Setup failed"
fi
cd "$SCRIPT_DIR"

# Test 3: Python template
header "Python project template"
TEST_DIR="$TEST_BASE/test-python"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
if bash "$SETUP_SCRIPT" --non-interactive --template python-project >/dev/null 2>&1; then
    if [[ -d ".vibe" ]]; then
        pass "Python template setup"
    else
        fail "Python template" "Missing .vibe directory"
    fi
else
    fail "Python template" "Setup failed"
fi
cd "$SCRIPT_DIR"

# Test 4: NodeJS template
header "NodeJS React template"
TEST_DIR="$TEST_BASE/test-nodejs"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
if bash "$SETUP_SCRIPT" --non-interactive --template nodejs-react >/dev/null 2>&1; then
    if [[ -d ".vibe" ]]; then
        pass "NodeJS template setup"
    else
        fail "NodeJS template" "Missing .vibe directory"
    fi
else
    fail "NodeJS template" "Setup failed"
fi
cd "$SCRIPT_DIR"

# Test 5: Invalid template fallback
header "Invalid template handling"
TEST_DIR="$TEST_BASE/test-invalid"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
# Strip color codes when checking output
INVALID_OUTPUT=$(bash "$SETUP_SCRIPT" --non-interactive --template "nonexistent" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
if echo "$INVALID_OUTPUT" | grep -q "Using default"; then
    if [[ -d ".vibe" ]]; then
        pass "Invalid template fallback to default"
    else
        fail "Invalid template" "Fallback didn't create files"
    fi
else
    fail "Invalid template" "Didn't fall back to default"
fi
cd "$SCRIPT_DIR"

# Test 6: Subdirectory execution
header "Setup from subdirectory"
TEST_DIR="$TEST_BASE/test-subdir/deep/nested"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
if bash "$SETUP_SCRIPT" --non-interactive --template default >/dev/null 2>&1; then
    if [[ -d ".vibe" ]]; then
        pass "Subdirectory setup"
    else
        fail "Subdirectory" "Missing .vibe directory"
    fi
else
    fail "Subdirectory" "Setup failed from subdirectory"
fi
cd "$SCRIPT_DIR"

# Test 7: Git integration
header "Git repository handling"
TEST_DIR="$TEST_BASE/test-git"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
git init >/dev/null 2>&1
if bash "$SETUP_SCRIPT" --non-interactive --template default >/dev/null 2>&1; then
    if [[ -f ".gitignore" ]] && grep -q ".vibe/backups/" .gitignore; then
        pass "Git repository integration"
    else
        fail "Git integration" ".gitignore not configured properly"
    fi
else
    fail "Git integration" "Setup failed in git repo"
fi
cd "$SCRIPT_DIR"

# Test 8: Existing .vibe handling
header "Existing .vibe directory handling"
TEST_DIR="$TEST_BASE/test-existing"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
# Create initial setup
bash "$SETUP_SCRIPT" --non-interactive --template default >/dev/null 2>&1
# Run again to test existing directory handling
if bash "$SETUP_SCRIPT" --non-interactive --template default >/dev/null 2>&1; then
    pass "Handled existing .vibe directory"
else
    fail "Existing directory" "Failed when .vibe exists"
fi
cd "$SCRIPT_DIR"

# Summary
echo -e "\n${BLUE}Test Summary:${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "Total: $((PASSED + FAILED))"

if [[ $FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi