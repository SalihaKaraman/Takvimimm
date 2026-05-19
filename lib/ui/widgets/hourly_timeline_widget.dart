import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';
import '../../models/daily_task.dart';
import 'add_task_dialog.dart';

/// [HourlyTimelineWidget] — 00:00 ile 23:00 saatleri arasındaki dikey zaman çizelgesi.
///
/// Her saat dilimi satırı:
/// - Sol tarafta saat etiketi (örneğin "09:00")
/// - Sağ tarafta o saate atanmış görevlerin listesi
/// - Saate tıklanarak doğrudan o zaman dilimine özel görev ekleme imkanı
class HourlyTimelineWidget extends StatelessWidget {
  final String dateKey;

  const HourlyTimelineWidget({super.key, required this.dateKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bölüm Başlığı ──────────────────────────────────────────────
        const Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 16,
              color: AppTheme.accentPrimary,
            ),
            SizedBox(width: 8),
            Text(
              'Saatlik Planlama',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Dikey Zaman Çizelgesi Listesi ──────────────────────────────
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 24, // 00:00 - 23:00
          itemBuilder: (context, index) {
            return _HourRow(
              hour: index,
              dateKey: dateKey,
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HourRow extends StatefulWidget {
  final int hour;
  final String dateKey;

  const _HourRow({
    required this.hour,
    required this.dateKey,
  });

  @override
  State<_HourRow> createState() => _HourRowState();
}

class _HourRowState extends State<_HourRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final hourTasks = provider.getTasksForHour(widget.dateKey, widget.hour);
    final String hourStr = '${widget.hour.toString().padLeft(2, '0')}:00';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          // Boş alana veya satıra tıklanınca o saate özel görev ekleme penceresi açılır
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (_) => AddTaskDialog(
              dateKey: widget.dateKey,
              hour: widget.hour,
            ),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.border,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sol: Saat Etiketi ──────────────────────────────────
                Container(
                  width: 55,
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hourStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),

                // ── Dikey Bölücü Çizgi ──────────────────────────────────
                const VerticalDivider(
                  color: AppTheme.border,
                  thickness: 1,
                  width: 16,
                ),

                // ── Sağ: Saatlik Görev Listesi / Ekleme Alanı ───────────
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _hovered
                          ? AppTheme.accentPrimary.withOpacity(0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: hourTasks.isEmpty
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _hovered ? '+ Görev/Etkinlik ekle' : '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.accentPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: hourTasks.map((task) {
                              return _HourlyTaskItem(task: task);
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HourlyTaskItem extends StatelessWidget {
  final DailyTask task;

  const _HourlyTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalendarProvider>();
    final isCompleted = task.isCompleted;

    return Row(
      children: [
        // ── Görev Tik Kutusu ──────────────────────────────────────────
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isCompleted,
            onChanged: (_) => provider.toggleTask(task),
          ),
        ),
        const SizedBox(width: 8),

        // ── Görev Başlığı ──────────────────────────────────────────────
        Expanded(
          child: Text(
            task.title,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? AppTheme.textDisabled : AppTheme.textPrimary,
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: AppTheme.textDisabled,
            ),
          ),
        ),

        // ── Sil Butonu ───────────────────────────────────────────────
        GestureDetector(
          onTap: () => provider.deleteTask(task),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
