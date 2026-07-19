import 'package:flutter/material.dart';

class AppColors {
  static const paper = Color(0xFFF0E0BE);
  static const paperDeep = Color(0xFFE7D2A6);
  static const card = Color(0xFFFBF3DC);
  static const ink = Color(0xFF2C2118);
  static const red = Color(0xFFD24B4E);
  static const redDark = Color(0xFFB23A3D);
  static const mustard = Color(0xFFE9A62C);
  static const teal = Color(0xFF2E9C8B);
  static const sepia = Color(0xFF9A7B54);
}

TextStyle baloo(double size, int wght, {Color? color, double? spacing}) {
  return TextStyle(
    fontFamily: 'Baloo2',
    fontSize: size,
    height: 1.08,
    letterSpacing: spacing,
    color: color ?? AppColors.ink,
    fontVariations: [FontVariation('wght', wght.toDouble())],
  );
}

class AppTheme {
  static const _radius = 20.0;
  static const _side = BorderSide(color: AppColors.ink, width: 2.5);

  static ThemeData get theme {
    const scheme = ColorScheme.light(
      primary: AppColors.red,
      onPrimary: AppColors.card,
      secondary: AppColors.mustard,
      onSecondary: AppColors.ink,
      tertiary: AppColors.teal,
      onTertiary: AppColors.card,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.paperDeep,
      outline: AppColors.ink,
      error: AppColors.redDark,
    );

    final body = TextStyle(fontFamily: 'Nunito', color: AppColors.ink);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: 'Nunito',
      textTheme: TextTheme(
        displaySmall: baloo(30, 800),
        headlineMedium: baloo(26, 800),
        headlineSmall: baloo(22, 800),
        titleLarge: baloo(20, 700),
        titleMedium: baloo(17, 700),
        titleSmall: baloo(15, 700),
        bodyLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        bodySmall: body.copyWith(fontSize: 12.5, color: AppColors.sepia, fontWeight: FontWeight.w700),
        labelLarge: baloo(15, 800),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baloo(24, 800),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 74,
        indicatorColor: AppColors.red,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: _side,
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? AppColors.card
                : AppColors.sepia,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => baloo(11, 700,
              color: s.contains(WidgetState.selected)
                  ? AppColors.redDark
                  : AppColors.sepia),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: _side,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.card,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: baloo(16, 800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: _side,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.redDark,
          textStyle: baloo(15, 700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.red,
        foregroundColor: AppColors.card,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: _side,
        ),
        extendedTextStyle: baloo(16, 800),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        labelStyle: body.copyWith(color: AppColors.sepia, fontWeight: FontWeight.w700),
        floatingLabelStyle: baloo(14, 700, color: AppColors.redDark),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: _side,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: _side,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 3),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 0,
        titleTextStyle: baloo(20, 800),
        contentTextStyle: body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: _side,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.teal : AppColors.card),
        checkColor: const WidgetStatePropertyAll(AppColors.card),
        side: _side,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.red,
        linearTrackColor: AppColors.paperDeep,
        circularTrackColor: AppColors.paperDeep,
      ),
      dividerTheme: const DividerThemeData(color: Color(0x332C2118), thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.ink,
        textColor: AppColors.ink,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: baloo(14, 700, color: AppColors.card),
      ),
    );
  }
}
