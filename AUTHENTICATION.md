# Authentication System Documentation

## Overview
Complete authentication system implementation for the Japanese Community app with secure token storage, session management, and comprehensive error handling.

## Architecture

### 1. Authentication Models (`lib/models/auth_models.dart`)
- **AuthRequest**: Login credentials
- **RegisterRequest**: Registration data with validation
- **AuthResponse**: API response wrapper
- **AuthError**: Error handling model
- **AuthStatus**: Authentication state enum

### 2. Authentication Service (`lib/services/auth_service.dart`)
- **Singleton Pattern**: Single instance across the app
- **Token Management**: Secure storage using SharedPreferences
- **Session Persistence**: User data caching
- **Mock Implementation**: Demo authentication for testing
- **API Ready**: Structure ready for real backend integration

#### Key Features:
- ✅ Token storage and retrieval
- ✅ User data persistence
- ✅ Session validation
- ✅ Automatic logout on token expiry
- ✅ Network error handling
- ✅ Mock authentication for demo

### 3. User Provider (`lib/providers/user_provider.dart`)
- **State Management**: Complete authentication flow
- **Error Handling**: Field-specific and general errors
- **Loading States**: UI feedback during operations
- **Auto-initialization**: Check existing sessions on app start

#### Authentication States:
- `initial`: App starting up
- `loading`: Processing authentication
- `authenticated`: User logged in
- `unauthenticated`: User not logged in
- `error`: Authentication error occurred

### 4. UI Components

#### Login Screen (`lib/screens/login_screen.dart`)
- **Form Validation**: Email and password validation
- **Error Display**: Field-specific error messages
- **Loading States**: Button loading indicators
- **Demo Login**: Quick demo access
- **Navigation**: Link to registration

#### Register Screen (`lib/screens/register_screen.dart`)
- **Complete Form**: Name, email, password, confirm password
- **Validation**: Client-side validation with server-side ready
- **Terms Agreement**: Terms of service checkbox
- **Error Handling**: Comprehensive error display
- **Navigation**: Link back to login

## Authentication Flow

### 1. App Initialization
```
App Start → UserProvider.initializeAuth() → Check stored token → Verify token validity → Set auth state
```

### 2. Login Process
```
User Input → Validation → AuthService.login() → Store token & user → Update state → Navigate to app
```

### 3. Registration Process
```
User Input → Validation → AuthService.register() → Store token & user → Update state → Navigate to app
```

### 4. Logout Process
```
User Action → AuthService.logout() → Clear storage → Update state → Navigate to login
```

## Security Features

### 1. Token Management
- **Secure Storage**: SharedPreferences for token storage
- **Auto-expiry**: Token validation on app start
- **Cleanup**: Automatic token removal on logout

### 2. Input Validation
- **Client-side**: Immediate feedback
- **Server-side Ready**: Backend validation structure
- **Error Mapping**: Field-specific error display

### 3. Session Management
- **Persistent Login**: Remember user sessions
- **Auto-logout**: Invalid token handling
- **State Consistency**: Synchronized auth state

## Mock Authentication

For demo purposes, the app includes mock authentication:

### Demo Credentials
- **Email**: Any valid email format
- **Password**: Minimum 6 characters

### Mock Validation Rules
- Email must contain '@'
- Password minimum 6 characters
- Name minimum 2 characters (registration)
- Passwords must match (registration)

## Integration Points

### 1. Navigation
- **Protected Routes**: Automatic redirect to login
- **Auth Guards**: Route-level authentication
- **Deep Linking**: Maintain navigation state

### 2. API Integration
To connect to real backend:

1. Update `AuthService._useMockAuth = false`
2. Set correct `_baseUrl`
3. Configure API endpoints:
   - `POST /auth/login`
   - `POST /auth/register`
   - `POST /auth/logout`
   - `GET /auth/verify`

### 3. Error Handling
- **Network Errors**: Connection issues
- **Validation Errors**: Field-specific errors
- **Server Errors**: API error responses
- **Token Errors**: Invalid/expired tokens

## Usage Examples

### Login
```dart
// In UI component
await context.read<UserProvider>().login(email, password);

// Check result
if (userProvider.isLoggedIn) {
  // Success - navigation handled automatically
} else {
  // Show error - userProvider.error or userProvider.getFieldError('email')
}
```

### Registration
```dart
await context.read<UserProvider>().register(
  name: name,
  email: email,
  password: password,
  confirmPassword: confirmPassword,
);
```

### Logout
```dart
await context.read<UserProvider>().logout();
// Navigation to login handled automatically
```

### Check Authentication Status
```dart
final userProvider = context.watch<UserProvider>();

if (userProvider.isLoggedIn) {
  // Show authenticated content
} else if (userProvider.isLoading) {
  // Show loading
} else {
  // Show login screen
}
```

## File Structure
```
lib/
├── models/
│   ├── auth_models.dart     # Authentication data models
│   └── models.dart          # User and other models
├── services/
│   └── auth_service.dart    # Authentication service
├── providers/
│   └── user_provider.dart   # Authentication state management
├── screens/
│   ├── login_screen.dart    # Login UI
│   └── register_screen.dart # Registration UI
└── main.dart               # Router with auth guards
```

## Testing

### Manual Testing
1. **Login Flow**: Use demo credentials
2. **Registration Flow**: Create new account
3. **Session Persistence**: Close/reopen app
4. **Logout Flow**: Logout and verify redirect
5. **Error Handling**: Invalid credentials, network errors

### Automated Testing
Ready for unit tests on:
- AuthService methods
- UserProvider state changes
- Form validation logic
- Error handling scenarios

## Future Enhancements

### Security
- [ ] Biometric authentication
- [ ] Two-factor authentication
- [ ] Password strength meter
- [ ] Account lockout protection

### Features
- [ ] Social login (Google, Apple)
- [ ] Password reset flow
- [ ] Email verification
- [ ] Profile completion wizard

### UX Improvements
- [ ] Remember me functionality
- [ ] Auto-fill support
- [ ] Offline authentication
- [ ] Progressive registration

## Troubleshooting

### Common Issues
1. **Token not persisting**: Check SharedPreferences permissions
2. **Navigation loops**: Verify router redirect logic
3. **State not updating**: Ensure notifyListeners() calls
4. **Form validation**: Check validation rules and error display

### Debug Tools
- Use `userProvider.authStatus` to check current state
- Monitor `userProvider.error` for error messages
- Check `userProvider.fieldErrors` for validation errors
- Verify token storage with `AuthService().getToken()`

---

**Status**: ✅ Complete Authentication System
**Next Steps**: Backend Integration or Real-time Chat Implementation