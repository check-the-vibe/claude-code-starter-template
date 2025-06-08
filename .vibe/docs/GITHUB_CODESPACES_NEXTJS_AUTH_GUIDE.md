# GitHub Codespaces Configuration Guide for Next.js with Authentication

This comprehensive guide covers configuring Next.js applications with Auth.js (NextAuth) authentication to work properly in GitHub Codespaces environments.

## Table of Contents
1. [Port Forwarding Configuration](#port-forwarding-configuration)
2. [URL Format and Environment Variables](#url-format-and-environment-variables)
3. [Authentication Configuration](#authentication-configuration)
4. [Environment Variables Setup](#environment-variables-setup)
5. [OAuth Provider Configuration](#oauth-provider-configuration)
6. [Troubleshooting Common Issues](#troubleshooting-common-issues)
7. [Best Practices](#best-practices)

## Port Forwarding Configuration

### Automatic Port Forwarding
GitHub Codespaces automatically detects when your Next.js application outputs localhost URLs to the terminal and forwards port 3000 automatically.

### Manual Port Configuration
For guaranteed port forwarding, configure your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Next.js with Auth",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:18",
  "forwardPorts": [3000],
  "portsAttributes": {
    "3000": {
      "label": "Next.js App",
      "onAutoForward": "openBrowser"
    }
  }
}
```

### Port Visibility Settings
- **Private** (default): Only accessible to you
- **Private to Organization**: Available to organization members
- **Public**: Anyone with the URL can access (needed for OAuth callbacks)

**Important**: For OAuth authentication to work, you typically need to set port 3000 to **Public** visibility.

## URL Format and Environment Variables

### Codespaces URL Pattern
GitHub Codespaces URLs follow this format:
```
https://{CODESPACE_NAME}-{PORT}.app.github.dev
```

Example: `https://mystical-space-guacamole-abc123-3000.app.github.dev`

### Dynamic URL Detection
Get your Codespace's URL programmatically:

```bash
# Shell script approach
CODESPACE_URL="https://${CODESPACE_NAME}-3000.app.github.dev"
echo "Your app is running at: $CODESPACE_URL"
```

```javascript
// Next.js approach
const getCodespaceUrl = () => {
  if (process.env.CODESPACE_NAME) {
    return `https://${process.env.CODESPACE_NAME}-3000.app.github.dev`;
  }
  return 'http://localhost:3000';
};
```

## Authentication Configuration

### Auth.js Configuration for Codespaces
Configure your `auth.ts` file to handle dynamic URLs:

```typescript
import NextAuth from "next-auth"
import GitHub from "next-auth/providers/github"
import Google from "next-auth/providers/google"

const getBaseUrl = () => {
  if (process.env.CODESPACE_NAME) {
    return `https://${process.env.CODESPACE_NAME}-3000.app.github.dev`;
  }
  if (process.env.NEXTAUTH_URL) {
    return process.env.NEXTAUTH_URL;
  }
  return 'http://localhost:3000';
};

export const { handlers, auth } = NextAuth({
  providers: [
    GitHub({
      clientId: process.env.AUTH_GITHUB_ID!,
      clientSecret: process.env.AUTH_GITHUB_SECRET!,
    }),
    Google({
      clientId: process.env.AUTH_GOOGLE_ID!,
      clientSecret: process.env.AUTH_GOOGLE_SECRET!,
    }),
  ],
  trustHost: true,
  callbacks: {
    async redirect({ url, baseUrl }) {
      const actualBaseUrl = getBaseUrl();
      // Redirect to the correct base URL
      if (url.startsWith('/')) return `${actualBaseUrl}${url}`;
      if (new URL(url).origin === actualBaseUrl) return url;
      return actualBaseUrl;
    },
  },
})
```

### Next.js Configuration
Update your `next.config.js` for Codespaces:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Allow external URLs in development
  ...(process.env.NODE_ENV === 'development' && {
    async rewrites() {
      return {
        beforeFiles: [
          {
            source: '/api/:path*',
            destination: '/api/:path*',
          },
        ],
      };
    },
  }),
  
  // Configure for Codespaces
  ...(process.env.CODESPACE_NAME && {
    assetPrefix: `https://${process.env.CODESPACE_NAME}-3000.app.github.dev`,
  }),
};

module.exports = nextConfig;
```

## Environment Variables Setup

### Required Environment Variables
Create a `.env.local` file with these variables:

```bash
# Auth.js Secret (generate with: openssl rand -base64 32)
NEXTAUTH_SECRET=your-secret-key-here

# Dynamic URL configuration
NEXTAUTH_URL=${CODESPACE_NAME ? `https://${CODESPACE_NAME}-3000.app.github.dev` : 'http://localhost:3000'}

# GitHub OAuth
AUTH_GITHUB_ID=your-github-oauth-app-id
AUTH_GITHUB_SECRET=your-github-oauth-app-secret

# Google OAuth
AUTH_GOOGLE_ID=your-google-oauth-client-id
AUTH_GOOGLE_SECRET=your-google-oauth-client-secret
```

### Codespaces Secrets Configuration
For production-like environments, configure secrets in GitHub:

1. Go to your repository settings
2. Navigate to "Codespaces" → "Repository secrets"
3. Add secrets for:
   - `AUTH_GITHUB_ID`
   - `AUTH_GITHUB_SECRET`
   - `AUTH_GOOGLE_ID`
   - `AUTH_GOOGLE_SECRET`
   - `NEXTAUTH_SECRET`

### Development Container Configuration
Add environment variables to `.devcontainer/devcontainer.json`:

```json
{
  "remoteEnv": {
    "NODE_ENV": "development",
    "NEXTAUTH_URL": "https://${CODESPACE_NAME}-3000.app.github.dev"
  }
}
```

## OAuth Provider Configuration

### GitHub OAuth Application Setup
1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Create a new OAuth app with:
   - **Application name**: Your app name
   - **Homepage URL**: `https://{your-codespace-name}-3000.app.github.dev`
   - **Authorization callback URL**: `https://{your-codespace-name}-3000.app.github.dev/api/auth/callback/github`

### Google OAuth Configuration
1. Go to Google Cloud Console → APIs & Services → Credentials
2. Create OAuth 2.0 Client ID with:
   - **Authorized JavaScript origins**: `https://{your-codespace-name}-3000.app.github.dev`
   - **Authorized redirect URIs**: `https://{your-codespace-name}-3000.app.github.dev/api/auth/callback/google`

### Dynamic OAuth Configuration Script
Create a helper script to update OAuth providers:

```bash
#!/bin/bash
# update-oauth-urls.sh

if [ -n "$CODESPACE_NAME" ]; then
    BASE_URL="https://${CODESPACE_NAME}-3000.app.github.dev"
    echo "Codespace detected. Your OAuth callback URLs should be:"
    echo "GitHub: ${BASE_URL}/api/auth/callback/github"
    echo "Google: ${BASE_URL}/api/auth/callback/google"
    echo ""
    echo "Update your OAuth provider settings with these URLs."
else
    echo "Not in a Codespace environment. Using localhost URLs."
fi
```

## Troubleshooting Common Issues

### OAuth Redirect Issues
**Problem**: OAuth redirects to localhost instead of Codespace URL

**Solutions**:
1. Ensure `trustHost: true` in Auth.js configuration
2. Set port 3000 to **Public** visibility
3. Update OAuth provider callback URLs to use Codespace URL
4. Verify `NEXTAUTH_URL` environment variable is correct

### Port Forwarding Not Working
**Problem**: Cannot access the application via Codespace URL

**Solutions**:
1. Check if port 3000 is automatically forwarded
2. Manually forward port 3000 if needed
3. Set port visibility to **Public**
4. Restart the Next.js development server

### Environment Variables Not Loading
**Problem**: Auth configuration not working

**Solutions**:
1. Verify `.env.local` exists and is not in `.gitignore`
2. Check Codespaces secrets are properly configured
3. Restart the Codespace if environment variables were added after creation
4. Use `echo $VARIABLE_NAME` to verify variables are loaded

### Session Cookie Issues
**Problem**: Authentication sessions not persisting

**Solutions**:
1. Ensure `NEXTAUTH_SECRET` is set and consistent
2. Check that cookies are allowed for the Codespace domain
3. Verify `trustHost: true` is set in Auth.js configuration

## Best Practices

### 1. Use Environment Variable Detection
Always detect the environment and set URLs dynamically:

```javascript
const isDevelopment = process.env.NODE_ENV === 'development';
const isCodespaces = !!process.env.CODESPACE_NAME;
const baseUrl = isCodespaces 
  ? `https://${process.env.CODESPACE_NAME}-3000.app.github.dev`
  : isDevelopment 
    ? 'http://localhost:3000'
    : process.env.NEXTAUTH_URL;
```

### 2. Port Configuration
- Always configure port 3000 in `devcontainer.json`
- Set appropriate port visibility for your use case
- Use consistent port numbers across environments

### 3. Security Considerations
- Never commit OAuth secrets to the repository
- Use Codespaces secrets for sensitive data
- Regularly rotate OAuth credentials
- Set appropriate port visibility (avoid Public unless necessary)

### 4. Development Workflow
- Create a setup script that detects Codespace environment
- Document OAuth configuration steps for team members
- Use consistent naming conventions for environment variables
- Test authentication flow in both local and Codespace environments

### 5. Team Collaboration
- Document required OAuth provider configurations
- Share Codespace configuration via `.devcontainer/devcontainer.json`
- Use organization-level Codespace secrets for shared credentials
- Provide clear setup instructions for new team members

## Sample Setup Script

Create `scripts/setup-codespaces.sh`:

```bash
#!/bin/bash
# Setup script for GitHub Codespaces

echo "🚀 Setting up Next.js with Auth.js in GitHub Codespaces..."

# Check if we're in Codespaces
if [ -n "$CODESPACE_NAME" ]; then
    BASE_URL="https://${CODESPACE_NAME}-3000.app.github.dev"
    echo "✅ Codespace detected: $CODESPACE_NAME"
    echo "📍 Your app will be available at: $BASE_URL"
    
    # Update NEXTAUTH_URL in .env.local
    if [ -f ".env.local" ]; then
        sed -i "s|NEXTAUTH_URL=.*|NEXTAUTH_URL=$BASE_URL|" .env.local
        echo "✅ Updated NEXTAUTH_URL in .env.local"
    else
        echo "⚠️  .env.local not found. Please create it with your environment variables."
    fi
    
    echo ""
    echo "🔗 OAuth Callback URLs to configure:"
    echo "   GitHub: ${BASE_URL}/api/auth/callback/github"
    echo "   Google: ${BASE_URL}/api/auth/callback/google"
    echo ""
    echo "⚙️  Remember to set port 3000 visibility to Public for OAuth to work!"
    
else
    echo "📍 Not in Codespaces - using localhost configuration"
fi

echo "🎉 Setup complete! Run 'npm run dev' to start your application."
```

This comprehensive guide provides everything needed to successfully configure Next.js applications with Auth.js authentication in GitHub Codespaces environments, including automatic URL detection, proper OAuth configuration, and troubleshooting common issues.