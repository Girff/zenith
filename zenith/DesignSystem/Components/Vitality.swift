//
//  Vitality.swift
//  zenith
//
//  Ecosystem Vitality indicators — Apple-Fitness-style rings and bars
//  with springy, hardware-accelerated progress animation.
//

import SwiftUI

// MARK: - Vitality ring

struct VitalityRing: View {
    /// 0...1
    let progress: Double
    var size: CGFloat = 96
    var lineWidth: CGFloat = 11
    var showsLabel: Bool = true

    @Environment(\.biomeTheme) private var theme

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.accent.opacity(0.14), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(
                    theme.vitalityGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.9, bounce: 0.25), value: progress)

            if showsLabel {
                VStack(spacing: 0) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: size * 0.27, weight: .heavy, design: .rounded))
                        .foregroundStyle(theme.accentDeep)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.6), value: progress)
                    Text("VITALITY")
                        .font(.system(size: size * 0.085, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(ZenithPalette.inkTertiary)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ecosystem vitality")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - Vitality bar

struct VitalityBar: View {
    let progress: Double
    var height: CGFloat = 10

    @Environment(\.biomeTheme) private var theme

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.accent.opacity(0.14))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [theme.accent, theme.sun],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(height, geo.size.width * progress))
                    .animation(.spring(duration: 0.8, bounce: 0.3), value: progress)
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - Status chip

struct VitalityStatusChip: View {
    let label: String
    let symbol: String

    @Environment(\.biomeTheme) private var theme

    var body: some View {
        HStack(spacing: Space.x1) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .bold))
            Text(label)
                .font(.zCaption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(theme.accentDeep)
        .padding(.horizontal, Space.x3)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.4), lineWidth: 1))
    }
}
