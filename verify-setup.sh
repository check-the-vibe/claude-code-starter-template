#!/bin/bash

# Quick verification of setup.sh functionality

echo "Verifying setup.sh..."
echo

# Test 1: Help
echo "1. Testing help output..."
if bash setup.sh --help | grep -q "Usage:"; then
    echo "✓ Help works"
else
    echo "✗ Help failed"
fi

# Test 2: Create test directory and run setup
echo
echo "2. Testing basic setup..."
rm -rf verify-test
mkdir verify-test
cd verify-test

if bash ../setup.sh --non-interactive --template default; then
    echo "✓ Setup completed"
    
    # Check files
    if [[ -d .vibe ]] && [[ -f CLAUDE.md ]]; then
        echo "✓ Files created correctly"
    else
        echo "✗ Files missing"
    fi
else
    echo "✗ Setup failed"
fi

cd ..
rm -rf verify-test

echo
echo "Verification complete!"