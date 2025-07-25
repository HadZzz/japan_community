import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/auth_models.dart';
import '../models/models.dart';
import 'supabase_config.dart';

class SupabaseAuthService {
  final supabase.SupabaseClient _client = SupabaseConfig.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? bio,
    String? location,
    List<String>? interests,
    String japaneseLevel = 'Beginner',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'bio': bio,
          'location': location,
          'interests': interests ?? [],
          'japanese_level': japaneseLevel,
        },
      );

      if (response.user != null) {
        // Create user profile in users table
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'bio': bio,
          'location': location,
          'interests': interests ?? [],
          'japanese_level': japaneseLevel,
        });
      }

      return AuthResponse(
        success: response.user != null,
        message: response.user != null ? 'Account created successfully!' : 'Failed to create account',
        user: response.user != null ? await _getUserFromSupabaseUser(response.user!) : null,
      );
    } on supabase.AuthException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return AuthResponse(
        success: response.user != null,
        message: response.user != null ? 'Login successful!' : 'Login failed',
        user: response.user != null ? await _getUserFromSupabaseUser(response.user!) : null,
      );
    } on supabase.AuthException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Demo login (for testing)
  Future<AuthResponse> signInDemo() async {
    // Create demo user if not exists
    const demoEmail = 'demo@japanese-community.com';
    const demoPassword = 'password123';
    const demoName = 'Demo User';

    try {
      // Try to sign in first
      var response = await signIn(email: demoEmail, password: demoPassword);
      
      if (!response.success) {
        // If sign in fails, try to create demo account
        response = await signUp(
          email: demoEmail,
          password: demoPassword,
          name: demoName,
          bio: 'This is a demo account for testing the Japanese Community app.',
          location: 'Tokyo, Japan',
          interests: ['Japanese Culture', 'Language Exchange', 'Technology'],
          japaneseLevel: 'Advanced',
        );
      }

      return response;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Demo login failed: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user
  supabase.User? get currentUser => _client.auth.currentUser;

  // Auth state changes stream
  Stream<supabase.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Check if user is signed in
  bool get isSignedIn => _client.auth.currentUser != null;

  // Convert Supabase User to our User model
  Future<User?> _getUserFromSupabaseUser(supabase.User supabaseUser) async {
    try {
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .single();

      return User(
        id: supabaseUser.id,
        name: userProfile['name'] ?? supabaseUser.email ?? 'Unknown',
        email: supabaseUser.email ?? '',
        profileImageUrl: userProfile['profile_image_url'],
        bio: userProfile['bio'],
        location: userProfile['location'],
        interests: List<String>.from(userProfile['interests'] ?? []),
        japaneseLevel: userProfile['japanese_level'] ?? 'Beginner',
        joinedDate: DateTime.parse(userProfile['joined_date'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      // Fallback to basic user info if profile fetch fails
      return User(
        id: supabaseUser.id,
        name: supabaseUser.email ?? 'Unknown',
        email: supabaseUser.email ?? '',
        joinedDate: DateTime.now(),
      );
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? location,
    List<String>? interests,
    String? japaneseLevel,
    String? profileImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (interests != null) updates['interests'] = interests;
      if (japaneseLevel != null) updates['japanese_level'] = japaneseLevel;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;
      
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('users')
          .update(updates)
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Get user profile by ID
  Future<User?> getUserProfile(String userId) async {
    try {
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return User(
        id: userId,
        name: userProfile['name'],
        email: userProfile['email'],
        profileImageUrl: userProfile['profile_image_url'],
        bio: userProfile['bio'],
        location: userProfile['location'],
        interests: List<String>.from(userProfile['interests'] ?? []),
        japaneseLevel: userProfile['japanese_level'] ?? 'Beginner',
        joinedDate: DateTime.parse(userProfile['joined_date']),
      );
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}