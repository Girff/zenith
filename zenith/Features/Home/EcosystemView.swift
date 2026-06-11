//
//  EcosystemView.swift
//  zenith
//
//  The living biome scene. Layered sky, sun, hills, flora and creatures,
//  all driven by vitality: a healthier ecosystem gets a higher sun,
//  denser flora and more wildlife.
//

import SwiftUI

struct EcosystemView: View {
    let biome: Biome
    /// 0...1
    let vitality: Double

    var body: some View {
        let theme = biome.theme

        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                theme.skyGradient

                // Sun — rises with vitality.
                SunView(theme: theme, vitality: vitality)
                    .position(x: w * 0.76, y: h * (0.46 - 0.28 * vitality))

                // Drifting clouds.
                CloudView(width: 90, opacity: 0.85, duration: 34)
                    .position(x: w * 0.2, y: h * 0.16)
                CloudView(width: 60, opacity: 0.6, duration: 46)
                    .position(x: w * 0.55, y: h * 0.27)

                // Layered hills.
                HillShape(crest: 0.55, phase: 0.2)
                    .fill(theme.horizon.opacity(0.75))
                    .frame(height: h * 0.5)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                HillShape(crest: 0.7, phase: 0.65)
                    .fill(theme.ground)
                    .frame(height: h * 0.38)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                HillShape(crest: 0.85, phase: 0.4)
                    .fill(theme.groundDeep)
                    .frame(height: h * 0.22)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // Flora — density scales with vitality.
                FloraLayer(biome: biome, vitality: vitality, size: geo.size)

                // Creatures bobbing along the ground.
                CreatureLayer(biome: biome, vitality: vitality, size: geo.size)

                // Sparkles when flourishing.
                if vitality > 0.7 {
                    SparkleLayer(theme: theme, size: geo.size)
                        .transition(.opacity)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(biome.displayName), vitality \(Int(vitality * 100)) percent")
    }
}

// MARK: - Sun

private struct SunView: View {
    let theme: BiomeTheme
    let vitality: Double
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.sun.opacity(0.35))
                .frame(width: 96, height: 96)
                .blur(radius: 18)
                .scaleEffect(pulsing ? 1.15 : 0.95)
            Circle()
                .fill(theme.sun)
                .frame(width: 56, height: 56)
        }
        .opacity(0.55 + vitality * 0.45)
        .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: pulsing)
        .onAppear { pulsing = true }
    }
}

// MARK: - Clouds

private struct CloudView: View {
    let width: CGFloat
    let opacity: Double
    let duration: Double
    @State private var drift = false

    var body: some View {
        Capsule()
            .fill(.white.opacity(opacity))
            .frame(width: width, height: width * 0.34)
            .overlay(
                Circle()
                    .fill(.white.opacity(opacity))
                    .frame(width: width * 0.45)
                    .offset(x: -width * 0.15, y: -width * 0.14)
            )
            .offset(x: drift ? 26 : -26)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: drift)
            .onAppear { drift = true }
    }
}

// MARK: - Hills

private struct HillShape: Shape {
    /// 0...1, where the crest peaks relative to height.
    let crest: CGFloat
    let phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.maxY))
        p.addLine(to: CGPoint(x: 0, y: rect.maxY - rect.height * (0.5 + 0.3 * sin(phase * .pi * 2))))
        p.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * crest),
            control: CGPoint(x: rect.width * 0.25, y: rect.maxY - rect.height * (crest + 0.25))
        )
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * (0.4 + 0.3 * cos(phase * .pi))),
            control: CGPoint(x: rect.width * 0.75, y: rect.maxY - rect.height * (crest - 0.3))
        )
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Flora

private struct FloraLayer: View {
    let biome: Biome
    let vitality: Double
    let size: CGSize

    var body: some View {
        let count = max(2, Int(vitality * 7))
        ForEach(0..<count, id: \.self) { i in
            let t = CGFloat(i) / CGFloat(max(1, count - 1))
            let x = size.width * (0.08 + t * 0.84)
            let y = size.height * (0.78 + 0.1 * sin(CGFloat(i) * 1.7))
            let scale = 0.7 + 0.5 * abs(sin(CGFloat(i) * 2.3))

            FloraSprite(biome: biome, seed: i)
                .scaleEffect(scale)
                .position(x: x, y: y)
        }
        .animation(.spring(duration: 0.8, bounce: 0.4), value: count)
    }
}

private struct FloraSprite: View {
    let biome: Biome
    let seed: Int
    @State private var sway = false

    /// Darker than every hill layer so sprites read as silhouettes
    /// instead of vanishing into same-colored ground.
    private var silhouette: Color {
        switch biome {
        case .verdantForest: biome.theme.accentDeep
        case .emberDesert: Color(hex: 0x55803C)      // saguaro green on sand
        case .tidalCove: biome.theme.accentDeep
        case .alpineMeadow: Color(hex: 0x3E6B46)
        }
    }

    var body: some View {
        Group {
            switch biome {
            case .verdantForest:
                VStack(spacing: -4) {
                    Circle()
                        .fill(silhouette)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .fill(.white.opacity(0.16))
                                .frame(width: 12, height: 12)
                                .offset(x: -5, y: -6)
                        )
                    Rectangle()
                        .fill(Color(hex: 0x53381F))
                        .frame(width: 5, height: 14)
                }
            case .emberDesert:
                ZStack {
                    Capsule()
                        .fill(silhouette)
                        .frame(width: 10, height: 34)
                    Capsule()
                        .fill(silhouette)
                        .frame(width: 8, height: 16)
                        .offset(x: -9, y: -4)
                    Capsule()
                        .fill(silhouette)
                        .frame(width: 8, height: 14)
                        .offset(x: 9, y: -2)
                }
            case .tidalCove:
                WaveBlade(color: silhouette)
            case .alpineMeadow:
                VStack(spacing: -2) {
                    Circle()
                        .fill([Color(hex: 0xE8A0C4), Color(hex: 0xF6D186), Color(hex: 0xFFFFFF)][seed % 3])
                        .frame(width: 12, height: 12)
                    Rectangle()
                        .fill(silhouette)
                        .frame(width: 3, height: 16)
                }
            }
        }
        .rotationEffect(.degrees(sway ? 4 : -4), anchor: .bottom)
        .animation(
            .easeInOut(duration: Double(2.2 + Double(seed % 3) * 0.5))
                .repeatForever(autoreverses: true),
            value: sway
        )
        .onAppear { sway = true }
    }
}

private struct WaveBlade: View {
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(color.opacity(0.9 - Double(i) * 0.2))
                    .frame(width: 5, height: CGFloat(26 - i * 6))
            }
        }
    }
}

// MARK: - Creatures

private struct CreatureLayer: View {
    let biome: Biome
    let vitality: Double
    let size: CGSize

    var body: some View {
        let visible = max(1, Int(vitality * Double(biome.creatures.count)))
        ForEach(Array(biome.creatures.prefix(visible).enumerated()), id: \.offset) { i, creature in
            BobbingEmoji(emoji: creature, delay: Double(i) * 0.6)
                .position(
                    x: size.width * (0.18 + CGFloat(i) * 0.22),
                    y: size.height * (0.86 + 0.05 * sin(CGFloat(i) * 2))
                )
        }
        .animation(.spring(duration: 0.7, bounce: 0.45), value: visible)
    }
}

private struct BobbingEmoji: View {
    let emoji: String
    let delay: Double
    @State private var bob = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 24))
            .offset(y: bob ? -5 : 2)
            .animation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(delay),
                value: bob
            )
            .onAppear { bob = true }
    }
}

// MARK: - Sparkles

private struct SparkleLayer: View {
    let theme: BiomeTheme
    let size: CGSize

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 20)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Canvas { ctx, canvasSize in
                for i in 0..<10 {
                    let fi = Double(i)
                    let x = canvasSize.width * (0.1 + 0.8 * ((sin(fi * 12.9898) + 1) / 2))
                    let baseY = canvasSize.height * (0.45 + 0.4 * ((cos(fi * 78.233) + 1) / 2))
                    let y = baseY + sin(t * 0.8 + fi) * 8
                    let alpha = (sin(t * 1.6 + fi * 2.1) + 1) / 2
                    let r = 1.6 + alpha * 1.4

                    ctx.fill(
                        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                        with: .color(theme.sun.opacity(0.25 + alpha * 0.6))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
