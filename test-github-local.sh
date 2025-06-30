#!/bin/bash

# Local test that simulates GitHub remote execution
# This tests the curl | bash workflow locally

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE} GitHub Method Test (Local Simulation)${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Get absolute path to setup.sh
SETUP_PATH="$(cd "$(dirname "$0")" && pwd)/setup.sh"

# Test 1: Simulate curl | bash with --list
echo -e "${YELLOW}TEST 1: List templates (simulating curl | bash)${NC}"
if cat "$SETUP_PATH" | bash -s -- --list 2>&1 | grep -q "default"; then
    echo -e "${GREEN}✓ PASSED${NC} - Templates listed successfully"
else
    echo -e "${RED}✗ FAILED${NC} - Failed to list templates"
fi
echo

# Test 2: Install default template (simulating curl | bash)
echo -e "${YELLOW}TEST 2: Install default template (simulating curl | bash)${NC}"
TEST_DIR="test-github-method-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

if cat "$SETUP_PATH" | bash -s -- --template default > install.log 2>&1; then
    if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - Installation successful"
        
        # Verify structure
        echo -e "${BLUE}  Verifying created structure:${NC}"
        for item in ".vibe/TASKS.md" ".vibe/ERRORS.md" ".vibe/PERSONA.md" "CLAUDE.md"; do
            if [[ -f "$item" ]]; then
                echo -e "  ${GREEN}  ✓${NC} $item"
            else
                echo -e "  ${RED}  ✗${NC} $item missing"
            fi
        done
    else
        echo -e "${RED}✗ FAILED${NC} - Expected files not created"
    fi
else
    echo -e "${RED}✗ FAILED${NC} - Installation failed"
    echo "Last 10 lines of output:"
    tail -10 install.log
fi

cd ..
rm -rf "$TEST_DIR"
echo

# Test 3: Non-interactive mode
echo -e "${YELLOW}TEST 3: Non-interactive mode (no template specified)${NC}"
TEST_DIR="test-noninteractive-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

if echo "" | cat "$SETUP_PATH" | bash > install.log 2>&1; then
    if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - Non-interactive installation successful (used default template)"
    else
        echo -e "${RED}✗ FAILED${NC} - Expected files not created"
    fi
else
    echo -e "${RED}✗ FAILED${NC} - Installation failed"
    echo "Last 10 lines of output:"
    tail -10 install.log
fi

cd ..
rm -rf "$TEST_DIR"

echo
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Local simulation tests completed${NC}"
echo
echo -e "${BLUE}These tests simulate the GitHub curl | bash workflow locally.${NC}"
echo -e "${BLUE}For actual GitHub testing, the repo must be pushed first.${NC}"