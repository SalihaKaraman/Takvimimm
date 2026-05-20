# Takvimimm — Masaüstü Planlayıcı

🗓️ **Takvimimm**, macOS için geliştirilmiş şık ve modern bir masaüstü takvim ve planlayıcı uygulamasıdır. Günlük görevlerinizi yönetin, saatlik zamanlamanız yapın ve her günün notlarını tutun — hepsi yerel ve gizli kalarak.

## 🎯 Özellikler

### 📅 Aylık Takvim Görünümü
- Günü güne takvim ızgarası
- Türkçe gün ve ay isimleri
- **Modern Modal Detay Penceresi:** Seçilen günün detayları ekranın tam ortasında süzülen şık bir pencerede açılır
- **Buzlu Cam (Backdrop Blur) & Karartma:** Detay modalı açıldığında arka plan yumuşak bir şekilde bulanıklaşır ve karartılır

### ✅ Görev Yönetimi
- **Günlük görevler**: Her gün için yapılacak görevler listesi oluşturun
- **Saatlik planlama**: Görevlerinizi belirli saatlere (0-23) atayın
- **Tamamlanma takibi**: Görevleri işaretleyerek ilerlemenizi takip edin
- **Hızlı ekleme**: Dialog arayüzü ile kolayca yeni görev ekleyin

### ⏰ Saatlik Zaman Çizelgesi
- Günü saat saat görüntüleyin
- Her saate atanmış görevleri see edin
- Saatlik görevleri yönetin ve düzenleyin

### 📝 Günlük Notlar
- "O Gün Yaptıklarım" bölümünde özet notlar tutun
- Günün sonunda yapılanları kaydedin

### 💾 Yerel Veri Depolama
- **Hive NoSQL** veritabanı kullanarak tüm veriler cihazda saklanır
- İnternet bağlantısı gerekmez
- Veriler gizli ve güvenli kalır
- Kapanış sonrasında otomatik olarak korunur

### 🎨 Modern Tasarım
- Türkçe tam dil desteği
- Derin gece mavisi tabanlı koyu tema ve neon lavanta aksan renkleri
- **Buzlu Cam Arayüzü:** Modal açıldığında arka plana `BackdropFilter` ile uygulanan ultra pürüzsüz estetik blur
- **Premium Animasyonlu Geçiş:** `AnimatedSwitcher` entegrasyonu ile yumuşak büyüyen (Scale) ve beliren (Fade) modal animasyonları (`Curves.easeOutBack`)
- **Masaüstü Odaklı Pratik UX:** Klavyeden `ESC` tuşuyla veya modal dışındaki herhangi bir boşluğa tıklayarak pencereyi anında kapatabilme desteği

## 🚀 Başlangıç

### Gereksinimler
- Flutter (en son sürüm)
- macOS 10.11 veya üzeri
- Dart SDK

### Kurulum
```bash
# Proje dizinine gidin
cd Takvimimm

# Bağımlılıkları yükleyin
flutter pub get

# Kod üretici çalıştırın (Hive adaptörleri için)
dart run build_runner build

# Uygulamayı çalıştırın
flutter run -d macos
```

## 📦 Teknolojiler

- **Framework**: Flutter
- **Durum Yönetimi**: Provider
- **Veri Depolama**: Hive (NoSQL)
- **Lokalizasyon**: intl (Türkçe destek)
- **Kod Üretimi**: build_runner, json_serializable

## 📁 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama başlatma ve yapılandırma
├── models/                   # Veri modelleri (DailyTask, DayEntry)
├── providers/                # State management (CalendarProvider)
└── ui/
    ├── screens/              # Ana ekran (HomeScreen)
    ├── theme/                # Tema tanımlamaları (AppTheme)
    └── widgets/              # UI bileşenleri
        ├── month_grid_widget.dart
        ├── day_detail_panel_widget.dart
        ├── hourly_timeline_widget.dart
        ├── todo_section_widget.dart
        └── add_task_dialog.dart
```

## 📖 Daha Fazla Bilgi

- [Flutter Belgeleri](https://docs.flutter.dev/)
- [Provider Paketi](https://pub.dev/packages/provider)
- [Hive Paketi](https://pub.dev/packages/hive)
