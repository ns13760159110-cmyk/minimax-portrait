import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // 统一圆角半径
  static const double radius     = 16.0;
  static const double radiusCard = 16.0;
  static const double radiusBtn  = 14.0;

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary:       AppColors.primaryLight,
            secondary:     AppColors.primaryLight,
            surface:       AppColors.surfaceDark,
            onSurface:     AppColors.textPri_D,
            onSurfaceVariant: AppColors.textSec_D,
          )
        : const ColorScheme.light(
            primary:       AppColors.primary,
            secondary:     AppColors.primary,
            surface:       AppColors.surfaceLight,
            onSurface:     AppColors.textPri_L,
            onSurfaceVariant: AppColors.textSec_L,
          );

    final bg     = isDark ? AppColors.bgDark     : AppColors.bgLight;
    final card   = isDark ? AppColors.cardDark   : AppColors.cardLight;
    final div    = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final txtPri = isDark ? AppColors.textPri_D  : AppColors.textPri_L;
    final txtSec = isDark ? AppColors.textSec_D  : AppColors.textSec_L;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: card,
      dividerColor: div,
      splashColor: AppColors.primary.withOpacity(0.08),
      highlightColor: AppColors.primary.withOpacity(0.04),

      // ── AppBar ──────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: txtPri,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: txtPri,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: txtPri, size: 22),
      ),

      // ── Card ────────────────────────────────────
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),

      // ── Input ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.bgLight,
        hintStyle: TextStyle(color: txtSec.withOpacity(0.55), fontSize: 14),
        labelStyle: TextStyle(color: txtSec),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: div),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Bottom Nav ───────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        selectedItemColor: isDark ? AppColors.primaryLight : AppColors.primary,
        unselectedItemColor: txtSec,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ── FAB ─────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
      ),

      // ── FilledButton ─────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusBtn)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      // ── OutlinedButton ───────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          side: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusBtn)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ───────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusBtn)),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Chip ────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.bgLight,
        labelStyle: TextStyle(color: txtPri, fontSize: 13),
        side: BorderSide(color: div),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),

      // ── Dialog ───────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        titleTextStyle: TextStyle(
            color: txtPri, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: txtSec, fontSize: 14, height: 1.5),
      ),

      // ── BottomSheet ──────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: div,
        dragHandleSize: const Size(36, 4),
      ),

      // ── SnackBar ─────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? AppColors.cardDark
            : const Color(0xFF1A1B2E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
      ),

      // ── Page transitions ─────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
