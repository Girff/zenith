//
//  HomeView.swift
//  zenith
//
//  Wireframe Home: THE [BIOME] title over the living ecosystem,
//  Today's Tasks card and Quick Stats beneath.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    var body: some View {
        let theme = store.theme

        ScrollView {
            VStack(spacing: Space.x5) {
                header

                VStack(spacing: Space.x5) {
                    todaysTasksCard
                    quickStats
                    encouragementCard
                }
                .padding(.horizontal, Space.x5)
            }
            .padding(.bottom, 120)
        }
        .background(theme.skyBottom.opacity(0.55))
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
    }

    // MARK: Header — the living biome

    private var header: some View {
        let theme = store.theme

        return ZStack(alignment: .bottom) {
            EcosystemView(biome: store.biome, vitality: store.vitality)
                .frame(height: 400)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: Radius.hero,
                        bottomTrailingRadius: Radius.hero,
                        style: .continuous
                    )
                )

            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: Space.x1) {
                        Text(greeting.uppercased())
                            .font(.zMicro)
                            .tracking(2)
                            .foregroundStyle(theme.accentDeep.opacity(0.8))
                        Text(store.biome.displayName.uppercased())
                            .font(.zScreenTitle)
                            .foregroundStyle(theme.accentDeep)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                        VitalityStatusChip(
                            label: store.vitalityStatus.label,
                            symbol: store.vitalityStatus.symbol
                        )
                    }

                    Spacer()

                    GlassPanel(padding: Space.x2, cornerRadius: 60) {
                        VitalityRing(progress: store.vitality, size: 86, lineWidth: 10)
                    }
                }
                .padding(.horizontal, Space.x5)
                .padding(.bottom, Space.x5)
            }
        }
    }

    // MARK: Today's tasks

    private var todaysTasksCard: some View {
        let theme = store.theme
        let tasks = store.todaysTasks

        return ZenithCard {
            VStack(alignment: .leading, spacing: Space.x2) {
                SectionHeader(
                    title: "Today's Tasks",
                    tint: theme.accentDeep
                )

                if tasks.isEmpty {
                    EmptyStateView(
                        icon: "leaf.arrow.trianglehead.clockwise",
                        title: "A clear day",
                        message: "Nothing due today. Plant a task and watch your biome thank you."
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(tasks) { task in
                            TaskRow(task: task) { store.toggle(task) }
                            if task.id != tasks.last?.id {
                                Divider().overlay(ZenithPalette.hairline)
                            }
                        }
                    }

                    HStack(spacing: Space.x2) {
                        VitalityBar(progress: progressToday)
                        Text("\(store.completedTodayCount)/\(tasks.count)")
                            .font(.zCaption)
                            .foregroundStyle(ZenithPalette.inkSecondary)
                            .monospacedDigit()
                    }
                    .padding(.top, Space.x2)
                }
            }
        }
    }

    private var progressToday: Double {
        let tasks = store.todaysTasks
        guard !tasks.isEmpty else { return 0 }
        return Double(store.completedTodayCount) / Double(tasks.count)
    }

    // MARK: Quick stats

    private var quickStats: some View {
        let theme = store.theme

        return VStack(alignment: .leading, spacing: Space.x3) {
            SectionHeader(title: "Quick Stats", tint: theme.accentDeep)

            HStack(spacing: Space.x3) {
                StatTile(
                    value: "\(store.streakDays)",
                    unit: "day streak",
                    symbol: "flame.fill",
                    tint: ZenithPalette.warning
                )
                StatTile(
                    value: "\(store.completedTodayCount)",
                    unit: "done today",
                    symbol: "checkmark.seal.fill",
                    tint: theme.accent
                )
                StatTile(
                    value: "\(store.xp)",
                    unit: "total XP",
                    symbol: "sparkles",
                    tint: Color(hex: 0x8B7BD8)
                )
            }
        }
    }

    // MARK: Encouragement

    private var encouragementCard: some View {
        let theme = store.theme

        return GlassPanel {
            HStack(spacing: Space.x3) {
                Image(systemName: store.vitalityStatus.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(theme.accentDeep)
                    .frame(width: 44, height: 44)
                    .background(theme.accentSoft, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.vitalityStatus.label)
                        .font(.zHeadline)
                        .foregroundStyle(ZenithPalette.ink)
                    Text(store.vitalityStatus.encouragement)
                        .font(.zSubhead)
                        .foregroundStyle(ZenithPalette.inkSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Stat tile

private struct StatTile: View {
    let value: String
    let unit: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(ZenithPalette.ink)
                .contentTransition(.numericText())
                .monospacedDigit()

            Text(unit.uppercased())
                .font(.zMicro)
                .tracking(0.8)
                .foregroundStyle(ZenithPalette.inkTertiary)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .aspectRatio(1, contentMode: .fit)
        .background(ZenithPalette.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .cardShadow()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(unit)")
    }
}
