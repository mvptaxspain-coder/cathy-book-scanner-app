# APK auf Website deployen - Anleitung

## 📱 Von Flutter-App zur herunterladbaren APK

### Schritt 1: APK bauen (5 Minuten)

```bash
cd /mnt/e/CodelocalLLM/cathy_book_scanner_app

# Release APK bauen (optimiert, klein)
flutter build apk --release
```

**Ausgabe:**
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (25.4MB)
```

**APK befindet sich hier:**
```
/mnt/e/CodelocalLLM/cathy_book_scanner_app/build/app/outputs/flutter-apk/app-release.apk
```

---

### Schritt 2: APK umbenennen (optional)

```bash
# Besseren Namen geben
cp build/app/outputs/flutter-apk/app-release.apk \
   build/app/outputs/flutter-apk/cathy-book-scanner.apk
```

---

### Schritt 3: Download-Ordner auf Server erstellen

```bash
# Via SFTP oder SSH
ssh su403214@5018735097.ssh.w2.strato.hosting

# Auf dem Server:
cd /dabrock.eu
mkdir downloads
chmod 755 downloads
exit
```

---

### Schritt 4: APK auf Server hochladen

#### Option A: Mit SFTP (empfohlen)

```bash
# SFTP Session starten
sftp su403214@5018735097.ssh.w2.strato.hosting

# Auf dem Server:
cd /dabrock.eu/downloads

# Lokale Datei hochladen
put build/app/outputs/flutter-apk/cathy-book-scanner.apk

# Berechtigungen setzen
chmod 644 cathy-book-scanner.apk

# Fertig!
bye
```

#### Option B: Mit FileZilla

1. FileZilla öffnen
2. Verbindung zu SFTP-Server:
   - Host: `5018735097.ssh.w2.strato.hosting`
   - Port: `22`
   - Protokoll: `SFTP`
   - User: `su403214`
   - Passwort: `deutz15!2000`
3. Rechts zum Ordner `/dabrock.eu/downloads` navigieren
4. Links zur APK navigieren
5. APK rüberziehen (Drag & Drop)
6. Fertig!

---

### Schritt 5: Download-Seite hochladen

Die Download-Seite wurde bereits erstellt: `app-download.html`

```bash
# Via SFTP
sftp su403214@5018735097.ssh.w2.strato.hosting
cd /dabrock.eu
put /mnt/e/CodelocalLLM/cathy_projekt/app-download.html
bye
```

---

### Schritt 6: Link zur Hauptseite hinzufügen

Bearbeite `index.html` und füge einen Link zur Download-Seite hinzu:

```html
<!-- Im Projekte-Bereich oder Navigation -->
<a href="app-download.html" class="project-card">
    <div class="project-icon">📱</div>
    <h3>Buch Scanner App</h3>
    <p>Mobile App für Android - Jetzt herunterladen!</p>
</a>
```

---

### Schritt 7: Testen

1. Öffne im Browser: `https://dabrock.eu/app-download.html`
2. Klicke auf "APK herunterladen"
3. APK sollte heruntergeladen werden
4. Fertig! 🎉

---

## 🔄 Updates deployen

Wenn du die App aktualisierst:

1. **App-Version erhöhen** in `pubspec.yaml`:
```yaml
version: 1.0.1+2  # ← Version erhöhen
```

2. **Neue APK bauen:**
```bash
flutter build apk --release
```

3. **Auf Server hochladen** (überschreibt alte Version):
```bash
sftp su403214@5018735097.ssh.w2.strato.hosting
cd /dabrock.eu/downloads
put build/app/outputs/flutter-apk/app-release.apk cathy-book-scanner.apk
bye
```

4. **Nutzer informieren:**
   - In app-download.html Versionsnummer aktualisieren
   - Changelog hinzufügen

---

## 📊 APK-Details überprüfen

### Größe prüfen
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
# Ausgabe: ~25M
```

### APK analysieren
```bash
# Installierte Packages anzeigen
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep package

# Berechtigungen anzeigen
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔒 APK signieren (für Play Store)

Falls du die App später auf Google Play hochladen möchtest:

### 1. Keystore erstellen
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. key.properties erstellen
```bash
# In android/key.properties
storePassword=dein_passwort
keyPassword=dein_passwort
keyAlias=upload
storeFile=/pfad/zu/upload-keystore.jks
```

### 3. build.gradle anpassen
```gradle
// android/app/build.gradle

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

### 4. Signierte APK bauen
```bash
flutter build apk --release
```

---

## 📱 Alternative: App Bundle für Play Store

```bash
# App Bundle statt APK
flutter build appbundle --release

# Ausgabe:
# build/app/outputs/bundle/release/app-release.aab
```

**Vorteile:**
- Kleinere Downloads (Google Play optimiert)
- Automatische Optimierung für verschiedene Geräte

---

## 🌐 Download-Link-Formate

### Direkt-Link
```
https://dabrock.eu/downloads/cathy-book-scanner.apk
```

### Schöner Link (mit Seite)
```
https://dabrock.eu/app-download.html
```

### QR-Code erstellen
1. Gehe zu: https://www.qr-code-generator.com/
2. Gib Link ein: `https://dabrock.eu/app-download.html`
3. QR-Code generieren
4. Herunterladen
5. Auf Website einfügen

---

## 📈 Download-Tracking (optional)

### Mit Google Analytics

In `app-download.html`:
```html
<script>
document.querySelector('.download-button').addEventListener('click', function() {
    // Google Analytics Event
    gtag('event', 'download', {
        'event_category': 'APK',
        'event_label': 'Cathy Book Scanner'
    });
});
</script>
```

### Mit Server-Logs
```bash
# Server-Logs anschauen
ssh su403214@5018735097.ssh.w2.strato.hosting
tail -f /var/log/apache2/access.log | grep "cathy-book-scanner.apk"
```

---

## 🔧 Troubleshooting

### Problem: "Download wird blockiert"
**Lösung:** Browser warnt vor APK-Downloads
- Normal bei APKs
- Nutzer muss bestätigen

### Problem: "Datei zu groß für Upload"
**Lösung:**
```bash
# APK komprimieren (nicht empfohlen, verliert Signatur)
# Oder: Split APKs erstellen
flutter build apk --split-per-abi --release
```

### Problem: "Installation fehlgeschlagen"
**Lösung:**
- Android-Version prüfen (mind. 7.0)
- "Unbekannte Quellen" aktivieren
- Alte Version deinstallieren

---

## ✅ Komplette Deploy-Checkliste

- [ ] APK bauen (`flutter build apk --release`)
- [ ] APK umbenennen (`cathy-book-scanner.apk`)
- [ ] `/dabrock.eu/downloads` Ordner erstellen
- [ ] APK auf Server hochladen
- [ ] Berechtigungen setzen (`chmod 644`)
- [ ] `app-download.html` hochladen
- [ ] Link in `index.html` einfügen
- [ ] Website testen
- [ ] Download testen
- [ ] Installation auf Handy testen
- [ ] QR-Code erstellen (optional)
- [ ] Analytics einrichten (optional)

---

## 🚀 Fertig!

Deine App ist jetzt unter diesem Link verfügbar:

```
https://dabrock.eu/app-download.html
```

Nutzer können die APK herunterladen und installieren! 🎉

---

## 📞 Weitere Optionen

### Play Store Veröffentlichung
- Google Play Console: https://play.google.com/console
- Kosten: $25 einmalig
- Review-Prozess: 1-3 Tage

### Alternative App Stores
- Amazon Appstore
- F-Droid (Open Source)
- Samsung Galaxy Store
- Huawei AppGallery

### Direct Distribution
- ✅ Eigene Website (was wir machen)
- QR-Code auf Flyern
- Link in E-Mail-Signatur
- Social Media Posts
