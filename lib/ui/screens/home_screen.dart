import 'package:flutter/material.dart';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Genişliğe göre responsive mod seçimi (950px eşik değeri)
          final bool isNarrow = constraints.maxWidth < 950;

          return Stack(
            children: [
              // ── 1. Merkez Panel: Takvim Grid Görünümü ─────────────────────
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    // Geniş ekranlarda takvimi sağa kaydırıp yer açıyoruz, dar ekranlarda yer açmıyoruz (overlay)
                    right: (provider.isDayPanelOpen && !isNarrow)
                        ? AppTheme.dayPanelWidth
                        : 0,
                  ),
                  child: Container(
                    color: AppTheme.bgPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: const MonthGridWidget(),
                  ),
                ),
              ),

              // ── 2. Sağ Panel: Detay Paneli (Seçili gün varsa görünür) ──────────
              if (provider.isDayPanelOpen)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: isNarrow
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 4,
                                offset: const Offset(-5, 0),
                              )
                            ]
                          : null,
                    ),
                    child: const DayDetailPanelWidget(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
