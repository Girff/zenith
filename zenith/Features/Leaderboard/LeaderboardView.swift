//
//  LeaderboardView.swift
//  zenith
//
//  Weekly XP leaderboard, after the reference shot — medals for the
//  top three, the current user highlighted.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(AppStore.self) private var store
    @State private var appeared = false

    var body: some View {
        let theme = store.theme
        let entries = store.leaderboard

        ScrollView {
            VStack(spacing: Space.x4) {
                VStack(spacing: Space.x1) {
                    Text("LEADERBOARD")
                        .font(.zScreenTitle)
                        .foregroundStyle(theme.accentDeep)
                    HStack(spacing: Space.x1) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 11, weight: .bold))
                        Text("7 days left")
                            .font(.zCaption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(ZenithPalette.warning)
                }
                .padding(.top, Space.x4)

                ZenithCard(padding: Space.x2) {
                    VStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRow(rank: index + 1, entry: entry)
                                .opacity(appeared ? 1 : 0)
                                .offset(x: appeared ? 0 : 40)
                                .animation(
                                    .spring(duration: 0.55, bounce: 0.25).delay(Double(index) * 0.05),
                                    value: appeared
                                )
                            if index < entries.count - 1 {
                                Divider().overlay(ZenithPalette.hairline)
                            }
                        }
                    }
                }
                .padding(.horizontal, Space.x5)

                GlassPanel {
                    HStack(spacing: Space.x3) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(theme.accentDeep)
                        Text("Earn XP by completing tasks. High-priority tasks feed your ecosystem the most.")
                            .font(.zSubhead)
                            .foregroundStyle(ZenithPalette.inkSecondary)
                    }
                }
                .padding(.horizontal, Space.x5)
            }
            .padding(.bottom, 140)
        }
        .background(theme.skyBottom.opacity(0.55))
        .scrollIndicators(.hidden)
        .onAppear { appeared = true }
    }
}

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry

    @Environment(\.biomeTheme) private var theme

    private var medal: (color: Color, glow: Color)? {
        switch rank {
        case 1: (Color(hex: 0xF6C445), Color(hex: 0xFFE9A8))
        case 2: (Color(hex: 0xB9C2CE), Color(hex: 0xE5EAF0))
        case 3: (Color(hex: 0xD08A4E), Color(hex: 0xF0C9A4))
        default: nil
        }
    }

    var body: some View {
        HStack(spacing: Space.x3) {
            // Rank medal or number
            ZStack {
                if let medal {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [medal.glow, medal.color],
                                center: .topLeading,
                                startRadius: 2,
                                endRadius: 24
                            )
                        )
                        .frame(width: 30, height: 30)
                    Text("\(rank)")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(ZenithPalette.inkTertiary)
                }
            }
            .frame(width: 32)

            // Avatar
            Text(entry.avatar)
                .font(.system(size: 20))
                .frame(width: 42, height: 42)
                .background(
                    entry.isUser ? theme.accentSoft : ZenithPalette.surfaceMuted,
                    in: Circle()
                )
                .overlay(
                    Circle().strokeBorder(
                        entry.isUser ? theme.accent : .clear,
                        lineWidth: 2
                    )
                )

            Text(entry.name)
                .font(.zHeadline)
                .foregroundStyle(entry.isUser ? theme.accentDeep : ZenithPalette.ink)

            if entry.isUser {
                Text("YOU")
                    .font(.system(size: 8, weight: .heavy))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(theme.accent, in: Capsule())
            }

            Spacer()

            Text("\(entry.xp) XP")
                .font(.zHeadline)
                .foregroundStyle(ZenithPalette.inkSecondary)
                .monospacedDigit()
        }
        .padding(.horizontal, Space.x3)
        .padding(.vertical, Space.x3)
        .background(
            entry.isUser ? theme.accentSoft.opacity(0.35) : .clear,
            in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rank \(rank): \(entry.name), \(entry.xp) experience points")
    }
}
