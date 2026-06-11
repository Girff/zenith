//
//  WelcomeView.swift
//  zenith
//
//  Wireframe: huge inspirational text + a field of creature bubbles.
//

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var appeared = false

    fileprivate struct Bubble: Identifiable {
        let id = Int.random(in: 0..<Int.max)
        let emoji: String
        let tint: Color
        let size: CGFloat
        let position: CGPoint   // unit space
        let drift: CGFloat
        let delay: Double
    }

    private let bubbles: [Bubble] = [
        .init(emoji: "🦊", tint: Color(hex: 0xFFE0D2), size: 84, position: .init(x: 0.16, y: 0.16), drift: 10, delay: 0.0),
        .init(emoji: "🐬", tint: Color(hex: 0xD2ECF6), size: 64, position: .init(x: 0.78, y: 0.10), drift: 14, delay: 0.4),
        .init(emoji: "🦉", tint: Color(hex: 0xCFEBDB), size: 72, position: .init(x: 0.52, y: 0.22), drift: 8, delay: 0.8),
        .init(emoji: "🦋", tint: Color(hex: 0xE4DEF8), size: 56, position: .init(x: 0.88, y: 0.30), drift: 12, delay: 0.2),
        .init(emoji: "🐢", tint: Color(hex: 0xD2ECF6), size: 60, position: .init(x: 0.10, y: 0.38), drift: 9, delay: 0.6),
        .init(emoji: "🐝", tint: Color(hex: 0xFFF1CC), size: 48, position: .init(x: 0.30, y: 0.30), drift: 16, delay: 1.0),
        .init(emoji: "🦎", tint: Color(hex: 0xFFE0D2), size: 52, position: .init(x: 0.66, y: 0.38), drift: 11, delay: 0.3),
        .init(emoji: "🐰", tint: Color(hex: 0xE4DEF8), size: 66, position: .init(x: 0.84, y: 0.52), drift: 13, delay: 0.7),
        .init(emoji: "🦌", tint: Color(hex: 0xCFEBDB), size: 58, position: .init(x: 0.14, y: 0.55), drift: 10, delay: 0.5),
        .init(emoji: "🐙", tint: Color(hex: 0xFFE5EC), size: 50, position: .init(x: 0.45, y: 0.47), drift: 15, delay: 0.9)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: 0xFFF8F3).ignoresSafeArea()

                // Drifting creature bubbles — every animal lives in a biome you can grow.
                ForEach(bubbles) { bubble in
                    FloatingBubble(bubble: bubble)
                        .position(
                            x: bubble.position.x * geo.size.width,
                            y: bubble.position.y * geo.size.height
                        )
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.4)
                        .animation(
                            .spring(duration: 0.8, bounce: 0.5).delay(bubble.delay * 0.25),
                            value: appeared
                        )
                }

                VStack(alignment: .leading, spacing: Space.x5) {
                    Spacer()

                    Text("Do the work.\nGrow a world.")
                        .font(.zDisplay)
                        .foregroundStyle(ZenithPalette.brand)
                        .lineSpacing(2)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 28)
                        .animation(.spring(duration: 0.9, bounce: 0.25).delay(0.3), value: appeared)

                    Text("Every task you complete breathes life into your own little ecosystem — watch it flourish as you focus.")
                        .font(.zBody)
                        .foregroundStyle(ZenithPalette.inkSecondary)
                        .lineSpacing(3)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(duration: 0.9, bounce: 0.25).delay(0.45), value: appeared)

                    ZenithPrimaryButton(title: "Get Growing", icon: "arrow.right", fill: ZenithPalette.brand) {
                        onContinue()
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.9, bounce: 0.25).delay(0.6), value: appeared)
                }
                .padding(.horizontal, Space.x6)
                .padding(.bottom, Space.x8)
            }
        }
        .onAppear { appeared = true }
    }
}

private struct FloatingBubble: View {
    let bubble: WelcomeView.Bubble
    @State private var floating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(bubble.tint)
            Circle()
                .strokeBorder(.white.opacity(0.8), lineWidth: 2)
            Text(bubble.emoji)
                .font(.system(size: bubble.size * 0.46))
        }
        .frame(width: bubble.size, height: bubble.size)
        .shadow(color: .black.opacity(0.07), radius: 10, y: 5)
        .offset(y: floating ? -bubble.drift : bubble.drift)
        .animation(
            .easeInOut(duration: Double.random(in: 2.6...3.8))
                .repeatForever(autoreverses: true)
                .delay(bubble.delay),
            value: floating
        )
        .onAppear { floating = true }
        .accessibilityHidden(true)
    }
}
