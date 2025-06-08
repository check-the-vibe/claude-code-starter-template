/**
 * Environment variable management for Electron and web environments
 */

/**
 * Get environment variable with fallback support
 */
export function getEnvVar(key, defaultValue = '') {
  // In Electron renderer process, use electronAPI
  if (typeof window !== 'undefined' && window.electronAPI) {
    return window.electronAPI.getEnv(key) || defaultValue;
  }
  
  // In Node.js environment (main process or web server)
  if (typeof process !== 'undefined' && process.env) {
    return process.env[key] || defaultValue;
  }
  
  return defaultValue;
}

/**
 * Check if we're running in Electron environment
 */
export function isElectron() {
  // Renderer process
  if (typeof window !== 'undefined' && window.electronAPI) {
    return true;
  }
  
  // Main process
  if (typeof process !== 'undefined' && process.versions && process.versions.electron) {
    return true;
  }
  
  return false;
}

/**
 * Get database URL based on environment
 */
export function getDatabaseUrl() {
  if (isElectron()) {
    // In Electron, the database path will be set by the main process
    return getEnvVar('DATABASE_URL', 'file:./database.db');
  }
  
  return getEnvVar('DATABASE_URL', 'file:./prisma/dev.db');
}

/**
 * Get NextAuth configuration
 */
export function getAuthConfig() {
  return {
    secret: getEnvVar('NEXTAUTH_SECRET', 'development-secret-change-in-production'),
    url: getEnvVar('NEXTAUTH_URL', 'http://localhost:3000'),
    googleClientId: getEnvVar('GOOGLE_CLIENT_ID', ''),
    googleClientSecret: getEnvVar('GOOGLE_CLIENT_SECRET', ''),
    githubId: getEnvVar('GITHUB_ID', ''),
    githubSecret: getEnvVar('GITHUB_SECRET', ''),
  };
}

/**
 * Environment configuration object
 */
export const env = {
  NODE_ENV: getEnvVar('NODE_ENV', 'development'),
  ELECTRON: getEnvVar('ELECTRON', 'false'),
  DATABASE_URL: getDatabaseUrl(),
  ...getAuthConfig(),
  
  // Computed properties
  isDevelopment: getEnvVar('NODE_ENV', 'development') === 'development',
  isProduction: getEnvVar('NODE_ENV', 'development') === 'production',
  isElectron: isElectron(),
};