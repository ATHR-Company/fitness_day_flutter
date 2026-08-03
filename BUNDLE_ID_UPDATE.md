# Bundle Identifier Update Summary

The app bundle identifier has been changed from `com.example.fitnessDay` to `com.athr.fitnessday` across the entire project.

## ✅ Completed Changes

### iOS
- ✅ Updated `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj`
  - Main app: `com.athr.fitnessday`
  - Tests: `com.athr.fitnessday.RunnerTests`
- ✅ Info.plist already uses `$(PRODUCT_BUNDLE_IDENTIFIER)` - no changes needed

### Android
- ✅ Updated `namespace` in `android/app/build.gradle.kts` to `com.athr.fitnessday`
- ✅ Updated `applicationId` in `android/app/build.gradle.kts` to `com.athr.fitnessday`
- ✅ Created new `MainActivity.kt` with package `com.athr.fitnessday`
- ✅ Moved MainActivity to correct directory: `android/app/src/main/kotlin/com/athr/fitnessday/`
- ✅ Removed old directory: `android/app/src/main/kotlin/com/example/`

## ⚠️ Required Manual Steps

### 1. iOS Code Signing (Required)
Open the project in Xcode and configure signing:
```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** (blue icon) in left navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. Select your **Team** from dropdown
6. Xcode will provision a profile for `com.athr.fitnessday`

### 2. Firebase Configuration (Critical!)
The `google-services.json` file still contains the old package name `com.example.fitness_day`.

**You must update Firebase Console:**

#### Android (google-services.json)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings
4. Add a new Android app OR update existing app's package name:
   - Package name: `com.athr.fitnessday`
5. Download the new `google-services.json`
6. Replace `android/app/google-services.json` with the new file

#### iOS (GoogleService-Info.plist)
1. In Firebase Console → Project Settings
2. Add a new iOS app OR update existing app's bundle ID:
   - Bundle ID: `com.athr.fitnessday`
3. Download the new `GoogleService-Info.plist`
4. Add it to `ios/Runner/` directory
5. **Important:** Also add it to Xcode project:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on `Runner` folder in project navigator
   - Select "Add Files to Runner..."
   - Select the `GoogleService-Info.plist` file
   - Make sure "Copy items if needed" is checked
   - Click "Add"

### 3. Deep Links Configuration
If you're using deep links (https://fitnessday.tech), you'll need to:

#### Android
Update `.well-known/assetlinks.json` on your server with the new package name and SHA-256 fingerprints:
```json
{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.athr.fitnessday",
    "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
  }
}
```

#### iOS
Update `.well-known/apple-app-site-association` on your server with the new bundle ID.

### 4. App Store / Play Store
When you're ready to publish:
- **App Store:** The bundle ID `com.athr.fitnessday` must match what's registered in App Store Connect
- **Play Store:** The applicationId `com.athr.fitnessday` must match what's registered in Play Console

## Verification Steps

After completing manual steps, verify everything works:

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# For iOS
cd ios && pod install && cd ..

# Run on device
flutter run
```

## Notes
- The old bundle ID was `com.example.fitnessDay` (mixed case)
- The new bundle ID is `com.athr.fitnessday` (all lowercase) - this is best practice
- All package/bundle identifiers should be lowercase to avoid issues
