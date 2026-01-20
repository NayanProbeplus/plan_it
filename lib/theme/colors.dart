// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ------------------------------
  // 🌕 Brand Colors
  // ------------------------------
  static const Color planItEmeraldGreen = Color.fromARGB(255, 38, 116, 62);
  static const Color plannerEmeraldGreen = Color(0xFF26743E);

  /// Messages gradient – light sky → steel → deep royal blue
  static const Color lightBlue = Color(0xFF89CFF0);
  static const Color steelBlue = Color(0xFF4682B4);
  static const Color royalBlue = Color(0xFF1E3A8A);

  static const List<Color> messageBlueGradient = [
    lightBlue,
    steelBlue,
    royalBlue,
  ];

  static const Color gold = Color(0xFFF4C430); // golden yellow
  static const Color metallicGold = Color(0xFFD4AF37); // deeper metallic tone
  static const Color charcoal = Color(0xFF2C2C2C);
  static const List<Color> appGoldGradient = [
    gold,
    metallicGold,
    charcoal,
  ];

  static const Color backgroundColor = Color.fromARGB(255, 241, 238, 221);

  // ------------------------------
  // 💫 Utility Colors
  // ------------------------------
  static const Color backgroundLight = Color(0xFFFFFFFF); // pure white
  static const Color backgroundOffWhite = Color(0xFFF8F8F8); // subtle off-white
  static const Color backgroundDark = Color(0xFF0B1020); // dark mode base

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF9E9E9E);

  static const Color accentPink = Color(0xFFFF80AB);
  static const Color accentPurple = Color(0xFFB39DDB);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFFB300);
  static const Color errorRed = Color(0xFFE53935);

  // ------------------------------
  // 🌈 Gradient Helpers (getters)
  // ------------------------------
  static LinearGradient get verticalGoldGradient => const LinearGradient(
        colors: appGoldGradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get horizontalBlueGradient => const LinearGradient(
        colors: messageBlueGradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // ============================================================
  // 🎨 Experimental Palettes (for To-Do / Habit / Notes / Finance)
  // ============================================================

  // 1️⃣ Calm Pastel – soft & friendly
  static const Color pastelBackground = Color(0xFFF6FBFF); // light blue-white
  static const Color pastelAccentBlue = Color(0xFF5AA9E6);
  static const Color pastelAccentOrange = Color(0xFFFFB86B);
  static const Color pastelTextDark = Color(0xFF0B2545);

  // 2️⃣ Vibrant Gradient – energetic purple → pink
  static const List<Color> vibrantGradient = [
    Color(0xFF6D5DF6),
    Color(0xFFFF5DA2),
  ];
  static const Color vibrantForeground = Color(0xFFFFFFFF);
  static const Color vibrantTextDark = Color(0xFF0B0B0B);

  // 3️⃣ Clean Dark – elegant & minimal
  static const Color darkBackground = Color(0xFF0F1724);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkAccentGreen = Color(0xFF22C55E);
  static const Color darkAccentBlue = Color(0xFF60A5FA);
  static const Color darkTextLight = Color(0xFFE6EEF8);

  // 4️⃣ Warm Minimal – calm beige + clay tones
  static const Color warmBackground = Color(0xFFFBF7F3);
  static const Color warmAccentClay = Color(0xFFD97706);
  static const Color warmAccentPurple = Color(0xFF7C3AED);
  static const Color warmTextDark = Color(0xFF2B2B2B);

  // 5️⃣ Fresh Mint – crisp, health/productivity feel
  static const Color mintBackground = Color(0xFFF0FFF7);
  static const Color mintTeal = Color(0xFF14B8A6);
  static const Color mintCyan = Color(0xFF06B6D4);
  static const Color mintTextDark = Color(0xFF073642);

  // ------------------------------
  // 🎨 Gradient Getters for New Palettes
  // ------------------------------
  static LinearGradient get vibrantGradientBg => const LinearGradient(
        colors: vibrantGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get mintGradient => const LinearGradient(
        colors: [mintTeal, mintCyan],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get darkAccentGradient => const LinearGradient(
        colors: [darkAccentBlue, darkAccentGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get warmGradient => const LinearGradient(
        colors: [warmAccentClay, warmAccentPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ------------------------------
  // 🔑 Theme seed colors (kept for compatibility)
  // ------------------------------
  static const Color seedColorLight = plannerEmeraldGreen;
  static const Color seedColorDark = darkAccentBlue;

  // Gradient border for Today filter chips
  static const List<Color> summaryGradient = [
    Color(0xFF6D5DF6), // purple
    Color(0xFFFF5DA2), // pink
  ];

  static LinearGradient get summaryGradientBorder => const LinearGradient(
        colors: summaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// Centralized Theme factory. Use AppTheme.light() and AppTheme.dark()
/// from your `app.dart` so all pages share the same ThemeData.
class AppTheme {
  AppTheme._();

  /// Build a LIGHT ColorScheme from your AppColors (manually).
  static ColorScheme _lightScheme() {
    // Start from the platform default light scheme and override fields you want
    const base = ColorScheme.light();

    return base.copyWith(
      // core surfaces
      surface: AppColors.backgroundOffWhite, // cards, surfaces
      onSurface: AppColors.textPrimary, // text on surfaces

      // primary / secondary
      primary: AppColors.plannerEmeraldGreen,
      onPrimary: Colors.white,
      secondary: AppColors.accentPurple,
      onSecondary: Colors.white,

      // tertiary (optional accent)
      tertiary: AppColors.accentPink,
      onTertiary: Colors.white,

      // error
      error: AppColors.errorRed,
      onError: Colors.white,

      // other helpful tokens
      outline: AppColors.textMuted,
      shadow: Colors.black,
      surfaceTint: Colors.transparent,
      // keep inverse values reasonable
      inverseSurface: const Color(0xFF121212),
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.plannerEmeraldGreen,
    );
  }

  /// Build a DARK ColorScheme from your AppColors (manually).
  static ColorScheme _darkScheme() {
    const base = ColorScheme.dark();

    return base.copyWith(
      // core surfaces
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextLight,

      // primary / secondary
      primary: AppColors.darkAccentBlue,
      onPrimary: Colors.black,
      secondary: AppColors.darkAccentGreen,
      onSecondary: Colors.black,

      // tertiary (optional accent)
      tertiary: AppColors.accentPink,
      onTertiary: Colors.white,

      // error
      error: AppColors.errorRed,
      onError: Colors.black,

      // other helpful tokens
      outline: AppColors.textMuted,
      shadow: Colors.black,
      surfaceTint: Colors.transparent,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: AppColors.plannerEmeraldGreen,
    );
  }

  /// Returns a light ThemeData configured for the app.
  static ThemeData light() {
    final cs = _lightScheme();

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),

      // Buttons / elevated actions
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: cs.primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // Text theme uses onBackground so colors adapt automatically
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),

      // Cards / surfaces
      cardTheme: CardTheme(
        color: cs.surface,
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),

      // small tweaks for consistent look
      iconTheme: IconThemeData(color: cs.onSurface),
      dividerColor: cs.outline,
    );
  }

  /// Returns a dark ThemeData configured for the app.
  static ThemeData dark() {
    final cs = _darkScheme();

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),

      // Buttons / elevated actions
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: cs.primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // Text theme uses onBackground so colors adapt automatically
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .white
          .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),

      // Cards / surfaces
      cardTheme: CardTheme(
        color: cs.surface,
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),

      // small tweaks for consistent look
      iconTheme: IconThemeData(color: cs.onBackground),
      dividerColor: cs.outline,
    );
  }

  /// Convenience: get a color scheme by brightness
  static ColorScheme colorScheme(Brightness brightness) {
    return brightness == Brightness.light ? _lightScheme() : _darkScheme();
  }
}
