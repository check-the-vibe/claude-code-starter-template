#!/bin/bash

# Claude Code Starter Template - Test Suite
# Tests all functionality of setup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/setup.sh"
TEST_DIR="${SCRIPT_DIR}/test-runs"
RESULTS_FILE="${TEST_DIR}/test-results.txt"
FAILED_TESTS=0
PASSED_TESTS=0

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to print test headers
print_test_header() {
    echo
    print_color "$PURPLE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "$PURPLE" " TEST: $1"
    print_color "$PURPLE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to record test result
record_result() {
    local test_name=$1
    local result=$2
    local details=$3
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $test_name: $result - $details" >> "$RESULTS_FILE"
    
    if [[ "$result" == "PASS" ]]; then
        print_color "$GREEN" "  ✓ $test_name: PASSED"
        ((PASSED_TESTS++))
    else
        print_color "$RED" "  ✗ $test_name: FAILED - $details"
        ((FAILED_TESTS++))
    fi
}

# Function to clean test directory
clean_test_dir() {
    local dir=$1
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
    fi
    mkdir -p "$dir"
}

# Test 1: Help command
test_help_command() {
    print_test_header "Help Command"
    
    local help_output=$(bash "$SETUP_SCRIPT" --help 2>&1)
    
    if echo "$help_output" | grep -q "Usage:"; then
        if echo "$help_output" | grep -q -- "--template"; then
            record_result "help_command" "PASS" "Help text displayed correctly with all options"
        else
            record_result "help_command" "FAIL" "Help text missing --template option"
        fi
    else
        record_result "help_command" "FAIL" "Help command did not display usage"
    fi
}

# Test 2: Setup from root directory
test_root_setup() {
    print_test_header "Setup from Root Directory"
    
    local test_dir="${TEST_DIR}/root-test"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Run setup with non-interactive mode
    if timeout 30 bash "$SETUP_SCRIPT" --non-interactive --template default > /dev/null 2>&1; then
        if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
            record_result "root_setup" "PASS" "Setup completed successfully"
        else
            record_result "root_setup" "FAIL" "Required files not created"
        fi
    else
        record_result "root_setup" "FAIL" "Setup script failed or timed out"
    fi
    
    cd "$SCRIPT_DIR"
}

# Test 3: Setup from subdirectory
test_subdirectory_setup() {
    print_test_header "Setup from Subdirectory"
    
    local test_dir="${TEST_DIR}/subdir-test/nested/deep"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Run setup from deep subdirectory
    if bash "$SETUP_SCRIPT" --non-interactive --template default 2>&1 > /dev/null; then
        if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
            record_result "subdirectory_setup" "PASS" "Setup from subdirectory successful"
        else
            record_result "subdirectory_setup" "FAIL" "Required files not created in subdirectory"
        fi
    else
        record_result "subdirectory_setup" "FAIL" "Setup script failed from subdirectory"
    fi
    
    cd "$SCRIPT_DIR"
}

# Test 4: Template selection
test_template_selection() {
    print_test_header "Template Selection"
    
    # Test each available template
    local templates=("default" "python-project" "nodejs-react")
    
    for template in "${templates[@]}"; do
        local test_dir="${TEST_DIR}/template-${template}"
        clean_test_dir "$test_dir"
        cd "$test_dir"
        
        if bash "$SETUP_SCRIPT" --non-interactive --template "$template" 2>&1 > /dev/null; then
            if [[ -d ".vibe" ]]; then
                record_result "template_${template}" "PASS" "Template $template applied successfully"
            else
                record_result "template_${template}" "FAIL" ".vibe directory not created"
            fi
        else
            record_result "template_${template}" "FAIL" "Failed to apply template $template"
        fi
        
        cd "$SCRIPT_DIR"
    done
}

# Test 5: Invalid template handling
test_invalid_template() {
    print_test_header "Invalid Template Handling"
    
    local test_dir="${TEST_DIR}/invalid-template"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Try to use non-existent template
    if bash "$SETUP_SCRIPT" --non-interactive --template "non-existent-template" 2>&1 | grep -q "Using default"; then
        if [[ -d ".vibe" ]]; then
            record_result "invalid_template_fallback" "PASS" "Correctly fell back to default template"
        else
            record_result "invalid_template_fallback" "FAIL" "Fallback failed - no .vibe created"
        fi
    else
        record_result "invalid_template_fallback" "FAIL" "Did not handle invalid template correctly"
    fi
    
    cd "$SCRIPT_DIR"
}

# Test 6: Save template functionality
test_save_template() {
    print_test_header "Save Template Functionality"
    
    local test_dir="${TEST_DIR}/save-template"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # First create a setup
    bash "$SETUP_SCRIPT" --non-interactive --template default 2>&1 > /dev/null
    
    # Modify some files
    echo "# Custom PERSONA" > .vibe/PERSONA.md
    
    # Save as template
    if echo -e "test-saved\nTest saved template" | bash "$SETUP_SCRIPT" --save-template 2>&1 > /dev/null; then
        if [[ -d "${SCRIPT_DIR}/templates/test-saved" ]]; then
            record_result "save_template" "PASS" "Template saved successfully"
            # Clean up
            rm -rf "${SCRIPT_DIR}/templates/test-saved"
        else
            record_result "save_template" "FAIL" "Template directory not created"
        fi
    else
        record_result "save_template" "FAIL" "Save template command failed"
    fi
    
    cd "$SCRIPT_DIR"
}

# Test 7: Git repository handling
test_git_handling() {
    print_test_header "Git Repository Handling"
    
    local test_dir="${TEST_DIR}/git-test"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Initialize git repo
    git init > /dev/null 2>&1
    
    # Run setup
    if bash "$SETUP_SCRIPT" --non-interactive --template default 2>&1 > /dev/null; then
        if [[ -f ".gitignore" ]] && grep -q ".vibe/backups/" .gitignore; then
            record_result "git_handling" "PASS" "Git repository handled correctly"
        else
            record_result "git_handling" "FAIL" ".gitignore not properly configured"
        fi
    else
        record_result "git_handling" "FAIL" "Setup failed in git repository"
    fi
    
    cd "$SCRIPT_DIR"
}

# Test 8: Backup functionality
test_backup_functionality() {
    print_test_header "Backup Functionality"
    
    local test_dir="${TEST_DIR}/backup-test"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Create initial setup
    bash "$SETUP_SCRIPT" --non-interactive --template default 2>&1 > /dev/null
    
    # Modify a file
    echo "Modified content" > .vibe/TASKS.md
    
    # Run setup again, should trigger backup prompt (but we're non-interactive so it won't backup)
    if bash "$SETUP_SCRIPT" --non-interactive --template default 2>&1 > /dev/null; then
        record_result "backup_functionality" "PASS" "Handled existing .vibe directory"
    else
        record_result "backup_functionality" "FAIL" "Failed when .vibe already exists"
    fi
    
    cd "$SCRIPT_DIR"
}

# Test 9: Curl simulation (basic test)
test_curl_simulation() {
    print_test_header "Curl Simulation Test"
    
    local test_dir="${TEST_DIR}/curl-test"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Simulate curl by piping script
    if cat "$SETUP_SCRIPT" | BASH_SOURCE="" bash -s -- --non-interactive 2>&1 > /dev/null; then
        if [[ -d ".vibe" ]]; then
            record_result "curl_simulation" "PASS" "Curl simulation successful"
        else
            record_result "curl_simulation" "FAIL" ".vibe not created in curl mode"
        fi
    else
        record_result "curl_simulation" "FAIL" "Script failed in curl simulation"
    fi
    
    cd "$SCRIPT_DIR"
}

# Main test runner
main() {
    print_color "$CYAN" "╔════════════════════════════════════════════════════════╗"
    print_color "$CYAN" "║     Claude Code Starter Template - Test Suite          ║"
    print_color "$CYAN" "╚════════════════════════════════════════════════════════╝"
    
    # Ensure setup script exists and is executable
    if [[ ! -f "$SETUP_SCRIPT" ]]; then
        print_color "$RED" "Error: setup.sh not found at $SETUP_SCRIPT"
        exit 1
    fi
    
    # Make setup script executable
    chmod +x "$SETUP_SCRIPT"
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    echo "Test run started at $(date)" > "$RESULTS_FILE"
    
    # Run all tests
    test_help_command
    test_root_setup
    test_subdirectory_setup
    test_template_selection
    test_invalid_template
    test_save_template
    test_git_handling
    test_backup_functionality
    test_curl_simulation
    
    # Print summary
    echo
    print_color "$CYAN" "════════════════════════════════════════════════════════"
    print_color "$CYAN" "Test Summary:"
    print_color "$GREEN" "  Passed: $PASSED_TESTS"
    print_color "$RED" "  Failed: $FAILED_TESTS"
    print_color "$CYAN" "  Total:  $((PASSED_TESTS + FAILED_TESTS))"
    print_color "$CYAN" "════════════════════════════════════════════════════════"
    
    # Save summary to results file
    echo "" >> "$RESULTS_FILE"
    echo "Test Summary: Passed=$PASSED_TESTS Failed=$FAILED_TESTS Total=$((PASSED_TESTS + FAILED_TESTS))" >> "$RESULTS_FILE"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        print_color "$GREEN" "✅ All tests passed!"
        exit 0
    else
        print_color "$RED" "❌ Some tests failed. Check $RESULTS_FILE for details."
        exit 1
    fi
}

# Run tests
main "$@"