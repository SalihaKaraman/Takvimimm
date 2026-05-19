import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/daily_task.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'add_task_dialog.dart';

/// [TodoSectionWidget] — Seçili gün için "Yapmak İstediklerim" listesi.
///
/// Her görev için:
/// - Checkbox ile tamamlama işaretleme
/// - Tamamlanınca üzeri çizili metin efekti
/// - Kaydırarak silme (Dismissible)
/// Listenin altındaki [+] butonu ile yeni görev ekleme diyaloğu açılır.
class TodoSectionWidget extends StatelessWidget {
  /// Görevlerin ait olduğu gün anahtarı (yyyy-MM-dd)
  final String dateKey;

  const TodoSectionWidget({super.key, required this.dateKey});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    // Saate bağlı olmayan genel görevleri al
    final tasks = provider.getGeneralTasksForDay(dateKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bölüm Başlığı ──────────────────────────────────────────────
        Row(
          children: [
            const Icon(
              Icons.checklist_rounded,
              size: 16,
              color: AppTheme.accentPrimary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Yapmak İstediklerim',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            // Görev sayısı rozeti
            if (tasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tasks.where((t) => t.isCompleted).length}/${tasks.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.accentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Görev Listesi ───────────────────────────────────────────────
        if (tasks.isEmpty)
          _EmptyTasksPlaceholder(onAdd: () => _openAddDialog(context))
        else ...[
          ...tasks.map((task) => _TaskItem(task: task)),
          const SizedBox(height: 6),
        ],

        // ── Görev Ekle Butonu ───────────────────────────────────────────
        if (tasks.isNotEmpty)
          _AddTaskButton(onTap: () => _openAddDialog(context)),
      ],
    );
  }

  /// Görev ekleme diyaloğunu açar.
  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => AddTaskDialog(dateKey: dateKey),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Tek bir görev satırı: checkbox, metin, sil butonu
class _TaskItem extends StatefulWidget {
  final DailyTask task;
  const _TaskItem({required this.task});

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalendarProvider>();
    final isCompleted = widget.task.isCompleted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.bgSelected : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            // ── Checkbox ───────────────────────────────────────────────
            Checkbox(
              value: isCompleted,
              onChanged: (_) => provider.toggleTask(widget.task),
            ),

            const SizedBox(width: 8),

            // ── Görev Metni (üstü çizili efekti) ──────────────────────
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 13,
                  color: isCompleted
                      ? AppTheme.textDisabled
                      : AppTheme.textPrimary,
                  // Tamamlandığında üzeri çizili efekt
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: AppTheme.textDisabled,
                  decorationThickness: 2,
                ),
              ),
            ),

            // ── Silme Butonu (hover'da görünür) ───────────────────────
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _hovered ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () => provider.deleteTask(widget.task),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Liste boşken gösterilen yer tutucu
class _EmptyTasksPlaceholder extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTasksPlaceholder({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.border,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: AppTheme.textDisabled, size: 22),
            SizedBox(height: 6),
            Text(
              'Görev eklemek için tıkla',
              style: TextStyle(
                color: AppTheme.textDisabled,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Listenin altındaki "Görev Ekle" mini butonu
class _AddTaskButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddTaskButton({required this.onTap});

  @override
  State<_AddTaskButton> createState() => _AddTaskButtonState();
}

class _AddTaskButtonState extends State<_AddTaskButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.accentPrimary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: _hovered
                    ? AppTheme.accentPrimary
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Görev ekle',
                style: TextStyle(
                  fontSize: 12,
                  color: _hovered
                      ? AppTheme.accentPrimary
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
