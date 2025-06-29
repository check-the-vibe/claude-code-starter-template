#!/bin/bash

# Simple test for setup.sh

echo "Testing setup.sh help..."
bash setup.sh --help 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -q "Usage:" && echo "PASS: Help shows Usage" || echo "FAIL: Help missing Usage"

echo -e "\nTesting basic setup..."
TEST_DIR="test-runs/simple-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

if bash ../../setup.sh --non-interactive --template default >/dev/null 2>&1; then
    if [[ -d ".vibe" ]] && [[ -f "CLAUDE.md" ]]; then
        echo "PASS: Basic setup completed"
    else
        echo "FAIL: Missing expected files"
    fi
else
    echo "FAIL: Setup script failed"
fi

cd ../..
echo -e "\nTest complete."