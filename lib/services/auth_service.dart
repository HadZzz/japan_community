import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _baseUrl = 'https://api.japanese-community.com'; // Replace with actual API
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // For demo purposes, we'll use mock authentication
  static const bool _useMockAuth = true;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Store token
  Future<bool> storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      return false;
    }
  }

  // Remove token
  Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      return false;
    }
  }

  // Store user data
  Future<bool> storeUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      return false;
    }
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Remove user data
  Future<bool> removeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userKey);
    } catch (e) {
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Login
  Future<AuthResponse> login(AuthRequest request) async {
    if (_useMockAuth) {
      return _mockLogin(request);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.token != null) {
          await storeToken(authResponse.token!);
          if (authResponse.user != null) {
            await storeUser(authResponse.user!);
          }
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Login failed',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Register
  Future<AuthResponse> register(RegisterRequest request) async {
    if (_useMockAuth) {
      return _mockRegister(request);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.token != null) {
          await storeToken(authResponse.token!);
          if (authResponse.user != null) {
            await storeUser(authResponse.user!);
          }
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Registration failed',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      // Call logout API if needed
      if (!_useMockAuth) {
        final token = await getToken();
        if (token != null) {
          await http.post(
            Uri.parse('$_baseUrl/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        }
      }

      // Clear local storage
      await removeToken();
      await removeUser();
      return true;
    } catch (e) {
      // Even if API call fails, clear local storage
      await removeToken();
      await removeUser();
      return true;
    }
  }

  // Verify token (check if still valid)
  Future<bool> verifyToken() async {
    if (_useMockAuth) {
      return await isAuthenticated();
    }

    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Token is invalid, remove it
        await removeToken();
        await removeUser();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Mock authentication for demo purposes
  Future<AuthResponse> _mockLogin(AuthRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation
    if (request.email.isEmpty || request.password.isEmpty) {
      return AuthResponse(
        success: false,
        message: 'Email and password are required',
        errors: {
          'email': request.email.isEmpty ? ['Email is required'] : null,
          'password': request.password.isEmpty ? ['Password is required'] : null,
        },
      );
    }

    if (!request.email.contains('@')) {
      return AuthResponse(
        success: false,
        message: 'Invalid email format',
        errors: {
          'email': ['Please enter a valid email address'],
        },
      );
    }

    if (request.password.length < 6) {
      return AuthResponse(
        success: false,
        message: 'Password too short',
        errors: {
          'password': ['Password must be at least 6 characters'],
        },
      );
    }

    // Mock successful login
    final user = User(
      id: '1',
      name: 'Tanaka Hiroshi',
      email: request.email,
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      bio: 'Japanese language enthusiast living in Tokyo. Love anime, manga, and traditional culture!',
      location: 'Tokyo, Japan',
      interests: ['Anime', 'Manga', 'Traditional Culture', 'Language Exchange'],
      joinedDate: DateTime.now().subtract(const Duration(days: 30)),
      japaneseLevel: 'Native',
    );

    const token = 'mock_jwt_token_12345';
    
    await storeToken(token);
    await storeUser(user);

    return AuthResponse(
      success: true,
      token: token,
      user: user,
      message: 'Login successful',
    );
  }

  Future<AuthResponse> _mockRegister(RegisterRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validation
    Map<String, List<String>> errors = {};

    if (request.name.isEmpty) {
      errors['name'] = ['Name is required'];
    } else if (request.name.length < 2) {
      errors['name'] = ['Name must be at least 2 characters'];
    }

    if (request.email.isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (!request.email.contains('@')) {
      errors['email'] = ['Please enter a valid email address'];
    }

    if (request.password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else if (request.password.length < 6) {
      errors['password'] = ['Password must be at least 6 characters'];
    }

    if (request.confirmPassword != request.password) {
      errors['confirmPassword'] = ['Passwords do not match'];
    }

    if (errors.isNotEmpty) {
      return AuthResponse(
        success: false,
        message: 'Validation failed',
        errors: errors,
      );
    }

    // Mock successful registration
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: request.name,
      email: request.email,
      profileImageUrl: 'https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}',
      bio: 'New member of the Japanese Community!',
      location: 'Unknown',
      interests: [],
      joinedDate: DateTime.now(),
      japaneseLevel: 'Beginner',
    );

    const token = 'mock_jwt_token_new_user';
    
    await storeToken(token);
    await storeUser(user);

    return AuthResponse(
      success: true,
      token: token,
      user: user,
      message: 'Registration successful',
    );
  }
}