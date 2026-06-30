import 'package:flutter/material.dart';

/// App Colors Design System
/// Fully refactored to follow semantic architectural naming conventions.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // 1. Core Branding & Semantic Colors
  // ---------------------------------------------------------------------------

  /// The main brand accent color (Vibrant Green for active states, buttons, etc.)
  static const Color primary = Color(0xFF00A417);

  /// Deep Forest Green used for premium subscription highlights and badges
  static const Color primaryDark = Color(0xFF046712);

  /// Secondary brand color (Deep Cyan/Teal for alternate flows)
  static const Color secondary = Color(0xFF017D9E);

  /// Success state indicator (Bright Green)
  static const Color success = Color(0xFF16B50A);

  /// Error, Alert, and Danger state indicators (Pure Vibrant Red)
  static const Color error = Color(0xFFEE1F1F);

  // ---------------------------------------------------------------------------
  // 2. Neutrals, Surfaces & Backgrounds
  // ---------------------------------------------------------------------------

  /// Pure white used for primary layouts, containers, and card backgrounds
  static const Color white = Color(0xFFFFFFFF);

  /// Pure solid black used for heavy titles, main body text, and dark accents
  static const Color black = Color(0xFF000000);

  /// Main text color (Charcoal Gray) used for body text and subheadings
  static const Color textPrimary = Color(0xFF4A4949);

  /// Secondary text color (Cool Ash Gray) used for captions, placeholders, and icons
  static const Color textSecondary = Color(0xFF8F8F8F);

  /// Subdued gray used for borders, dividers, and inactive form strokes
  static const Color divider = Color(0xFFCACACA);

  /// Very soft warm green tint used for subtle container backgrounds
  static const Color backgroundTint = Color(0xFFE6F6E8);

  /// Premium dark overlay used for modal masks and bottom sheet backdrops
  static const Color scrimOverlay = Color(0xFF222222);

  /// Cool neutral gray used for secondary button backgrounds or field fills
  static const Color surfaceGray = Color(0xFFA0A9BA);

  // ---------------------------------------------------------------------------
  // 2B. Hydration / Water-Tracking Accent
  // ---------------------------------------------------------------------------

  /// Bright cyan/teal used specifically on the Hydration screen — progress
  /// ring, quick-add badge, outlined buttons, and manual-entry sheet.
  static const Color waterAccent = Color(0xFF4CCFD9);

  /// Very light cyan tint used for the selected state of preset amount
  /// chips in the manual water-entry sheet.
  static const Color waterAccentLight = Color(0xFFE3F8FA);

  // ---------------------------------------------------------------------------
  // 3. Hardware / OS Overlays
  // ---------------------------------------------------------------------------

  /// Dark Navy/Purple background color used for the native System Status Bar
  static const Color statusBar = Color(0xFF19122A);

  /// Pitch black shadow mask used for simulating the device's screen notch cutout
  static const Color notchMask = Color(0xFF010005);

  // ---------------------------------------------------------------------------
  // 4. Brand Green Tonal Palette (Darkest to Lightest)
  // ---------------------------------------------------------------------------

  /// Ultra dark green shade (almost black) for deep contrasts
  static const Color greenMidnight = Color(0xFF001002);

  /// Extremely dark green for subtle gradients or shadow boundaries
  static const Color greenDeepShade = Color(0xFF002105);

  /// Dark rich green accent
  static const Color greenForest = Color(0xFF003107);

  /// Classic deep green hue
  static const Color greenOlive = Color(0xFF004209);

  /// Medium-dark organic green
  static const Color greenJungle = Color(0xFF00620E);

  /// Pure dark green tone
  static const Color greenDarkAccent = Color(0xFF008312);

  /// Vibrant mid-tone emerald green
  static const Color greenEmerald = Color(0xFF29B63D);

  /// Light sage/lime green for positive updates or progress steps
  static const Color greenLightAccent = Color(0xFF52C863);

  /// Soft mint green for secondary badges or active tabs backgrounds
  static const Color greenMint = Color(0xFF7BDB88);

  /// Pale pastel green for informative alert boxes
  static const Color greenPale = Color(0xFF8FE49B);

  /// Very light soft green tint for successful action cards
  static const Color greenSoftTint = Color(0xFFA4EDAE);

  /// Ultra-light crystalline green for smooth gradient endings or backgrounds
  static const Color greenCrystal = Color(0xFFCDFFD4);

  /// Ultra-light crystalline green for smooth gradient endings or backgrounds
  static const Color gradientPrimary = Color(0xFFDEF3E1);

  static const LinearGradient splashBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.center,
    colors: [
      Color(0xFFb5e5ba),
      Color(0xFFddf3de),
      Color(0xFFfbfefb),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient visitsBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.center,
    colors: [
      Color(0xFFEFFBF1),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient timeRemainingGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7CD588),
      Color(0xFFE6FFE9),
      Color(0xFF7CD588),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFEFFFF2),
    ],
  );

  static const Color headerBackground = Color(0xFFEAF6EA);
  static const Color inactiveGray = Color(0xFFDDDDDD);

  static const LinearGradient weightStatusGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      
      Color(0xFF76D183),
      Color(0xFFB4FFC0),
      Color(0xFF76D183),
      
    ],
  );

  // ---------------------------------------------------------------------------
  // Unified Case-Insensitive Design Tokens Map
  // ---------------------------------------------------------------------------
  static Map<String, Color> get allColors => {
    'primary': primary,
    'primaryDark': primaryDark,
    'secondary': secondary,
    'success': success,
    'error': error,
    'white': white,
    'black': black,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'divider': divider,
    'backgroundTint': backgroundTint,
    'scrimOverlay': scrimOverlay,
    'surfaceGray': surfaceGray,
    'waterAccent': waterAccent,
    'waterAccentLight': waterAccentLight,
    'statusBar': statusBar,
    'notchMask': notchMask,
    'greenMidnight': greenMidnight,
    'greenDeepShade': greenDeepShade,
    'greenForest': greenForest,
    'greenOlive': greenOlive,
    'greenJungle': greenJungle,
    'greenDarkAccent': greenDarkAccent,
    'greenEmerald': greenEmerald,
    'greenLightAccent': greenLightAccent,
    'greenMint': greenMint,
    'greenPale': greenPale,
    'greenSoftTint': greenSoftTint,
    'greenCrystal': greenCrystal,
  };

  static Color red = Colors.red;

  /// Get color by name (case-insensitive)
  static Color? getColorByName(String name) {
    final lowerName = name.toLowerCase();
    for (final entry in allColors.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }
    return null;
  }
}