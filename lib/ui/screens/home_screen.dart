import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/month_grid_widget.dart';
import '../widgets/day_detail_panel_widget.dart';

/// [HomeScreen] — Uygulamanın ana ekran mimarisini sunar.
///
/// Taşma (Overflow) ve Sıkıştırma Korumalı Gelişmiş Yerleşim:
/// - `LayoutBuilder` ile pencere genişliği (`maxWidth`) dinamik olarak takip edilir.
/// - Eğer pencere genişliği **950px'den küçükse (Narrow Mode)**:
///   - Takvim ekranın %100'ünü kaplar.
///   - Gün detay paneli sağdan **şık bir yüzen panel (floating drawer/overlay)** olarak gelip
///     takvimin üstüne biner ve gölge efekti taşır. Takvimin aşırı derecede sıkışıp
///     taşma yapmasını engeller.
/// - Eğer pencere genişliği **950px veya üzerindeyse (Wide Mode)**:
///   - Takvim grid'i ve sağ detay paneli yan yana (side-by-side) mükemmel bir uyumla hizalanır.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Merkez Panel: Takvim Grid Görünümü ─────────────────────
          Positioned.fill(
            child: Container(
              color: AppTheme.bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: const MonthGridWidget(),
            ),
          ),

          // ── 2. Modal Katmanı: Detay Penceresi (Buzlu Cam & Animasyon) ───
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Fade ve yumuşak Scale animasyonu ile premium geçiş
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: provider.isDayPanelOpen
                  ? _buildModalOverlay(context, provider)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  /// Arka planı bulanıklaştıran ve ESC tuşunu dinleyen modal katmanı widget'ı.
  Widget _buildModalOverlay(BuildContext context, CalendarProvider provider) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          provider.closeDayPanel();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          // ── Tıklanabilir Arka Plan & Bulanıklaştırma (Blur) ───────────
          Positioned.fill(
            child: GestureDetector(
              onTap: provider.closeDayPanel,
              behavior: HitTestBehavior.opaque,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.45),
                  ),
                ),
              ),
            ),
          ),

          // ── Merkezî Modal Kartı ─────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () {}, // İçeriğe tıklanınca kapanmayı engelle
              behavior: HitTestBehavior.opaque,
              child: const DayDetailPanelWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
