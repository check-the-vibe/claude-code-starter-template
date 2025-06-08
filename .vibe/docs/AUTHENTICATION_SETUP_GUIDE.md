# Authentication Setup Guide - Auth.js Implementation

This document provides step-by-step instructions for getting the authentication system up and running.

## Overview

The authentication system is built with:
- **Auth.js (NextAuth.js v5)** for authentication logic
- **Prisma** with SQLite for user data storage
- **bcryptjs** for password hashing
- **Email/Password** and **OAuth** (Google, GitHub) authentication
- **Route protection** via Next.js middleware
- **Session management** with JWT tokens

## Prerequisites

- Node.js 18+ installed
- Next.js 15 project setup
- Basic understanding of React and Next.js

## Step-by-Step Setup

### 1. Install Dependencies

```bash
npm install next-auth@beta @auth/prisma-adapter prisma @prisma/client bcryptjs
```

### 2. Initialize Database

The SQLite database is already configured. To recreate it:

```bash
npx prisma db push
npx prisma generate
```

### 3. Environment Variables

Update `.env` file with your OAuth credentials:

```env
# Database
DATABASE_URL="file:./dev.db"

# NextAuth.js
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-super-secret-key-change-this-in-production"

# OAuth Providers
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
GITHUB_ID="your-github-client-id"
GITHUB_SECRET="your-github-client-secret"
```

### 4. OAuth Provider Setup

#### Google OAuth Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Go to Credentials → Create Credentials → OAuth 2.0 Client ID
5. Add authorized redirect URI: `http://localhost:3000/api/auth/callback/google`
6. Copy Client ID and Client Secret to `.env`

#### GitHub OAuth Setup
1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Set Authorization callback URL: `http://localhost:3000/api/auth/callback/github`
4. Copy Client ID and Client Secret to `.env`

### 5. Start Development Server

```bash
npm run dev
```

Visit `http://localhost:3000` to see the application.

## File Structure

```
src/
├── app/
│   ├── api/
│   │   ├── auth/[...nextauth]/route.js    # Auth.js API routes
│   │   └── register/route.js              # User registration endpoint
│   ├── login/page.js                      # Login page
│   ├── register/page.js                   # Registration page
│   ├── dashboard/page.js                  # Protected dashboard
│   ├── profile/page.js                    # User profile page
│   └── layout.js                          # Root layout with SessionProvider
├── components/
│   ├── Navigation.js                      # Navigation with auth state
│   └── SessionProvider.js                # NextAuth session provider
├── lib/
│   └── auth.js                           # Auth.js configuration
├── middleware.js                         # Route protection
└── generated/
    └── prisma/                           # Generated Prisma client
```

## Configuration Files

### Auth.js Configuration (`src/lib/auth.js`)
- Configures providers (credentials, Google, GitHub)
- Sets up Prisma adapter for database
- Defines JWT session strategy
- Custom pages for sign-in/sign-up

### Middleware (`src/middleware.js`)
- Protects `/dashboard` and `/profile` routes
- Redirects unauthenticated users to login
- Redirects authenticated users away from auth pages

### Database Schema (`prisma/schema.prisma`)
- User, Account, Session, VerificationToken models
- SQLite for development (easily upgradeable to PostgreSQL)

## Features Implemented

### ✅ Core Authentication
- [x] Email/password registration and login
- [x] Password hashing with bcryptjs
- [x] User session management
- [x] Secure logout functionality

### ✅ OAuth Integration
- [x] Google OAuth login
- [x] GitHub OAuth login
- [x] Profile image and name import from OAuth

### ✅ Route Protection
- [x] Middleware-based route protection
- [x] Automatic redirects for auth/unauth users
- [x] Protected dashboard and profile pages

### ✅ User Interface
- [x] Responsive login/register forms
- [x] Form validation with error messages
- [x] Loading states and success feedback
- [x] Authentication-aware navigation
- [x] User profile display with OAuth images

### ✅ Security Features
- [x] CSRF protection (built into Auth.js)
- [x] Secure password hashing
- [x] HTTP-only cookies for sessions
- [x] Environment variable protection

## Testing the Authentication

### Manual Testing Checklist

1. **Registration Flow**
   - [ ] Visit `/register`
   - [ ] Test form validation (empty fields, invalid email, weak password)
   - [ ] Register with valid email/password
   - [ ] Verify redirect to login page

2. **Login Flow**
   - [ ] Visit `/login`
   - [ ] Test invalid credentials
   - [ ] Login with registered email/password
   - [ ] Verify redirect to dashboard

3. **OAuth Flow**
   - [ ] Click Google/GitHub login buttons
   - [ ] Complete OAuth authorization
   - [ ] Verify user creation and login
   - [ ] Check profile image display

4. **Route Protection**
   - [ ] Try accessing `/dashboard` without login (should redirect)
   - [ ] Try accessing `/profile` without login (should redirect)
   - [ ] Login and verify access to protected routes

5. **Navigation**
   - [ ] Check navigation changes based on auth state
   - [ ] Test mobile navigation menu
   - [ ] Verify logout functionality

6. **Dashboard & Profile**
   - [ ] Check user information display
   - [ ] Verify different data for OAuth vs email users
   - [ ] Test navigation between pages

## Production Deployment Notes

### Environment Variables
- Generate a strong `NEXTAUTH_SECRET`
- Update `NEXTAUTH_URL` to production domain
- Configure OAuth redirect URIs for production

### Database Migration
- Switch from SQLite to PostgreSQL for production
- Update `DATABASE_URL` in environment
- Run migrations: `npx prisma db push`

### Security Considerations
- Enable HTTPS in production
- Configure proper CORS settings
- Set up database backups
- Monitor authentication logs

## Troubleshooting

### Common Issues

1. **OAuth not working**
   - Check redirect URIs match exactly
   - Verify environment variables are set
   - Ensure OAuth apps are enabled

2. **Database errors**
   - Run `npx prisma generate` after schema changes
   - Check database file permissions
   - Verify DATABASE_URL format

3. **Session issues**
   - Clear browser cookies
   - Check NEXTAUTH_SECRET is set
   - Verify middleware configuration

### Development Tips

- Use browser dev tools to inspect network requests
- Check server logs for authentication errors
- Test in incognito mode to avoid cached sessions
- Use `console.log(session)` to debug session data

## Next Steps

Future enhancements could include:
- Password reset functionality
- Email verification
- Two-factor authentication
- User profile editing
- Account deletion
- Social login with additional providers