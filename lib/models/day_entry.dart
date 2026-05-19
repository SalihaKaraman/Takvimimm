import 'package:hive/hive.dart';

// Hive kod üreteci için gerekli part direktifi
part 'day_entry.g.dart';

/// [DayEntry] — Belirli bir günün tüm serbest metin verilerini tutar.
///
/// Her gün için yalnızca bir [DayEntry] kaydı olur;
/// birincil anahtar [dateKey] ("yyyy-MM-dd") alanıdır.
/// Görevler ayrı [DailyTask] nesneleri olarak tutulur,
/// burası yalnızca günlük notları barındırır.
@HiveType(typeId: 1)
class DayEntry extends HiveObject {
  /// Günü tanımlayan birincil anahtar — "yyyy-MM-dd" formatı
  @HiveField(0)
  String dateKey;

  /// "O Gün Yaptıklarım" serbest metin alanı
  @HiveField(1)
  String dailyNote;

  DayEntry({
    required this.dateKey,
    this.dailyNote = '',
  });
}
