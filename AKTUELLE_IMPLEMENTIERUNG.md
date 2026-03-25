# 📋 Aktuelle Implementierung - Cathy Book Scanner App

## Technologie-Stack

### Frontend Framework
- **Flutter 3.19.6** (Stable Channel)
- **Dart 3.x**
- **Material Design 3** mit dynamischen Farben

### State Management
- ✅ **Provider Pattern** (ChangeNotifier)
- ❌ **NICHT Riverpod** (siehe IMPLEMENTATION_PLAN.md für Migration)
- ❌ **NICHT Bloc/Cubit**

### HTTP Client
- ✅ **Dio 5.4.0**
- ❌ **NICHT http package**
- Features: Timeout (120s), FormData für Multipart-Uploads

### Storage
- ✅ **SharedPreferences** für lokale Datenspeicherung (JSON)
- ❌ **NICHT flutter_secure_storage** (API-URLs sind im Code!)
- ❌ **KEINE Verschlüsselung** der gespeicherten Daten

### Audio
- **record 5.0.4** - Sprachaufnahme
- **audioplayers 5.2.1** - Audio-Wiedergabe

### Kamera
- **image_picker 1.0.5** - Kamera & Galerie-Zugriff

### UI
- **google_fonts 6.1.0** - Poppins-Schriftart
- **intl 0.18.1** - Datum/Zeit-Formatierung

---

## Architektur-Übersicht

```
lib/
├── main.dart                    # App-Einstiegspunkt
├── models/                      # Datenmodelle
│   ├── book.dart                # Book & BookPage Models
│   └── voice.dart               # Voice Model
├── providers/                   # State Management (Provider)
│   ├── books_provider.dart      # BooksProvider (ChangeNotifier)
│   └── voices_provider.dart     # VoicesProvider (ChangeNotifier)
├── services/                    # Business Logic
│   ├── storage_service.dart     # SharedPreferences Wrapper
│   ├── ocr_service.dart         # OCR API-Calls (Qwen2.5-VL)
│   └── tts_service.dart         # TTS API-Calls (ChatterboxTTS)
├── screens/                     # UI Screens
│   ├── home_screen.dart         # Hauptmenü
│   ├── book_scanner_screen.dart # Scanner
│   ├── books_library_screen.dart # Bücherverwaltung
│   ├── voice_library_screen.dart # Stimmenverwaltung
│   └── book_reader_screen.dart  # Vorlese-Screen
└── widgets/                     # Wiederverwendbare Komponenten
    └── progress_dialog.dart     # Loading-Dialog
```

---

## API-Integration

### OCR-Service (Qwen2.5-VL auf Modal)

**Endpoint:**
```
https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr
```

**Implementation:**
```dart
// lib/services/ocr_service.dart
class OcrService {
  static const String _ocrApiUrl = 'https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
  ));

  Future<String> extractText(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'page.jpg',
      ),
    });

    final response = await _dio.post(_ocrApiUrl, data: formData);

    if (response.statusCode == 200) {
      final result = response.data;
      if (result['status'] == 'error') {
        throw Exception('OCR Error: ${result['error']}');
      }
      return result['text']?.toString().trim() ?? '';
    }
    throw Exception('OCR API returned status ${response.statusCode}');
  }
}
```

**Request Format:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body: `file` (JPG/PNG Image)

**Response Format:**
```json
{
  "status": "success",
  "text": "Extracted text here..."
}
```

### TTS-Service (ChatterboxTTS auf Modal)

**Endpoint:**
```
https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts
```

**Implementation:**
```dart
// lib/services/tts_service.dart
class TtsService {
  static const String _ttsApiUrl = 'https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
  ));

  Future<File> synthesizeSpeech(String text, {File? voiceFile}) async {
    final formData = FormData.fromMap({
      'text': text,
      if (voiceFile != null)
        'voice_file': await MultipartFile.fromFile(
          voiceFile.path,
          filename: 'voice.wav',
        ),
    });

    final response = await _dio.post(_ttsApiUrl, data: formData);

    if (response.statusCode == 200) {
      final result = response.data;
      if (result['status'] == 'error') {
        throw Exception('TTS Error: ${result['error']}');
      }

      // Decode base64 audio
      final audioBase64 = result['audio'] as String;
      final audioBytes = _base64Decode(audioBase64);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final audioFile = File(
        '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await audioFile.writeAsBytes(audioBytes);

      return audioFile;
    }
    throw Exception('TTS API returned status ${response.statusCode}');
  }
}
```

**Request Format:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body:
  - `text` (String) - Text zum Vorlesen
  - `voice_file` (Optional WAV) - Stimme zum Klonen

**Response Format:**
```json
{
  "status": "success",
  "audio": "base64_encoded_wav_data..."
}
```

---

## Sicherheitsprobleme ⚠️

### 1. Hardcoded API-URLs
**Problem:** URLs sind direkt im Code
**Impact:** Keine Flexibilität, keine Secrets-Rotation
**Lösung:** flutter_secure_storage (siehe IMPLEMENTATION_PLAN.md)

### 2. Keine API-Authentifizierung
**Problem:** Jeder kann die APIs nutzen
**Impact:** Potentiell unbegrenzte Kosten
**Lösung:** API-Keys hinzufügen

### 3. Keine Rate Limiting
**Problem:** App kann unbegrenzt API-Calls machen
**Impact:** Hohe Modal-Kosten
**Lösung:** QuotaService implementieren (siehe IMPLEMENTATION_PLAN.md)

### 4. Keine Request-Validierung
**Problem:** Keine File-Size-Limits, keine Format-Checks
**Impact:** Fehleranfällig, lange Requests
**Lösung:** Client-side Validierung

### 5. Unverschlüsselte lokale Daten
**Problem:** Bücher und Stimmen in Klartext
**Impact:** Bei Geräteverlust lesbar
**Lösung:** Encrypted SharedPreferences

---

## Performance-Probleme 🐌

### 1. Keine Caching-Strategie
**Problem:** Gleiche OCR/TTS-Requests mehrfach
**Impact:** Langsam, teuer
**Lösung:** CacheService (siehe IMPLEMENTATION_PLAN.md)

### 2. Synchrone State-Updates
**Problem:** UI blockiert während API-Calls
**Impact:** Schlechte UX
**Lösung:** Optimistic UI-Updates

### 3. Große Bilddateien
**Problem:** Keine Kompression vor Upload
**Impact:** Lange Upload-Zeiten
**Lösung:** Image-Compression

### 4. Keine Pagination
**Problem:** Alle Bücher/Stimmen laden
**Impact:** Langsam bei vielen Büchern
**Lösung:** Lazy Loading

---

## Testing-Status 🧪

### Unit Tests
- ❌ **0 Tests geschrieben**
- Keine Tests für Services
- Keine Tests für Providers
- Keine Tests für Models

### Integration Tests
- ❌ **0 Tests geschrieben**

### Widget Tests
- ❌ **0 Tests geschrieben**

### E2E Tests
- ❌ **0 Tests geschrieben**

**TODO:** Test-Suite aufbauen (siehe IMPLEMENTATION_PLAN.md)

---

## Build & Deployment

### Local Build (funktioniert NICHT)
❌ Flutter SDK auf WSL langsam/problematisch
❌ Docker nicht verfügbar in WSL2

### GitHub Actions (VERWENDET)
✅ `.github/workflows/build-apk.yml`
✅ Automatischer Build bei jedem Push
✅ APK als Artifact verfügbar
✅ Repository: https://github.com/mvptaxspain-coder/cathy-book-scanner-app

**Siehe:** DOCKER_WORKAROUND_DOKUMENTATION.md

---

## Antworten auf deine Fragen:

### 1. Dio oder http verwendet?
**Antwort:** ✅ **Dio 5.4.0**
- Timeout: 120 Sekunden
- FormData für Multipart-Uploads
- Keine Retry-Logic (TODO)

### 2. flutter_secure_storage für Keys?
**Antwort:** ❌ **NEIN**
- API-URLs sind hardcoded
- Keine Secrets-Management
- TODO: Siehe IMPLEMENTATION_PLAN.md Phase 1.1

### 3. Riverpod oder Bloc für State Management?
**Antwort:** ❌ **Weder noch**
- Aktuell: **Provider Pattern** mit ChangeNotifier
- TODO: Migration zu Riverpod (siehe IMPLEMENTATION_PLAN.md Phase 2.1)

### 4. Obergrenzen für API-Nutzung?
**Antwort:** ❌ **NEIN**
- Keine Rate Limits
- Keine Quota-Verwaltung
- Keine Kosten-Tracking
- TODO: QuotaService (siehe IMPLEMENTATION_PLAN.md Phase 1.2)

---

## Next Steps

1. ✅ **APK-Build abwarten** (läuft gerade auf GitHub Actions)
2. **APK testen** und auf dabrock.eu deployen
3. **Phase 1.1 starten:** flutter_secure_storage einbauen
4. **Phase 1.2 starten:** Rate Limiting implementieren

---

## Kontakt & Links

**GitHub Repository:** https://github.com/mvptaxspain-coder/cathy-book-scanner-app
**Download-Seite:** https://dabrock.eu/app-download.html (nach APK-Upload)
**OCR-API:** https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr
**TTS-API:** https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts

---

Stand: 25.03.2026
Version: 1.0.0
