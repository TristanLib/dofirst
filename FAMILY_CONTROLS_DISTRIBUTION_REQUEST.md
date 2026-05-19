# Family Controls Distribution Entitlement Request

Use this content for Apple's Family Controls distribution entitlement request form:

https://developer.apple.com/contact/request/family-controls-distribution

## Team

- Account holder: Bo Li
- Team ID: `6D4LF7V6W3`
- App name: `DoFirst`
- App Store Connect app ID: `6769286854`

## Bundle IDs

```text
tristan.DoFirst
tristan.DoFirst.ShieldConfigurationExtension
tristan.DoFirst.ShieldActionExtension
tristan.DoFirst.DeviceActivityMonitorExtension
tristan.DoFirst.DeviceActivityReportExtension
```

## Requested Entitlement

```text
Family Controls distribution entitlement / com.apple.developer.family-controls
```

## App Description

```text
DoFirst is a self-management focus/productivity app for adult users. It helps users voluntarily block distracting apps and websites during focus sessions and scheduled focus periods.

The app uses Apple's Screen Time APIs locally on the user's device, with explicit user authorization, to let users select apps, categories, and websites; apply ManagedSettings shields; monitor scheduled focus periods with DeviceActivity; customize the shield screen; and show basic local activity summaries.

DoFirst does not collect, sell, or share Screen Time data. It is not positioned as a parental surveillance product. The Screen Time APIs are used only for user-controlled focus and distraction blocking.
```

## Why Family Controls Is Required

```text
DoFirst requires the Family Controls entitlement because its core user-facing functionality depends on Apple's Screen Time APIs:

1. FamilyControls lets users privately select the apps, categories, and websites they want to limit.
2. ManagedSettings applies shields to the selected apps/websites during focus sessions and scheduled focus periods.
3. DeviceActivityMonitor starts and ends scheduled rules such as work-time blocks and bedtime protection.
4. ShieldConfiguration and ShieldAction extensions provide a clear self-management experience when users try to open blocked apps.

Without this entitlement, DoFirst cannot provide its core focus and distraction-blocking behavior.
```

## Privacy And Safety

```text
DoFirst is designed for individual self-management. Users explicitly authorize Screen Time access and choose their own restricted apps/categories/websites. The app stores only local rules, focus sessions, unlock tokens, emergency unlock records, and system-provided opaque selection tokens.

DoFirst does not collect raw Screen Time usage data on a server, does not sell or share Screen Time data, and does not use the entitlement for monitoring children or third parties.
```

## Review Notes

```text
The app's product positioning is voluntary focus and productivity for adult users. It uses a reward-based flow: users complete a focus session first, then temporarily unlock entertainment apps. Emergency unlock is limited and user-controlled.

We request approval for the Family Controls distribution entitlement for the main app and all related Screen Time extensions listed above so the App Store distribution provisioning profiles can include com.apple.developer.family-controls.
```
