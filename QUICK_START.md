# Quick Start - Cathy Buch Scanner App

## 🚀 Schnellstart (5 Minuten)

### Schritt 1: Flutter prüfen
```bash
flutter doctor
```

**Ergebnis sollte sein:**
```
✓ Flutter (Channel stable, 3.x.x)
✓ Android toolchain
✓ Chrome - develop for the web
✓ Android Studio
✓ VS Code
```

Falls Fehler: `flutter doctor` Anweisungen folgen.

---

### Schritt 2: Projekt öffnen
```bash
cd /mnt/e/CodelocalLLM/cathy_book_scanner_app
```

---

### Schritt 3: Dependencies installieren
```bash
flutter pub get
```

**Dauert:** ~30 Sekunden

**Ausgabe:**
```
Running "flutter pub get" in cathy_book_scanner_app...
✓ All dependencies resolved
```

---

### Schritt 4: Gerät verbinden

#### Option A: Android-Gerät (USB)
1. USB-Debugging aktivieren auf dem Handy
2. Handy per USB verbinden
3. Prüfen:
```bash
flutter devices
```

#### Option B: Android-Emulator
```bash
# Emulator starten
flutter emulators --launch <emulator_name>
```

#### Option C: iOS-Simulator (nur macOS)
```bash
open -a Simulator
```

---

### Schritt 5: App starten
```bash
flutter run
```

**Fertig!** Die App sollte jetzt auf deinem Gerät laufen.

---

## 📱 Erste Schritte in der App

### 1. Buch scannen
1. Gehe zu Tab "Scanner" 📷
2. Drücke "Foto aufnehmen" oder "Aus Galerie"
3. Warte auf OCR (ca. 5-10 Sekunden)
4. Wiederhole für weitere Seiten
5. Drücke "Als Buch speichern"
6. Gib einen Titel ein
7. Fertig! ✅

### 2. Stimme aufnehmen
1. Gehe zu Tab "Stimmen" 🎭
2. Drücke den "+" Button unten rechts
3. Gib einen Namen ein (z.B. "Papas Stimme")
4. Drücke "Aufnahme starten"
5. Sprich mindestens 5 Sekunden
6. Drücke "Aufnahme stoppen"
7. Optional: "Anhören"
8. Drücke "Speichern"
9. Fertig! ✅

### 3. Buch vorlesen
1. Gehe zu Tab "Meine Bücher" 📚
2. Wähle ein Buch aus der Liste
3. Wähle eine Stimme aus dem Dropdown
4. Drücke den großen Play-Button ▶️
5. Warte auf Audio-Generierung (ca. 5-10 Sekunden)
6. Buch wird vorgelesen! 🎉
7. Blättert automatisch weiter

---

## 🔧 Troubleshooting

### Problem: "No devices found"
**Lösung:**
```bash
# Android: USB-Debugging prüfen
adb devices

# iOS: Simulator starten
open -a Simulator
```

### Problem: "Could not resolve dependencies"
**Lösung:**
```bash
flutter clean
flutter pub get
```

### Problem: "Gradle build failed"
**Lösung:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem: "iOS build failed"
**Lösung:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Problem: "Camera permission denied"
**Lösung:**
- Android: Einstellungen → Apps → Cathy Buch Scanner → Berechtigungen → Kamera aktivieren
- iOS: Einstellungen → Cathy Buch Scanner → Kamera aktivieren

### Problem: "OCR/TTS funktioniert nicht"
**Lösung:**
- Internetverbindung prüfen
- Modal Services müssen laufen:
  - https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr
  - https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts

---

## 🎯 Quick Commands

| Befehl | Beschreibung |
|--------|--------------|
| `flutter run` | App starten (Debug) |
| `r` | Hot Reload (App läuft) |
| `R` | Hot Restart (App läuft) |
| `q` | App beenden |
| `flutter logs` | Logs anzeigen |
| `flutter clean` | Cache leeren |
| `flutter pub get` | Dependencies neu laden |
| `flutter doctor` | System prüfen |
| `flutter devices` | Geräte anzeigen |

---

## 📦 APK bauen (zum Verteilen)

```bash
# Debug APK (schnell, zum Testen)
flutter build apk --debug

# Release APK (optimiert)
flutter build apk --release
```

**APK finden:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**APK versenden:**
- Per E-Mail
- Per WhatsApp
- Per Airdrop
- Auf Website hochladen

**APK installieren:**
- APK auf Handy übertragen
- Antippen und "Installieren" wählen
- Falls "Unbekannte Quellen" blockiert → Einstellungen → Sicherheit → Unbekannte Quellen aktivieren

---

## 🎨 App anpassen

### Farben ändern
**Datei:** `lib/main.dart`
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFFD4AF37), // ← Hier ändern!
  brightness: Brightness.light,
),
```

### App-Name ändern
**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Dein App Name" <!-- ← Hier ändern! -->
```

**iOS:** `ios/Runner/Info.plist`
```xml
<key>CFBundleDisplayName</key>
<string>Dein App Name</string> <!-- ← Hier ändern! -->
```

### App-Icon ändern
1. Icon-Datei (1024x1024 PNG) vorbereiten
2. https://appicon.co/ besuchen
3. Icon hochladen
4. Download für Android & iOS
5. Dateien ersetzen in `android/app/src/main/res/` und `ios/Runner/Assets.xcassets/`

---

## 🐛 Debug-Tipps

### Logs in App anzeigen
```dart
print('🔍 Debug: $variable');
debugPrint('🔍 Debug: $variable');
```

### Performance prüfen
```bash
flutter run --profile
```

### Netzwerk-Requests anzeigen
In `lib/services/ocr_service.dart` und `tts_service.dart` sind bereits Logs eingebaut:
```
🔍 [OCR] Starting OCR for...
✅ [OCR] Extracted 450 characters
🎙️ [TTS] Starting TTS synthesis
✅ [TTS] Audio saved to...
```

---

## 📚 Weiterführende Links

- **Flutter Dokumentation:** https://flutter.dev/docs
- **Dart Language Tour:** https://dart.dev/guides/language/language-tour
- **Flutter Cookbook:** https://flutter.dev/docs/cookbook
- **Material Design 3:** https://m3.material.io/
- **Provider Package:** https://pub.dev/packages/provider

---

## 💡 Tipps

### Entwicklung beschleunigen
1. **Hot Reload nutzen** (r) statt App neu starten
2. **DevTools verwenden** für Widget-Inspektor
3. **Flutter Extension** für VS Code installieren
4. **Dart Analysis** aktivieren für Code-Hilfe

### Code-Qualität
1. **Linter aktivieren:** `flutter analyze`
2. **Formatierung:** `dart format .`
3. **Imports organisieren:** VS Code → Rechtsklick → "Organize Imports"

### Performance
1. **Keine console.log in Production** → Logs entfernen
2. **Bilder optimieren** → max. 2-3 MB pro Bild
3. **Lazy Loading** für große Listen

---

## 🎉 Fertig!

Du hast jetzt eine voll funktionsfähige Buch-Scanner-App!

**Next Steps:**
1. ✅ App auf deinem Handy installieren
2. ✅ Erstes Buch scannen
3. ✅ Eigene Stimme aufnehmen
4. ✅ Buch vorlesen lassen
5. 🚀 Mit Familie und Freunden teilen!

---

## 📞 Support

Bei Fragen oder Problemen:
- **Dokumentation:** Siehe README.md, FEATURES.md, PROJEKTSTRUKTUR.md
- **Flutter Issues:** https://github.com/flutter/flutter/issues
- **Modal Issues:** https://modal.com/docs

**Viel Spaß mit der App!** 🎉
