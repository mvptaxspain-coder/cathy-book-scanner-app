# Cathy Buch Scanner - Projektstruktur

## 📁 Verzeichnisstruktur

```
cathy_book_scanner_app/
│
├── android/                          # Android-spezifische Dateien
│   ├── app/
│   │   ├── src/main/
│   │   │   └── AndroidManifest.xml  # Permissions & App-Config
│   │   └── build.gradle              # Build-Konfiguration
│   └── build.gradle                  # Root Build-Config
│
├── ios/                              # iOS-spezifische Dateien
│   └── Runner/
│       └── Info.plist                # Permissions & App-Config
│
├── lib/                              # Haupt-Quellcode
│   │
│   ├── main.dart                     # App-Entry-Point
│   │
│   ├── models/                       # Daten-Modelle
│   │   ├── book.dart                 # Buch & BookPage
│   │   └── voice.dart                # Stimme
│   │
│   ├── providers/                    # State Management
│   │   ├── books_provider.dart       # Bücher-Verwaltung
│   │   └── voices_provider.dart      # Stimmen-Verwaltung
│   │
│   ├── services/                     # Business Logic
│   │   ├── storage_service.dart      # Lokaler Speicher
│   │   ├── ocr_service.dart          # OCR API-Calls
│   │   └── tts_service.dart          # TTS API-Calls
│   │
│   ├── screens/                      # UI-Screens
│   │   ├── home_screen.dart          # Navigation & Tabs
│   │   ├── book_scanner_screen.dart  # Scanner-Tab
│   │   ├── books_library_screen.dart # Bücher-Tab
│   │   ├── voice_library_screen.dart # Stimmen-Tab
│   │   └── book_reader_screen.dart   # Vorlese-Screen
│   │
│   └── widgets/                      # Wiederverwendbare Widgets
│       └── progress_dialog.dart      # Progress-Dialog
│
├── assets/                           # App-Assets
│   └── images/                       # Bilder & Icons
│
├── pubspec.yaml                      # Dependencies & Config
├── README.md                         # Haupt-Dokumentation
├── BUILD_GUIDE.md                    # Build-Anleitung
├── FEATURES.md                       # Feature-Übersicht
└── PROJEKTSTRUKTUR.md               # Diese Datei
```

---

## 📋 Datei-Beschreibungen

### Root-Level

#### `pubspec.yaml`
**Zweck:** Flutter-Projekt-Konfiguration
- App-Name, Version, Beschreibung
- Dependencies (Packages)
- Assets-Referenzen
- SDK-Versionen

**Wichtige Dependencies:**
- `provider` - State Management
- `image_picker` - Kamera & Galerie
- `record` - Audio-Aufnahme
- `audioplayers` - Audio-Wiedergabe
- `dio` - HTTP-Requests
- `shared_preferences` - Lokaler Speicher
- `google_fonts` - Schriftarten

---

### `/lib` - Hauptcode

#### `main.dart`
**Zweck:** App-Entry-Point
- App-Initialisierung
- Provider-Setup
- Theme-Konfiguration
- Material App Setup

**Wichtige Funktionen:**
```dart
void main() async {
  // Storage initialisieren
  // App starten
}
```

---

### `/lib/models` - Datenmodelle

#### `book.dart`
**Zweck:** Buch-Datenstruktur
```dart
class Book {
  String id
  String title
  List<BookPage> pages
  DateTime createdAt
  DateTime? lastRead
}

class BookPage {
  int pageNumber
  String text
  String? imagePath
}
```

**Methoden:**
- `toJson()` - Serialisierung
- `fromJson()` - Deserialisierung
- `totalPages` - Getter

#### `voice.dart`
**Zweck:** Stimmen-Datenstruktur
```dart
class Voice {
  String id
  String name
  String description
  String? audioPath
  DateTime createdAt
  bool isDefault
}
```

---

### `/lib/providers` - State Management

#### `books_provider.dart`
**Zweck:** Bücher-Zustandsverwaltung
```dart
class BooksProvider extends ChangeNotifier {
  List<Book> _books
  bool _isLoading

  // CRUD Operations
  loadBooks()
  addBook(Book)
  deleteBook(String id)
  updateBook(Book)
  getBook(String id)
}
```

**Verantwortlichkeiten:**
- Bücher laden/speichern
- UI benachrichtigen (notifyListeners)
- Storage-Service nutzen

#### `voices_provider.dart`
**Zweck:** Stimmen-Zustandsverwaltung
```dart
class VoicesProvider extends ChangeNotifier {
  List<Voice> _voices
  bool _isLoading

  // CRUD Operations
  loadVoices()
  addVoice(Voice)
  deleteVoice(String id)
  getVoice(String id)
  get defaultVoice
}
```

---

### `/lib/services` - Business Logic

#### `storage_service.dart`
**Zweck:** Lokaler Datenspeicher (SharedPreferences)

**Funktionen:**
```dart
class StorageService {
  // Singleton Pattern
  static final instance = StorageService._()

  // Bücher
  getBooks() -> List<Book>
  saveBooks(List<Book>)
  addBook(Book)
  deleteBook(String id)
  updateBook(Book)

  // Stimmen
  getVoices() -> List<Voice>
  saveVoices(List<Voice>)
  addVoice(Voice)
  deleteVoice(String id)
}
```

#### `ocr_service.dart`
**Zweck:** OCR-API-Integration (Qwen2.5-VL)

**API-Endpunkt:**
```
https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr
```

**Funktionen:**
```dart
class OcrService {
  extractText(File image) -> String
  extractTextFromMultipleImages(List<File>) -> List<String>
}
```

**Flow:**
1. Bild zu Base64 oder FormData
2. POST Request an Modal API
3. Response parsen (JSON)
4. Text extrahieren
5. Error Handling

#### `tts_service.dart`
**Zweck:** TTS-API-Integration (ChatterboxTTS)

**API-Endpunkt:**
```
https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts
```

**Funktionen:**
```dart
class TtsService {
  synthesizeSpeech(String text, File? voiceFile) -> File
}
```

**Flow:**
1. Text + optionale Stimme zu FormData
2. POST Request an Modal API
3. Base64 Audio empfangen
4. Base64 -> Bytes -> WAV File
5. Temporäre Datei speichern
6. File zurückgeben

---

### `/lib/screens` - UI-Screens

#### `home_screen.dart`
**Zweck:** Haupt-Navigation mit Bottom Navigation Bar

**Struktur:**
```dart
class HomeScreen extends StatefulWidget {
  int _currentIndex = 0
  List<Widget> _screens = [
    BookScannerScreen(),
    BooksLibraryScreen(),
    VoiceLibraryScreen(),
  ]
}
```

**Navigation:**
- Tab 0: Scanner 📷
- Tab 1: Meine Bücher 📚
- Tab 2: Stimmen 🎭

#### `book_scanner_screen.dart`
**Zweck:** Seiten scannen und als Buch speichern

**Features:**
- Kamera-Button
- Galerie-Button
- Seiten-Liste mit Thumbnails
- Seite löschen
- Als Buch speichern

**Flow:**
1. Foto aufnehmen/auswählen
2. Progress Dialog anzeigen
3. OCR durchführen
4. Seite zur Liste hinzufügen
5. Wiederholen für mehr Seiten
6. "Als Buch speichern" → Dialog → Speichern

#### `books_library_screen.dart`
**Zweck:** Alle Bücher anzeigen und verwalten

**Features:**
- Card-Layout für jedes Buch
- Buch-Informationen anzeigen
- Buch öffnen (→ Reader)
- Buch löschen
- Empty State

**UI-Elemente:**
- ListView mit Cards
- PopupMenu für Aktionen
- Confirmation Dialog

#### `voice_library_screen.dart`
**Zweck:** Stimmen aufnehmen und verwalten

**Features:**
- Stimmen-Liste
- Stimme aufnehmen (FAB)
- Stimme anhören
- Stimme löschen
- Standard-Stimme geschützt

**Recording-Flow:**
1. FAB drücken → Dialog
2. Name eingeben
3. "Aufnahme starten" → Recording
4. "Aufnahme stoppen" → Vorschau
5. "Anhören" (optional)
6. "Speichern" → Fertig

#### `book_reader_screen.dart`
**Zweck:** Buch vorlesen mit TTS

**Features:**
- Stimmen-Dropdown
- Seiten-Navigation (Prev/Next)
- Seiten-Anzeige
- Bild + Text anzeigen
- Play/Pause/Skip Controls
- Automatisches Weiterblättern

**TTS-Flow:**
1. Seite auswählen
2. Stimme auswählen
3. Play drücken
4. Progress Dialog
5. TTS-Synthese
6. Audio abspielen
7. Bei Ende → Nächste Seite (auto)

---

### `/lib/widgets` - Komponenten

#### `progress_dialog.dart`
**Zweck:** Wiederverwendbarer Progress Dialog

**Verwendung:**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => ProgressDialog(
    message: 'Verarbeite...',
  ),
);
```

---

## 🔄 Datenfluss

### 1. Buch scannen und speichern
```
User → BookScannerScreen
  → ImagePicker (Foto)
  → OcrService.extractText()
    → Modal API
  ← Text zurück
  → _scannedPages.add()
  → "Speichern" Button
  → BooksProvider.addBook()
    → StorageService.addBook()
      → SharedPreferences
```

### 2. Buch vorlesen
```
User → BooksLibraryScreen
  → Buch auswählen
  → BookReaderScreen
  → Stimme wählen
  → Play Button
  → TtsService.synthesizeSpeech()
    → Modal API (mit voice_file)
  ← Audio File
  → AudioPlayer.play()
  → Bei Ende: Nächste Seite
```

### 3. Stimme aufnehmen
```
User → VoiceLibraryScreen
  → FAB "+"
  → Dialog öffnen
  → "Aufnahme starten"
  → AudioRecorder.start()
  → User spricht...
  → "Aufnahme stoppen"
  → AudioRecorder.stop()
  → Vorschau anhören (optional)
  → "Speichern"
  → VoicesProvider.addVoice()
    → StorageService.addVoice()
      → SharedPreferences
```

---

## 🎨 UI-Hierarchie

```
MaterialApp
└── MultiProvider
    ├── BooksProvider
    └── VoicesProvider
        └── HomeScreen
            └── NavigationBar
                ├── Tab 0: BookScannerScreen
                │   ├── AppBar
                │   ├── Action Buttons
                │   ├── Scanned Pages List
                │   └── Save Button
                │
                ├── Tab 1: BooksLibraryScreen
                │   ├── AppBar
                │   └── ListView
                │       └── Book Cards
                │           └── PopupMenu
                │
                └── Tab 2: VoiceLibraryScreen
                    ├── AppBar
                    ├── ListView
                    │   └── Voice Cards
                    └── FAB
                        └── Recording Dialog

BookReaderScreen (separate)
├── AppBar
├── Voice Selector Card
├── Page Navigation Row
├── Page Content (scrollable)
└── Player Controls
```

---

## 🔐 Permissions

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS (`Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Kamerazugriff für Buchseiten-Scan</string>

<key>NSMicrophoneUsageDescription</key>
<string>Mikrofonzugriff für Stimmenaufnahme</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Galerie-Zugriff für Bildauswahl</string>
```

---

## 🧩 Dependencies-Übersicht

| Package | Version | Zweck |
|---------|---------|-------|
| `provider` | ^6.1.1 | State Management |
| `image_picker` | ^1.0.5 | Kamera & Galerie |
| `camera` | ^0.10.5 | Kamera-Preview |
| `record` | ^5.0.4 | Audio-Aufnahme |
| `audioplayers` | ^5.2.1 | Audio-Wiedergabe |
| `dio` | ^5.4.0 | HTTP-Client |
| `shared_preferences` | ^2.2.2 | Lokaler Speicher |
| `path_provider` | ^2.1.1 | Dateipfade |
| `google_fonts` | ^6.1.0 | Schriftarten |
| `uuid` | ^4.2.2 | Unique IDs |
| `intl` | ^0.19.0 | Datumsformatierung |

---

## 📦 Build-Artefakte

### Android
```
build/app/outputs/
├── flutter-apk/
│   ├── app-debug.apk          # Debug APK
│   └── app-release.apk        # Release APK
└── bundle/release/
    └── app-release.aab        # App Bundle für Play Store
```

### iOS
```
build/ios/
├── ipa/
│   └── cathy_book_scanner.ipa # IPA für App Store
└── Runner.app                  # App Binary
```

---

## 🔧 Entwicklung

### Hot Reload
```bash
# App läuft bereits
# Code ändern
# In Terminal: r (Hot Reload) oder R (Hot Restart)
```

### Debugging
```bash
# Debug-Modus starten
flutter run --debug

# Logs anzeigen
flutter logs

# DevTools öffnen
flutter pub global activate devtools
flutter pub global run devtools
```

### Testing
```bash
# Unit Tests
flutter test

# Integration Tests
flutter drive --target=test_driver/app.dart

# Widget Tests
flutter test test/widget_test.dart
```

---

## 📝 Code-Konventionen

### Naming
- **Klassen**: `PascalCase` (z.B. `BookScannerScreen`)
- **Variablen**: `camelCase` (z.B. `currentIndex`)
- **Private**: `_camelCase` (z.B. `_books`)
- **Konstanten**: `UPPER_SNAKE_CASE` (z.B. `OCR_API_URL`)

### Datei-Namen
- **Screens**: `*_screen.dart`
- **Widgets**: `*_widget.dart`
- **Services**: `*_service.dart`
- **Models**: `*.dart` (ohne Suffix)

### Imports
```dart
// 1. Dart-Packages
import 'dart:io';

// 2. Flutter-Packages
import 'package:flutter/material.dart';

// 3. Externe Packages
import 'package:provider/provider.dart';

// 4. Lokale Imports
import '../models/book.dart';
```

---

Diese Struktur ist modular, skalierbar und folgt Flutter Best Practices!
