import 'package:flutter/material.dart';

/// Color palette extracted from Smart Farm Assistant UI designs.
/// Primary palette is green/teal — matching the farm theme.
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Primary Green (main brand color) ──────────────────────────────
  static const Color primary        = Color(0xFF3D7A4E); // dark green – buttons
  static const Color primaryLight   = Color(0xFF5A9E6F); // medium green
  static const Color primaryLighter = Color(0xFF7EC89A); // soft green
  static const Color primaryPale    = Color(0xFFE8F5ED); // very light green bg

  // ── Teal (onboarding & splash bg) ────────────────────────────────
  static const Color teal           = Color(0xFF5BA89A); // from splash screen
  static const Color tealLight      = Color(0xFF7DC4B8); // lighter teal
  static const Color tealPale       = Color(0xFFE1F5EE); // background teal wash

  // ── Input Fields (teal-green fill) ────────────────────────────────
  static const Color inputFill      = Color(0xFF7BBFB5); // from login screen

  // ── Neutrals ──────────────────────────────────────────────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF1A1A1A);
  static const Color grey100        = Color(0xFFF5F5F5);
  static const Color grey200        = Color(0xFFEEEEEE);
  static const Color grey400        = Color(0xFFBDBDBD);
  static const Color grey600        = Color(0xFF757575);
  static const Color grey800        = Color(0xFF424242);

  // ── Semantic Colors ───────────────────────────────────────────────
  static const Color success        = Color(0xFF4CAF50);
  static const Color warning        = Color(0xFFFFA726);
  static const Color error          = Color(0xFFEF5350);
  static const Color info           = Color(0xFF42A5F5);

  // ── Risk Level Colors (Livestock Diagnosis) ───────────────────────
  static const Color riskLow        = Color(0xFF4CAF50); // green
  static const Color riskMedium     = Color(0xFFFFA726); // orange
  static const Color riskHigh       = Color(0xFFEF5350); // red

  // ── Background ────────────────────────────────────────────────────
  static const Color scaffoldBg     = Color(0xFFF8FAF9);
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFE0E0E0);

  // ── Text ──────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF757575);
  static const Color textHint       = Color(0xFFBDBDBD);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // ── Chat Bubbles ──────────────────────────────────────────────────
  static const Color userBubble     = Color(0xFF3D7A4E);
  static const Color aiBubble       = Color(0xFFF1F8F4);
  static const Color userBubbleText = Color(0xFFFFFFFF);
  static const Color aiBubbleText   = Color(0xFF1A1A1A);

  // ── Gradient (splash / onboarding backgrounds) ────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [teal, tealLight, Color(0xFFE8F5ED)],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
}
