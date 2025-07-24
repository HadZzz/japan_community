import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  AuthStatus _authStatus = AuthStatus.initial;
  String? _error;
  Map<String, dynamic>? _fieldErrors;

  User? get currentUser => _currentUser;
  AuthStatus get authStatus => _authStatus;
  String? get error => _error;
  Map<String, dynamic>? get fieldErrors => _fieldErrors;
  bool get isLoading => _authStatus == AuthStatus.loading;
  bool get isLoggedIn => _authStatus == AuthStatus.authenticated && _currentUser != null;

  // Initialize authentication state
  Future<void> initializeAuth() async {
    _authStatus = AuthStatus.loading;
    notifyListeners();

    try {
      // Check if user is already authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        // Verify token is still valid
        final isValid = await _authService.verifyToken();
        
        if (isValid) {
          // Get stored user data
          final user = await _authService.getStoredUser();
          if (user != null) {
            _currentUser = user;
            _authStatus = AuthStatus.authenticated;
          } else {
            _authStatus = AuthStatus.unauthenticated;
          }
        } else {
          _authStatus = AuthStatus.unauthenticated;
        }
      } else {
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }

    notifyListeners();
  }

  // Login
  Future<void> login(String email, String password) async {
    _authStatus = AuthStatus.loading;
    _error = null;
    _fieldErrors = null;
    notifyListeners();

    try {
      final request = AuthRequest(email: email, password: password);
      final response = await _authService.login(request);

      if (response.success) {
        _currentUser = response.user;
        _authStatus = AuthStatus.authenticated;
        _error = null;
        _fieldErrors = null;
      } else {
        _authStatus = AuthStatus.unauthenticated;
        _error = response.message;
        _fieldErrors = response.errors;
      }
    } catch (e) {
      _authStatus = AuthStatus.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _authStatus = AuthStatus.loading;
    _error = null;
    _fieldErrors = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      final response = await _authService.register(request);

      if (response.success) {
        _currentUser = response.user;
        _authStatus = AuthStatus.authenticated;
        _error = null;
        _fieldErrors = null;
      } else {
        _authStatus = AuthStatus.unauthenticated;
        _error = response.message;
        _fieldErrors = response.errors;
      }
    } catch (e) {
      _authStatus = AuthStatus.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _authStatus = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
      _error = null;
      _fieldErrors = null;
    } catch (e) {
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }

    notifyListeners();
  }

  // Update profile
  Future<void> updateProfile(User updatedUser) async {
    _authStatus = AuthStatus.loading;
    notifyListeners();

    try {
      // In a real app, this would call an API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update local storage
      await _authService.storeUser(updatedUser);
      _currentUser = updatedUser;
      _authStatus = AuthStatus.authenticated;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }

    notifyListeners();
  }

  // Clear errors
  void clearErrors() {
    _error = null;
    _fieldErrors = null;
    notifyListeners();
  }

  // Get field error
  String? getFieldError(String field) {
    if (_fieldErrors == null) return null;
    final errors = _fieldErrors![field];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    return null;
  }

  // Auto-login for demo purposes (deprecated - use initializeAuth instead)
  @deprecated
  void autoLogin() {
    initializeAuth();
  }
}