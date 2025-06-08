/**
 * Electron-compatible authentication utilities
 * This provides a simplified authentication system that works in Electron environment
 */

import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { getPrismaClient } from './database.js';

const JWT_SECRET = process.env.NEXTAUTH_SECRET || 'your-fallback-secret-key';
const TOKEN_EXPIRY = '7d'; // 7 days

/**
 * Create a JWT token for a user
 */
export function createToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      name: user.name,
    },
    JWT_SECRET,
    { expiresIn: TOKEN_EXPIRY }
  );
}

/**
 * Verify and decode a JWT token
 */
export function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
}

/**
 * Register a new user
 */
export async function registerUser(name, email, password) {
  const prisma = getPrismaClient();
  
  try {
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      throw new Error('User already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
      },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
      }
    });

    return user;
  } catch (error) {
    throw error;
  }
}

/**
 * Authenticate user with email and password
 */
export async function authenticateUser(email, password) {
  const prisma = getPrismaClient();
  
  try {
    const user = await prisma.user.findUnique({
      where: { email }
    });

    if (!user || !user.password) {
      throw new Error('Invalid credentials');
    }

    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      throw new Error('Invalid credentials');
    }

    // Return user without password
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  } catch (error) {
    throw error;
  }
}

/**
 * Get user by ID
 */
export async function getUserById(id) {
  const prisma = getPrismaClient();
  
  try {
    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        email: true,
        image: true,
        createdAt: true,
        updatedAt: true,
      }
    });

    return user;
  } catch (error) {
    throw error;
  }
}

/**
 * Store authentication token securely in Electron
 */
export function storeAuthToken(token) {
  if (typeof window !== 'undefined' && window.electronAPI) {
    // Use Electron's secure storage
    return window.electronAPI.setSecureStorage('auth_token', token);
  } else {
    // Fallback to localStorage for web environment
    localStorage.setItem('auth_token', token);
    return Promise.resolve();
  }
}

/**
 * Retrieve authentication token from secure storage
 */
export function getAuthToken() {
  if (typeof window !== 'undefined' && window.electronAPI) {
    // Use Electron's secure storage
    return window.electronAPI.getSecureStorage('auth_token');
  } else {
    // Fallback to localStorage for web environment
    return Promise.resolve(localStorage.getItem('auth_token'));
  }
}

/**
 * Remove authentication token from storage
 */
export function removeAuthToken() {
  if (typeof window !== 'undefined' && window.electronAPI) {
    // Use Electron's secure storage
    return window.electronAPI.deleteSecureStorage('auth_token');
  } else {
    // Fallback to localStorage for web environment
    localStorage.removeItem('auth_token');
    return Promise.resolve();
  }
}

/**
 * Get current authenticated user from token
 */
export async function getCurrentUser() {
  try {
    const token = await getAuthToken();
    
    if (!token) {
      return null;
    }

    const decoded = verifyToken(token);
    
    if (!decoded) {
      // Token is invalid, remove it
      await removeAuthToken();
      return null;
    }

    // Get fresh user data from database
    const user = await getUserById(decoded.id);
    
    if (!user) {
      // User no longer exists, remove token
      await removeAuthToken();
      return null;
    }

    return user;
  } catch (error) {
    console.error('Error getting current user:', error);
    return null;
  }
}

/**
 * Login user and store token
 */
export async function loginUser(email, password) {
  try {
    const user = await authenticateUser(email, password);
    const token = createToken(user);
    await storeAuthToken(token);
    return user;
  } catch (error) {
    throw error;
  }
}

/**
 * Logout user and remove token
 */
export async function logoutUser() {
  try {
    await removeAuthToken();
    return true;
  } catch (error) {
    console.error('Error logging out user:', error);
    return false;
  }
}