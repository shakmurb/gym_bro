import 'package:material_ui/material_ui.dart';

class GymBroColors {
  static const background = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const elevatedSurface = Color(0xFF1F242C);
  static const border = Color(0xFF30363D);
  static const green = Color(0xFF39FF14);
  static const mutedGreen = Color(0xFFBACCB0);
  static const text = Color(0xFFDEE2EC);
  static const red = Color(0xFFE11D48);
  static const darkText = Color(0xFF0D1117);
}

ThemeData buildGymBroTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GymBroColors.green,
      brightness: Brightness.dark,
    ).copyWith(
      primary: GymBroColors.green,
      onPrimary: GymBroColors.darkText,
      secondary: GymBroColors.mutedGreen,
      surface: GymBroColors.background,
      onSurface: GymBroColors.text,
      outline: GymBroColors.border,
    ),
    scaffoldBackgroundColor: GymBroColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: GymBroColors.background,
      foregroundColor: GymBroColors.text,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GymBroColors.green,
        foregroundColor: GymBroColors.darkText,
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GymBroColors.elevatedSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GymBroColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GymBroColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GymBroColors.green),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF090F15),
      indicatorColor: Colors.transparent,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? GymBroColors.green
              : GymBroColors.mutedGreen,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: GymBroColors.text,
      displayColor: GymBroColors.text,
    ),
  );
}
