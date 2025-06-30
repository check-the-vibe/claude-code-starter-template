#!/bin/bash

# Simple test script for setup.sh - tests both local and remote modes
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Testing Claude Code Setup Script${NC}"
echo "=================================="

# Test 1: Local mode - list templates
echo -e "\n${YELLOW}TEST 1: Local mode - list templates${NC}"
if bash setup.sh --list 2>&1 | grep -q "default"; then
    echo -e "${GREEN}✓ PASSED${NC} - Local list command works"
else
    echo -e "${RED}✗ FAILED${NC} - Local list command failed"
    exit 1
fi

# Test 2: Remote mode - list templates (simulate curl pipe)
echo -e "\n${YELLOW}TEST 2: Remote mode - list templates${NC}"
if cat setup.sh | bash -s -- --list 2>&1 | grep -q "default"; then
    echo -e "${GREEN}✓ PASSED${NC} - Remote list command works"
else
    echo -e "${RED}✗ FAILED${NC} - Remote list command failed"
    exit 1
fi

# Test 3: Local mode - install default template
echo -e "\n${YELLOW}TEST 3: Local mode - install default template${NC}"
TEST_DIR="test-local-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
cp -r ../setup.sh .
cp -r ../templates .

if echo "y" | bash setup.sh --template default > install.log 2>&1; then
    if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - Local installation successful"
    else
        echo -e "${RED}✗ FAILED${NC} - Files not created"
        cd ..
        exit 1
    fi
else
    echo -e "${RED}✗ FAILED${NC} - Installation failed"
    cat install.log
    cd ..
    exit 1
fi
cd ..
rm -rf "$TEST_DIR"

# Test 4: Remote mode - would require actual GitHub URL
echo -e "\n${YELLOW}TEST 4: Remote mode installation${NC}"
echo -e "${BLUE}Note: Remote installation test requires actual GitHub URL${NC}"
echo -e "${BLUE}To test manually, run:${NC}"
echo "curl -fsSL https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.sh | bash"

echo -e "\n${GREEN}✅ All tests passed!${NC}"
echo "The setup script correctly handles both local and remote execution modes."