# Authentication Test Plan

This document outlines comprehensive testing procedures for the Auth.js authentication implementation.

## Test Environment Setup

### Prerequisites
- Development server running (`npm run dev`)
- Clean browser state (clear cookies/localStorage)
- Valid OAuth applications configured (optional for manual testing)
- Database accessible and migrations applied

### Test Data
- **Valid Email**: `test@example.com`
- **Valid Password**: `password123`
- **Invalid Email**: `invalid-email`
- **Weak Password**: `123`

## Test Categories

## 1. Registration Testing

### Test Case 1.1: Valid Registration
**Objective**: Verify successful user registration with valid data

**Steps**:
1. Navigate to `/register`
2. Fill form with valid data:
   - Name: "Test User"
   - Email: "test@example.com"
   - Password: "password123"
   - Confirm Password: "password123"
3. Click "Create account"

**Expected Results**:
- ✅ Form submits successfully
- ✅ Success message displays
- ✅ Redirect to login page after 2 seconds
- ✅ User created in database
- ✅ Password is hashed in database

### Test Case 1.2: Registration Validation
**Objective**: Test form validation rules

**Test Scenarios**:
| Field | Input | Expected Error |
|-------|-------|----------------|
| Name | Empty | "Name is required" |
| Email | Empty | "Email is required" |
| Email | "invalid" | "Please enter a valid email address" |
| Password | Empty | "Password is required" |
| Password | "123" | "Password must be at least 6 characters long" |
| Confirm | "different" | "Passwords do not match" |

### Test Case 1.3: Duplicate Email Registration
**Objective**: Verify duplicate email handling

**Steps**:
1. Register user with `test@example.com`
2. Attempt to register again with same email

**Expected Results**:
- ✅ Error message: "User with this email already exists"
- ✅ No duplicate user created

## 2. Login Testing

### Test Case 2.1: Valid Email/Password Login
**Objective**: Verify successful login with registered credentials

**Steps**:
1. Navigate to `/login`
2. Enter registered email and password
3. Click "Sign in"

**Expected Results**:
- ✅ Login successful
- ✅ Redirect to `/dashboard`
- ✅ User session created
- ✅ Navigation shows authenticated state

### Test Case 2.2: Invalid Credentials
**Objective**: Test login with wrong credentials

**Test Scenarios**:
| Email | Password | Expected Error |
|-------|----------|----------------|
| "wrong@email.com" | "password123" | "Invalid email or password" |
| "test@example.com" | "wrongpassword" | "Invalid email or password" |
| Empty | "password123" | Browser validation |
| "test@example.com" | Empty | Browser validation |

### Test Case 2.3: OAuth Login (Google)
**Objective**: Test Google OAuth authentication

**Steps**:
1. Navigate to `/login`
2. Click "Google" button
3. Complete Google OAuth flow
4. Return to application

**Expected Results**:
- ✅ Redirect to Google OAuth
- ✅ OAuth flow completes
- ✅ User account created/linked
- ✅ Redirect to `/dashboard`
- ✅ Profile image and name imported

### Test Case 2.4: OAuth Login (GitHub)
**Objective**: Test GitHub OAuth authentication

**Steps**:
1. Navigate to `/login`
2. Click "GitHub" button
3. Complete GitHub OAuth flow
4. Return to application

**Expected Results**:
- ✅ Redirect to GitHub OAuth
- ✅ OAuth flow completes
- ✅ User account created/linked
- ✅ Redirect to `/dashboard`
- ✅ Profile image and name imported

## 3. Route Protection Testing

### Test Case 3.1: Unauthenticated Access
**Objective**: Verify protection of authenticated routes

**Test Scenarios**:
| Route | Expected Behavior |
|-------|-------------------|
| `/dashboard` | Redirect to `/login?callbackUrl=/dashboard` |
| `/profile` | Redirect to `/login?callbackUrl=/profile` |
| `/login` | Allow access |
| `/register` | Allow access |
| `/` | Allow access |
| `/about` | Allow access |
| `/contact` | Allow access |

### Test Case 3.2: Authenticated Route Access
**Objective**: Verify authenticated users can access protected routes

**Steps**:
1. Login with valid credentials
2. Navigate to protected routes

**Expected Results**:
- ✅ `/dashboard` accessible
- ✅ `/profile` accessible
- ✅ User data displays correctly

### Test Case 3.3: Auth Route Redirect
**Objective**: Verify authenticated users are redirected away from auth pages

**Steps**:
1. Login with valid credentials
2. Try to navigate to `/login` or `/register`

**Expected Results**:
- ✅ Redirect to `/dashboard`
- ✅ Cannot access auth pages while logged in

## 4. Session Management Testing

### Test Case 4.1: Session Persistence
**Objective**: Verify session persists across browser refresh

**Steps**:
1. Login successfully
2. Refresh the browser
3. Navigate to protected routes

**Expected Results**:
- ✅ User remains logged in
- ✅ No re-authentication required
- ✅ User data still accessible

### Test Case 4.2: Logout Functionality
**Objective**: Test logout process

**Steps**:
1. Login successfully
2. Click "Sign Out" in navigation
3. Try accessing protected routes

**Expected Results**:
- ✅ Session cleared
- ✅ Redirect to home page
- ✅ Navigation shows unauthenticated state
- ✅ Protected routes require re-authentication

## 5. User Interface Testing

### Test Case 5.1: Navigation State
**Objective**: Verify navigation changes based on authentication state

**Authentication States to Test**:
- **Unauthenticated**: Shows "Sign In" and "Sign Up" buttons
- **Authenticated**: Shows user info, "Dashboard" link, and "Sign Out"
- **Loading**: Shows loading spinner

### Test Case 5.2: Responsive Design
**Objective**: Test authentication UI on different screen sizes

**Breakpoints to Test**:
- Desktop (1200px+)
- Tablet (768px - 1199px)
- Mobile (< 768px)

**Features to Verify**:
- ✅ Login/register forms responsive
- ✅ Mobile navigation menu works
- ✅ OAuth buttons properly sized
- ✅ Dashboard layouts adapt

### Test Case 5.3: Loading States
**Objective**: Verify loading indicators work properly

**Loading States to Test**:
- Registration form submission
- Login form submission
- OAuth redirect flow
- Navigation authentication check

## 6. Dashboard & Profile Testing

### Test Case 6.1: Dashboard Content
**Objective**: Verify dashboard displays correct user information

**For Email/Password Users**:
- ✅ Name displays correctly
- ✅ Email shows
- ✅ Login method shows "Email"
- ✅ No profile image (default avatar)

**For OAuth Users**:
- ✅ Name from OAuth provider
- ✅ Email from OAuth provider
- ✅ Login method shows "OAuth"
- ✅ Profile image from provider

### Test Case 6.2: Profile Page
**Objective**: Test profile information display

**Steps**:
1. Navigate to `/profile`
2. Verify all user information

**Expected Results**:
- ✅ All user data displayed
- ✅ Account security status shown
- ✅ Navigation between dashboard/profile works

## 7. Error Handling Testing

### Test Case 7.1: Network Errors
**Objective**: Test behavior with network issues

**Scenarios**:
- Registration with server error
- Login with API unavailable
- OAuth callback failures

### Test Case 7.2: Database Errors
**Objective**: Test database connectivity issues

**Scenarios**:
- Database unavailable during registration
- Session lookup failures
- User creation errors

## 8. Security Testing

### Test Case 8.1: Password Security
**Objective**: Verify password handling security

**Checks**:
- ✅ Passwords are hashed in database
- ✅ Original passwords not stored
- ✅ Different users have different hashes
- ✅ Same password produces different hashes (salt)

### Test Case 8.2: Session Security
**Objective**: Test session token security

**Checks**:
- ✅ Sessions use HTTP-only cookies
- ✅ Session tokens are not accessible via JavaScript
- ✅ Sessions expire appropriately
- ✅ CSRF protection is active

### Test Case 8.3: SQL Injection Protection
**Objective**: Test protection against SQL injection

**Test Inputs**:
- `'; DROP TABLE users; --` in email field
- `<script>alert('xss')</script>` in name field
- SQL injection attempts in all form fields

**Expected Results**:
- ✅ All inputs properly sanitized
- ✅ No database corruption
- ✅ No script execution

## Test Execution

### Automated Testing (Future)
Consider implementing automated tests with:
- **Unit Tests**: Individual component testing
- **Integration Tests**: API endpoint testing
- **E2E Tests**: Full user flow testing with Playwright/Cypress

### Manual Testing Checklist

#### Pre-Test Setup
- [ ] Clear browser data
- [ ] Verify development server running
- [ ] Check database connection
- [ ] Confirm OAuth apps configured (if testing)

#### Core Authentication Flow
- [ ] Registration with email/password
- [ ] Login with email/password
- [ ] Google OAuth flow (if configured)
- [ ] GitHub OAuth flow (if configured)
- [ ] Route protection verification
- [ ] Logout functionality

#### Edge Cases
- [ ] Duplicate registration attempts
- [ ] Invalid form submissions
- [ ] Network error scenarios
- [ ] Browser refresh during auth flow
- [ ] Direct URL navigation while authenticated

#### UI/UX Testing
- [ ] Mobile responsive design
- [ ] Loading state indicators
- [ ] Error message display
- [ ] Success feedback
- [ ] Navigation state changes

### Test Results Documentation

For each test case, document:
- **Status**: Pass/Fail/Blocked
- **Actual Results**: What actually happened
- **Screenshots**: For UI-related issues
- **Browser/Device**: Testing environment
- **Notes**: Additional observations

## Success Criteria

The authentication system passes testing when:
- ✅ All core authentication flows work correctly
- ✅ Route protection functions properly
- ✅ User data is secure and properly handled
- ✅ UI is responsive and user-friendly
- ✅ Error scenarios are handled gracefully
- ✅ Security measures are in place and effective

## Known Limitations

Current implementation limitations to be aware of:
- OAuth requires valid API keys for full testing
- Email verification not implemented
- Password reset functionality not available
- Profile editing not implemented
- SQLite database (development only)
- No rate limiting on authentication attempts