# iOS Permissions Testing Checklist

## Pre-Test Setup ✅
- [x] Info.plist has all required permission descriptions
- [x] Permission handling code implemented
- [x] iOS pods installed and updated
- [x] Permission Tester screen created
- [x] Debug menu access added

## Testing Environment
- **Device Required:** Real iPhone (permissions don't work properly in simulator)
- **Build Mode:** Debug mode (to access Permission Tester)
- **iOS Version:** iOS 13.0 or higher

---

## Test 1: Permission Tester Screen

### Steps:
1. [ ] Run app: `flutter run`
2. [ ] Navigate to **Profile** tab (bottom navigation)
3. [ ] Stay on **Settings** tab (should be selected by default)
4. [ ] Locate **"🛠️ Permission Tester (Debug Only)"** at the top
5. [ ] Tap to open Permission Tester screen

**Expected:** Permission Tester screen opens showing all permissions with status

### Initial Status Check:
- [ ] Camera: ❌ Denied (or current status)
- [ ] Photos: ❌ Denied (or current status)
- [ ] Microphone: ❌ Denied (or current status)
- [ ] Location: ❌ Denied (or current status)
- [ ] Motion & Fitness: ❌ Denied (or current status)

---

## Test 2: Request Camera Permission

### Via Permission Tester:
1. [ ] In Permission Tester, tap **"Request Camera (via Helper)"**
2. [ ] iOS permission dialog should appear
3. [ ] Read the usage description (should match Info.plist)
4. [ ] Tap **"Allow"**
5. [ ] Status should update to: ✅ Granted

**Expected Dialog:**
```
"Fitness Day" Would Like to Access the Camera

Fitness Day needs camera access to take photos 
for your profile, challenges, and chat messages.

[Don't Allow]  [OK]
```

### Verify in iOS Settings:
1. [ ] Tap **"Open iOS Settings"** button
2. [ ] iOS Settings app opens
3. [ ] Scroll down to **"Fitness Day"**
4. [ ] Tap on it
5. [ ] **Camera** should now appear in the list with toggle

**Expected in Settings:**
```
Fitness Day
├── Siri & Search
├── Camera          ← Should be visible now!
└── ...
```

---

## Test 3: Request Photos Permission

### Via Permission Tester:
1. [ ] Return to app (don't close it)
2. [ ] In Permission Tester, tap **"Request Photos (via Helper)"**
3. [ ] iOS permission dialog should appear
4. [ ] Options: "Select Photos...", "Allow Access to All Photos", "Don't Allow"
5. [ ] Tap **"Allow Access to All Photos"**
6. [ ] Status should update to: ✅ Granted

**Expected Dialog (iOS 14+):**
```
"Fitness Day" Would Like to Access Your Photos

Fitness Day needs access to your photo library 
to select images for your profile, challenges, 
and chat messages.

[Select Photos...]
[Allow Access to All Photos]
[Don't Allow]
```

### Verify in iOS Settings:
1. [ ] Tap **"Open iOS Settings"** button again
2. [ ] Navigate back to **"Fitness Day"**
3. [ ] Both **Camera** and **Photos** should now be visible

**Expected in Settings:**
```
Fitness Day
├── Siri & Search
├── Camera          ← Still visible
├── Photos          ← Now visible too!
└── ...
```

---

## Test 4: Camera via Profile Picture

### Steps:
1. [ ] Return to app
2. [ ] Go to **Profile** tab
3. [ ] Tap the **edit icon** (✏️) on your profile card
4. [ ] Tap on the **avatar/profile picture**
5. [ ] Tap **"Camera"** in the bottom sheet
6. [ ] Camera should open (permission already granted)
7. [ ] Take a photo
8. [ ] Photo should appear as profile picture

**Expected:** Camera opens immediately without permission dialog (already granted)

---

## Test 5: Photos via Profile Picture

### Steps:
1. [ ] In Profile edit screen, tap avatar again
2. [ ] Tap **"Gallery"** in the bottom sheet
3. [ ] Photo library should open (permission already granted)
4. [ ] Select a photo
5. [ ] Photo should appear as profile picture

**Expected:** Gallery opens immediately without permission dialog (already granted)

---

## Test 6: Camera in Challenge Creation

### Steps:
1. [ ] Navigate to **Challenges** section
2. [ ] Tap **"Create Challenge"** or similar
3. [ ] Tap the image picker area
4. [ ] Select **"Camera"**
5. [ ] Camera should open
6. [ ] Take a photo
7. [ ] Photo should appear in challenge

**Expected:** Works without asking permission again

---

## Test 7: Photos in Chat

### Steps:
1. [ ] Open any conversation in **Conversations**
2. [ ] Tap the **attach button** (📎)
3. [ ] Select **"Gallery"**
4. [ ] Photo library should open
5. [ ] Select one or more photos
6. [ ] Photos should attach to message

**Expected:** Works without asking permission again

---

## Test 8: Permission Denied Scenario

### Steps:
1. [ ] Delete app from iPhone completely
2. [ ] Reinstall: `flutter run`
3. [ ] Go to Permission Tester
4. [ ] Tap **"Request Camera (via Helper)"**
5. [ ] In the dialog, tap **"Don't Allow"**
6. [ ] Status should show: ❌ Denied
7. [ ] Try using camera feature (Profile → Camera)
8. [ ] A dialog should appear: **"Permission Required"**
9. [ ] Tap **"Open Settings"**
10. [ ] iOS Settings should open to your app settings
11. [ ] Enable Camera permission manually
12. [ ] Return to app
13. [ ] Camera should now work

**Expected:** App handles denial gracefully with "Open Settings" option

---

## Test 9: Permission Permanently Denied

### Steps:
1. [ ] In iOS Settings → Fitness Day, turn OFF Camera
2. [ ] Return to app
3. [ ] Try using camera (Profile → Camera)
4. [ ] Permission dialog with **"Open Settings"** should appear
5. [ ] Tap **"Open Settings"**
6. [ ] Should navigate to Settings → Fitness Day
7. [ ] Enable Camera
8. [ ] Return to app and try again

**Expected:** App directs user to Settings when permission is off

---

## Test 10: Limited Photos Access (iOS 14+)

### Steps:
1. [ ] Delete app and reinstall
2. [ ] Request Photos permission
3. [ ] Choose **"Select Photos..."**
4. [ ] Select only 2-3 photos
5. [ ] Tap Done
6. [ ] Status should show: ⚠️ Limited
7. [ ] Try using gallery
8. [ ] Should only show selected photos

**Expected:** App works with limited photo access

---

## Test 11: Other Permissions

### Microphone (Voice Messages):
1. [ ] Open a conversation
2. [ ] Long-press the microphone button
3. [ ] Permission dialog should appear
4. [ ] Grant permission
5. [ ] Record voice message
6. [ ] Check Settings → Microphone appears

### Location (Running):
1. [ ] Go to Activities → Running
2. [ ] Start a run
3. [ ] Permission dialog should appear
4. [ ] Grant "While Using the App"
5. [ ] Check Settings → Location appears

### Motion (Steps):
1. [ ] Go to Home → Walking/Steps
2. [ ] Permission may be requested
3. [ ] Check Settings → Motion & Fitness appears

---

## Verification Checklist

After all tests, verify in iOS Settings → Fitness Day:

```
Fitness Day Settings
├── Siri & Search
├── Camera                     ← ✅ Should be here
├── Photos                     ← ✅ Should be here
├── Microphone                 ← ✅ If voice tested
├── Location                   ← ✅ If running tested
├── Motion & Fitness           ← ✅ If steps tested
├── Cellular Data
└── Background App Refresh
```

---

## Common Issues & Solutions

### Issue: Permission Tester not showing
**Solution:** 
- Running in Debug mode? `flutter run --debug`
- Check imports in user_profile_page.dart

### Issue: Permissions not appearing in Settings
**Solution:**
- Did you actually tap Allow/Don't Allow?
- Close Settings app completely and reopen
- Test on real device, not simulator

### Issue: Permission dialog doesn't appear
**Solution:**
- Permission already granted/denied
- Check status in Permission Tester
- Delete app and reinstall for fresh test

### Issue: App crashes on permission request
**Solution:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## Final Verification

- [ ] Camera appears in Settings after request
- [ ] Photos appears in Settings after request
- [ ] All permission flows work in production features
- [ ] Denial scenario handled gracefully
- [ ] "Open Settings" button works
- [ ] Permissions persist after app restart

---

## Production Release

Before releasing to App Store:

1. [ ] Test on multiple iOS versions (13, 14, 15, 16, 17)
2. [ ] Test on different device sizes
3. [ ] Verify all permission descriptions are user-friendly
4. [ ] Test in both English and Arabic
5. [ ] The Permission Tester will auto-hide (kDebugMode)

---

## Success Criteria ✅

All tests pass when:
- ✅ Camera and Photos appear in iOS Settings after being requested
- ✅ Permission dialogs show correct descriptions
- ✅ App handles all permission states correctly
- ✅ "Open Settings" functionality works
- ✅ Features work after granting permissions
- ✅ Features show appropriate messages when denied

**Status: Ready for Testing** 🚀
