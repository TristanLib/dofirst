# DoFirst App Store Upload Progress

Last updated: 2026-05-19

## Goal

Upload the new iOS app `DoFirst` to App Store Connect as a separate app.

Do not overwrite or reuse the existing app `人生刻度`.

## Current App Store Connect State

- Existing app to avoid:
  - Name: `人生刻度`
  - Apple ID: `6762440559`
  - Bundle ID: `tristan.LifeWatch`
  - SKU: `lifewatch-001`
  - Current version/build observed: version `1.2`, build `4`
- New app created:
  - Name: `DoFirst`
  - Apple ID: `6769286854`
  - App Store Connect URL: `https://appstoreconnect.apple.com/apps/6769286854/distribution/ios/version/inflight`
  - Status observed: `1.0 准备提交`
  - Latest uploaded build observed in TestFlight: version `1.0`, build `1`
  - Current build status observed: `准备提交`

## Bundle ID And Entitlement Changes Already Applied

The project was changed from informal `com.example.DoFirst` identifiers to identifiers matching the style of `人生刻度`:

- Main app: `tristan.DoFirst`
- Shield configuration extension: `tristan.DoFirst.ShieldConfigurationExtension`
- Shield action extension: `tristan.DoFirst.ShieldActionExtension`
- Device activity monitor extension: `tristan.DoFirst.DeviceActivityMonitorExtension`
- Device activity report extension: `tristan.DoFirst.DeviceActivityReportExtension`
- App group: `group.tristan.dofirst`

Files changed:

- `DoFirst.xcodeproj/project.pbxproj`
- `DoFirst/DoFirst.entitlements`
- `ShieldConfigurationExtension/ShieldConfigurationExtension.entitlements`
- `ShieldActionExtension/ShieldActionExtension.entitlements`
- `DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.entitlements`
- `DeviceActivityReportExtension/DeviceActivityReportExtension.entitlements`
- `DoFirst/Services/SharedScreenTimeKeys.swift`
- `Scripts/generate_xcodeproj.rb`
- `README.md`

## Latest Successful Archive

Archive command used:

```sh
xcodebuild \
  -project DoFirst.xcodeproj \
  -scheme DoFirst \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /Users/yuebao/projects/xcode/DoFirst/build/archives/DoFirst-20260513-235532.xcarchive \
  -allowProvisioningUpdates \
  archive
```

Archive path:

```text
/Users/yuebao/projects/xcode/DoFirst/build/archives/DoFirst-20260518-235108.xcarchive
```

The archive was verified to use bundle ID `tristan.DoFirst`, version `1.0`, build `1`.

## Upload Result And Compliance Status

Upload/export plist exists at:

```text
build/exportOptions-upload.plist
```

Upload command used:

```sh
xcodebuild \
  -exportArchive \
  -archivePath /Users/yuebao/projects/xcode/DoFirst/build/archives/DoFirst-20260518-235108.xcarchive \
  -exportPath /Users/yuebao/projects/xcode/DoFirst/build/export-upload-20260518-235124 \
  -exportOptionsPlist build/exportOptions-upload.plist \
  -allowProvisioningUpdates
```

Upload completed successfully on 2026-05-18:

```text
Uploaded DoFirst
** EXPORT SUCCEEDED **
```

Export/upload log:

```text
/Users/yuebao/projects/xcode/DoFirst/build/logs/export-upload-20260518-235124.log
```

The old Family Controls distribution entitlement blocker is resolved.

The export compliance blocker was resolved in App Store Connect on 2026-05-19 by selecting:

```text
不属于上述的任意一种算法
```

After saving the App Encryption Documentation dialog, TestFlight showed build `1` status as:

```text
准备提交
90 天后过期
```

The main app `Info.plist` also now includes:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

This should prevent future uploads from repeatedly requiring the same export compliance answer unless the app's encryption usage changes.

## Previous Upload Blocker

```sh
xcodebuild \
  -exportArchive \
  -archivePath /Users/yuebao/projects/xcode/DoFirst/build/archives/DoFirst-20260513-235532.xcarchive \
  -exportPath build/export-upload \
  -exportOptionsPlist build/exportOptions-upload.plist \
  -allowProvisioningUpdates
```

This retry also failed with exit code `70`.

Root cause:

The App Store distribution provisioning profiles for these identifiers do not include the `Family Controls (Development)` capability / `com.apple.developer.family-controls` entitlement:

- `tristan.DoFirst`
- `tristan.DoFirst.ShieldConfigurationExtension`
- `tristan.DoFirst.ShieldActionExtension`
- `tristan.DoFirst.DeviceActivityMonitorExtension`
- `tristan.DoFirst.DeviceActivityReportExtension`

Development signing works, which is why the app can install and run on the iPhone 15. App Store/TestFlight distribution is blocked until Apple approves the Family Controls distribution entitlement for this app.

Resolved on 2026-05-18 by enabling `Family Controls (Distribution)` in Apple Developer for all five `tristan.DoFirst` App IDs.

## Previous Required Step

The Apple Developer Account Holder requested Family Controls distribution entitlement approval on 2026-05-16 and Apple showed:

```text
Thank you for your submission.
We'll review your request and contact you soon with a status update.
```

Request URL:

```text
https://developer.apple.com/contact/request/family-controls-distribution
```

Apple reference:

```text
https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement
```

Suggested explanation draft:

```text
DoFirst is a focus/productivity app that helps users voluntarily block distracting apps and monitor selected device activity during focus sessions. The app uses Apple's Screen Time APIs locally on the user's device, with explicit user authorization, to configure shields and monitor focus schedules. It does not collect, sell, or share Screen Time data.
```

Do not remove the Family Controls / Screen Time entitlements just to force an upload. The app depends on those APIs, and removing them would either break core behavior or create an App Review risk.

## Current Next Steps

1. Complete App Store metadata, screenshots, privacy, accessibility, and review information.
2. Select the uploaded build `1` for version `1.0`.
3. Submit the version for App Review when the metadata is complete.

Note: the local app icon asset is present and included in the archive (`CFBundleIconName = AppIcon`, 1024x1024 marketing icon present). App Store Connect's app list still showed a placeholder icon immediately after upload, but TestFlight showed build `1` with the uploaded app icon. The list icon may lag behind processing/cache or require the build to clear compliance metadata.

## Metadata Draft Prepared

On 2026-05-19, `APPSTORE_METADATA_DRAFT.md` was added with recommended DoFirst App Store metadata based on the already published `人生刻度` app and DoFirst's local feature set.

Reusable settings from `人生刻度`:

- Simplified Chinese primary language.
- Apple Standard License Agreement.
- No third-party content rights declaration.
- No data collected privacy direction, assuming DoFirst remains local-only.
- Review contact details and copyright owner.
- Automatic release after App Review, if confirmed.

DoFirst-specific decisions:

- Recommended categories: Productivity primary, Lifestyle secondary.
- Recommended subtitle: `先专注，再解锁娱乐`.
- Recommended login requirement: off.
- Recommended review note explains Screen Time / FamilyControls usage and local-only storage.

Local privacy policy pages were prepared under `appstore/`:

- `appstore/index.html`
- `appstore/privacy-policy.html`
- `appstore/privacy-policy-zh.html`

Still needed before applying metadata in App Store Connect:

- Confirm or enable the public GitHub Pages privacy policy URL for DoFirst.
- Use support URL `https://github.com/TristanLib/dofirst/issues` after the repo is pushed.
- Upload fresh DoFirst screenshots from `appstore/screenshots/iphone-65/`.
- Confirm before saving public metadata or transmitting review contact information to Apple.

Fresh screenshots generated from the iPhone 17 simulator:

- Raw simulator screenshots: `appstore/screenshots/raw/`
- App Store Connect 6.5-inch upload set, resized to 1284 x 2778: `appstore/screenshots/iphone-65/`
