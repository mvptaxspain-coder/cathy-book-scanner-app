# ⚠️ Docker Workaround Dokumentation

## Problem

Bei dem Versuch, die APK lokal mit Docker zu bauen, ist folgender Fehler aufgetreten:

```bash
$ docker run --rm -v "$(pwd)":/app -w /app cirrusci/flutter:stable sh -c "flutter pub get && flutter build apk --release"

The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.
```

## Ursache

Docker ist in dieser WSL2-Distribution nicht installiert bzw. nicht korrekt konfiguriert.

## Lösung: GitHub Actions stattdessen verwenden

Da Docker nicht verfügbar ist, haben wir auf **GitHub Actions** umgestellt:

1. **Repository erstellt:**
   ```bash
   cd /mnt/e/CodelocalLLM/cathy_book_scanner_app
   git init
   git add .
   git commit -m "Initial commit: Cathy Book Scanner App with OCR and TTS"
   gh repo create cathy-book-scanner-app --public --source=. --remote=origin --push
   ```

2. **GitHub Actions Workflow:** `.github/workflows/build-apk.yml` (bereits erstellt)

3. **Automatischer Build:**
   - Push zu GitHub → Workflow startet automatisch
   - Build dauert ~8-10 Minuten
   - APK verfügbar als Artifact zum Download

## Warum GitHub Actions besser ist

| Aspekt | Docker | GitHub Actions |
|--------|--------|----------------|
| Installation | Benötigt Docker Desktop | Keine Installation nötig |
| Konfiguration | WSL2-Integration nötig | Funktioniert out-of-the-box |
| Build-Zeit | ~10 Minuten | ~8-10 Minuten |
| Wiederholbarkeit | Lokale Umgebung kann variieren | Konsistente Ubuntu-Runner |
| CI/CD | Manuell | Automatisch bei jedem Push |
| Kostenlos | Ja | Ja (2000 Minuten/Monat) |

## Alternative Lösungen (falls GitHub Actions nicht gewünscht)

### Option 1: Docker in WSL2 aktivieren

Falls du Docker trotzdem nutzen möchtest:

1. **Docker Desktop für Windows installieren:**
   - Download: https://www.docker.com/products/docker-desktop

2. **WSL2-Integration aktivieren:**
   - Docker Desktop öffnen
   - Settings → Resources → WSL Integration
   - Deine WSL2-Distribution aktivieren (z.B. Ubuntu)
   - Apply & Restart

3. **In WSL2 testen:**
   ```bash
   docker --version
   # Sollte jetzt funktionieren
   ```

4. **APK bauen:**
   ```bash
   cd /mnt/e/CodelocalLLM/cathy_book_scanner_app
   docker run --rm -v "$(pwd)":/app -w /app cirrusci/flutter:stable \
     sh -c "flutter pub get && flutter build apk --release"
   ```

### Option 2: Flutter direkt in Windows installieren

1. Flutter SDK für Windows herunterladen
2. In PowerShell:
   ```powershell
   cd E:\CodelocalLLM\cathy_book_scanner_app
   flutter pub get
   flutter build apk --release
   ```

Siehe `JETZT_AUSFUEHREN.md` für Details.

## Empfehlung

**Verwende GitHub Actions** - das ist die stabilste und wartungsfreundlichste Lösung:

✅ Keine lokale Installation nötig
✅ Konsistente Build-Umgebung
✅ Automatisiert bei jedem Push
✅ APK-Historie in GitHub Releases
✅ Kostenlos für öffentliche Repositories

## Repository

**GitHub:** https://github.com/mvptaxspain-coder/cathy-book-scanner-app

**Workflow Status prüfen:**
```bash
cd /mnt/e/CodelocalLLM/cathy_book_scanner_app
gh run list
gh run watch  # Live-Verfolgung
```

**APK herunterladen:**
```bash
# Nach erfolgreichem Build
gh run download <run-id>
```

## Zusammenfassung

- ❌ Docker funktioniert nicht in WSL2 (ohne Docker Desktop)
- ✅ GitHub Actions ist die bessere Alternative
- ⏱️ Erster Build läuft bereits (Run ID: 23546061470)
- 📦 APK wird in ~8-10 Minuten verfügbar sein

**NICHT nochmal Docker versuchen, ohne vorher Docker Desktop zu installieren!**
