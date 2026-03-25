# Build-Anleitung: Cathy Buch Scanner App

## Voraussetzungen

### 1. Flutter SDK installieren
```bash
# Download von https://flutter.dev/docs/get-started/install
# Dann Path setzen
export PATH="$PATH:`pwd`/flutter/bin"

# Flutter prüfen
flutter doctor
```

### 2. Android Studio (für Android)
- Download: https://developer.android.com/studio
- Android SDK installieren (API Level 24+)
- Android Emulator oder physisches Gerät

### 3. Xcode (für iOS, nur macOS)
- Download vom Mac App Store
- Xcode Command Line Tools installieren:
```bash
xcode-select --install
```
- CocoaPods installieren:
```bash
sudo gem install cocoapods
```

## Build-Schritte

### 1. Dependencies installieren
```bash
cd /mnt/e/CodelocalLLM/cathy_book_scanner_app
flutter pub get
```

### 2. Android Build

#### Debug APK (zum Testen)
```bash
flutter build apk --debug
```
**Ausgabe:** `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK (für Veröffentlichung)
```bash
flutter build apk --release
```
**Ausgabe:** `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle (für Google Play)
```bash
flutter build appbundle --release
```
**Ausgabe:** `build/app/outputs/bundle/release/app-release.aab`

### 3. iOS Build (nur macOS)

#### Debug Build
```bash
flutter build ios --debug
```

#### Release Build
```bash
flutter build ios --release
```

#### IPA erstellen (für App Store)
```bash
flutter build ipa --release
```
**Ausgabe:** `build/ios/ipa/cathy_book_scanner.ipa`

## Direkt auf Gerät installieren

### Android
```bash
# Gerät via USB verbinden und USB-Debugging aktivieren
flutter install -d android
```

### iOS
```bash
# iPhone via USB verbinden
flutter install -d ios
```

## Emulator/Simulator starten

### Android Emulator
```bash
# Liste aller verfügbaren Emulatoren
flutter emulators

# Emulator starten
flutter emulators --launch <emulator_id>

# App ausführen
flutter run
```

### iOS Simulator (nur macOS)
```bash
# Simulator öffnen
open -a Simulator

# App ausführen
flutter run -d ios
```

## Gerät auswählen

```bash
# Alle verfügbaren Geräte anzeigen
flutter devices

# Auf spezifischem Gerät ausführen
flutter run -d <device_id>
```

## Häufige Probleme

### Problem: "Flutter SDK not found"
**Lösung:**
```bash
export PATH="$PATH:/path/to/flutter/bin"
# In .bashrc oder .zshrc dauerhaft hinzufügen
```

### Problem: "Android licenses not accepted"
**Lösung:**
```bash
flutter doctor --android-licenses
# Alle Lizenzen akzeptieren mit "y"
```

### Problem: "CocoaPods not installed" (iOS)
**Lösung:**
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Problem: "Execution failed for task ':app:packageDebug'"
**Lösung:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

## APK-Datei verteilen

Die fertige APK-Datei findest du hier:
```
build/app/outputs/flutter-apk/app-release.apk
```

Diese Datei kannst du:
- Per E-Mail/WhatsApp versenden
- Auf deiner Website zum Download anbieten
- Auf Google Play hochladen (nach Signierung)

## APK signieren (für Google Play)

1. **Keystore erstellen:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **key.properties erstellen:**
```bash
# In android/key.properties
storePassword=<passwort>
keyPassword=<passwort>
keyAlias=upload
storeFile=/pfad/zu/upload-keystore.jks
```

3. **build.gradle anpassen:**
```gradle
// In android/app/build.gradle

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. **Signierte APK bauen:**
```bash
flutter build apk --release
```

## App-Größe reduzieren

```bash
# App Bundle verwenden (Google Play empfohlen)
flutter build appbundle --release --target-platform android-arm,android-arm64

# Nur für 64-bit Geräte
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

## Performance-Optimierung

```bash
# Obfuscation aktivieren (Code verschleiern)
flutter build apk --release --obfuscate --split-debug-info=/<projekt>/debug-info

# Tree-shaking (unbenutzte Code entfernen)
flutter build apk --release --tree-shake-icons
```

## Quick Reference

| Befehl | Beschreibung |
|--------|--------------|
| `flutter doctor` | System-Check |
| `flutter pub get` | Dependencies installieren |
| `flutter clean` | Build-Cache leeren |
| `flutter run` | App starten (Debug) |
| `flutter build apk` | Android APK bauen |
| `flutter build ios` | iOS IPA bauen |
| `flutter devices` | Verfügbare Geräte |
| `flutter emulators` | Verfügbare Emulatoren |

## Nächste Schritte

1. **Google Play hochladen:**
   - Google Play Console: https://play.google.com/console
   - App Bundle hochladen
   - Store Listing ausfüllen
   - Screenshots hinzufügen

2. **App Store hochladen:**
   - App Store Connect: https://appstoreconnect.apple.com
   - IPA hochladen via Xcode oder Transporter
   - App-Informationen ausfüllen
   - Screenshots hinzufügen

## Support

Bei Problemen:
- Flutter Dokumentation: https://flutter.dev/docs
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Flutter Discord: https://discord.gg/flutter
