# Electron Development Guide - Next.js Desktop App

This guide provides comprehensive instructions for developing, building, and distributing the Next.js Electron desktop application.

## Overview

The application has been successfully transformed from a web-only Next.js app into a cross-platform desktop application using Electron. It maintains all existing functionality while adding desktop-specific features.

## Architecture

### Project Structure
```
├── electron/
│   ├── main/
│   │   └── main.js          # Electron main process
│   └── preload/
│       └── preload.js       # Preload script for secure IPC
├── src/
│   ├── app/                 # Next.js App Router pages
│   ├── components/          # React components
│   └── lib/
│       ├── auth.js          # Web authentication (Auth.js)
│       ├── electron-auth.js # Electron authentication (JWT)
│       ├── database.js      # Database configuration
│       └── env.js           # Environment management
├── prisma/
│   ├── schema.prisma        # Database schema
│   └── dev.db              # SQLite database
└── package.json            # Electron configuration
```

### Dual Environment Support

The application supports both web and desktop environments:

- **Web Mode**: Traditional Next.js with Auth.js authentication
- **Desktop Mode**: Electron with JWT-based authentication and local storage

## Development Setup

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Linux, macOS, or Windows (for development)
- For building: Linux can build Linux packages only

### Installation

1. **Install dependencies**:
```bash
npm install
```

2. **Initialize database**:
```bash
npx prisma generate
npx prisma db push
```

3. **Set up environment variables**:
```bash
# Copy and configure environment variables
cp .env .env.local
# Edit .env.local with your configuration
```

## Development Workflows

### Web Development (Next.js)

Standard Next.js development:
```bash
npm run dev
```
- Runs Next.js dev server on http://localhost:3000
- Hot reloading enabled
- Full Auth.js authentication

### Electron Development

#### Option 1: Concurrent Development (Recommended)
```bash
npm run electron:dev
```
This command:
1. Starts Next.js dev server
2. Waits for server to be ready
3. Launches Electron with dev server
4. Enables hot reloading for both processes

#### Option 2: Manual Process
```bash
# Terminal 1: Start Next.js
npm run dev

# Terminal 2: Launch Electron (after Next.js is ready)
npm run electron
```

### Key Development Features

- **Hot Reloading**: Changes to React components update immediately
- **DevTools**: Electron DevTools available in development
- **Database**: Local SQLite database in user data directory
- **Authentication**: JWT-based authentication with secure storage
- **IPC Communication**: Secure renderer-main process communication

## Building for Distribution

### Development Build Test
```bash
npm run electron:build
```

### Platform-Specific Builds

#### Linux (AppImage and .deb)
```bash
npm run electron:build-linux
```

#### macOS (DMG)
```bash
npm run electron:build-mac
```

#### Windows (NSIS installer)
```bash
npm run electron:build-win
```

### Build Output

Builds are created in the `dist/` directory:
- **Linux**: `nextjs-electron-app-0.1.0.AppImage`, `.deb` files
- **macOS**: `nextjs-electron-app-0.1.0.dmg`
- **Windows**: `nextjs-electron-app Setup 0.1.0.exe`

## Configuration

### Environment Variables

The application uses different environment variable strategies:

#### Web Environment (.env.local)
```bash
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret
DATABASE_URL=file:./prisma/dev.db
```

#### Electron Environment
Environment variables are managed through:
1. System environment variables
2. Electron's secure storage for sensitive data
3. Main process environment configuration

### Database Configuration

#### Web Mode
- Uses `./prisma/dev.db` for development
- Relative path configuration

#### Electron Mode  
- Uses user data directory: `{userData}/database.db`
- Absolute path configuration
- Cross-platform user data storage

### Authentication Configuration

#### Web Mode (Auth.js)
- OAuth flows with GitHub, Google
- Session-based authentication
- CSRF protection

#### Electron Mode (JWT)
- JWT token authentication
- Secure storage using Electron's safeStorage
- Local user management

## Security Features

### Electron Security Best Practices

1. **Context Isolation**: Enabled for all renderer processes
2. **Node Integration**: Disabled in renderer processes
3. **Preload Scripts**: Secure IPC communication only
4. **Content Security Policy**: Restricts resource loading
5. **Secure Storage**: Uses Electron's encrypted storage for tokens

### IPC Security

The preload script exposes only necessary APIs:
```javascript
window.electronAPI = {
  getEnv: (key) => // Get allowed environment variables
  setSecureStorage: (key, value) => // Store encrypted data
  getSecureStorage: (key) => // Retrieve encrypted data
  // ... other secure methods
}
```

## Testing

### Manual Testing Checklist

#### Electron Development
- [ ] Application launches without errors
- [ ] Next.js content displays correctly
- [ ] Hot reloading works for React components
- [ ] DevTools accessible and functional
- [ ] Database operations work

#### Authentication Testing
- [ ] User registration works
- [ ] User login works
- [ ] JWT tokens stored securely
- [ ] Session persistence across app restarts
- [ ] Logout clears stored tokens

#### Desktop Features
- [ ] Window controls (minimize, maximize, close)
- [ ] Menus and keyboard shortcuts
- [ ] Platform-specific behavior
- [ ] External link handling

#### Build Testing
- [ ] Production build completes without errors
- [ ] Packaged app launches successfully
- [ ] All features work in packaged version
- [ ] Database initializes correctly

## Troubleshooting

### Common Development Issues

#### 1. Electron Won't Launch
```bash
# Check if processes are running
ps aux | grep electron
ps aux | grep next

# Kill hanging processes
pkill -f electron
pkill -f next
```

#### 2. Database Connection Issues
```bash
# Regenerate Prisma client
npx prisma generate

# Reset database
rm prisma/dev.db
npx prisma db push
```

#### 3. Hot Reloading Not Working
- Ensure Next.js dev server is running on port 3000
- Check for console errors in Electron DevTools
- Restart both Next.js and Electron processes

#### 4. Build Failures
```bash
# Clear Next.js cache
rm -rf .next

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Platform-Specific Issues

#### Linux
- Requires `libgtk-3-0` for UI components
- AppImage may require FUSE for older systems
- `.deb` packages work on Debian/Ubuntu derivatives

#### macOS
- Code signing required for distribution
- Notarization needed for Gatekeeper approval
- ARM64 and x64 universal builds supported

#### Windows
- Antivirus may flag unsigned executables
- Admin privileges may be required for installation
- PATH environment variables for system integration

## Performance Optimization

### Development Performance
- Use `--turbopack` flag for faster development builds
- Disable unused Electron features
- Optimize Prisma queries

### Production Performance
- Enable Next.js optimizations in `next.config.mjs`
- Minimize Electron bundle size
- Use native modules sparingly

### Memory Management
- Close database connections properly
- Handle Electron process lifecycle events
- Implement proper cleanup in IPC handlers

## Distribution

### Code Signing (Production)

#### macOS
```bash
# Configure in package.json
"build": {
  "mac": {
    "identity": "Developer ID Application: Your Name",
    "hardenedRuntime": true,
    "gatekeeperAssess": false
  }
}
```

#### Windows
```bash
# Configure in package.json
"build": {
  "win": {
    "certificateFile": "path/to/certificate.p12",
    "certificatePassword": "password"
  }
}
```

### Auto-Updates

Consider implementing auto-updates with `electron-updater`:
```bash
npm install electron-updater
```

### App Store Distribution

For app store distribution, additional configuration is required:
- **Mac App Store**: Sandboxing and entitlements
- **Microsoft Store**: MSIX packaging
- **Snap Store**: Snap packaging for Linux

## Next Steps

### Future Enhancements

1. **Auto-updater**: Implement automatic updates
2. **Native Menus**: Add application menus
3. **System Integration**: Tray icons, notifications
4. **Offline Support**: Enhanced offline capabilities
5. **Performance**: Optimize bundle size and startup time

### Production Checklist

- [ ] Configure code signing certificates
- [ ] Set up CI/CD for automated builds
- [ ] Implement crash reporting
- [ ] Add analytics and usage tracking
- [ ] Create installation documentation
- [ ] Set up support channels

The Electron desktop application is now ready for development and can be built for distribution on Linux and macOS platforms.