import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';

/// [AddTaskDialog] — Yeni bir görev eklemek için kullanılan modern dialog.
///
/// İki mod destekler:
/// - [hour] null → Genel "Yapmak İstediklerim" listesine görev ekler
/// - [hour] bir değer → Belirli bir saat dilimine görev ekler
///
/// Kullanım:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AddTaskDialog(dateKey: '2026-05-19', hour: 14),
/// );
/// ```
class AddTaskDialog extends StatefulWidget {
  /// Görevin ekleneceği gün (yyyy-MM-dd)
  final String dateKey;

  /// Görevin atanacağı saat (0–23). Genel görev için null.
  final int? hour;

  const AddTaskDialog({
    super.key,
    required this.dateKey,
    this.hour,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  // Dialog açılış animasyonu için
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // Kısa bir scale-in animasyonu
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _animCtrl.forward();

    // Dialog açılınca klavye hemen aktifleşsin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  /// Görevi kaydeder ve dialog'u kapatır.
  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await context.read<CalendarProvider>().addTask(
          title: text,
          dateKey: widget.dateKey,
          hour: widget.hour,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Başlık metnini saate göre belirle
    final title = widget.hour != null
        ? '${widget.hour!.toString().padLeft(2, '0')}:00 — Etkinlik Ekle'
        : 'Görev Ekle';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Başlık Satırı ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: AppTheme.accentPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Kapat butonu
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Görev Metin Alanı ─────────────────────────────────────
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  hintText: 'Görevi buraya yazın...',
                ),
              ),

              const SizedBox(height: 16),

              // ── Aksiyon Butonları ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // İptal
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  // Kaydet
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Kaydet',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
