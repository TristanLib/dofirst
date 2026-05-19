# DoFirst

DoFirst is a SwiftUI MVP for the digital focus app described in `ios_digital_focus_app_plan.md`.

## Implemented scope

- 4-tab app shell: Home, Rules, Reports, Settings.
- Onboarding: goal selection, distraction category, Family Controls authorization, Family Activity Picker, first focus rule.
- SwiftData models for rules, app selections, focus sessions, unlock tokens, emergency unlocks, daily stats, and user goals.
- Focus loop: 25-minute focus timer, one pause, reward token generation, 15-minute entertainment unlock.
- Rules: focus unlock, scheduled block, bedtime protection, enable/disable, edit/delete, DeviceActivity scheduling entry point.
- Screen Time plumbing: FamilyControls authorization/picker, ManagedSettings shield apply/clear, app group sharing for extensions.
- Extensions: Shield Configuration, Shield Action, Device Activity Monitor, and Device Activity Report.

## Required Apple setup

Real Screen Time behavior requires an Apple Developer account, a real device, and the Family Controls entitlement on the main app and extensions. The project uses placeholder identifiers:

- `tristan.DoFirst`
- `group.tristan.dofirst`

Before running on a device, replace these with identifiers owned by your developer team and enable App Groups + Family Controls in the Apple Developer portal.

## Build

For simulator compile checks without signing:

```sh
xcodebuild -project DoFirst.xcodeproj -scheme DoFirst -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO build
```
