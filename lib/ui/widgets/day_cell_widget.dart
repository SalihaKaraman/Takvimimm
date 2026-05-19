import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';
import '../../models/daily_task.dart';

/// [DayCellWidget] — Aylık takvim grid'indeki tek bir günü temsil eden hücre.
///
/// Taşma (Overflow) Korumalı ve Duyarlı (Responsive) Tasarım:
/// - `LayoutBuilder` yardımıyla her bir gün kutucuğunun dikey yüksekliği (`maxHeight`) dinamik olarak ölçülür.
/// - Kutucuk alanı küçüldüğünde (örneğin pencere daraltıldığında/sıkıştırıldığında):
///   - Padding değerleri `8.0`'den `4.0`'e çekilir.
///   - Gösterilecek maksimum görev sayısı (maxVisibleTasks) dikey yüksekliğe göre **3, 2, 1 veya 0'a** dinamik olarak uyarlanır.
///   - Görev metinleri ve göstergeler otomatik küçülür.
///   - **Bu sayede dikey veya yatay olarak ekran ne kadar daraltılırsa daraltılsın hücre içi taşma (overflow) sıfırlanır!**
class DayCellWidget extends StatelessWidget {
  /// Bu hücrenin temsil ettiği tarih
  final DateTime date;

  /// Hücrenin bulunduğu ayda olup olmadığı
  final bool isCurrentMonth;

  const DayCellWidget({
    super.key,
    required this.date,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final dateKey = CalendarProvider.formatDateKey(date);

    final bool isToday = _isSameDay(date, DateTime.now());
    final bool isSelected = _isSameDay(date, provider.selectedDay);
    final bool hasNote = provider.getEntryForDay(dateKey)?.dailyNote.isNotEmpty ?? false;

    // O güne ait tüm görevleri alıyoruz
    final List<DailyTask> tasks = provider.getTasksForDay(dateKey);

    // Hücre arka plan rengi
    Color bgColor;
    if (!isCurrentMonth) {
      bgColor = AppTheme.bgPrimary.withOpacity(0.5);
    } else if (isSelected) {
      bgColor = AppTheme.bgSelected;
    } else {
      bgColor = AppTheme.bgCard;
    }

    return GestureDetector(
      onTap: () => provider.selectDay(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentPrimary
                : isToday
                    ? AppTheme.accentToday.withOpacity(0.8)
                    : AppTheme.border.withOpacity(0.5),
            width: isSelected || isToday ? 1.8 : 1.0,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableHeight = constraints.maxHeight;

            // ── DUYARLI DEĞERLER (Kutucuk yüksekliğine göre otomatik uyarlanır) ──
            // Hücre çok daraldığında padding'leri ve boşlukları küçültüyoruz
            final double outerPadding = availableHeight < 85 ? 4.0 : 8.0;
            final double headerBottomSpacing = availableHeight < 85 ? 3.0 : 6.0;
            final double pillHeight = availableHeight < 95 ? 18.0 : 22.0;
            final double pillFontSize = availableHeight < 95 ? 9.0 : 10.5;
            final double pillMarginBottom = availableHeight < 95 ? 3.0 : 5.0;

            // Yüksekliğe sığacak görev sayısını dinamik olarak hesaplıyoruz
            int maxVisibleTasks = 3;
            if (availableHeight < 70) {
              maxVisibleTasks = 0; // Sadece gün sayısı gösterilir, görev gösterilmez
            } else if (availableHeight < 95) {
              maxVisibleTasks = 1; // Yalnızca 1 görev sığar
            } else if (availableHeight < 125) {
              maxVisibleTasks = 2; // 2 görev sığar
            } else {
              maxVisibleTasks = 3; // 3 görev rahatça sığar
            }

            final int extraTasksCount = tasks.length - maxVisibleTasks;

            return Padding(
              padding: EdgeInsets.all(outerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── ÜST KISIM: Gün Sayısı & Not Göstergesi ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sol: Not İkonu (Yer varsa göster)
                      if (hasNote && isCurrentMonth && availableHeight >= 70)
                        const Icon(
                          Icons.edit_document,
                          size: 12,
                          color: AppTheme.accentSecondary,
                        )
                      else
                        const SizedBox.shrink(),

                      // Sağ: Gün Numarası
                      if (!isCurrentMonth)
                        Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: AppTheme.textDisabled,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else if (isToday)
                        Container(
                          width: availableHeight < 80 ? 20 : 24,
                          height: availableHeight < 80 ? 20 : 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentToday,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                        fontSize: availableHeight < 80 ? 11 : 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                ],
              ),

                  SizedBox(height: headerBottomSpacing),

                  // ── MERKEZ/ALT KISIM: Görev Pills (Etiketler) ────────────────
                  if (isCurrentMonth && tasks.isNotEmpty && maxVisibleTasks > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ...tasks.take(maxVisibleTasks).map((task) {
                            final bool isTaskHourSpecific = task.hour != null;
                            final Color indicatorColor =
                                isTaskHourSpecific ? AppTheme.accentSecondary : AppTheme.accentPrimary;

                            return Container(
                              margin: EdgeInsets.only(bottom: pillMarginBottom),
                              height: pillHeight,
                              decoration: BoxDecoration(
                                color: task.isCompleted
                                    ? AppTheme.success.withOpacity(0.06)
                                    : indicatorColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Row(
                                  children: [
                                    // Sol dikey kalın çizgi barı
                                    Container(
                                      width: availableHeight < 95 ? 2.5 : 3.5,
                                      color: task.isCompleted ? AppTheme.success : indicatorColor,
                                    ),
                                    const SizedBox(width: 4),
                                    // Küçük yuvarlak dot (Hücre yüksekliği yeterliyse göster)
                                    if (availableHeight >= 90) ...[
                                      Container(
                                        width: 4.0,
                                        height: 4.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: task.isCompleted ? AppTheme.success : indicatorColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    // Görev Başlığı
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: pillFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: task.isCompleted
                                              ? AppTheme.textDisabled
                                              : AppTheme.textPrimary,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Sığmayan görevler için "+X daha" etiketi
                          if (extraTasksCount > 0 && availableHeight >= 85)
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 1),
                              child: Text(
                                '+$extraTasksCount daha',
                                style: const TextStyle(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDisabled,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// İki tarihin aynı gün, ay ve yıla sahip olup olmadığını kontrol eder.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
