import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case rules
    case reports
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            "首页"
        case .rules:
            "规则"
        case .reports:
            "报告"
        case .settings:
            "我的"
        }
    }

    var symbolName: String {
        switch self {
        case .home:
            "target"
        case .rules:
            "slider.horizontal.3"
        case .reports:
            "chart.bar.xaxis"
        case .settings:
            "person.crop.circle"
        }
    }
}

struct AppShellView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    content(for: tab)
                        .navigationTitle(tab.title)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.symbolName)
                }
                .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .rules:
            RulesView()
        case .reports:
            ReportsView()
        case .settings:
            SettingsView()
        }
    }
}

