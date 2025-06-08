import { PrismaClient } from '@/generated/prisma';

// Only import these in Node.js environment
let path, app;
if (typeof window === 'undefined') {
  path = require('path');
  try {
    const electron = require('electron');
    app = electron.app;
  } catch (error) {
    // Not in Electron environment
  }
}

let prisma = null;

/**
 * Get the appropriate database path based on environment
 */
function getDatabasePath() {
  if (typeof window !== 'undefined') {
    // Browser environment - this shouldn't happen but fallback to relative path
    return './dev.db';
  }

  // Check if we're in Electron
  if (process.type === 'renderer' || process.type === 'worker') {
    // In Electron renderer process, we shouldn't directly access the database
    throw new Error('Database access should only happen in the main process');
  }

  try {
    // Electron main process
    if (app && app.getPath) {
      const userDataPath = app.getPath('userData');
      return path.join(userDataPath, 'database.db');
    }
  } catch (error) {
    // Not in Electron environment or app not ready
  }

  // Development or non-Electron environment
  if (process.env.NODE_ENV === 'development') {
    return './prisma/dev.db';
  }

  // Production fallback
  return './database.db';
}

/**
 * Initialize Prisma client with appropriate database URL
 */
export function initializePrisma() {
  if (prisma) {
    return prisma;
  }

  const dbPath = getDatabasePath();
  const databaseUrl = `file:${dbPath}`;
  
  console.log(`Initializing Prisma with database: ${databaseUrl}`);

  prisma = new PrismaClient({
    datasources: {
      db: {
        url: databaseUrl,
      },
    },
  });

  return prisma;
}

/**
 * Get the Prisma client instance
 */
export function getPrismaClient() {
  if (!prisma) {
    return initializePrisma();
  }
  return prisma;
}

/**
 * Close the Prisma client connection
 */
export async function closePrismaClient() {
  if (prisma) {
    await prisma.$disconnect();
    prisma = null;
  }
}

// For development/web environment, use the standard approach
export const db = process.env.ELECTRON === 'true' 
  ? null // Will be initialized by Electron main process
  : new PrismaClient();