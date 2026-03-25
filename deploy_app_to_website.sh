#!/bin/bash

# Deploy Flutter App APK to dabrock.eu
# Dieses Skript baut die APK und lädt sie auf den Server hoch

echo "🚀 Deploy Cathy Book Scanner App to dabrock.eu"
echo "=============================================="
echo ""

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# SFTP Zugangsdaten
SFTP_HOST="5018735097.ssh.w2.strato.hosting"
SFTP_PORT="22"
SFTP_USER="su403214"
SFTP_PASS="deutz15!2000"
SFTP_DIR="/dabrock.eu"

# Schritt 1: APK bauen
echo -e "${BLUE}📦 Schritt 1: Building Release APK...${NC}"
flutter build apk --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ APK not found at $APK_PATH${NC}"
    exit 1
fi

# APK-Größe anzeigen
APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
echo -e "${GREEN}✅ APK built successfully! Size: $APK_SIZE${NC}"
echo ""

# Schritt 2: APK umbenennen
echo -e "${BLUE}📝 Schritt 2: Renaming APK...${NC}"
cp "$APK_PATH" "build/app/outputs/flutter-apk/cathy-book-scanner.apk"
echo -e "${GREEN}✅ APK renamed to cathy-book-scanner.apk${NC}"
echo ""

# Schritt 3: Upload via SFTP
echo -e "${BLUE}🌐 Schritt 3: Uploading to dabrock.eu...${NC}"
echo ""

# SFTP Commands erstellen
cat > /tmp/sftp_upload_app.txt << EOFSFTP
cd $SFTP_DIR
-mkdir downloads
cd downloads
put build/app/outputs/flutter-apk/cathy-book-scanner.apk
chmod 644 cathy-book-scanner.apk
ls -la
bye
EOFSFTP

# Upload mit sshpass oder expect
if command -v sshpass &> /dev/null; then
    sshpass -p "$SFTP_PASS" sftp -oBatchMode=no -oStrictHostKeyChecking=no -P $SFTP_PORT -b /tmp/sftp_upload_app.txt $SFTP_USER@$SFTP_HOST
    UPLOAD_STATUS=$?
else
    echo -e "${YELLOW}⚠️  sshpass not installed, using expect...${NC}"
    
    if command -v expect &> /dev/null; then
        expect << EOFEXPECT
spawn sftp -oStrictHostKeyChecking=no -P $SFTP_PORT $SFTP_USER@$SFTP_HOST
expect "password:"
send "$SFTP_PASS\r"
expect "sftp>"
send "cd $SFTP_DIR\r"
expect "sftp>"
send "mkdir downloads\r"
expect "sftp>"
send "cd downloads\r"
expect "sftp>"
send "put build/app/outputs/flutter-apk/cathy-book-scanner.apk\r"
expect "sftp>"
send "chmod 644 cathy-book-scanner.apk\r"
expect "sftp>"
send "ls -la\r"
expect "sftp>"
send "bye\r"
expect eof
EOFEXPECT
        UPLOAD_STATUS=$?
    else
        echo -e "${RED}❌ Neither sshpass nor expect installed!${NC}"
        echo ""
        echo "Please use FileZilla:"
        echo "1. Connect to: $SFTP_HOST:$SFTP_PORT"
        echo "2. Navigate to: $SFTP_DIR/downloads"
        echo "3. Upload: build/app/outputs/flutter-apk/cathy-book-scanner.apk"
        exit 1
    fi
fi

# Cleanup
rm -f /tmp/sftp_upload_app.txt

echo ""
if [ $UPLOAD_STATUS -eq 0 ]; then
    echo -e "${GREEN}✅ Success! APK uploaded to dabrock.eu!${NC}"
    echo ""
    echo "📱 Your app is now available at:"
    echo "   https://dabrock.eu/downloads/cathy-book-scanner.apk"
    echo ""
    echo "📄 Download page:"
    echo "   https://dabrock.eu/app-download.html"
    echo ""
    echo "Next steps:"
    echo "  1. Test the download link"
    echo "  2. Install APK on your phone"
    echo "  3. Share the link!"
    echo ""
else
    echo -e "${RED}❌ Upload failed!${NC}"
    echo ""
    echo "Please try manually with FileZilla or check your credentials."
    echo ""
fi
