//
//  AppBlockingView.swift
//  zenith
//
//  Focus Shield — distraction-blocking sessions, after the "Sessions"
//  reference shot (Today / Upcoming / Quick Ideas).
//

import SwiftUI

struct AppBlockingView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let theme = store.theme

        ScrollView {
            VStack(alignment: .leading, spacing: Space.x4) {
                VStack(alignment: .leading, spacing: Space.x1) {
                    OverlineText(text: "Protect your focus", color: theme.accentDeep.opacity(0.7))
                    Text("FOCUS SHIELD")
                        .font(.zScreenTitle)
                        .foregroundStyle(theme.accentDeep)
                }
                .padding(.top, Space.x2)

                section(title: "Today", slot: .today)
                section(title: "Upcoming", slot: .upcoming)
                section(title: "Quick Ideas", slot: .idea)
            }
            .padding(.horizontal, Space.x5)
            .padding(.bottom, 140)
        }
        .background(theme.skyBottom.opacity(0.55))
        .scrollIndicators(.hidden)
        .navigationTitle("Focus Shield")
        .inlineNavigationTitle()
    }

    @ViewBuilder
    private func section(title: String, slot: FocusSessionRule.Slot) -> some View {
        let rules = store.focusRules.filter { $0.slot == slot }

        if !rules.isEmpty {
            VStack(alignment: .leading, spacing: Space.x2) {
                SectionHeader(title: title, tint: store.theme.accentDeep)
                VStack(spacing: Space.x3) {
                    ForEach(rules) { rule in
                        FocusRuleCard(rule: rule, isIdea: slot == .idea)
                    }
                }
            }
        }
    }
}

private struct FocusRuleCard: View {
    let rule: FocusSessionRule
    let isIdea: Bool

    @Environment(AppStore.self) private var store
    @Environment(\.biomeTheme) private var theme

    var body: some View {
        ZenithCard(padding: Space.x3) {
            HStack(spacing: Space.x3) {
                Text(rule.emoji)
                    .font(.system(size: 26))
                    .frame(width: 52, height: 52)
                    .background(theme.accentSoft.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(rule.name)
                        .font(.zHeadline)
                        .foregroundStyle(ZenithPalette.ink)

                    HStack(spacing: Space.x1) {
                        if let minutes = rule.blockedMinutes {
                            HStack(spacing: 2) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 9))
                                Text("\(minutes)")
                                    .font(.zCaption)
                            }
                            .foregroundStyle(theme.accentDeep)
                        }
                        Text(rule.schedule)
                            .font(.zCaption)
                            .foregroundStyle(ZenithPalette.inkTertiary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                if isIdea {
                    Button {
                        adopt()
                    } label: {
                        Label("Add", systemImage: "plus")
                            .font(.zCaption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Space.x3)
                            .padding(.vertical, 7)
                            .background(theme.accent, in: Capsule())
                    }
                    .buttonStyle(.pressable(scale: 0.9))
                    .accessibilityLabel("Add \(rule.name) session")
                } else {
                    Toggle("", isOn: binding)
                        .labelsHidden()
                        .tint(theme.accent)
                        .accessibilityLabel("\(rule.name) enabled")
                }
            }
        }
    }

    private var binding: Binding<Bool> {
        Binding(
            get: { store.focusRules.first(where: { $0.id == rule.id })?.isEnabled ?? false },
            set: { newValue in
                if let i = store.focusRules.firstIndex(where: { $0.id == rule.id }) {
                    store.focusRules[i].isEnabled = newValue
                }
            }
        )
    }

    private func adopt() {
        guard let i = store.focusRules.firstIndex(where: { $0.id == rule.id }) else { return }
        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
            store.focusRules[i] = FocusSessionRule(
                name: rule.name,
                emoji: rule.emoji,
                schedule: rule.schedule,
                blockedMinutes: rule.blockedMinutes ?? 30,
                slot: .upcoming,
                isEnabled: true
            )
        }
    }
}
