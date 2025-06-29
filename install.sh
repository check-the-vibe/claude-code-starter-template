#!/bin/bash

# Claude Code Starter Template - Quick Install Script
# This script downloads setup.sh, runs it, then cleans up

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Create temporary file
TEMP_SCRIPT=$(mktemp)

# Cleanup function
cleanup() {
    rm -f "$TEMP_SCRIPT"
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo -e "${GREEN}Downloading Claude Code Starter Template setup script...${NC}"

# Download the setup script
if curl -fsSL https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.sh -o "$TEMP_SCRIPT"; then
    echo -e "${GREEN}Download complete. Running setup...${NC}"
    
    # Make it executable
    chmod +x "$TEMP_SCRIPT"
    
    # Run the setup script
    bash "$TEMP_SCRIPT" "$@"
else
    echo -e "${RED}Failed to download setup script${NC}"
    exit 1
fi