/**
 * Electron Main Process
 * This is the entry point for the Electron application
 */

const { app, BrowserWindow, ipcMain, shell } = require('electron');
const { join } = require('path');
const isDev = process.env.NODE_ENV === 'development';

// Keep a global reference of the window object
let mainWindow;

/**
 * Create the main application window
 */
function createMainWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    show: false, // Don't show until ready-to-show
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: join(__dirname, '../preload/preload.js'),
      webSecurity: true,
    },
    icon: join(__dirname, '../../public/favicon.ico'), // App icon
  });

  // Load the Next.js application
  if (isDev) {
    // Development: Load from Next.js dev server
    mainWindow.loadURL('http://localhost:3000');
    // Open DevTools in development
    mainWindow.webContents.openDevTools();
  } else {
    // Production: Load from built Next.js files
    mainWindow.loadFile(join(__dirname, '../../app/index.html'));
  }

  // Show window when ready to prevent visual flash
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    
    // Focus on window for better UX
    if (isDev) {
      mainWindow.webContents.focus();
    }
  });

  // Handle window closed
  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // Handle external links
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Security: Prevent new window creation
  mainWindow.webContents.on('new-window', (event, url) => {
    event.preventDefault();
    shell.openExternal(url);
  });
}

/**
 * App event handlers
 */

// This method will be called when Electron has finished initialization
app.whenReady().then(() => {
  createMainWindow();

  // macOS: Re-create window when dock icon is clicked
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    }
  });
});

// Quit when all windows are closed, except on macOS
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// Security: Prevent new window creation
app.on('web-contents-created', (event, contents) => {
  contents.on('new-window', (event, url) => {
    event.preventDefault();
    shell.openExternal(url);
  });
});

/**
 * IPC Handlers for secure communication between renderer and main process
 */

// Get environment variables securely
ipcMain.handle('get-env', (event, key) => {
  // Only allow specific environment variables
  const allowedKeys = [
    'NODE_ENV',
    'NEXTAUTH_SECRET',
    'DATABASE_URL',
    'GOOGLE_CLIENT_ID',
    'GITHUB_ID',
  ];
  
  if (allowedKeys.includes(key)) {
    return process.env[key] || '';
  }
  
  return '';
});

// Secure storage using Electron's safeStorage (Electron 13+)
ipcMain.handle('set-secure-storage', async (event, key, value) => {
  try {
    const { safeStorage } = require('electron');
    if (safeStorage.isEncryptionAvailable()) {
      const encrypted = safeStorage.encryptString(value);
      // Store encrypted data (you might want to use a proper storage solution)
      global.secureStorage = global.secureStorage || {};
      global.secureStorage[key] = encrypted;
      return true;
    }
  } catch (error) {
    console.error('Secure storage error:', error);
  }
  return false;
});

ipcMain.handle('get-secure-storage', async (event, key) => {
  try {
    const { safeStorage } = require('electron');
    if (safeStorage.isEncryptionAvailable() && global.secureStorage && global.secureStorage[key]) {
      return safeStorage.decryptString(global.secureStorage[key]);
    }
  } catch (error) {
    console.error('Secure storage error:', error);
  }
  return null;
});

ipcMain.handle('delete-secure-storage', async (event, key) => {
  try {
    if (global.secureStorage && global.secureStorage[key]) {
      delete global.secureStorage[key];
      return true;
    }
  } catch (error) {
    console.error('Secure storage error:', error);
  }
  return false;
});

// App information
ipcMain.handle('get-app-version', () => {
  return app.getVersion();
});

ipcMain.handle('get-app-path', (event, name) => {
  try {
    return app.getPath(name);
  } catch (error) {
    console.error('Get app path error:', error);
    return '';
  }
});

/**
 * Development utilities
 */
if (isDev) {
  // Enable live reload for Electron in development
  try {
    require('electron-reload')(__dirname, {
      electron: require(join(__dirname, '../../node_modules/.bin/electron')),
      hardResetMethod: 'exit'
    });
  } catch (error) {
    // electron-reload not installed, continue without it
  }
}