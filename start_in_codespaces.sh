#!/bin/bash

# GitHub Codespaces Setup Script for Next.js with Auth.js
# This script automatically configures and starts a Next.js application with authentication in GitHub Codespaces

set -e

echo "🚀 GitHub Codespaces Setup for Next.js with Auth.js"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in GitHub Codespaces
if [ -z "$CODESPACE_NAME" ]; then
    echo -e "${RED}❌ This script is designed to run in GitHub Codespaces environment${NC}"
    echo -e "${YELLOW}💡 For local development, use: npm run dev${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub Codespaces environment detected${NC}"
echo -e "${BLUE}📍 Codespace Name: $CODESPACE_NAME${NC}"

# Construct the base URL for this Codespace
BASE_URL="https://${CODESPACE_NAME}-3000.app.github.dev"
echo -e "${BLUE}🌐 Base URL: $BASE_URL${NC}"

# Check if package.json exists (Next.js project)
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found. This doesn't appear to be a Next.js project.${NC}"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
    echo -e "${GREEN}✅ Dependencies installed${NC}"
fi

# Check if .env.local exists, create or update it
echo -e "${YELLOW}⚙️  Configuring environment variables...${NC}"

if [ -f ".env.local" ]; then
    # Update existing NEXTAUTH_URL
    if grep -q "NEXTAUTH_URL=" ".env.local"; then
        sed -i "s|NEXTAUTH_URL=.*|NEXTAUTH_URL=$BASE_URL|" .env.local
        echo -e "${GREEN}✅ Updated NEXTAUTH_URL in .env.local${NC}"
    else
        echo "NEXTAUTH_URL=$BASE_URL" >> .env.local
        echo -e "${GREEN}✅ Added NEXTAUTH_URL to .env.local${NC}"
    fi
else
    echo -e "${YELLOW}📝 Creating .env.local file...${NC}"
    cat > .env.local << EOF
# Environment variables for GitHub Codespaces
NEXTAUTH_URL=$BASE_URL

# Auth.js Secret (generate with: openssl rand -base64 32)
# NEXTAUTH_SECRET=your-secret-here

# GitHub OAuth (configure in your GitHub OAuth App)
# AUTH_GITHUB_ID=your-github-oauth-app-id
# AUTH_GITHUB_SECRET=your-github-oauth-app-secret

# Google OAuth (configure in Google Cloud Console)
# AUTH_GOOGLE_ID=your-google-oauth-client-id
# AUTH_GOOGLE_SECRET=your-google-oauth-client-secret
EOF
    echo -e "${GREEN}✅ Created .env.local with template${NC}"
fi

# Display OAuth configuration instructions
echo ""
echo -e "${BLUE}🔐 OAuth Configuration Required${NC}"
echo -e "${YELLOW}To enable authentication, configure your OAuth providers with these URLs:${NC}"
echo ""
echo -e "${BLUE}GitHub OAuth App:${NC}"
echo -e "   Homepage URL: $BASE_URL"
echo -e "   Authorization callback URL: $BASE_URL/api/auth/callback/github"
echo ""
echo -e "${BLUE}Google OAuth Client:${NC}"
echo -e "   Authorized JavaScript origins: $BASE_URL"
echo -e "   Authorized redirect URIs: $BASE_URL/api/auth/callback/google"
echo ""

# Check for required environment variables
echo -e "${YELLOW}🔍 Checking environment variables...${NC}"

missing_vars=()

if [ -z "$NEXTAUTH_SECRET" ]; then
    missing_vars+=("NEXTAUTH_SECRET")
fi

if [ -z "$AUTH_GITHUB_ID" ]; then
    missing_vars+=("AUTH_GITHUB_ID")
fi

if [ -z "$AUTH_GITHUB_SECRET" ]; then
    missing_vars+=("AUTH_GITHUB_SECRET")
fi

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Missing environment variables:${NC}"
    for var in "${missing_vars[@]}"; do
        echo -e "   - $var"
    done
    echo ""
    echo -e "${YELLOW}💡 Add these to your Codespaces secrets or .env.local file${NC}"
    echo -e "${BLUE}📖 See: https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-development-environment-secrets-for-your-repository-or-organization${NC}"
fi

# Check if auth configuration exists
if [ -f "auth.ts" ] || [ -f "lib/auth.ts" ] || [ -f "app/api/auth/[...nextauth]/route.ts" ]; then
    echo -e "${GREEN}✅ Auth.js configuration found${NC}"
else
    echo -e "${YELLOW}⚠️  Auth.js configuration not found${NC}"
    echo -e "${YELLOW}💡 Make sure you have configured Auth.js properly${NC}"
fi

# Function to check port status
check_port() {
    if command -v lsof > /dev/null; then
        lsof -ti:3000 > /dev/null 2>&1
    else
        netstat -tuln 2>/dev/null | grep :3000 > /dev/null 2>&1
    fi
}

# Check if port 3000 is already in use
if check_port; then
    echo -e "${YELLOW}⚠️  Port 3000 is already in use${NC}"
    echo -e "${YELLOW}🔄 Attempting to stop existing process...${NC}"
    pkill -f "next dev" || true
    sleep 2
fi

# Set port visibility to public (this requires manual action)
echo ""
echo -e "${YELLOW}📡 Port Configuration${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT: Set port 3000 visibility to 'Public' for OAuth to work${NC}"
echo -e "${BLUE}1. Go to the 'PORTS' tab in VS Code${NC}"
echo -e "${BLUE}2. Right-click on port 3000${NC}"
echo -e "${BLUE}3. Select 'Port Visibility' → 'Public'${NC}"
echo ""

# Start the development server
echo -e "${YELLOW}🚀 Starting Next.js development server...${NC}"
echo -e "${BLUE}📍 Your application will be available at: $BASE_URL${NC}"
echo ""

# Check if npm run dev script exists
if npm run | grep -q "dev"; then
    echo -e "${GREEN}▶️  Running npm run dev...${NC}"
    npm run dev
else
    echo -e "${RED}❌ 'dev' script not found in package.json${NC}"
    echo -e "${YELLOW}💡 Try running: next dev${NC}"
    exit 1
fi