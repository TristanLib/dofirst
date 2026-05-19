# DoFirst App Store Metadata Draft

Last updated: 2026-05-19

## Current Blocking Items Observed

- App Info:
  - Subtitle is empty.
  - Primary and secondary categories are unset.
  - Content rights are unset.
  - Age rating is unset.
- App Privacy:
  - Privacy policy URL is empty.
  - App privacy data declaration has not been started.
- Version 1.0:
  - Screenshots are missing.
  - Promotional text, description, keywords, support URL, copyright are empty.
  - Build `1` is uploaded but not selected on the version page.
  - "Requires login" is currently checked, but DoFirst does not have an account login flow.
  - App Review contact fields are empty.

## Fields To Reuse From `人生刻度`

- Primary language: Simplified Chinese.
- License agreement: Apple Standard License Agreement.
- Content rights answer: No third-party content.
- App privacy direction: No data collected, if the app remains local-only and has no analytics/server upload.
- Review contact:
  - First name: Bo
  - Last name: Li
  - Phone: +8613578543257
  - Email: wintersday@163.com
- Copyright:
  - `© 2026 Bo Li`
- Release option:
  - Automatic release after App Review, matching `人生刻度`.

## Fields Not To Copy Directly

- Category should not copy `人生刻度`'s Health & Fitness category. Recommended for DoFirst:
  - Primary category: Productivity
  - Secondary category: Lifestyle
- Privacy policy URL should not reuse the LifeWatch privacy URL. A DoFirst-specific URL is needed.
- Screenshots cannot be reused from `人生刻度`.

## Recommended App Info

- Name:
  - `DoFirst`
- Subtitle:
  - `先专注，再解锁娱乐`
- Categories:
  - Primary: Productivity
  - Secondary: Lifestyle
- Content rights:
  - No, this app does not contain, show, or access third-party content.
- Age rating:
  - Recommended target: `4+`, assuming the questionnaire confirms no unrestricted web access, user-generated content, gambling, medical advice, violence, adult content, ads, or chat.

## Recommended Version 1.0 Metadata

### Promotional Text

先完成重要任务，再解锁娱乐 App。用专注计时、规则限制和每日复盘，把短视频、游戏和社交的冲动变成可执行的自控流程。

### Description

先做重要的事，再享受娱乐时间。

DoFirst 是一款面向学生和上班族的数字自控工具。你可以选择容易分心的 App、类别或网站，设置专注规则，在完成一段专注后再解锁娱乐时间。

核心功能

• 专注后解锁 - 完成 25 分钟专注，获得 15 分钟娱乐时间
• App 限制规则 - 使用系统 Screen Time 能力，限制你主动选择的分心 App、类别或网站
• 固定时间段封锁 - 为工作、学习或睡前设置自动限制时段
• 睡前保护 - 减少夜间刷手机，把休息时间留给自己
• 每日复盘 - 查看今日专注时长、完成次数、解锁次数和连续天数
• 本地优先 - 专注记录、规则和解锁记录保存在设备本地

DoFirst 不靠意志力提醒你“别玩手机”，而是帮你把规则提前设好：先完成任务，再有节制地使用娱乐 App。

你可以用它来：

• 学习前限制短视频和社交 App
• 工作时减少频繁切换和拖延
• 睡前自动屏蔽容易分心的内容
• 用可见的专注记录建立稳定节奏

DoFirst 使用 Apple Screen Time 相关能力。你选择的 App 信息由系统以隐私保护方式处理；DoFirst 不会上传你的 App 选择、专注记录或解锁记录。

### Keywords

专注,自律,戒手机,时间管理,番茄钟,屏幕时间,学习,工作,短视频,社交,拖延,习惯

### Support URL

https://github.com/TristanLib/dofirst/issues

### Marketing URL

Leave empty.

### Copyright

© 2026 Bo Li

## Recommended App Privacy

Recommended declaration:

- The app does not collect data.

Reason:

- Local code search found no networking, analytics SDK, telemetry SDK, Firebase, CloudKit, HealthKit, StoreKit, or server upload code.
- DoFirst stores rules, focus sessions, unlock records, emergency unlock records, daily stats, user goals, and opaque FamilyControls selection tokens locally.
- App selections are handled through Apple's FamilyControls privacy-preserving picker.

Do not submit this privacy declaration if analytics, crash reporting, accounts, cloud sync, ads, purchases, or server APIs are added later.

Local DoFirst privacy policy files prepared for deployment:

- `appstore/index.html`
- `appstore/privacy-policy.html`
- `appstore/privacy-policy-zh.html`

These still need to be hosted at a public HTTPS URL before App Store Connect can use them.

Preferred URL if GitHub Pages is enabled for the repo:

https://tristanlib.github.io/dofirst/appstore/privacy-policy-zh.html

Public GitHub fallback after the repo is pushed:

https://github.com/TristanLib/dofirst/blob/main/appstore/privacy-policy-zh.html

Recommended to use the GitHub Pages URL once it returns HTTP 200.

## Recommended App Review Info

- Login required:
  - Off
- Review notes:

DoFirst is a self-management focus and productivity app. It uses Apple's Screen Time APIs with explicit user authorization so users can voluntarily select apps, categories, or websites to limit during focus sessions and scheduled focus periods.

The app does not require an account. It stores focus rules, focus sessions, unlock records, emergency unlock records, and system-provided opaque FamilyControls selection tokens locally on the device. It does not collect, sell, or share Screen Time data.

To test the core flow, launch the app, complete onboarding, grant Family Controls authorization when prompted, choose a distracting app/category/site in the system picker, create or enable a focus rule, then start a focus session from the Home tab.

## User Confirmation Needed

Before I apply these values in App Store Connect, confirm:

1. Confirm or enable the GitHub Pages privacy policy URL.
2. Whether automatic release after App Review is OK for the first DoFirst release.
3. Final confirmation before saving public metadata in App Store Connect.
