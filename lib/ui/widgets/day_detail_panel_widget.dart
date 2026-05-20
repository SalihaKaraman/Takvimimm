import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'todo_section_widget.dart';
import 'hourly_timeline_widget.dart';

/// [DayDetailPanelWidget] — Sağ tarafta yer alan detay panelidir.
///
/// İçerdiği Alanlar:
/// 1. Seçili gün başlığı ve kapatma butonu
/// 2. "O Gün Yaptıklarım" Not Alanı: Serbest metin girişi. Kullanıcı
///    yazmayı bıraktığında otomatik olarak veritabanına kaydedilir (Debounce).
/// 3. "Yapmak İstediklerim" (To-Do List) Bölümü.
/// 4. "Saatlik Planlama" (00:00 - 23:00) dikey zaman çizgisi.
class DayDetailPanelWidget extends StatefulWidget {
  const DayDetailPanelWidget({super.key});

  @override
  State<DayDetailPanelWidget> createState() => _DayDetailPanelWidgetState();
}

class _DayDetailPanelWidgetState extends State<DayDetailPanelWidget> {
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _currentDateKey = '';
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.watch<CalendarProvider>();
    final newDateKey = CalendarProvider.formatDateKey(provider.selectedDay);

    // Eğer kullanıcı başka bir güne tıkladıysa, not alanını o günün verisiyle güncelle
    if (_currentDateKey != newDateKey) {
      _currentDateKey = newDateKey;
      _debounceTimer?.cancel();

      final entry = provider.getEntryForDay(newDateKey);
      _noteController.text = entry?.dailyNote ?? '';
      _isSaving = false;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Kullanıcı yazarken tetiklenen debounce not kaydetme işlemi.
  /// 700ms boyunca yeni bir tuşa basılmazsa otomatik olarak veritabanına yazar.
  void _onNoteChanged(String value) {
    setState(() {
      _isSaving = true;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () async {
      await context
          .read<CalendarProvider>()
          .saveDailyNote(_currentDateKey, value);
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final date = provider.selectedDay;

    // Türkçe gün ve ay ismi formatı (Örn: "19 Mayıs 2026, Salı")
    final String formattedDate =
        DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date);

    return Container(
      constraints: BoxConstraints(
        maxWidth: 550,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
          // ── ÜST KISIM: Panel Başlığı & Kapat Butonu ──────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _isSaving
                                ? Icons.sync_rounded
                                : Icons.cloud_done_rounded,
                            size: 12,
                            color: _isSaving
                                ? AppTheme.accentToday
                                : AppTheme.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSaving ? 'Kaydediliyor...' : 'Otomatik Kaydedildi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _isSaving
                                  ? AppTheme.accentToday
                                  : AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: provider.closeDayPanel,
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.textSecondary,
                  hoverColor: AppTheme.bgSelected,
                  splashRadius: 20,
                  tooltip: 'Paneli Kapat',
                ),
              ],
            ),
          ),

          // ── İÇERİK KISMI: Kaydırılabilir Gövde ─────────────────────────
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. "O Gün Yaptıklarım" Not Alanı ─────────────────────
                    const Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                          color: AppTheme.accentPrimary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'O Gün Yaptıklarım',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      onChanged: _onNoteChanged,
                      maxLines: 5,
                      minLines: 3,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Bugün neler yaptınız? Not alın...',
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.border, height: 1),
                    const SizedBox(height: 20),

                    // ── 2. To-Do (Yapılacaklar) Yönetimi ─────────────────────
                    TodoSectionWidget(dateKey: _currentDateKey),

                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.border, height: 1),
                    const SizedBox(height: 20),

                    // ── 3. Saatlik Planlama (Zaman Çizgisi) ──────────────────
                    HourlyTimelineWidget(dateKey: _currentDateKey),
                  ],
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
