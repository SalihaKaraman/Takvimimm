import 'package:hive/hive.dart';

// Hive kod üreteci için gerekli part direktifi
part 'daily_task.g.dart';

/// [DailyTask] — Belirli bir güne ait tek bir yapılacak görev öğesini temsil eder.
///
/// [dateKey] alanı "yyyy-MM-dd" formatında tutulur; bu sayede
/// belirli bir günün görevleri veritabanından kolayca sorgulanır.
/// [hour] alanı null ise görev günlük listeye aittir; bir değer
/// taşıyorsa belirli bir saatlik zaman dilimine bağlanmış demektir.
@HiveType(typeId: 0)
class DailyTask extends HiveObject {
  /// Görevin benzersiz kimliği (UUID formatında)
  @HiveField(0)
  String id;

  /// Görevin kısa başlık metni
  @HiveField(1)
  String title;

  /// Görevin tamamlanıp tamamlanmadığını belirten bayrak
  @HiveField(2)
  bool isCompleted;

  /// Görevin ait olduğu günü temsil eden anahtar — "yyyy-MM-dd"
  @HiveField(3)
  String dateKey;

  /// Saatlik planlama için saat değeri (0–23). Genel görevlerde null'dır.
  @HiveField(4)
  int? hour;

  DailyTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dateKey,
    this.hour,
  });
}
