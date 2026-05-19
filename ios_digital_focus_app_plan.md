# 方向 2：数字自控 / 专注 / 戒手机 iOS App 详细方案

## 1. 产品定位

**一句话定位：**  
用户先完成学习、工作或习惯任务，才能解锁短视频、社交、游戏等娱乐 App。

**核心逻辑：**

```text
选择想限制的 App → 设置规则 → 被分心时拦截 → 完成专注任务 → 获得娱乐时间 → 每日复盘
```

这个 App 不应该只是“封锁 App”，而应该是一个帮助用户建立自控力的行为系统。

产品理念：

> 我不是不让你玩，而是帮你先完成重要的事，再有节制地玩。

---

## 2. 推荐首批用户

第一版建议定位成人用户，不建议一开始做儿童防沉迷或家长控制。

| 用户类型 | 场景 | 痛点 | 解决方式 |
|---|---|---|---|
| 学生 | 学习时总刷短视频 | 想学但控制不住 | 完成学习后才能解锁娱乐 |
| 上班族 | 工作时频繁看社交软件 | 注意力碎片化 | 工作时段自动限制 |
| 自由职业者 | 没人监督、拖延严重 | 缺少外部约束 | 任务和解锁机制 |
| 晚睡人群 | 睡前刷手机停不下来 | 作息失控 | 睡前保护模式 |

第一版建议聚焦：

> 学生和上班族的“专注解锁娱乐”工具。

---

## 3. 产品核心价值

这个产品的价值不是“让用户痛苦地少玩手机”，而是：

1. **把自控变成一个可执行系统。**  
   用户不需要靠意志力，而是靠规则。

2. **用奖励替代单纯禁止。**  
   完成专注后解锁娱乐，用户更容易接受。

3. **减少无意识刷手机。**  
   用户每次打开被限制 App 时，会被提醒当前目标。

4. **建立长期反馈。**  
   今日专注、连续天数、解锁次数、分心拦截次数都能给用户成就感。

---

## 4. iOS 技术边界

这个方向会涉及 Apple Screen Time 相关能力，开发复杂度和审核风险都高于普通 App。

主要技术包括：

| 技术 | 用途 |
|---|---|
| FamilyControls | 让用户选择要限制的 App、类别、网站 |
| DeviceActivity | 监测设备活动和时间段 |
| ManagedSettings | 对选中的 App / 网站加 shield 限制 |
| ShieldConfiguration Extension | 自定义被限制时看到的页面 |
| ShieldAction Extension | 处理用户在 shield 页面上的操作 |
| DeviceActivityMonitor Extension | 到指定时间触发限制或解除限制 |
| DeviceActivityReport Extension | 展示设备活动报告 |

### 重要注意事项

- 需要申请 Family Controls entitlement。
- 必须在真机上测试。
- 不能把 Screen Time API 本身包装成付费解锁点。
- 付费点更适合放在高级计划、报告、挑战、AI 教练、模板等附加价值上。
- 不建议第一版定位儿童或家长控制，因为儿童数据和审核要求更复杂。

---

## 5. MVP 功能范围

### 第一版必须做

| 模块 | 功能 | 优先级 |
|---|---|---|
| 授权 | FamilyControls 授权 | P0 |
| App 选择 | 选择要限制的 App / 类别 / 网站 | P0 |
| 规则 | 专注解锁规则 | P0 |
| 规则 | 固定时间段封锁 | P0 |
| 规则 | 睡前保护 | P0 |
| Shield | 自定义限制页面 | P0 |
| 计时 | 25 分钟专注计时 | P0 |
| 解锁 | 完成专注后解锁娱乐时间 | P0 |
| 紧急解锁 | 每天 1 次，5 分钟 | P0 |
| 报告 | 今日专注、完成次数、解锁次数 | P1 |
| 设置 | 规则开关、重置授权、隐私说明 | P0 |

### 第一版暂时不做

| 功能 | 暂不做原因 |
|---|---|
| 朋友监督 | 社交冷启动复杂 |
| 家长控制 | 合规复杂，儿童数据要求高 |
| 跨设备管理 | 技术复杂度高 |
| AI 教练 | 第二版再做 |
| 复杂成就系统 | 等验证留存后再加 |
| 复杂屏幕时间排行榜 | Screen Time 数据边界需要谨慎 |
| 团队 / 班级功能 | 早期不需要 |

---

## 6. 核心机制

## 6.1 任务解锁娱乐

这是产品最重要的机制。

用户选择想限制的 App，例如短视频、社交、游戏。  
然后设置规则：

```text
专注学习 25 分钟 → 解锁娱乐 App 15 分钟
```

这个机制比“永久封锁”更容易被用户接受。

---

## 6.2 固定时间段封锁

适合上班族和学生。

示例规则：

```text
工作日 9:00–12:00 禁用短视频
工作日 14:00–18:00 禁用游戏和社交 App
```

功能细节：

- 支持选择星期几。
- 支持多个时间段。
- 支持当天跳过一次。
- 支持临时暂停。
- 支持紧急解锁。

---

## 6.3 睡前保护

适合晚睡用户。

示例规则：

```text
每天 23:00–07:00 禁用短视频、游戏和社交 App
```

功能细节：

- 睡前 30 分钟提醒。
- 到点后自动进入限制。
- 第二天早上自动解除。
- 跨午夜规则要单独处理。
- 每晚允许一次紧急解锁。

---

## 6.4 紧急解锁

不要完全不给用户退路，否则用户容易卸载 App。

建议规则：

- 每天 1 次。
- 每次 5 分钟。
- 可以要求用户填写原因。
- 紧急解锁次数会进入日报。

示例文案：

```text
你确定要使用今天的紧急解锁吗？
这会解锁 5 分钟，今天只能使用 1 次。
```

---

## 6.5 解锁令牌

用户通过完成专注获得娱乐时间。

| 行为 | 奖励 |
|---|---|
| 专注 25 分钟 | 娱乐 15 分钟 |
| 完成 3 个专注 | 额外娱乐 10 分钟 |
| 连续 3 天达标 | 周末奖励 30 分钟 |
| 使用紧急解锁 | 消耗 1 次紧急机会 |

解锁令牌字段：

- tokenId。
- createdAt。
- expiresAt。
- unlockMinutes。
- sourceFocusSessionId。
- usedAt。
- status。

---

## 7. Onboarding 设计

第一次打开 App 的流程要短，目标是 3 分钟内完成设置。

### Step 1：选择目标

选项：

- 我想学习时少刷手机。
- 我想工作时更专注。
- 我想晚上早点睡。
- 我想减少短视频时间。

### Step 2：选择限制类型

选项：

- 短视频。
- 社交。
- 游戏。
- 购物。
- 新闻。
- 自定义选择。

### Step 3：授权说明

文案示例：

```text
为了帮你限制分心 App，我们需要你授权 Screen Time 相关权限。
你选择的 App 信息会由系统以隐私保护的方式处理。
```

### Step 4：选择 App / 类别 / 网站

使用 Family Activity Picker。

### Step 5：创建第一条规则

默认推荐：

```text
专注 25 分钟 → 解锁娱乐 15 分钟
```

---

## 8. 页面设计

建议第一版使用 4 个 Tab。

| Tab | 页面内容 |
|---|---|
| 首页 | 当前状态、开始专注、今日进度 |
| 规则 | App 选择、规则列表、时间段设置 |
| 报告 | 今日、本周、连续天数、解锁次数 |
| 我的 | 会员、隐私、授权、设置 |

---

## 9. 首页功能细节

首页是用户每天最常用的地方。

### 状态卡片

显示当前状态：

- 正在限制中。
- 已解锁，还有 X 分钟。
- 未启用规则。
- 睡前保护将在 23:00 开始。

### 主按钮

根据状态变化：

| 当前状态 | 主按钮 |
|---|---|
| 未专注 | 开始 25 分钟专注 |
| 专注中 | 显示倒计时 |
| 已完成专注 | 解锁娱乐 15 分钟 |
| 限制中 | 查看限制原因 |

### 今日进度

显示：

- 今日专注总时长。
- 完成专注次数。
- 已解锁娱乐时间。
- 紧急解锁次数。
- 连续达标天数。

---

## 10. 规则页功能细节

### 规则列表

每条规则显示：

- 规则名称。
- 规则类型。
- 生效时间。
- 目标 App / 类别。
- 开关。

### 规则类型

第一版做 3 种：

1. 专注解锁。
2. 固定时间段封锁。
3. 睡前保护。

### 规则编辑页

字段：

- 规则名称。
- 生效星期。
- 开始时间。
- 结束时间。
- 目标 App 选择。
- 是否允许紧急解锁。
- 是否启用通知提醒。

---

## 11. Shield 页面设计

Shield 页面是用户尝试打开被限制 App 时看到的页面。这个页面非常重要，因为它决定用户是继续坚持，还是讨厌你的 App。

### 文案原则

不要羞辱用户，不要说教。  
应该支持用户、提醒目标、给出下一步行动。

### Shield 文案示例

```text
你正在保护自己的注意力。

先完成 25 分钟专注，
再回来玩 15 分钟。
```

### 按钮设计

| 按钮 | 功能 |
|---|---|
| 开始专注 | 跳回 App，进入专注计时 |
| 稍后再说 | 返回系统或退出 |
| 紧急解锁 5 分钟 | 消耗当天紧急解锁机会 |
| 查看今日进度 | 打开 App 首页 |

---

## 12. 专注计时功能

### 计时设置

默认：25 分钟。

可选：

- 15 分钟。
- 25 分钟。
- 45 分钟。
- 自定义。

第一版可以只做 25 分钟，后面再开放自定义。

### 专注任务名称

用户可以输入：

- 复习英语。
- 写报告。
- 整理资料。
- 健身。
- 阅读。

### 计时期间

- 显示倒计时。
- 显示当前任务。
- 显示完成后可解锁时间。
- 可以暂停 1 次。
- 可以放弃，但不获得解锁奖励。

### 完成后

显示：

```text
你完成了 25 分钟专注。
已获得 15 分钟娱乐时间。
```

按钮：

- 立即解锁。
- 稍后使用。
- 再来一轮。

---

## 13. 报告系统

### 今日报告

显示：

- 专注时长。
- 专注次数。
- 完成率。
- 解锁娱乐时间。
- 紧急解锁次数。
- 被拦截次数。

### 本周报告

显示：

- 本周专注总时长。
- 连续达标天数。
- 最容易分心的时间段。
- 最常触发限制的 App 类别。
- 本周进步一句话总结。

### 报告文案示例

```text
你今天完成了 3 次专注，总计 75 分钟。
你成功拦截了 6 次无意识刷手机。
相比昨天，你减少了 20 分钟娱乐解锁时间。
```

---

## 14. 数据模型设计

### FocusRule

```swift
struct FocusRule {
    var id: UUID
    var name: String
    var type: FocusRuleType
    var weekdays: [Int]
    var startTime: DateComponents?
    var endTime: DateComponents?
    var isEnabled: Bool
    var allowsEmergencyUnlock: Bool
}
```

### AppSelectionProfile

```swift
struct AppSelectionProfile {
    var id: UUID
    var name: String
    var selectedTokensData: Data
    var createdAt: Date
    var updatedAt: Date
}
```

### FocusSession

```swift
struct FocusSession {
    var id: UUID
    var taskName: String
    var startedAt: Date
    var endedAt: Date?
    var plannedMinutes: Int
    var completed: Bool
    var rewardMinutes: Int
}
```

### UnlockToken

```swift
struct UnlockToken {
    var id: UUID
    var minutes: Int
    var createdAt: Date
    var expiresAt: Date?
    var usedAt: Date?
    var status: UnlockTokenStatus
}
```

### EmergencyUnlock

```swift
struct EmergencyUnlock {
    var id: UUID
    var usedAt: Date
    var minutes: Int
    var reason: String?
}
```

### DailyStats

```swift
struct DailyStats {
    var date: Date
    var focusMinutes: Int
    var sessionsCompleted: Int
    var unlockMinutes: Int
    var emergencyCount: Int
    var shieldTriggerCount: Int
}
```

### UserGoal

```swift
struct UserGoal {
    var id: UUID
    var type: UserGoalType
    var targetFocusMinutes: Int
    var targetSleepTime: DateComponents?
}
```

---

## 15. 技术架构

| 层级 | 推荐技术 |
|---|---|
| UI | SwiftUI |
| 本地数据 | SwiftData |
| App 选择 | FamilyControls |
| 时间监测 | DeviceActivity |
| App 限制 | ManagedSettings |
| Shield 页面 | ShieldConfiguration Extension |
| Shield 操作 | ShieldAction Extension |
| 定时触发 | DeviceActivityMonitor Extension |
| 报告 | DeviceActivityReport Extension |
| 本地通知 | UserNotifications |
| 付费 | StoreKit 2 |
| 测试分发 | TestFlight |

---

## 16. 8 周实施计划

## 第 0 周：权限和可行性验证

这个方向必须先做权限验证。

任务：

- 注册 Apple Developer Program。
- 创建 App ID。
- 申请 Family Controls entitlement。
- 配置主 App 和扩展能力。
- 搭建最小 demo：选择 App → shield App → 解除 shield。

验收标准：

- 能在真机上选择 App。
- 能成功 shield。
- 能解除 shield。
- 能处理授权失败。

如果这一步卡住，不要继续堆 UI。

---

## 第 1 周：基础 App + Onboarding

目标：完成产品入口。

任务：

- 创建 SwiftUI 项目。
- 做首页。
- 做授权说明页。
- 实现 FamilyControls 授权流程。
- 做 App / 类别选择页。
- 保存用户选择。

验收标准：

- 用户能完成授权。
- 用户能选择要限制的 App。
- 选择结果能保存。

---

## 第 2 周：规则系统

目标：创建规则。

任务：

- 创建 FocusRule 数据模型。
- 做规则列表。
- 做规则编辑页。
- 支持专注解锁规则。
- 支持固定时间段规则。
- 支持睡前保护规则。

验收标准：

- 用户能创建、编辑、删除规则。
- 规则能启用 / 停用。
- 规则能保存到本地。

---

## 第 3 周：ManagedSettings + Shield

目标：真正限制 App。

任务：

- 接入 ManagedSettingsStore。
- 根据规则 shield 选中的 App。
- 做解除 shield。
- 做 ShieldConfiguration Extension。
- 设计限制页文案。
- 加“开始专注”和“紧急解锁”按钮。

验收标准：

- 到限制状态时，选中的 App 被 shield。
- 用户看到自定义限制页。
- 点击按钮能进入正确流程。

---

## 第 4 周：专注计时 + 解锁

目标：完成核心闭环。

任务：

- 实现 25 分钟专注计时。
- 支持专注任务名称。
- 完成后生成 UnlockToken。
- 解锁娱乐 App 15 分钟。
- 到期后重新 shield。
- 紧急解锁每天限制 1 次。

验收标准：

- 用户完成专注后能解锁。
- 解锁到期后能重新限制。
- 紧急解锁次数受控。

---

## 第 5 周：DeviceActivityMonitor

目标：让规则自动运行。

任务：

- 创建 DeviceActivityMonitor Extension。
- 配置时间段监测。
- 到开始时间触发 shield。
- 到结束时间解除 shield。
- 处理跨午夜规则，例如 23:00–07:00。
- 处理 App 重启后的规则恢复。

验收标准：

- 固定时间段规则可以自动执行。
- 睡前保护可以跨天执行。
- App 重启后规则仍然有效。

---

## 第 6 周：报告页

目标：让用户看到成就。

任务：

- 今日专注时长。
- 今日完成次数。
- 今日解锁娱乐分钟数。
- 紧急解锁次数。
- 连续达标天数。
- DeviceActivityReport 展示。

验收标准：

- 用户能看到今天和本周的行为变化。
- 报告页面清晰、有激励感。
- 不依赖不稳定或不可获取的数据。

---

## 第 7 周：商业化 + 审核准备

目标：准备 TestFlight。

任务：

- 免费版：基础规则、基础专注。
- Pro：高级规则模板、周报、睡前计划、挑战系统。
- StoreKit 2。
- 隐私政策。
- App Review 说明文档。
- 准备演示账号或演示流程。

注意：

不要写成“付费解锁 Screen Time 限制能力”。  
更安全的表达是：

```text
Pro 解锁高级习惯计划、复盘报告、挑战模板和个性化建议。
```

---

## 第 8 周：TestFlight 内测

目标：验证用户是否真的坚持用。

任务：

- 找 20–30 个有拖延或刷手机问题的人。
- 观察授权完成率。
- 观察规则创建率。
- 记录用户是否完成第一次专注。
- 观察 7 日留存。
- 收集卡点和卸载原因。

重点指标：

| 指标 | 目标 |
|---|---:|
| 完成授权比例 | ≥ 60% |
| 成功创建规则比例 | ≥ 70% |
| 第一次专注完成率 | ≥ 50% |
| 7 日留存 | ≥ 25% |
| 人均专注次数 | ≥ 5 次/周 |
| 紧急解锁使用率 | 不超过 30% |
| 愿意付费人数 | ≥ 3–5 人 |

---

## 17. 商业化设计

### 免费版

- 1 个 App 选择配置。
- 1–2 条基础规则。
- 基础专注计时。
- 每天 1 次紧急解锁。
- 基础今日报告。

### Pro 版

- 多个规则模板。
- 多组 App 配置。
- 睡前保护计划。
- 周报和趋势分析。
- 挑战系统。
- 高级提醒。
- 个性化习惯建议。

### 不建议的收费方式

不要把这些做成付费点：

- 付费才能限制 App。
- 付费才能使用 Screen Time 基础能力。
- 付费才能选择 App。

更合理的付费点是行为系统、报告、模板和长期计划。

---

## 18. 14 天立即执行清单

### 第 1–3 天

- 确定第一版定位：学生 / 上班族专注解锁娱乐。
- 写产品说明。
- 画首页、规则页、Shield 页面、报告页。
- 查看 FamilyControls、DeviceActivity、ManagedSettings 文档。
- 准备 Apple Developer 账号和 entitlement 申请。

### 第 4–7 天

- 创建 SwiftUI 项目。
- 创建基础页面。
- 尝试 FamilyControls 授权。
- 尝试 Family Activity Picker。
- 保存 App 选择结果。

### 第 8–10 天

- 尝试 ManagedSettings shield。
- 实现最小限制 Demo。
- 实现解除限制。
- 处理授权失败和授权撤销。

### 第 11–14 天

- 做 25 分钟专注计时。
- 完成后解锁 15 分钟。
- 到期后重新限制。
- 做第一个完整闭环 Demo。

14 天结束时应该可以演示：

```text
选择短视频 App → 开始限制 → 完成 25 分钟专注 → 解锁 15 分钟 → 到期重新限制
```

---

## 19. 风险与应对

| 风险 | 表现 | 应对 |
|---|---|---|
| 权限申请卡住 | Family Controls entitlement 无法顺利拿到 | 第 0 周先验证，别先做大量 UI |
| 审核风险 | 被认为滥用 Screen Time API | 文案和功能定位为自我管理，不做付费解锁 API |
| 用户反感限制 | 用户觉得 App 太强硬 | 使用奖励机制和紧急解锁 |
| 留存差 | 用户设置后很少回来 | 增加报告、连续天数、任务奖励 |
| 技术不稳定 | shield 状态和规则同步出错 | 做状态恢复和详细日志 |
| 数据边界误判 | 想拿到过多屏幕时间原始数据 | 尊重系统限制，报告只做可稳定获取的内容 |

---

## 20. 后续版本路线

### V1.1

- 自定义专注时长。
- 多个 App 配置。
- 更多规则模板。
- 更好的睡前提醒。

### V1.2

- 周报。
- 连续挑战。
- 自控力评分。
- 个性化文案。

### V2.0

- AI 教练：每天生成一句复盘和建议。
- 根据用户行为推荐规则。
- 自动识别最容易分心的时间段。

### V3.0

- 与方向 1 融合：

```text
导入学习资料 → AI 生成学习任务 → 完成任务 → 解锁娱乐 App
```

这个融合方向会比单纯戒手机 App 更有差异化。

---

## 21. 推荐产品路线

不建议一开始就完整开发方向 2。  
更稳妥路线：

1. 先完成权限和 shield Demo。
2. 再做专注解锁 MVP。
3. 内测验证用户是否真的愿意长期使用。
4. 最后再加报告、挑战、Pro 订阅。

如果方向 1 也在做，推荐最终融合成：

> AI 学习资料整理 + 专注学习 + 娱乐解锁。

这会形成非常完整的产品闭环。

---

## 22. 参考资料

- Apple Developer - Screen Time API Documentation: https://developer.apple.com/documentation/ScreenTimeAPIDocumentation
- Apple Developer - FamilyControls: https://developer.apple.com/documentation/familycontrols
- Apple Developer - DeviceActivity: https://developer.apple.com/documentation/deviceactivity
- Apple Developer - ManagedSettings: https://developer.apple.com/documentation/managedsettings
- Apple Developer - DeviceActivityReport: https://developer.apple.com/documentation/deviceactivity/deviceactivityreport
- Apple Developer - StoreKit: https://developer.apple.com/storekit/
- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
