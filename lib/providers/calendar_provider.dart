import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/daily_task.dart';
import '../models/day_entry.dart';

/// [CalendarProvider] — Uygulamanın tüm iş mantığını ve veri yönetimini üstlenen
/// merkezi [ChangeNotifier] sınıfıdır.
///
/// Hive kutularıyla doğrudan konuşur ve UI widgetlarına temiz bir API sunar.
/// Tüm yazma işlemleri eşzamansız (async) olarak gerçekleştirilir ve
/// Hive'a anında kaydedilir, böylece veri kalıcılığı garantilenir.
class CalendarProvider extends ChangeNotifier {
  // ── Hive Kutuları ─────────────────────────────────────────────────────────
  late Box<DailyTask> _taskBox;
  late Box<DayEntry> _entryBox;

  // ── UUID Üreteci ──────────────────────────────────────────────────────────
  final _uuid = const Uuid();

  // ── Seçili Gün Durumu ─────────────────────────────────────────────────────
  DateTime _selectedDay = DateTime.now();

  /// Şu an seçili olan gün (takvim grid'inde tıklanan gün)
  DateTime get selectedDay => _selectedDay;

  // ── Takvim Ay Navigasyonu ─────────────────────────────────────────────────
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  /// Takvim grid'inin gösterdiği ay
  DateTime get focusedMonth => _focusedMonth;

  // ── Sağ Panel Görünürlüğü ─────────────────────────────────────────────────
  bool _isDayPanelOpen = false;

  /// Sağ taraftaki gün detay panelinin açık olup olmadığı
  bool get isDayPanelOpen => _isDayPanelOpen;

  // ──────────────────────────────────────────────────────────────────────────
  // Başlatma
  // ──────────────────────────────────────────────────────────────────────────

  /// Hive kutularını açar ve provider'ı kullanıma hazır hâle getirir.
  /// [main.dart] içinde [runApp] çağrılmadan önce çağrılmalıdır.
  Future<void> init() async {
    _taskBox = await Hive.openBox<DailyTask>('daily_tasks');
    _entryBox = await Hive.openBox<DayEntry>('day_entries');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Navigasyon & Seçim
  // ──────────────────────────────────────────────────────────────────────────

  /// Takvimde bir güne tıklanıldığında seçili günü günceller ve
  /// detay panelini açar.
  void selectDay(DateTime day) {
    _selectedDay = day;
    _isDayPanelOpen = true;
    notifyListeners();
  }

  /// Sağ detay panelini kapatır.
  void closeDayPanel() {
    _isDayPanelOpen = false;
    notifyListeners();
  }

  /// Takvimi bir önceki aya kaydırır.
  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  /// Takvimi bir sonraki aya kaydırır.
  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Görev (Task) CRUD İşlemleri
  // ──────────────────────────────────────────────────────────────────────────

  /// Belirli bir tarihe ait tüm görevleri döndürür.
  /// [dateKey] formatı: "yyyy-MM-dd"
  List<DailyTask> getTasksForDay(String dateKey) {
    return _taskBox.values
        .where((t) => t.dateKey == dateKey)
        .toList()
      ..sort((a, b) {
        // Saatli görevleri önce, sonra saatsizleri getir
        final aH = a.hour ?? 99;
        final bH = b.hour ?? 99;
        return aH.compareTo(bH);
      });
  }

  /// Belirli bir saat dilimine ait görevleri döndürür.
  /// [hour] null ise genel (saatsiz) görevleri döndürür.
  List<DailyTask> getTasksForHour(String dateKey, int hour) {
    return _taskBox.values
        .where((t) => t.dateKey == dateKey && t.hour == hour)
        .toList();
  }

  /// Belirli bir tarihin genel (saate bağlı olmayan) görevlerini döndürür.
  List<DailyTask> getGeneralTasksForDay(String dateKey) {
    return _taskBox.values
        .where((t) => t.dateKey == dateKey && t.hour == null)
        .toList();
  }

  /// Yeni bir görev ekler ve anında Hive'a kaydeder.
  Future<void> addTask({
    required String title,
    required String dateKey,
    int? hour,
  }) async {
    final task = DailyTask(
      id: _uuid.v4(),
      title: title,
      dateKey: dateKey,
      hour: hour,
    );
    await _taskBox.put(task.id, task);
    notifyListeners();
  }

  /// Görevin tamamlanma durumunu tersine çevirir (toggle).
  Future<void> toggleTask(DailyTask task) async {
    task.isCompleted = !task.isCompleted;
    await task.save(); // Hive HiveObject.save() ile anında kaydeder
    notifyListeners();
  }

  /// Görevi kalıcı olarak siler.
  Future<void> deleteTask(DailyTask task) async {
    await task.delete();
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Günlük Not İşlemleri
  // ──────────────────────────────────────────────────────────────────────────

  /// Belirli bir güne ait [DayEntry] nesnesini döndürür.
  /// Eğer o gün için kayıt yoksa null döner.
  DayEntry? getEntryForDay(String dateKey) {
    return _entryBox.get(dateKey);
  }

  /// "O Gün Yaptıklarım" metnini günceller veya ilk kez oluşturur.
  Future<void> saveDailyNote(String dateKey, String note) async {
    final existing = _entryBox.get(dateKey);
    if (existing != null) {
      existing.dailyNote = note;
      await existing.save();
    } else {
      final entry = DayEntry(dateKey: dateKey, dailyNote: note);
      await _entryBox.put(dateKey, entry);
    }
    // Not kaydedildiğinde takvim grid'ini de güncellemek için bildir
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Yardımcı Metodlar
  // ──────────────────────────────────────────────────────────────────────────

  /// DateTime nesnesini "yyyy-MM-dd" formatında string'e dönüştürür.
  static String formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Bir günün herhangi bir verisi (not veya görev) olup olmadığını kontrol eder.
  /// Takvim grid'indeki küçük göstergeler için kullanılır.
  bool hasDataForDay(String dateKey) {
    final hasTasks = _taskBox.values.any((t) => t.dateKey == dateKey);
    final hasNote = (_entryBox.get(dateKey)?.dailyNote.isNotEmpty) ?? false;
    return hasTasks || hasNote;
  }

  /// Belirli bir günün tamamlanmış görev sayısını döndürür.
  int completedTaskCount(String dateKey) {
    return _taskBox.values
        .where((t) => t.dateKey == dateKey && t.isCompleted)
        .length;
  }

  /// Belirli bir günün toplam görev sayısını döndürür.
  int totalTaskCount(String dateKey) {
    return _taskBox.values.where((t) => t.dateKey == dateKey).length;
  }
}
