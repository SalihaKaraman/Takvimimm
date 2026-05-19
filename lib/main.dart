import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'models/daily_task.dart';
import 'models/day_entry.dart';
import 'providers/calendar_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  // Flutter widget ağacının ve yerel kanalların hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Yerel Dil Desteği Başlatma ──────────────────────────────────────────
  // Takvim ve panellerdeki Türkçe gün/ay isimleri için intl paketini yapılandırıyoruz
  await initializeDateFormatting('tr_TR', null);

  // ── 2. Hive NoSQL Veritabanı Kurulumu ──────────────────────────────────────
  // Hive uygulamanın yerel veri depolama motorudur. Kapandığında veriler kaybolmaz.
  await Hive.initFlutter();

  // Hive Adaptörlerini Kaydediyoruz (build_runner ile üretilen kodlar)
  Hive.registerAdapter(DailyTaskAdapter());
  Hive.registerAdapter(DayEntryAdapter());

  // ── 3. Provider ve İş Mantığı Başlatma ────────────────────────────────────
  final calendarProvider = CalendarProvider();
  await calendarProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CalendarProvider>.value(value: calendarProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takvimimm — Masaüstü Planlayıcı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
