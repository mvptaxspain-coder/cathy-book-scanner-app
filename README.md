# Cathy Buch Scanner App

Eine Flutter-App zum Scannen, Speichern und Vorlesen von Büchern mit eigener Stimme.

## Features

### 📷 Buch Scanner
- Fotos mit Kamera aufnehmen
- Bilder aus Galerie auswählen
- OCR-Texterkennung mit Qwen2.5-VL (Modal)
- Mehrere Seiten scannen
- Als Buch speichern

### 📚 Meine Bücher
- Alle gescannten Bücher anzeigen
- Bücher öffnen und lesen
- Bücher löschen
- Letzte Lesezeit anzeigen

### 🎭 Stimmen Bibliothek
- Eigene Stimme aufnehmen
- Mehrere Stimmen speichern
- Stimmen anhören
- Stimmen verwalten

### 📖 Buch Vorlesen
- Bücher mit ausgewählter Stimme vorlesen
- Seitenweise Navigation
- Play/Pause Steuerung
- Automatisches Weiterblättern
- TTS mit ChatterboxTTS (Modal)

## Installation

### Voraussetzungen
- Flutter SDK (>=3.0.0)
- Android Studio / Xcode
- Modal OCR & TTS Services müssen laufen

### Setup

1. **Dependencies installieren:**
```bash
cd cathy_book_scanner_app
flutter pub get
```

2. **Android:**
```bash
flutter run -d android
```

3. **iOS:**
```bash
flutter run -d ios
```

## Verwendete Packages

- **provider**: State Management
- **image_picker**: Kamera & Galerie
- **record**: Audio-Aufnahme
- **audioplayers**: Audio-Wiedergabe
- **dio**: HTTP-Requests
- **shared_preferences**: Lokaler Speicher
- **google_fonts**: Schöne Schriftarten

## API-Endpunkte

### OCR Service
```
https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr
```

### TTS Service
```
https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts
```

## Berechtigungen

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Wir brauchen Kamerazugriff zum Scannen von Buchseiten</string>
<key>NSMicrophoneUsageDescription</key>
<string>Wir brauchen Mikrofonzugriff zum Aufnehmen deiner Stimme</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Wir brauchen Galerie-Zugriff zum Auswählen von Bildern</string>
```

## Projektstruktur

```
lib/
├── main.dart                      # App-Entry-Point
├── models/
│   ├── book.dart                  # Buch-Datenmodell
│   └── voice.dart                 # Stimmen-Datenmodell
├── providers/
│   ├── books_provider.dart        # Bücher State Management
│   └── voices_provider.dart       # Stimmen State Management
├── screens/
│   ├── home_screen.dart           # Haupt-Navigation
│   ├── book_scanner_screen.dart   # Scanner-Screen
│   ├── books_library_screen.dart  # Bücher-Bibliothek
│   ├── voice_library_screen.dart  # Stimmen-Bibliothek
│   └── book_reader_screen.dart    # Buch-Vorleser
├── services/
│   ├── storage_service.dart       # Lokaler Speicher
│   ├── ocr_service.dart           # OCR API
│   └── tts_service.dart           # TTS API
└── widgets/
    └── progress_dialog.dart       # Progress-Dialog
```

## Design

- **Material Design 3** mit dynamischen Farben
- **Gold-Theme** (`#D4AF37`) passend zu dabrock.eu
- **Poppins & Playfair Display** Schriftarten
- **Dark Mode** Support
- **Responsive** Layout

## Entwickler

Michael Dabrock
https://dabrock.eu
