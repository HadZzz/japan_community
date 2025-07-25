import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Ganti dengan URL dan Key dari project Supabase Anda
  // Dapatkan dari: Supabase Dashboard > Settings > API
  
  static const String supabaseUrl = 'https://khyrkgquyyhyaabjwozt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoeXJrZ3F1eXloeWFhYmp3b3p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0MzM0NTMsImV4cCI6MjA2OTAwOTQ1M30.Ap_9Xfgs4JsXvV3CpX5wwc-eHOVsbJJ7lBj2Ii3Dp5g';
  
  // Demo configuration untuk testing (akan diganti dengan real config)
  static const String demoSupabaseUrl = 'https://demo.supabase.co';
  static const String demoSupabaseAnonKey = 'demo-key';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl.contains('your-project') ? demoSupabaseUrl : supabaseUrl,
      anonKey: supabaseAnonKey.contains('your-anon-key') ? demoSupabaseAnonKey : supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static bool get isConfigured => 
      !supabaseUrl.contains('your-project') && 
      !supabaseAnonKey.contains('your-anon-key');
}