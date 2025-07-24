import 'package:flutter/material.dart';

class AppColors {
  // Minimalist color palette inspired by Japanese aesthetics
  
  // Primary colors - Soft, muted tones
  static const Color primary = Color(0xFF2C3E50);        // Deep blue-grey (main accent)
  static const Color primaryLight = Color(0xFF34495E);   // Lighter blue-grey
  static const Color primaryDark = Color(0xFF1A252F);    // Darker blue-grey
  
  // Secondary colors - Warm, subtle accents
  static const Color secondary = Color(0xFFE8B4B8);      // Soft pink (Japanese influence)
  static const Color secondaryLight = Color(0xFFF5E6E8); // Very light pink
  static const Color secondaryDark = Color(0xFFD4989C);  // Muted pink
  
  // Neutral colors - Clean, minimal
  static const Color surface = Color(0xFFFAFAFA);        // Off-white background
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light grey surface
  static const Color outline = Color(0xFFE0E0E0);        // Subtle borders
  static const Color outlineVariant = Color(0xFFF0F0F0); // Very light borders
  
  // Text colors - High contrast, readable
  static const Color onPrimary = Color(0xFFFFFFFF);      // White on primary
  static const Color onSurface = Color(0xFF1A1A1A);      // Dark text on light
  static const Color onSurfaceVariant = Color(0xFF666666); // Medium grey text
  static const Color onSecondary = Color(0xFF2C3E50);    // Dark text on secondary
  
  // Status colors - Minimal, functional
  static const Color success = Color(0xFF27AE60);        // Soft green
  static const Color warning = Color(0xFFF39C12);        // Soft orange
  static const Color error = Color(0xFFE74C3C);          // Soft red
  static const Color info = Color(0xFF3498DB);           // Soft blue
  
  // Category colors - Muted, harmonious
  static const Color categoryDiscussion = Color(0xFF5DADE2);  // Soft blue
  static const Color categoryQuestion = Color(0xFFF7DC6F);    // Soft yellow
  static const Color categoryEvent = Color(0xFF82E0AA);       // Soft green
  static const Color categoryPhotos = Color(0xFFD7BFDC);      // Soft purple
  static const Color categoryNews = Color(0xFFFFAB91);        // Soft orange
  
  // Event category colors
  static const Color eventLanguageExchange = Color(0xFF85C1E9); // Light blue
  static const Color eventCultural = Color(0xFFD2B4DE);        // Light purple
  static const Color eventSocial = Color(0xFF85E085);          // Light green
  static const Color eventEducational = Color(0xFFFDD835);     // Light amber
  
  // Shadow and elevation
  static const Color shadow = Color(0x1A000000);         // 10% black shadow
  static const Color shadowLight = Color(0x0D000000);    // 5% black shadow
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
        onError: Colors.white,
      ),
      
      // Typography
      fontFamily: 'Inter', // More modern than Roboto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          color: AppColors.onSurface,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          letterSpacing: -0.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowLight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.secondaryLight,
        labelStyle: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}