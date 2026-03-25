# 🎯 Implementation Plan - App Verbesserungen

## Aktuelle Situation (Stand: 25.03.2026)

### ✅ Was bereits funktioniert:
- Flutter-App mit 4 Hauptfeatures (Scanner, Library, Voices, Reader)
- Dio HTTP Client für API-Calls
- Provider für State Management
- SharedPreferences für lokale Datenspeicherung
- OCR-Integration mit Qwen2.5-VL auf Modal
- TTS-Integration mit ChatterboxTTS auf Modal
- Material Design 3 mit Gold-Theme
- GitHub Actions für automatische APK-Builds

### ⚠️ Was fehlt (Sicherheit & Best Practices):
1. ❌ Keine sichere Speicherung der API-URLs
2. ❌ Keine API Rate Limiting / Quota-Verwaltung
3. ❌ State Management könnte robuster sein (Riverpod statt Provider)
4. ❌ Keine Error-Boundaries und Retry-Logik
5. ❌ Keine Offline-First Strategie
6. ❌ Keine API-Key-Authentifizierung

---

## Phase 1: Sicherheit & Konfiguration (Priorität: HOCH)

### 1.1 Flutter Secure Storage einbauen

**Problem:** API-URLs sind hart im Code kodiert.

**Lösung:**
```dart
// Neue Dependency in pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0

// Neues File: lib/config/api_config.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const _storage = FlutterSecureStorage();

  // Default-URLs (können überschrieben werden)
  static const String defaultOcrUrl =
    'https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr';
  static const String defaultTtsUrl =
    'https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts';

  // API-URLs aus Secure Storage lesen
  static Future<String> getOcrUrl() async {
    return await _storage.read(key: 'ocr_url') ?? defaultOcrUrl;
  }

  static Future<String> getTtsUrl() async {
    return await _storage.read(key: 'tts_url') ?? defaultTtsUrl;
  }

  // URLs setzen (für zukünftige Änderungen)
  static Future<void> setOcrUrl(String url) async {
    await _storage.write(key: 'ocr_url', value: url);
  }

  static Future<void> setTtsUrl(String url) async {
    await _storage.write(key: 'tts_url', value: url);
  }

  // Optional: API-Keys für authentifizierte Requests
  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }

  static Future<void> setApiKey(String key) async {
    await _storage.write(key: 'api_key', value: key);
  }
}
```

**Changes in Services:**
```dart
// lib/services/ocr_service.dart
class OcrService {
  Future<String> extractText(File imageFile) async {
    final ocrUrl = await ApiConfig.getOcrUrl();  // ← Dynamisch
    final apiKey = await ApiConfig.getApiKey();

    final headers = apiKey != null ? {'X-API-Key': apiKey} : null;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _dio.post(
      ocrUrl,
      data: formData,
      options: Options(headers: headers),
    );
    // ...
  }
}
```

**Settings-Screen hinzufügen:**
```dart
// lib/screens/settings_screen.dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Einstellungen')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('API-Einstellungen'),
            subtitle: const Text('URLs und Keys konfigurieren'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ApiSettingsScreen()),
            ),
          ),
          ListTile(
            title: const Text('Quota-Übersicht'),
            subtitle: const Text('API-Nutzung anzeigen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuotaScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Aufwand:** 2-3 Stunden
**Dateien:** `lib/config/api_config.dart`, `lib/screens/settings_screen.dart`, Updates in Services

---

### 1.2 API Rate Limiting & Quota-Verwaltung

**Problem:** Keine Kontrolle über API-Nutzung, potentiell hohe Modal-Kosten.

**Lösung:**
```dart
// lib/services/quota_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class QuotaService {
  static const int dailyOcrLimit = 100;    // 100 OCR-Requests/Tag
  static const int dailyTtsLimit = 50;     // 50 TTS-Requests/Tag
  static const int monthlyCostLimit = 20;  // $20/Monat

  // Zähler für heutigen Tag
  static Future<int> getOcrCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString('ocr_date') ?? '';

    if (lastDate != today) {
      await prefs.setString('ocr_date', today);
      await prefs.setInt('ocr_count', 0);
      return 0;
    }

    return prefs.getInt('ocr_count') ?? 0;
  }

  static Future<void> incrementOcrCount() async {
    final count = await getOcrCount();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ocr_count', count + 1);
  }

  static Future<bool> canUseOcr() async {
    final count = await getOcrCount();
    return count < dailyOcrLimit;
  }

  // Ähnlich für TTS
  static Future<int> getTtsCount() async { /* ... */ }
  static Future<void> incrementTtsCount() async { /* ... */ }
  static Future<bool> canUseTts() async { /* ... */ }

  // Geschätzte Kosten
  static Future<double> getEstimatedCosts() async {
    final ocrCount = await getOcrCount();
    final ttsCount = await getTtsCount();

    const ocrCostPerRequest = 0.05;  // $0.05 pro OCR
    const ttsCostPerRequest = 0.10;  // $0.10 pro TTS

    return (ocrCount * ocrCostPerRequest) + (ttsCount * ttsCostPerRequest);
  }

  // Quota zurücksetzen (z.B. monatlich)
  static Future<void> resetMonthlyQuota() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ocr_count', 0);
    await prefs.setInt('tts_count', 0);
  }
}
```

**Integration in Services:**
```dart
// lib/services/ocr_service.dart
class OcrService {
  Future<String> extractText(File imageFile) async {
    // Quota prüfen BEVOR API-Call
    if (!await QuotaService.canUseOcr()) {
      throw Exception('Tägliches OCR-Limit erreicht (${QuotaService.dailyOcrLimit})');
    }

    try {
      final text = await _performOcr(imageFile);
      await QuotaService.incrementOcrCount();  // Zähler erhöhen
      return text;
    } catch (e) {
      // Bei Fehler NICHT zählen
      rethrow;
    }
  }
}
```

**UI-Anzeige:**
```dart
// lib/screens/quota_screen.dart
class QuotaScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 API-Nutzung')),
      body: FutureBuilder(
        future: Future.wait([
          QuotaService.getOcrCount(),
          QuotaService.getTtsCount(),
          QuotaService.getEstimatedCosts(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final ocrCount = snapshot.data![0] as int;
          final ttsCount = snapshot.data![1] as int;
          final costs = snapshot.data![2] as double;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Heute', style: Theme.of(context).textTheme.headlineSmall),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: ocrCount / QuotaService.dailyOcrLimit,
                      ),
                      Text('OCR: $ocrCount / ${QuotaService.dailyOcrLimit}'),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ttsCount / QuotaService.dailyTtsLimit,
                      ),
                      Text('TTS: $ttsCount / ${QuotaService.dailyTtsLimit}'),
                    ],
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Geschätzte Kosten'),
                  subtitle: Text('Heute'),
                  trailing: Text('\$${costs.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

**Aufwand:** 3-4 Stunden
**Dateien:** `lib/services/quota_service.dart`, `lib/screens/quota_screen.dart`, Updates in Services

---

## Phase 2: State Management mit Riverpod (Priorität: MITTEL)

### 2.1 Migration von Provider zu Riverpod

**Warum Riverpod?**
- ✅ Compile-time safety (keine Runtime-Fehler)
- ✅ Besseres Testing
- ✅ Keine BuildContext nötig
- ✅ Auto-dispose
- ✅ Bessere DevTools

**Migration Steps:**

```yaml
# pubspec.yaml
dependencies:
  # provider: ^6.1.1  ← Entfernen
  flutter_riverpod: ^2.4.9  # ← Hinzufügen
```

```dart
// lib/providers/books_provider.dart (NEU mit Riverpod)
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider definieren
final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>((ref) {
  return BooksNotifier();
});

class BooksNotifier extends StateNotifier<List<Book>> {
  BooksNotifier() : super([]) {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await StorageService.instance.loadBooks();
    state = books;
  }

  Future<void> addBook(Book book) async {
    state = [...state, book];
    await StorageService.instance.saveBooks(state);
  }

  Future<void> deleteBook(String bookId) async {
    state = state.where((b) => b.id != bookId).toList();
    await StorageService.instance.saveBooks(state);
  }
}

// Ähnlich für Voices
final voicesProvider = StateNotifierProvider<VoicesNotifier, List<Voice>>((ref) {
  return VoicesNotifier();
});
```

```dart
// lib/main.dart (NEU mit Riverpod)
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();

  runApp(
    const ProviderScope(  // ← Riverpod Wrapper
      child: CathyBookScannerApp(),
    ),
  );
}

class CathyBookScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Kein MultiProvider mehr nötig!
      theme: ThemeData(...),
      home: const HomeScreen(),
    );
  }
}
```

```dart
// lib/screens/books_library_screen.dart (Update)
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooksLibraryScreen extends ConsumerWidget {  // ← ConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {  // ← WidgetRef
    final books = ref.watch(booksProvider);  // ← Kein Provider.of mehr!

    return Scaffold(
      appBar: AppBar(title: const Text('📚 Meine Bücher')),
      body: books.isEmpty
          ? Center(child: Text('Keine Bücher'))
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book.title),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookReaderScreen(book: book),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref.read(booksProvider.notifier).deleteBook(book.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
```

**Aufwand:** 4-5 Stunden
**Dateien:** Alle Provider und Screens aktualisieren

---

## Phase 3: Robustheit & Offline-Support (Priorität: MITTEL)

### 3.1 Error Handling & Retry Logic

```dart
// lib/services/network_service.dart
import 'package:dio/dio.dart';

class NetworkService {
  final Dio _dio;

  NetworkService(this._dio) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              return handler.resolve(await _retry(error.requestOptions));
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           (error.response?.statusCode ?? 0) >= 500;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    for (int i = 0; i < maxRetries; i++) {
      await Future.delayed(retryDelay * (i + 1));  // Exponential backoff

      try {
        return await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
      }
    }

    throw Exception('Max retries reached');
  }
}
```

### 3.2 Offline-First mit Cached Requests

```dart
// lib/services/cache_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  // OCR-Ergebnisse cachen
  static Future<void> cacheOcrResult(String imageHash, String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${dir.path}/ocr_cache/$imageHash.txt');
    await cacheFile.create(recursive: true);
    await cacheFile.writeAsString(text);
  }

  static Future<String?> getCachedOcrResult(String imageHash) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${dir.path}/ocr_cache/$imageHash.txt');
    if (await cacheFile.exists()) {
      return await cacheFile.readAsString();
    }
    return null;
  }

  // TTS-Audio cachen
  static Future<void> cacheTtsAudio(String textHash, File audioFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${dir.path}/tts_cache/$textHash.wav');
    await cacheFile.create(recursive: true);
    await audioFile.copy(cacheFile.path);
  }

  static Future<File?> getCachedTtsAudio(String textHash) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${dir.path}/tts_cache/$textHash.wav');
    if (await cacheFile.exists()) {
      return cacheFile;
    }
    return null;
  }
}
```

**Integration:**
```dart
// lib/services/ocr_service.dart
Future<String> extractText(File imageFile) async {
  // Hash berechnen
  final bytes = await imageFile.readAsBytes();
  final hash = sha256.convert(bytes).toString();

  // Cache prüfen
  final cached = await CacheService.getCachedOcrResult(hash);
  if (cached != null) {
    print('✅ OCR from cache');
    return cached;
  }

  // API-Call
  final text = await _performOcr(imageFile);

  // Ergebnis cachen
  await CacheService.cacheOcrResult(hash, text);

  return text;
}
```

**Aufwand:** 3-4 Stunden
**Dateien:** `lib/services/network_service.dart`, `lib/services/cache_service.dart`, Updates in OCR/TTS Services

---

## Phase 4: Monitoring & Analytics (Priorität: NIEDRIG)

### 4.1 Error Tracking mit Sentry

```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.14.0
```

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      const ProviderScope(child: CathyBookScannerApp()),
    ),
  );
}
```

### 4.2 Analytics mit Firebase

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
```

```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logOcrScan({
    required int pageCount,
    required Duration duration,
  }) async {
    await _analytics.logEvent(
      name: 'ocr_scan',
      parameters: {
        'page_count': pageCount,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }

  static Future<void> logBookRead({
    required String bookId,
    required int pageNumber,
  }) async {
    await _analytics.logEvent(
      name: 'book_read',
      parameters: {
        'book_id': bookId,
        'page_number': pageNumber,
      },
    );
  }
}
```

**Aufwand:** 2-3 Stunden
**Dateien:** Firebase-Setup, Analytics-Integration

---

## Zusammenfassung & Zeitplan

### Priorisierung:

| Phase | Feature | Priorität | Aufwand | Nutzen |
|-------|---------|-----------|---------|--------|
| 1.1 | Secure Storage | 🔴 HOCH | 2-3h | Sicherheit |
| 1.2 | Rate Limiting | 🔴 HOCH | 3-4h | Kostensparen |
| 2.1 | Riverpod Migration | 🟡 MITTEL | 4-5h | Code-Qualität |
| 3.1 | Error Handling | 🟡 MITTEL | 3-4h | Robustheit |
| 3.2 | Offline Support | 🟡 MITTEL | 3-4h | UX |
| 4.1 | Sentry | 🟢 NIEDRIG | 2-3h | Monitoring |
| 4.2 | Analytics | 🟢 NIEDRIG | 2-3h | Insights |

### Zeitplan:

**Woche 1:**
- Phase 1.1: Secure Storage (Tag 1-2)
- Phase 1.2: Rate Limiting (Tag 3-4)
- Testing & Bug Fixes (Tag 5)

**Woche 2:**
- Phase 2.1: Riverpod Migration (Tag 1-3)
- Phase 3.1: Error Handling (Tag 4-5)

**Woche 3:**
- Phase 3.2: Offline Support (Tag 1-3)
- Phase 4: Monitoring (Tag 4-5)

**Gesamt:** ~20-30 Stunden Entwicklung

---

## Nächste Schritte

1. **Jetzt:** APK-Build auf GitHub Actions abwarten
2. **Danach:** APK testen und auf dabrock.eu deployen
3. **Dann:** Mit Phase 1.1 (Secure Storage) starten

Soll ich mit Phase 1.1 anfangen, sobald die APK deployed ist?
