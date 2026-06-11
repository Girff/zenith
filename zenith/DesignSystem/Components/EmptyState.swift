//
//  EmptyState.swift
//  zenith
//
//  Encouraging empty states — never a blank screen.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @Environment(\.biomeTheme) private var theme
    @State private var sway = false

    var body: some View {
        VStack(spacing: Space.x4) {
            ZStack {
                Circle()
                    .fill(theme.accentSoft)
                    .frame(width: 88, height: 88)
                Circle()
                    .fill(theme.accent.opacity(0.18))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(theme.accentDeep)
                    .rotationEffect(.degrees(sway ? 6 : -6))
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: sway)
            }
            .onAppear { sway = true }

            VStack(spacing: Space.x1) {
                Text(title)
                    .font(.zSectionTitle)
                    .foregroundStyle(ZenithPalette.ink)
                Text(message)
                    .font(.zSubhead)
                    .foregroundStyle(ZenithPalette.inkSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.zHeadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Space.x5)
                        .padding(.vertical, Space.x3)
                        .background(theme.accentGradient, in: Capsule())
                }
                .buttonStyle(.pressable)
            }
        }
        .padding(Space.x6)
        .frame(maxWidth: .infinity)
    }
}
