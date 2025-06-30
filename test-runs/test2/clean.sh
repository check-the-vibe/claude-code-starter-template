#!/bin/bash

# Clean script to remove .vibe directory and CLAUDE.md
# This helps reset the project to a clean state

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Claude Code Node.js React Template - Clean Script${NC}"
echo "================================================="
echo

# Check what exists
FILES_TO_REMOVE=()

if [[ -d ".vibe" ]]; then
    FILES_TO_REMOVE+=(".vibe/")
fi

if [[ -f "CLAUDE.md" ]]; then
    FILES_TO_REMOVE+=("CLAUDE.md")
fi

# If nothing to remove, exit
if [[ ${#FILES_TO_REMOVE[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ Already clean - no .vibe/ or CLAUDE.md found${NC}"
    exit 0
fi

# Show what will be removed
echo -e "${YELLOW}The following will be removed:${NC}"
for item in "${FILES_TO_REMOVE[@]}"; do
    echo "  - $item"
done
echo

# Confirm with user
read -p "Are you sure you want to remove these files? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Remove files
    for item in "${FILES_TO_REMOVE[@]}"; do
        rm -rf "$item"
        echo -e "${GREEN}✓ Removed $item${NC}"
    done
    echo
    echo -e "${GREEN}✓ Cleanup complete!${NC}"
    echo -e "${BLUE}You can now run setup.sh to create a fresh configuration.${NC}"
else
    echo -e "${RED}✗ Cleanup cancelled${NC}"
    exit 1
fi
