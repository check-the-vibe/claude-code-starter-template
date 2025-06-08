# Next.js to Electron Implementation Guide

## Quick Start for Linux Development Environment

This guide provides step-by-step instructions for transforming your existing Next.js application into a production-ready Electron desktop app, optimized for Linux development environment with cross-platform distribution capabilities.

---

## Prerequisites

### System Requirements
- Node.js 18+ (LTS recommended)
- npm or yarn package manager
- Git for version control
- Linux development environment (Ubuntu/Debian preferred)

### Existing Next.js Application
- Functioning Next.js application
- Modern Next.js 13+ with App Router (recommended)
- Existing authentication system (Auth.js/NextAuth)
- Database integration (if applicable)

---

## Phase 1: Initial Setup and Assessment

### 1.1 Assess Current Application

First, examine your current Next.js application structure:

```bash
# Check Next.js version and configuration
cat package.json | grep next
cat next.config.js

# Identify authentication setup
grep -r "nextauth\|auth\.js" --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" .

# Check for API routes
find . -path "./pages/api/*" -o -path "./app/api/*" | head -10

# Identify database dependencies
grep -E "(prisma|sqlite|postgres|mysql)" package.json
```

### 1.2 Create Development Branch

```bash
# Create new branch for Electron development
git checkout -b feature/electron-migration
git push -u origin feature/electron-migration
```

### 1.3 Document Current State

Create a migration checklist:

```bash
# Create migration documentation
mkdir -p .electron-migration
cat > .electron-migration/current-state.md << 'EOF'
# Current Application State

## Next.js Configuration
- Version: [VERSION]
- Router: [App Router/Pages Router]
- Output: [default/export/standalone]

## Authentication
- Provider: [Auth.js/NextAuth/Custom]
- OAuth providers: [List providers]
- Session storage: [JWT/Database]

## Database
- Type: [SQLite/PostgreSQL/MySQL/None]
- ORM: [Prisma/Drizzle/Raw SQL]
- Connection: [Local/Remote]

## API Routes
- Count: [Number of API routes]
- Dependencies: [External APIs/Services]

## Build Configuration
- Custom webpack config: [Yes/No]
- Environment variables: [List critical vars]
EOF
```

---

## Phase 2: Nextron Integration

### 2.1 Install Nextron

```bash
# Install Nextron globally (recommended for CLI)
npm install -g nextron

# Alternative: Use npx for one-time setup
# npx create-nextron-app my-app --example basic-lang-javascript
```

### 2.2 Initialize Electron Structure

Create the basic Electron structure in your existing Next.js app:

```bash
# Create Electron main process directory
mkdir -p electron

# Create main process file
cat > electron/main.js << 'EOF'
const { app, BrowserWindow } = require('electron');
const path = require('path');
const isDev = process.env.NODE_ENV === 'development';
const { createServer } = require('next');
const { parse } = require('url');

let mainWindow;

async function createWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  if (isDev) {
    // Development: load from Next.js dev server
    await mainWindow.loadURL('http://localhost:3000');
    mainWindow.webContents.openDevTools();
  } else {
    // Production: serve static files
    const nextApp = createServer({ dev: false });
    await nextApp.prepare();
    
    const handle = nextApp.getRequestHandler();
    const server = require('http').createServer((req, res) => {
      const parsedUrl = parse(req.url, true);
      handle(req, res, parsedUrl);
    });
    
    server.listen(0, () => {
      const port = server.address().port;
      mainWindow.loadURL(`http://localhost:${port}`);
    });
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
EOF

# Create preload script for secure IPC
cat > electron/preload.js << 'EOF'
const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Add secure IPC methods here
  getVersion: () => process.versions.electron,
  platform: process.platform
});
EOF
```

### 2.3 Update Package.json

```bash
# Backup current package.json
cp package.json package.json.backup

# Add Electron dependencies
npm install --save-dev electron electron-builder
npm install --save next-electron-server

# Update package.json scripts
```

Add these scripts to your package.json:

```json
{
  "main": "electron/main.js",
  "scripts": {
    "electron": "electron .",
    "electron:dev": "concurrently \"npm run dev\" \"wait-on http://localhost:3000 && electron .\"",
    "electron:build": "next build && electron-builder",
    "electron:dist": "npm run build && electron-builder --publish=never"
  },
  "build": {
    "appId": "com.yourcompany.yourapp",
    "productName": "Your App Name",
    "directories": {
      "output": "dist"
    },
    "files": [
      "electron/**/*",
      ".next/**/*",
      "public/**/*",
      "package.json"
    ],
    "linux": {
      "target": [
        {
          "target": "AppImage",
          "arch": ["x64"]
        },
        {
          "target": "deb",
          "arch": ["x64"]
        }
      ]
    },
    "mac": {
      "target": [
        {
          "target": "dmg",
          "arch": ["x64", "arm64"]
        }
      ]
    }
  }
}
```

### 2.4 Install Additional Dependencies

```bash
# For concurrent development servers
npm install --save-dev concurrently wait-on

# For hot reloading in development
npm install --save-dev electron-reload
```

---

## Phase 3: Next.js Configuration for Electron

### 3.1 Update Next.js Configuration

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Use standalone for better Electron compatibility
  output: process.env.NODE_ENV === 'production' ? 'standalone' : undefined,
  
  // Disable image optimization for static export compatibility
  images: {
    unoptimized: true
  },
  
  // Enable trailing slash for better file serving
  trailingSlash: true,
  
  // Configure asset prefix for production
  assetPrefix: process.env.NODE_ENV === 'production' ? './' : undefined,
  
  // Webpack configuration for Electron
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.target = 'electron-renderer';
    }
    return config;
  }
};

module.exports = nextConfig;
```

### 3.2 Environment Variables Configuration

```bash
# Create .env.local for development
cat > .env.local << 'EOF'
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here
NODE_ENV=development
EOF

# Create .env.production for Electron builds
cat > .env.production << 'EOF'
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here
NODE_ENV=production
EOF
```

---

## Phase 4: Authentication Migration

### 4.1 Assess Authentication Compatibility

Since NextAuth/Auth.js has limitations in Electron production builds, you'll need to choose an approach:

#### Option A: Keep NextAuth (Requires Server Mode)
```javascript
// This requires running a Next.js server in production
// Update next.config.js
module.exports = {
  output: 'standalone', // Instead of 'export'
  // ... other config
};
```

#### Option B: Migrate to JWT-Based Auth
```bash
# Install JWT libraries
npm install jsonwebtoken jose

# Create new auth utility
mkdir -p lib/auth-electron
```

### 4.2 Create Electron-Compatible Auth Service

```javascript
// lib/auth-electron/auth.js
export class ElectronAuth {
  constructor() {
    this.tokenKey = 'electron_auth_token';
  }

  async signIn(credentials) {
    try {
      // Call your auth API
      const response = await fetch('/api/auth/signin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials)
      });
      
      const data = await response.json();
      
      if (data.token) {
        localStorage.setItem(this.tokenKey, data.token);
        return { success: true, user: data.user };
      }
    } catch (error) {
      console.error('Auth error:', error);
      return { success: false, error: error.message };
    }
  }

  async signOut() {
    localStorage.removeItem(this.tokenKey);
    // Clear other auth-related data
  }

  getToken() {
    return localStorage.getItem(this.tokenKey);
  }

  isAuthenticated() {
    const token = this.getToken();
    if (!token) return false;
    
    try {
      // Verify token is not expired
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.exp > Date.now() / 1000;
    } catch {
      return false;
    }
  }
}
```

---

## Phase 5: Database Integration

### 5.1 Choose Database Strategy

For Electron apps, local storage is preferred:

#### Option A: SQLite with Better-SQLite3
```bash
# Install Better-SQLite3
npm install better-sqlite3
npm install --save-dev electron-rebuild

# Add rebuild script
echo '"rebuild": "electron-rebuild"' >> package.json scripts
```

#### Option B: Browser-Compatible Database
```bash
# Install Dexie for IndexedDB
npm install dexie

# Or install LokiJS for document store
npm install lokijs
```

### 5.2 Database Migration Script

```javascript
// scripts/migrate-to-electron-db.js
const Database = require('better-sqlite3');
const path = require('path');

function setupElectronDatabase() {
  const dbPath = path.join(process.cwd(), 'data', 'app.db');
  const db = new Database(dbPath);

  // Create tables
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS sessions (
      id TEXT PRIMARY KEY,
      user_id INTEGER NOT NULL,
      expires_at DATETIME NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)
    );
  `);

  return db;
}

module.exports = { setupElectronDatabase };
```

---

## Phase 6: Development Workflow Setup

### 6.1 Hot Reloading Configuration

```javascript
// electron/main.js - Add hot reloading for development
if (isDev) {
  require('electron-reload')(__dirname, {
    electron: path.join(__dirname, '..', 'node_modules', '.bin', 'electron'),
    hardResetMethod: 'exit'
  });
}
```

### 6.2 Development Scripts

```bash
# Create development startup script
cat > scripts/dev-start.sh << 'EOF'
#!/bin/bash
echo "Starting Next.js + Electron development environment..."

# Start Next.js dev server in background
npm run dev &
NEXTJS_PID=$!

# Wait for Next.js to be ready
echo "Waiting for Next.js server..."
npx wait-on http://localhost:3000

# Start Electron
echo "Starting Electron..."
npm run electron

# Cleanup on exit
trap "kill $NEXTJS_PID" EXIT
EOF

chmod +x scripts/dev-start.sh
```

### 6.3 Testing Setup

```bash
# Install testing dependencies
npm install --save-dev spectron jest electron-chromedriver

# Create test configuration
mkdir -p tests/electron
```

---

## Phase 7: Build and Distribution

### 7.1 Linux-Specific Build Configuration

```json
// package.json build configuration for Linux
{
  "build": {
    "linux": {
      "target": [
        {
          "target": "AppImage",
          "arch": ["x64"]
        },
        {
          "target": "deb",
          "arch": ["x64"]
        },
        {
          "target": "snap",
          "arch": ["x64"]
        }
      ],
      "category": "Development"
    }
  }
}
```

### 7.2 Cross-Platform Build Scripts

```bash
# Create build scripts
mkdir -p scripts

cat > scripts/build-all.sh << 'EOF'
#!/bin/bash
echo "Building for all platforms..."

# Build Next.js
npm run build

# Build for Linux
npm run electron:dist -- --linux

# Build for macOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  npm run electron:dist -- --mac
fi

echo "Build complete! Check the 'dist' directory."
EOF

chmod +x scripts/build-all.sh
```

### 7.3 GitHub Actions for CI/CD

```yaml
# .github/workflows/electron-build.yml
name: Build Electron App

on:
  push:
    branches: [ main, feature/electron-migration ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build Next.js
      run: npm run build
      
    - name: Build Electron (Linux)
      if: matrix.os == 'ubuntu-latest'
      run: npm run electron:dist -- --linux
      
    - name: Build Electron (macOS)
      if: matrix.os == 'macos-latest'
      run: npm run electron:dist -- --mac
      
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: electron-builds-${{ matrix.os }}
        path: dist/
```

---

## Phase 8: Testing and Quality Assurance

### 8.1 Create Test Plan

```bash
# Create comprehensive test checklist
cat > .electron-migration/test-plan.md << 'EOF'
# Electron App Testing Checklist

## Functional Testing
- [ ] Application starts successfully
- [ ] All Next.js routes work correctly
- [ ] Authentication flow works
- [ ] Database operations function
- [ ] API routes respond correctly

## Platform Testing
- [ ] Linux AppImage works
- [ ] Linux .deb package installs
- [ ] macOS .dmg works (if applicable)
- [ ] Window resizing works properly
- [ ] Menu functionality works

## Performance Testing
- [ ] Startup time < 5 seconds
- [ ] Memory usage reasonable
- [ ] No memory leaks
- [ ] Responsive UI interactions

## Security Testing
- [ ] No Node.js integration in renderer
- [ ] Content Security Policy configured
- [ ] Secure IPC communication
- [ ] Authentication tokens secure
EOF
```

### 8.2 Automated Testing

```javascript
// tests/electron/basic.spec.js
const { Application } = require('spectron');
const path = require('path');

describe('Electron App', () => {
  let app;

  beforeEach(async () => {
    app = new Application({
      path: path.join(__dirname, '../../node_modules/.bin/electron'),
      args: [path.join(__dirname, '../../electron/main.js')],
      startTimeout: 10000,
      waitTimeout: 10000
    });
    
    await app.start();
  });

  afterEach(async () => {
    if (app && app.isRunning()) {
      await app.stop();
    }
  });

  it('should open application window', async () => {
    const windowCount = await app.client.getWindowCount();
    expect(windowCount).toBe(1);
  });

  it('should have correct title', async () => {
    const title = await app.client.getTitle();
    expect(title).toBe('Your App Name');
  });
});
```

---

## Phase 9: Production Deployment

### 9.1 Release Preparation

```bash
# Create release script
cat > scripts/prepare-release.sh << 'EOF'
#!/bin/bash
set -e

echo "Preparing release..."

# Run tests
npm test

# Build application
npm run build

# Build Electron packages
npm run electron:dist

# Create checksums
cd dist
for file in *.AppImage *.deb *.dmg; do
  if [ -f "$file" ]; then
    sha256sum "$file" > "$file.sha256"
  fi
done

echo "Release preparation complete!"
echo "Files ready for distribution:"
ls -la *.AppImage *.deb *.dmg 2>/dev/null || echo "No distribution files found"
EOF

chmod +x scripts/prepare-release.sh
```

### 9.2 Auto-Updater Setup

```javascript
// electron/updater.js
const { autoUpdater } = require('electron-updater');
const { dialog } = require('electron');

function setupAutoUpdater() {
  autoUpdater.checkForUpdatesAndNotify();

  autoUpdater.on('update-available', () => {
    dialog.showMessageBox({
      type: 'info',
      title: 'Update available',
      message: 'A new version is available. It will be downloaded in the background.',
      buttons: ['OK']
    });
  });

  autoUpdater.on('update-downloaded', () => {
    dialog.showMessageBox({
      type: 'info',
      title: 'Update ready',
      message: 'Update downloaded. The application will restart to apply the update.',
      buttons: ['Restart Now', 'Later']
    }).then((result) => {
      if (result.response === 0) {
        autoUpdater.quitAndInstall();
      }
    });
  });
}

module.exports = { setupAutoUpdater };
```

---

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. "Module not found" errors
```bash
# Solution: Rebuild native modules
npm run rebuild
```

#### 2. Authentication not working in production
```bash
# Check if using 'export' instead of 'standalone'
# Update next.config.js to use 'standalone' output
```

#### 3. Database connection issues
```bash
# Ensure database path is correct for Electron
# Use app.getPath('userData') for database location
```

#### 4. Build fails on different platforms
```bash
# Use platform-specific build commands
npm run electron:dist -- --linux
npm run electron:dist -- --mac
```

#### 5. Large application size
```bash
# Optimize build configuration
# Remove unnecessary dependencies
# Use webpack-bundle-analyzer to identify large modules
npm install --save-dev webpack-bundle-analyzer
```

---

## Success Metrics

### Application Ready When:
- ✅ Starts in under 5 seconds
- ✅ All authentication flows work
- ✅ Database operations are reliable
- ✅ Cross-platform builds succeed
- ✅ Memory usage is reasonable (<200MB idle)
- ✅ Auto-updates function correctly
- ✅ Security best practices implemented

### Distribution Ready When:
- ✅ Linux AppImage and .deb packages work
- ✅ macOS .dmg functions (if targeted)
- ✅ Code signing configured (if applicable)
- ✅ Update mechanism tested
- ✅ Installation/uninstallation smooth
- ✅ Documentation complete

This implementation guide provides a practical, step-by-step approach to migrating your Next.js application to Electron while maintaining production quality and Linux development environment compatibility.