import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MedFleet design tokens (emerald palette). Light + dark (deep green, no black).
class MfPalette {
  final Color bg, m1, surface, line, ink, mute, accent, accent2, onAccent;
  final Color gold, goldS, greenS, red, redS, l1, l2, l3, panel, goldOnTile;
  const MfPalette({
    required this.bg,
    required this.m1,
    required this.surface,
    required this.line,
    required this.ink,
    required this.mute,
    required this.accent,
    required this.accent2,
    required this.onAccent,
    required this.gold,
    required this.goldS,
    required this.greenS,
    required this.red,
    required this.redS,
    required this.l1,
    required this.l2,
    required this.l3,
    required this.panel,
    required this.goldOnTile,
  });

  static const light = MfPalette(
    bg: Color(0xFFF7F4EC),
    m1: Color(0xFFDDEBDD),
    surface: Color(0xFFFFFFFF),
    line: Color(0xFFE2DDCF),
    ink: Color(0xFF17261F),
    mute: Color(0xFF6A7A70),
    accent: Color(0xFF0F7B5F),
    accent2: Color(0xFF0A5A46),
    onAccent: Color(0xFFFFFFFF),
    gold: Color(0xFFC98F14),
    goldS: Color(0xFFFBF0D3),
    greenS: Color(0xFFDDF1E8),
    red: Color(0xFFC4452F),
    redS: Color(0xFFFBE3DD),
    l1: Color(0xFF2FB38C),
    l2: Color(0xFF0F7B5F),
    l3: Color(0xFF0A4F3E),
    panel: Color(0xFF0A5A46),
    goldOnTile: Color(0xFFF6D77C),
  );

  static const dark = MfPalette(
    bg: Color(0xFF0E1E19),
    m1: Color(0xFF14382D),
    surface: Color(0xFF152A23),
    line: Color(0xFF244036),
    ink: Color(0xFFEAF3EE),
    mute: Color(0xFF93AAA0),
    accent: Color(0xFF4FD1A6),
    accent2: Color(0xFF2AAE87),
    onAccent: Color(0xFF06261B),
    gold: Color(0xFFE8B84A),
    goldS: Color(0xFF3A3217),
    greenS: Color(0xFF173D31),
    red: Color(0xFFFF8A72),
    redS: Color(0xFF412019),
    l1: Color(0xFF2FB38C),
    l2: Color(0xFF0F7B5F),
    l3: Color(0xFF0A4F3E),
    panel: Color(0xFF1B5A47),
    goldOnTile: Color(0xFFF6D77C),
  );
}

extension MfContext on BuildContext {
  MfPalette get mf => Theme.of(this).brightness == Brightness.dark
      ? MfPalette.dark
      : MfPalette.light;
}

/// Headings: Noto Kufi Arabic.
TextStyle kufi(double size, {FontWeight w = FontWeight.w700, Color? c, double? h}) =>
    GoogleFonts.notoKufiArabic(fontSize: size, fontWeight: w, color: c, height: h);

/// Body: Noto Sans Arabic.
TextStyle sans(double size, {FontWeight w = FontWeight.w400, Color? c, double? h}) =>
    GoogleFonts.notoSansArabic(fontSize: size, fontWeight: w, color: c, height: h);

/// Numbers / codes: Manrope.
TextStyle mono(double size, {FontWeight w = FontWeight.w800, Color? c}) =>
    GoogleFonts.manrope(
      fontSize: size,
      fontWeight: w,
      color: c,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? MfPalette.dark : MfPalette.light;
  final base = ThemeData(brightness: b, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: p.accent, brightness: b)
        .copyWith(primary: p.accent, surface: p.surface),
    textTheme: GoogleFonts.notoSansArabicTextTheme(base.textTheme)
        .apply(bodyColor: p.ink, displayColor: p.ink),
    splashFactory: InkRipple.splashFactory,
    dividerColor: p.line,
  );
}
