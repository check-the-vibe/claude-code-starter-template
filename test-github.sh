#!/bin/bash

# Test script for GitHub remote execution of setup.sh
# This tests the actual curl | bash workflow from GitHub

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# GitHub configuration
GITHUB_REPO="check-the-vibe/claude-code-starter-template"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE} GitHub Remote Execution Test${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Testing against: ${BLUE}${GITHUB_RAW_URL}${NC}"
echo

# Function to run a test
run_test() {
    local test_name="$1"
    local test_dir="$2"
    local test_cmd="$3"
    
    echo -e "${YELLOW}TEST: $test_name${NC}"
    
    # Create test directory
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Run test
    if eval "$test_cmd" > output.log 2>&1; then
        # Check if expected files were created
        if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
            echo -e "  ${GREEN}✓ PASSED${NC} - Remote installation successful"
            
            # Verify .vibe structure
            local expected_files=(".vibe/TASKS.md" ".vibe/ERRORS.md" ".vibe/PERSONA.md" ".vibe/ENVIRONMENT.md" ".vibe/LOG.txt" ".vibe/LINKS.csv" ".vibe/docs")
            local all_exist=true
            
            echo -e "  ${BLUE}Verifying .vibe structure:${NC}"
            for file in "${expected_files[@]}"; do
                if [[ -e "$file" ]]; then
                    echo -e "    ${GREEN}✓${NC} $file"
                else
                    echo -e "    ${RED}✗${NC} $file missing"
                    all_exist=false
                fi
            done
            
            if [[ "$all_exist" == "true" ]]; then
                echo -e "  ${GREEN}✓ All expected files created${NC}"
            else
                echo -e "  ${RED}✗ Some files missing${NC}"
                return 1
            fi
        else
            echo -e "  ${RED}✗ FAILED${NC} - Core files not created"
            echo -e "  ${RED}Contents of directory:${NC}"
            ls -la
            echo -e "  ${RED}Last 20 lines of output:${NC}"
            tail -20 output.log
            return 1
        fi
    else
        echo -e "  ${RED}✗ FAILED${NC} - Installation script failed"
        echo -e "  ${RED}Error output:${NC}"
        tail -20 output.log | sed 's/^/    /'
        return 1
    fi
    
    cd ..
    return 0
}

# Create temporary test directory
TEST_ROOT="github-test-$(date +%s)"
mkdir -p "$TEST_ROOT"
cd "$TEST_ROOT"

echo -e "${BLUE}Created test directory: $TEST_ROOT${NC}"
echo

# Test 1: Check if setup.sh is accessible from GitHub
echo -e "${YELLOW}TEST 1: Verify setup.sh is accessible${NC}"
if curl -fsSL "${GITHUB_RAW_URL}/setup.sh" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ PASSED${NC} - setup.sh is accessible from GitHub"
else
    echo -e "  ${RED}✗ FAILED${NC} - Cannot access setup.sh from GitHub"
    echo -e "  ${RED}URL: ${GITHUB_RAW_URL}/setup.sh${NC}"
    cd ..
    rm -rf "$TEST_ROOT"
    exit 1
fi
echo

# Test 2: List templates from GitHub
echo -e "${YELLOW}TEST 2: List templates via GitHub${NC}"
if curl -fsSL "${GITHUB_RAW_URL}/setup.sh" | bash -s -- --list 2>&1 | grep -q "default"; then
    echo -e "  ${GREEN}✓ PASSED${NC} - Can list templates from GitHub"
else
    echo -e "  ${RED}✗ FAILED${NC} - Failed to list templates"
fi
echo

# Test 3: Install default template from GitHub
echo -e "${YELLOW}TEST 3: Install default template from GitHub${NC}"
if run_test "Default template installation" "test-default" "curl -fsSL '${GITHUB_RAW_URL}/setup.sh' | bash -s -- --template default"; then
    echo -e "  ${GREEN}✓ Installation test passed${NC}"
else
    echo -e "  ${RED}✗ Installation test failed${NC}"
fi
echo

# Test 4: Non-interactive mode (piped input)
echo -e "${YELLOW}TEST 4: Non-interactive installation from GitHub${NC}"
if run_test "Non-interactive installation" "test-noninteractive" "echo '' | curl -fsSL '${GITHUB_RAW_URL}/setup.sh' | bash"; then
    echo -e "  ${GREEN}✓ Non-interactive test passed${NC}"
else
    echo -e "  ${RED}✗ Non-interactive test failed${NC}"
fi
echo

# Test 5: Verify template script is accessible
echo -e "${YELLOW}TEST 5: Verify template scripts are accessible${NC}"
TEMPLATE_URL="${GITHUB_RAW_URL}/templates/default/setup.sh"
if curl -fsSL "$TEMPLATE_URL" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ PASSED${NC} - Template script accessible at: $TEMPLATE_URL"
else
    echo -e "  ${RED}✗ FAILED${NC} - Cannot access template script"
    echo -e "  ${RED}This may cause remote installations to fail${NC}"
fi
echo

# Cleanup
cd ..
echo -e "${BLUE}Cleaning up test directory...${NC}"
rm -rf "$TEST_ROOT"

# Summary
echo
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE} Test Summary${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ GitHub remote execution tests completed${NC}"
echo
echo -e "${BLUE}To manually test the full installation:${NC}"
echo -e "curl -fsSL ${GITHUB_RAW_URL}/setup.sh | bash"
echo
echo -e "${YELLOW}Note: This test requires the repository to be pushed to GitHub${NC}"
echo -e "${YELLOW}at ${GITHUB_REPO}${NC}"