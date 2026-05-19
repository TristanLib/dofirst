import FamilyControls
import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(ScreenTimeController.self) private var screenTime
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusRule.createdAt) private var rules: [FocusRule]

    let onComplete: () -> Void

    @State private var step = 0
    @State private var selectedGoal: UserGoalType = .study
    @State private var selectedRestriction = "短视频"
    @State private var isPickerPresented = false

    private let restrictionTypes = ["短视频", "社交", "游戏", "购物", "新闻", "自定义"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: 5)
                    .padding(.horizontal)
                    .padding(.top)

                TabView(selection: $step) {
                    goalStep.tag(0)
                    restrictionStep.tag(1)
                    authorizationStep.tag(2)
                    selectionStep.tag(3)
                    firstRuleStep.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                footer
            }
            .navigationTitle("DoFirst")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.pageBackground)
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: Binding(
                get: { screenTime.selection },
                set: { screenTime.selection = $0 }
            )
        )
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            onboardingHeader(
                symbol: "target",
                title: "先选一个目标",
                subtitle: "首版聚焦学生和上班族的专注解锁娱乐流程。"
            )

            ForEach(UserGoalType.allCases) { goal in
                optionButton(
                    title: goal.title,
                    isSelected: selectedGoal == goal,
                    symbol: goal == .sleepEarlier ? "moon" : "checkmark.circle"
                ) {
                    selectedGoal = goal
                }
            }
            Spacer()
        }
        .padding()
    }

    private var restrictionStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            onboardingHeader(
                symbol: "app.badge",
                title: "选择容易分心的类型",
                subtitle: "下一步会打开系统选择器，精确选择 App、类别或网站。"
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                ForEach(restrictionTypes, id: \.self) { type in
                    optionButton(title: type, isSelected: selectedRestriction == type, symbol: "square.grid.2x2") {
                        selectedRestriction = type
                    }
                }
            }
            Spacer()
        }
        .padding()
    }

    private var authorizationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            onboardingHeader(
                symbol: "lock.shield",
                title: "授权 Screen Time",
                subtitle: "为了帮你限制分心 App，需要 Family Controls 授权。选择的 App 信息由系统以隐私保护方式处理。"
            )

            VStack(alignment: .leading, spacing: 12) {
                Label("当前状态：\(screenTime.authorizationLabel)", systemImage: "checkmark.seal")
                    .font(.headline)

                Button {
                    Task { await screenTime.requestAuthorization() }
                } label: {
                    Label("请求授权", systemImage: "hand.raised")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let message = screenTime.lastErrorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            Spacer()
        }
        .padding()
    }

    private var selectionStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            onboardingHeader(
                symbol: "rectangle.stack.badge.person.crop",
                title: "选择限制对象",
                subtitle: "可以选择 App、类别或网站。后续规则都会使用这组选择。"
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(screenTime.selectionSummary)
                    .font(.headline)

                Button {
                    isPickerPresented = true
                } label: {
                    Label("打开系统选择器", systemImage: "plus.app")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let message = screenTime.lastErrorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            Spacer()
        }
        .padding()
    }

    private var firstRuleStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            onboardingHeader(
                symbol: "timer",
                title: "创建第一条规则",
                subtitle: "默认规则是专注 25 分钟，获得 15 分钟娱乐时间。"
            )

            VStack(alignment: .leading, spacing: 16) {
                Label("专注 25 分钟", systemImage: "timer")
                Label("解锁娱乐 15 分钟", systemImage: "lock.open")
                Label("每天 1 次紧急解锁 5 分钟", systemImage: "exclamationmark.triangle")

                if let message = screenTime.lastErrorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            Spacer()
        }
        .padding()
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button {
                step = max(0, step - 1)
            } label: {
                Label("上一步", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(step == 0)

            Button {
                if step < 4 {
                    step += 1
                } else {
                    finishOnboarding()
                }
            } label: {
                Label(step < 4 ? "下一步" : "开始使用", systemImage: step < 4 ? "chevron.right" : "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial)
    }

    private func onboardingHeader(symbol: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.largeTitle)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 56, height: 56)
                .background(AppTheme.primary.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            Text(title)
                .font(.largeTitle.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func optionButton(title: String, isSelected: Bool, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .frame(width: 24)
                Text(title)
                    .font(.headline)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.success)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
            .background(isSelected ? AppTheme.primary.opacity(0.12) : AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? AppTheme.primary : .clear, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func finishOnboarding() {
        guard screenTime.saveCurrentSelection(named: "默认限制对象", in: modelContext) != nil else {
            return
        }
        modelContext.insert(UserGoal(type: selectedGoal))
        SeedData.ensureDefaults(in: modelContext, existingRules: rules)
        try? modelContext.save()
        onComplete()
    }
}
