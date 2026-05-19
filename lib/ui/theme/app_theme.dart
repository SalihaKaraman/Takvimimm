import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [AppTheme] — Uygulamanın tüm renk, tipografi ve boyut sabitlerini
/// tek bir yerde toplar.
///
/// Tüm widget'lar bu sınıftan renk ve stil alır; böylece tasarım
/// tutarlılığı ve kolay tema değişimi sağlanır.
class AppTheme {
  AppTheme._(); // Örneklenemesin diye private constructor

  // ── Renk Paleti ───────────────────────────────────────────────────────────

  /// Ana arka plan — derin gece mavisi
  static const Color bgPrimary = Color(0xFF0F1117);

  /// İkincil yüzey — hafif açık panel arka planı
  static const Color bgSurface = Color(0xFF1A1D27);

  /// Kart ve hücre yüzeyi
  static const Color bgCard = Color(0xFF21253A);

  /// Hover / seçili hücre
  static const Color bgSelected = Color(0xFF2D3354);

  /// Birincil aksan rengi — neon lavanta
  static const Color accentPrimary = Color(0xFF7C6FF7);

  /// Hafif aksan — tamamlanmış görev çizgisi
  static const Color accentSecondary = Color(0xFF5A7FFF);

  /// Bugünü işaretleyen aksan
  static const Color accentToday = Color(0xFFFF6B9D);

  /// Başarı / tamamlandı rengi
  static const Color success = Color(0xFF4ECDC4);

  /// Metin — ana
  static const Color textPrimary = Color(0xFFF0F2FF);

  /// Metin — ikincil / soluk
  static const Color textSecondary = Color(0xFF8B91B3);

  /// Metin — devre dışı / placeholder
  static const Color textDisabled = Color(0xFF454A6B);

  /// Kenarlık rengi
  static const Color border = Color(0xFF2E3352);

  // ── Boyutlar ──────────────────────────────────────────────────────────────

  /// Takvim hücresinin minimum yüksekliği
  static const double dayCellMinHeight = 90.0;

  /// Sağ detay panelinin genişliği
  static const double dayPanelWidth = 380.0;

  /// Saatlik zaman çizgisi satır yüksekliği
  static const double timelineRowHeight = 56.0;

  // ── MaterialApp ThemeData ─────────────────────────────────────────────────

  /// Uygulamanın ana [ThemeData] nesnesi.
  static ThemeData get theme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        surface: bgSurface,
        primary: accentPrimary,
        secondary: accentSecondary,
        onPrimary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentPrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textDisabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentPrimary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(textPrimary),
        side: const BorderSide(color: textSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
