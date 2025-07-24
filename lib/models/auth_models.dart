import '../models/models.dart';

class AuthRequest {
  final String email;
  final String password;

  AuthRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest extends AuthRequest {
  final String name;
  final String confirmPassword;

  RegisterRequest({
    required this.name,
    required super.email,
    required super.password,
    required this.confirmPassword,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
      errors: json['errors'],
    );
  }
}

class AuthError {
  final String message;
  final String? field;
  final int? statusCode;

  AuthError({
    required this.message,
    this.field,
    this.statusCode,
  });

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] ?? 'Unknown error occurred',
      field: json['field'],
      statusCode: json['statusCode'],
    );
  }
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}