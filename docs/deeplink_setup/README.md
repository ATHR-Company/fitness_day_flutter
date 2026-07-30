# Deep Link Setup — FitnessDay

## How App Links work (Android) / Universal Links (iOS)

When a user taps `https://fitnessday.tech/user-home` the OS checks if any
installed app owns that domain by fetching a verification file from the server.
If verified, the OS opens the app directly — no browser, no chooser dialog.

---

## 1. Files to upload to the server

### Android — `assetlinks.json`
Upload to: `https://fitnessday.tech/.well-known/assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.fitness_day",
      "sha256_cert_fingerprints": [
        "72:59:50:DA:EE:9F:F2:DA:03:48:28:78:C8:CC:17:EB:AB:85:B8:13:61:D5:F9:DA:8C:6B:89:F1:05:81:9E:E1",
        "0C:C2:2D:13:F3:99:56:F0:41:26:84:7F:E8:7F:88:1C:A6:6B:B3:FD:87:10:06:C0:C9:EE:3C:6E:42:51:87:97"
      ]
    }
  }
]
```

- First fingerprint = **release** keystore (`D:\athr\fitness_day.jks`)
- Second fingerprint = **debug** keystore (`~/.android/debug.keystore`)

Server requirements:
- Must be HTTPS (not HTTP)
- Content-Type: `application/json`
- No redirect on the path (must respond 200 directly)

### iOS — `apple-app-site-association`
Upload to: `https://fitnessday.tech/.well-known/apple-app-site-association`

Replace `TEAMID` with your Apple Developer Team ID (10 chars, e.g. `XB8YVBDAM7`).

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.example.fitness_day",
        "paths": [
          "/store/products/*",
          "/open",
          "/user-home",
          "/challenges",
          "/user-profile"
        ]
      }
    ]
  },
  "webcredentials": {
    "apps": ["TEAMID.com.example.fitness_day"]
  }
}
```

---

## 2. Android — What was already done in this repo

`AndroidManifest.xml` — added inside `<activity>`:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="fitnessday.tech" />
</intent-filter>
```

`android:autoVerify="true"` tells Android to verify the domain at install time.
After verification, tapping any `https://fitnessday.tech/*` link opens the app
directly.

---

## 3. iOS — Info.plist / Entitlements (still needed)

### `ios/Runner/Runner.entitlements`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:fitnessday.tech</string>
        <string>webcredentials:fitnessday.tech</string>
    </array>
</dict>
</plist>
```

This must be added via Xcode → Signing & Capabilities → Associated Domains,
or by creating the file manually and setting the capability in the project.

---

## 4. Supported deep link paths

All paths below open the corresponding screen:

| URL | Screen |
|-----|--------|
| `https://fitnessday.tech/user-home` | Home |
| `https://fitnessday.tech/store` | Market / Store |
| `https://fitnessday.tech/challenges` | Challenges |
| `https://fitnessday.tech/user-profile` | Profile |
| `https://fitnessday.tech/awards` | Awards |
| `https://fitnessday.tech/user-progress` | Progress |

GoRouter handles all paths automatically because every route is already
registered — no extra link-handling code is required.

---

## 5. Test a deep link (Android)

```powershell
# While app is installed on a connected device/emulator:
adb shell am start -W -a android.intent.action.VIEW `
  -d "https://fitnessday.tech/user-home" `
  com.example.fitness_day
```

## 6. Verify assetlinks (online tool)

https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://fitnessday.tech&relation=delegate_permission/common.handle_all_urls
