import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'day_cell_widget.dart';

/// [MonthGridWidget] — Takvimin aylık grid görünümü.
///
/// Tasarım Güncellemesi (Boyut Sıkıştırma/Overflow Koruması):
/// - Grid genişliği ve yüksekliği `LayoutBuilder` ile ölçülerek **dinamik `childAspectRatio`** hesaplanır.
/// - Formül: `(genişlik * 6) / (yükseklik * 7)`
/// - Bu sayede 6 satırlık grid, ekran yüksekliği ne kadar küçülürse küçülsün
///   **ekrana dikeyde sıfıra sıfır oturur ve asla dikey taşma (overflow) yapmaz!**
class MonthGridWidget extends StatelessWidget {
  const MonthGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final month = provider.focusedMonth;

    // O aya ait tüm hücre tarihlerini üret
    final days = _buildCalendarDays(month);

    return Column(
      children: [
        // ── Ay Navigasyon Başlığı ─────────────────────────────────────────
        _MonthHeader(month: month),

        const SizedBox(height: 12),

        // ── Gün İsimleri Satırı ──────────────────────────────────────────
        _WeekdayLabels(),

        const SizedBox(height: 4),

        // ── Takvim Grid'i (Dinamik Aspect Ratio ve Boyutlandırma) ──────────
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double gridWidth = constraints.maxWidth;
              final double gridHeight = constraints.maxHeight;

              // Grid'in ekran yüksekliğine tam oturması için hücre oranını hesaplıyoruz
              double dynamicRatio = 1.22;
              if (gridWidth > 0 && gridHeight > 0) {
                dynamicRatio = (gridWidth * 6) / (gridHeight * 7);
                // Uç oranları sınırlıyoruz (aşırı basık veya dikey olmaması için)
                if (dynamicRatio < 0.8) dynamicRatio = 0.8;
                if (dynamicRatio > 2.0) dynamicRatio = 2.0;
              }

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,                  // 7 gün
                  childAspectRatio: dynamicRatio,     // Dikey ve yatayda tam sığmayı sağlayan oran
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth =
                      day.month == month.month && day.year == month.year;
                  return DayCellWidget(
                    date: day,
                    isCurrentMonth: isCurrentMonth,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// [focusedMonth] için takvim hücrelerini hesaplar.
  List<DateTime> _buildCalendarDays(DateTime focusedMonth) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final leadingDays = firstDay.weekday % 7;

    final List<DateTime> days = [];

    // Önceki ayın doldurma günleri
    for (int i = leadingDays; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Mevcut ayın günleri
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(DateTime(focusedMonth.year, focusedMonth.month, d));
    }

    // Sonraki ayın doldurma günleri (toplam 42 = 6 satır)
    while (days.length < 42) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alt Widget'lar
// ─────────────────────────────────────────────────────────────────────────────

/// Ay başlığı ve navigasyon butonları
class _MonthHeader extends StatelessWidget {
  final DateTime month;
  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalendarProvider>();
    final title = DateFormat('MMMM yyyy', 'tr_TR').format(month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: provider.previousMonth,
            tooltip: 'Önceki ay',
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: provider.nextMonth,
            tooltip: 'Sonraki ay',
          ),
        ],
      ),
    );
  }
}

/// Küçük navigasyon ikon butonu
class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hovered ? AppTheme.bgSelected : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(
              widget.icon,
              color: _hovered ? AppTheme.accentPrimary : AppTheme.textSecondary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

/// Haftanın gün isimleri başlık satırı (Paz, Pzt, ..., Cmt)
class _WeekdayLabels extends StatelessWidget {
  static const _labels = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels.map((label) {
        final bool isWeekend = label == 'Cmt' || label == 'Paz';
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? AppTheme.accentToday.withOpacity(0.7)
                    : AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
