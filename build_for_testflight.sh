#!/bin/bash

# Fitness Day - TestFlight Build Script
# This script prepares and builds your app for TestFlight upload

set -e  # Exit on any error

echo "🚀 Building Fitness Day for TestFlight..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Clean previous builds
echo "📦 Step 1: Cleaning previous builds..."
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Step 2: Get dependencies
echo "📥 Step 2: Getting Flutter dependencies..."
flutter pub get
echo -e "${GREEN}✓ Dependencies downloaded${NC}"
echo ""

# Step 3: Install iOS dependencies
echo "🍎 Step 3: Installing iOS CocoaPods dependencies..."
cd ios
pod install
cd ..
echo -e "${GREEN}✓ CocoaPods dependencies installed${NC}"
echo ""

# Step 4: Run Flutter doctor
echo "🔍 Step 4: Checking Flutter environment..."
flutter doctor
echo ""

# Step 5: Build IPA
echo "🏗️  Step 5: Building IPA for release..."
echo -e "${YELLOW}⏳ This may take several minutes...${NC}"
flutter build ipa --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ BUILD SUCCESSFUL!${NC}"
    echo ""
    echo "📍 Your IPA file is located at:"
    echo "   build/ios/ipa/fitness_day.ipa"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Open App Store Connect: https://appstoreconnect.apple.com"
    echo "   2. Ensure your app is created with Bundle ID: com.athr.fitnessday"
    echo "   3. Upload using one of these methods:"
    echo "      • Xcode Organizer: open ios/Runner.xcworkspace then Product > Archive > Distribute"
    echo "      • Transporter app: Drag and drop the IPA file"
    echo "      • Command line: See TESTFLIGHT_GUIDE.md for details"
    echo ""
    echo "📖 For detailed instructions, see: TESTFLIGHT_GUIDE.md"
    echo ""
else
    echo ""
    echo -e "${RED}❌ BUILD FAILED${NC}"
    echo ""
    echo "Common fixes:"
    echo "  • Make sure you have a valid Apple Developer account"
    echo "  • Check your signing configuration in Xcode"
    echo "  • Ensure CocoaPods are up to date: pod repo update"
    echo "  • See TESTFLIGHT_GUIDE.md for troubleshooting"
    echo ""
    exit 1
fi
