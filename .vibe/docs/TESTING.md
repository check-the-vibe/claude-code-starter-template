# Testing Documentation

## Overview

The Claude Code Starter Template includes multiple test scripts to verify the functionality of the setup.sh script:

1. **test-setup.sh** - Comprehensive test suite with 9 different test scenarios
2. **run-tests.sh** - Simplified test runner with 8 core tests
3. **verify-setup.sh** - Quick verification script for basic functionality

## Test Scripts

### test-setup.sh

The most comprehensive test suite that includes:
- Help command validation
- Setup from root directory
- Setup from subdirectory
- Template selection (default, python-project, nodejs-react)
- Invalid template handling
- Save template functionality
- Git repository handling
- Backup functionality
- Curl simulation test

Results are saved to `test-runs/test-results.txt`

### run-tests.sh

A simplified version that tests:
- Help command output
- Basic setup with default template
- Python template setup
- NodeJS React template setup
- Invalid template fallback
- Subdirectory execution
- Git integration
- Existing .vibe directory handling

### verify-setup.sh

Quick verification script that:
- Tests help output
- Performs basic setup
- Verifies file creation
- Cleans up test directory

## Running Tests

```bash
# Make scripts executable
chmod +x test-setup.sh run-tests.sh verify-setup.sh

# Run comprehensive tests
./test-setup.sh

# Run simplified tests
./run-tests.sh

# Run quick verification
./verify-setup.sh
```

## Test Results

Test results are stored in:
- `test-runs/test-results.txt` - Detailed results with timestamps
- Console output shows pass/fail status for each test

## Known Issues

1. **Color Code Handling**: The test scripts need to strip ANSI color codes from the setup.sh output when checking for specific text patterns. This was addressed by using `sed 's/\x1b\[[0-9;]*m//g'` to remove color codes.

2. **Template Path Resolution**: When running from subdirectories, the script correctly resolves paths to templates directory.

3. **Non-interactive Mode**: All tests use `--non-interactive` flag to avoid prompts during automated testing.

## Test Structure

```
test-runs/
├── test-results.txt
├── root-test/
├── subdir-test/
├── template-default/
├── template-python-project/
├── template-nodejs-react/
├── invalid-template/
├── save-template/
├── git-test/
├── backup-test/
└── curl-test/
```

Each test creates its own directory within test-runs/ to avoid conflicts.

## Adding New Tests

To add a new test:

1. Create a test function following the pattern:
```bash
test_new_feature() {
    print_test_header "New Feature Test"
    
    local test_dir="${TEST_DIR}/new-feature"
    clean_test_dir "$test_dir"
    cd "$test_dir"
    
    # Test logic here
    
    if [[ condition ]]; then
        record_result "new_feature" "PASS" "Description"
    else
        record_result "new_feature" "FAIL" "Error description"
    fi
    
    cd "$SCRIPT_DIR"
}
```

2. Add the function call to the main() function
3. Update test counters and summary

## Debugging Tests

For debugging:
- Run with `bash -x test-setup.sh` to see execution trace
- Check test-runs/test-results.txt for detailed logs
- Individual test directories preserve state for inspection