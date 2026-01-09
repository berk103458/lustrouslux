import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LustrousTheme {
  // Color Palette
  static const Color midnightBlack = Color(0xFF000000);
  static const Color lustrousGold = Color(0xFFD4AF37);
  static const Color slateGray = Color(0xFF707070);
  static const Color softWhite = Color(0xFFF5F5F5);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: midnightBlack,
    primaryColor: lustrousGold,
    colorScheme: const ColorScheme.dark(
      primary: lustrousGold,
      secondary: lustrousGold,
      surface: midnightBlack,
      background: midnightBlack,
      onPrimary: midnightBlack,
      onSurface: softWhite,
      error: Color(0xFFCF6679),
    ),
    
    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lustrousGold,
        letterSpacing: 1.2,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: softWhite,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: softWhite,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: slateGray,
      ),
      labelLarge: GoogleFonts.lato( // Button text
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: midnightBlack,
        letterSpacing: 1.0,
      ),
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: midnightBlack,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        color: lustrousGold,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: lustrousGold),
    ),

    // ElevatedButton Theme (Gold Buttons)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lustrousGold,
        foregroundColor: midnightBlack,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0), // Sharp, minimalist corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),

    // Input Decoration Theme (Minimalist Inputs)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: slateGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: slateGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: lustrousGold),
      ),
      labelStyle: const TextStyle(color: slateGray),
      hintStyle: TextStyle(color: slateGray.withOpacity(0.5)),
    ),
  );
}
