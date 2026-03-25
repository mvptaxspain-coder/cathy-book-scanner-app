#!/bin/bash

# Build & Deploy Cathy Book Scanner App
# Dieses Script baut die APK und lädt sie automatisch auf dabrock.eu hoch

set -e  # Exit on error

echo "🚀 Building and Deploying Cathy Book Scanner App"
echo "=================================================="
echo ""

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter nicht gefunden!${NC}"
    echo ""
    echo "Bitte installiere Flutter:"
    echo "  https://flutter.dev/docs/get-started/install"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Flutter gefunden: $(flutter --version | head -1)${NC}"
echo ""

# SFTP Credentials
SFTP_HOST="5018735097.ssh.w2.strato.hosting"
SFTP_PORT="22"
SFTP_USER="su403214"
SFTP_PASS="deutz15!2000"
SFTP_DIR="/dabrock.eu/downloads"

# Step 1: Clean
echo -e "${BLUE}🧹 Step 1: Cleaning previous builds...${NC}"
flutter clean
echo ""

# Step 2: Get dependencies
echo -e "${BLUE}📦 Step 2: Getting dependencies...${NC}"
flutter pub get
echo ""

# Step 3: Build APK
echo -e "${BLUE}🔨 Step 3: Building Release APK...${NC}"
echo "This may take 5-10 minutes..."
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

# Get APK size
APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
echo ""
echo -e "${GREEN}✅ APK built successfully!${NC}"
echo "   Size: $APK_SIZE"
echo "   Location: $APK_PATH"
echo ""

# Step 4: Rename APK
echo -e "${BLUE}📝 Step 4: Renaming APK...${NC}"
cp "$APK_PATH" "build/app/outputs/flutter-apk/cathy-book-scanner.apk"
echo -e "${GREEN}✅ APK renamed to cathy-book-scanner.apk${NC}"
echo ""

# Step 5: Upload to server
echo -e "${BLUE}🌐 Step 5: Uploading to dabrock.eu...${NC}"
echo ""

# Create SFTP commands
cat > /tmp/sftp_upload_apk.txt << EOF
cd $SFTP_DIR
put build/app/outputs/flutter-apk/cathy-book-scanner.apk
chmod 644 cathy-book-scanner.apk
ls -lh cathy-book-scanner.apk
bye
EOF

# Try upload with sshpass
if command -v sshpass &> /dev/null; then
    echo "Using sshpass for upload..."
    sshpass -p "$SFTP_PASS" sftp -oBatchMode=no -oStrictHostKeyChecking=no -P $SFTP_PORT -b /tmp/sftp_upload_apk.txt $SFTP_USER@$SFTP_HOST
    UPLOAD_STATUS=$?
elif command -v expect &> /dev/null; then
    echo "Using expect for upload..."
    expect << EOFEXPECT
spawn sftp -oStrictHostKeyChecking=no -P $SFTP_PORT $SFTP_USER@$SFTP_HOST
expect "password:"
send "$SFTP_PASS\r"
expect "sftp>"
send "cd $SFTP_DIR\r"
expect "sftp>"
send "put build/app/outputs/flutter-apk/cathy-book-scanner.apk\r"
expect "sftp>"
send "chmod 644 cathy-book-scanner.apk\r"
expect "sftp>"
send "ls -lh cathy-book-scanner.apk\r"
expect "sftp>"
send "bye\r"
expect eof
EOFEXPECT
    UPLOAD_STATUS=$?
else
    echo -e "${YELLOW}⚠️  Neither sshpass nor expect found!${NC}"
    echo ""
    echo "Please upload manually using FileZilla:"
    echo "1. Connect to: $SFTP_HOST:$SFTP_PORT"
    echo "2. Username: $SFTP_USER"
    echo "3. Password: $SFTP_PASS"
    echo "4. Navigate to: $SFTP_DIR"
    echo "5. Upload: build/app/outputs/flutter-apk/cathy-book-scanner.apk"
    echo ""
    echo "APK is ready at: $(pwd)/build/app/outputs/flutter-apk/cathy-book-scanner.apk"
    rm -f /tmp/sftp_upload_apk.txt
    exit 0
fi

# Cleanup
rm -f /tmp/sftp_upload_apk.txt

echo ""
if [ $UPLOAD_STATUS -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ SUCCESS! App deployed to dabrock.eu!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
    echo "📱 Your app is now available at:"
    echo ""
    echo -e "${BLUE}   Download Page:${NC}"
    echo "   https://dabrock.eu/app-download.html"
    echo ""
    echo -e "${BLUE}   Direct APK Link:${NC}"
    echo "   https://dabrock.eu/downloads/cathy-book-scanner.apk"
    echo ""
    echo "🎉 Next steps:"
    echo "  1. Open https://dabrock.eu/app-download.html in your browser"
    echo "  2. Test the download"
    echo "  3. Install on your phone"
    echo "  4. Share with friends & family!"
    echo ""
else
    echo -e "${RED}❌ Upload failed!${NC}"
    echo ""
    echo "APK is ready at: $(pwd)/build/app/outputs/flutter-apk/cathy-book-scanner.apk"
    echo "Please upload manually using FileZilla (see instructions above)"
    echo ""
fi
