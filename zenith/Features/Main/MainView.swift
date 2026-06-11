//
//  MainView.swift
//  zenith
//
//  Five-tab shell from the wireframe: Home · Tasks · Add-Ons ·
//  Calendar · Leaderboard, with a floating glass tab bar.
//

import SwiftUI

enum ZenithTab: String, CaseIterable, Identifiable {
    case home, tasks, addOns, calendar, leaderboard

    var id: String { rawValue }

    var label: String {
        switch self {
        case .home: "Home"
        case .tasks: "Tasks"
        case .addOns: "Add-Ons"
        case .calendar: "Calendar"
        case .leaderboard: "Ranks"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .tasks: "checklist"
        case .addOns: "square.grid.2x2"
        case .calendar: "calendar"
        case .leaderboard: "trophy"
        }
    }

    var activeIcon: String {
        switch self {
        case .home: "house.fill"
        case .tasks: "checklist.checked"
        case .addOns: "square.grid.2x2.fill"
        case .calendar: "calendar"
        case .leaderboard: "trophy.fill"
        }
    }
}

struct MainView: View {
    @Environment(AppStore.self) private var store
    @State private var selection: ZenithTab

    init() {
        // Launch-argument override for simulator debugging/screenshots:
        // `simctl launch <device> <bundle-id> -zenithTab tasks`
        let initial = UserDefaults.standard.string(forKey: "zenithTab")
            .flatMap(ZenithTab.init(rawValue:)) ?? .home
        _selection = State(initialValue: initial)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home: HomeView()
                case .tasks: TasksView()
                case .addOns: AddOnsView()
                case .calendar: CalendarScreenView()
                case .leaderboard: LeaderboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZenithTabBar(selection: $selection)
                .padding(.horizontal, Space.x4)
                .padding(.bottom, Space.x2)
        }
        .ignoresSafeArea(.keyboard)
        .environment(\.biomeTheme, store.theme)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

// MARK: - Floating glass tab bar

struct ZenithTabBar: View {
    @Binding var selection: ZenithTab
    @Environment(\.biomeTheme) private var theme
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ZenithTab.allCases) { tab in
                let isActive = selection == tab

                Button {
                    withAnimation(.spring(duration: 0.45, bounce: 0.3)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: isActive ? tab.activeIcon : tab.icon)
                            .font(.system(size: 19, weight: isActive ? .semibold : .regular))
                            .symbolEffect(.bounce, value: isActive)
                        Text(tab.label)
                            .font(.zMicro)
                    }
                    .foregroundStyle(isActive ? theme.accentDeep : ZenithPalette.inkTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Space.x2)
                    .background {
                        if isActive {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(theme.accentSoft.opacity(0.85))
                                .matchedGeometryEffect(id: "activePill", in: pill)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.pressable(scale: 0.92))
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(isActive ? [.isSelected] : [])
            }
        }
        .padding(Space.x1)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.4), lineWidth: 1)
        )
        .floatShadow()
    }
}
