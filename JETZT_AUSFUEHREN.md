# 🚀 APK Bauen und Hochladen - JETZT AUSFÜHREN

## ⚠️ Flutter ist auf diesem WSL-System nicht installiert

Du musst die APK auf einem System mit Flutter SDK bauen. Hier sind deine Optionen:

---

## ✅ **Option 1: Auf Windows (empfohlen)**

### Schritt 1: Flutter installieren (falls noch nicht)
```powershell
# In PowerShell:
# Download Flutter SDK von: https://flutter.dev/docs/get-started/install/windows
# Oder mit Chocolatey:
choco install flutter
```

### Schritt 2: Zum Projekt navigieren
```powershell
cd E:\CodelocalLLM\cathy_book_scanner_app
```

### Schritt 3: Script ausführen
```bash
# In Git Bash oder WSL:
bash BUILD_AND_DEPLOY.sh
```

**Oder manuell:**
```powershell
# In PowerShell:
flutter clean
flutter pub get
flutter build apk --release
```

Die APK wird hier erstellt:
```
E:\CodelocalLLM\cathy_book_scanner_app\build\app\outputs\flutter-apk\app-release.apk
```

---

## ✅ **Option 2: Mit Android Studio**

1. **Android Studio öffnen**
2. **Projekt öffnen:**
   ```
   E:\CodelocalLLM\cathy_book_scanner_app
   ```
3. **Build → Flutter → Build APK**
4. **Warten bis fertig** (5-10 Minuten)
5. **APK finden in:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

---

## ✅ **Option 3: Auf einem anderen Linux/Mac System**

```bash
cd /path/to/cathy_book_scanner_app
bash BUILD_AND_DEPLOY.sh
```

---

## 📤 **APK Hochladen (nach Build)**

### Automatisch (wenn sshpass/expect installiert):
```bash
# Das BUILD_AND_DEPLOY.sh Script lädt automatisch hoch
bash BUILD_AND_DEPLOY.sh
```

### Manuell mit FileZilla:

1. **FileZilla öffnen**

2. **Verbindung herstellen:**
   ```
   Host: 5018735097.ssh.w2.strato.hosting
   Port: 22
   Protokoll: SFTP
   Benutzername: su403214
   Passwort: deutz15!2000
   ```

3. **Zum Zielordner navigieren:**
   ```
   /dabrock.eu/downloads
   ```

4. **APK hochladen:**
   - Lokale Datei: `build/app/outputs/flutter-apk/app-release.apk`
   - Umbenennen zu: `cathy-book-scanner.apk`

5. **Fertig!** ✅

---

## 🎯 **Schnellstart (Windows PowerShell)**

```powershell
# 1. Zum Projekt
cd E:\CodelocalLLM\cathy_book_scanner_app

# 2. Dependencies
flutter pub get

# 3. Build
flutter build apk --release

# 4. APK finden
explorer build\app\outputs\flutter-apk
```

Die `app-release.apk` dann mit FileZilla hochladen (siehe oben).

---

## 🔍 **Flutter Installation prüfen**

```bash
flutter doctor
```

**Sollte zeigen:**
```
✓ Flutter (Channel stable, 3.x.x)
✓ Android toolchain
✓ Connected device (oder Android Emulator)
```

Falls Fehler: `flutter doctor` Anweisungen folgen.

---

## 📱 **Nach dem Upload testen**

1. **Download-Seite öffnen:**
   ```
   https://dabrock.eu/app-download.html
   ```

2. **APK herunterladen**

3. **Auf Handy installieren:**
   - APK öffnen
   - "Installieren" antippen
   - Falls blockiert: Einstellungen → Sicherheit → Unbekannte Quellen

4. **App öffnen und testen!** 🎉

---

## ⏱️ **Zeitaufwand**

- **Erstes Build:** ~10-15 Minuten (Download von Dependencies)
- **Folgende Builds:** ~3-5 Minuten
- **Upload:** ~30 Sekunden (APK ist ~25 MB)

---

## 🐛 **Troubleshooting**

### "Flutter nicht gefunden"
```bash
# Flutter zu PATH hinzufügen
export PATH="$PATH:/pfad/zu/flutter/bin"
```

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
# Alle mit "y" akzeptieren
```

### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### "Out of memory"
```bash
# In android/gradle.properties hinzufügen:
org.gradle.jvmargs=-Xmx4096m
```

---

## 🎯 **TL;DR (Zusammenfassung)**

**Auf Windows:**
1. Flutter installieren (falls nicht vorhanden)
2. `cd E:\CodelocalLLM\cathy_book_scanner_app`
3. `flutter build apk --release`
4. APK mit FileZilla hochladen zu `/dabrock.eu/downloads/`
5. Umbenennen zu `cathy-book-scanner.apk`
6. Testen: https://dabrock.eu/app-download.html

**Fertig!** 🚀

---

## 💡 **Alternative: Docker verwenden**

Falls du Flutter nicht installieren möchtest:

```bash
# Flutter in Docker
docker run --rm -v $(pwd):/app -w /app cirrusci/flutter:stable \
  sh -c "flutter pub get && flutter build apk --release"
```

---

Ich hoffe, das hilft! Wenn du Fragen hast, frag einfach! 😊
