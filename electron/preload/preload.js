/**
 * Electron Preload Script
 * This script runs in the renderer process before the web content loads
 * It provides secure communication between the renderer and main process
 */

const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Environment variables
  getEnv: (key) => ipcRenderer.invoke('get-env', key),
  
  // Secure storage for authentication tokens
  setSecureStorage: (key, value) => ipcRenderer.invoke('set-secure-storage', key, value),
  getSecureStorage: (key) => ipcRenderer.invoke('get-secure-storage', key),
  deleteSecureStorage: (key) => ipcRenderer.invoke('delete-secure-storage', key),
  
  // App information
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  getAppPath: (name) => ipcRenderer.invoke('get-app-path', name),
  
  // Platform information
  platform: process.platform,
  isElectron: true,
});

// Security: Remove Node.js globals in renderer
delete window.require;
delete window.exports;
delete window.module;

// DOM Content Loaded event for initialization
window.addEventListener('DOMContentLoaded', () => {
  console.log('Electron preload script loaded');
  
  // Add Electron-specific CSS class to body
  document.body.classList.add('electron-app');
  
  // Add platform-specific CSS class
  document.body.classList.add(`platform-${process.platform}`);
});