import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';

/// Theme and styling utilities for consistent app theming
/// Provides color schemes, text styles, and UI component helpers
class ThemeUtils {
  
  // Core Colors
  static const Color primaryBlue = Color(0xFF1A237E);
  static const Color secondaryBlue = Color(0xFF3949AB);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color mysticPurple = Color(0xFF6A1B9A);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  
  // Prophet-specific colors
  static const Map<ProfetType, Color> prophetColors = {
    ProfetType.mistico: mysticPurple,
    ProfetType.caotico: Color(0xFF2E7D32),
    ProfetType.cinico: Color(0xFFE65100),
  };

  /// Gets theme color for specific prophet
  static Color getProphetColor(ProfetType prophet) {
    return prophetColors[prophet] ?? primaryBlue;
  }

  /// Gets theme color with opacity
  static Color getProphetColorWithOpacity(ProfetType prophet, double opacity) {
    return getProphetColor(prophet).withOpacity(opacity);
  }

  /// Creates gradient for prophet-specific backgrounds
  static LinearGradient getProphetGradient(ProfetType prophet) {
    final baseColor = getProphetColor(prophet);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.1),
        baseColor.withOpacity(0.3),
      ],
    );
  }

  /// Text Styles
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: primaryBlue,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: secondaryBlue,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Gets prophet-specific text style
  static TextStyle getProphetTextStyle(ProfetType prophet, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: getProphetColor(prophet),
    );
  }

  /// Card decoration with shadow and rounded corners
  static BoxDecoration getCardDecoration({
    Color? backgroundColor,
    double borderRadius = 12,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: hasShadow ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ] : null,
    );
  }

  /// Prophet-specific card decoration
  static BoxDecoration getProphetCardDecoration(ProfetType prophet, {
    double borderRadius = 12,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: getProphetColor(prophet).withOpacity(0.3),
        width: 2,
      ),
      boxShadow: hasShadow ? [
        BoxShadow(
          color: getProphetColor(prophet).withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ] : null,
    );
  }

  /// Button styles
  static ButtonStyle getPrimaryButtonStyle({
    Color? backgroundColor,
    double borderRadius = 8,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 2,
    );
  }

  static ButtonStyle getSecondaryButtonStyle({
    Color? borderColor,
    double borderRadius = 8,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: borderColor ?? primaryBlue,
      side: BorderSide(color: borderColor ?? primaryBlue),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static ButtonStyle getProphetButtonStyle(ProfetType prophet, {
    double borderRadius = 8,
  }) {
    final color = getProphetColor(prophet);
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 2,
    );
  }

  /// Input field decoration
  static InputDecoration getInputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? borderColor,
    bool isError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isError ? Colors.red : (borderColor ?? Colors.grey),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor ?? Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor ?? primaryBlue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  /// Prophet-specific input decoration
  static InputDecoration getProphetInputDecoration(
    ProfetType prophet, {
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    final color = getProphetColor(prophet);
    return getInputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      borderColor: color,
    );
  }

  /// Container decorations
  static BoxDecoration getGradientDecoration({
    required List<Color> colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    double borderRadius = 0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static BoxDecoration getProphetGradientDecoration(
    ProfetType prophet, {
    double borderRadius = 0,
    double opacity = 0.3,
  }) {
    final color = getProphetColor(prophet);
    return getGradientDecoration(
      colors: [
        color.withOpacity(opacity * 0.5),
        color.withOpacity(opacity),
      ],
      borderRadius: borderRadius,
    );
  }

  /// Spacing utilities
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Edge insets presets
  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingSM = EdgeInsets.all(spacingSM);
  static const EdgeInsets paddingMD = EdgeInsets.all(spacingMD);
  static const EdgeInsets paddingLG = EdgeInsets.all(spacingLG);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);

  static const EdgeInsets horizontalPaddingSM = EdgeInsets.symmetric(horizontal: spacingSM);
  static const EdgeInsets horizontalPaddingMD = EdgeInsets.symmetric(horizontal: spacingMD);
  static const EdgeInsets horizontalPaddingLG = EdgeInsets.symmetric(horizontal: spacingLG);

  static const EdgeInsets verticalPaddingSM = EdgeInsets.symmetric(vertical: spacingSM);
  static const EdgeInsets verticalPaddingMD = EdgeInsets.symmetric(vertical: spacingMD);
  static const EdgeInsets verticalPaddingLG = EdgeInsets.symmetric(vertical: spacingLG);

  /// SizedBox presets for spacing
  static const Widget spacerXS = SizedBox(height: spacingXS);
  static const Widget spacerSM = SizedBox(height: spacingSM);
  static const Widget spacerMD = SizedBox(height: spacingMD);
  static const Widget spacerLG = SizedBox(height: spacingLG);
  static const Widget spacerXL = SizedBox(height: spacingXL);

  static const Widget horizontalSpacerXS = SizedBox(width: spacingXS);
  static const Widget horizontalSpacerSM = SizedBox(width: spacingSM);
  static const Widget horizontalSpacerMD = SizedBox(width: spacingMD);
  static const Widget horizontalSpacerLG = SizedBox(width: spacingLG);

  /// Theme data generators
  static ThemeData getLightTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        headlineLarge: headlineStyle,
        titleLarge: titleStyle,
        titleMedium: subtitleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: getPrimaryButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: getSecondaryButtonStyle(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      primaryColor: primaryBlue,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardBackgroundDark,
      textTheme: TextTheme(
        headlineLarge: headlineStyle.copyWith(color: Colors.white),
        titleLarge: titleStyle.copyWith(color: Colors.white),
        titleMedium: subtitleStyle.copyWith(color: Colors.white70),
        bodyLarge: bodyStyle.copyWith(color: Colors.white),
        bodyMedium: captionStyle.copyWith(color: Colors.white54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: getPrimaryButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: getSecondaryButtonStyle(borderColor: Colors.white70),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Extension on BuildContext for easy theme access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  Color get primaryColor => theme.primaryColor;
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get cardColor => theme.cardColor;
}
