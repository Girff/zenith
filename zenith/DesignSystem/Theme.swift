//
//  Theme.swift
//  zenith
//
//  Biome-driven design tokens. Every screen reads its palette from the
//  active biome so the whole app shifts hue when the ecosystem changes.
//

import SwiftUI

// MARK: - Hex color support

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

// MARK: - Biomes

enum Biome: String, CaseIterable, Identifiable, Codable {
    case verdantForest
    case emberDesert
    case tidalCove
    case alpineMeadow

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .verdantForest: "The Verdant Forest"
        case .emberDesert:   "The Ember Desert"
        case .tidalCove:     "The Tidal Cove"
        case .alpineMeadow:  "The Alpine Meadow"
        }
    }

    var shortName: String {
        switch self {
        case .verdantForest: "Forest"
        case .emberDesert:   "Desert"
        case .tidalCove:     "Cove"
        case .alpineMeadow:  "Meadow"
        }
    }

    var tagline: String {
        switch self {
        case .verdantForest: "Every task you finish helps the canopy grow."
        case .emberDesert:   "Bloom where nothing else dares to."
        case .tidalCove:     "Steady tides carve the deepest coves."
        case .alpineMeadow:  "Small steps, wild flowers."
        }
    }

    var emblem: String {
        switch self {
        case .verdantForest: "leaf.fill"
        case .emberDesert:   "sun.max.fill"
        case .tidalCove:     "water.waves"
        case .alpineMeadow:  "mountain.2.fill"
        }
    }

    var creatures: [String] {
        switch self {
        case .verdantForest: ["🦊", "🦉", "🐿️", "🦌"]
        case .emberDesert:   ["🦂", "🦎", "🐫", "🦅"]
        case .tidalCove:     ["🐬", "🦀", "🐙", "🐢"]
        case .alpineMeadow:  ["🐐", "🦋", "🐰", "🐝"]
        }
    }

    var theme: BiomeTheme {
        switch self {
        case .verdantForest:
            BiomeTheme(
                accent: Color(hex: 0x3E9B6E),
                accentDeep: Color(hex: 0x1F5C44),
                accentSoft: Color(hex: 0xCFEBDB),
                skyTop: Color(hex: 0xBFE6CF),
                skyBottom: Color(hex: 0xEFF8EE),
                horizon: Color(hex: 0x9ED4AC),
                ground: Color(hex: 0x5FB57F),
                groundDeep: Color(hex: 0x2E7D54),
                sun: Color(hex: 0xFFD37A),
                ink: Color(hex: 0x16382B)
            )
        case .emberDesert:
            BiomeTheme(
                accent: Color(hex: 0xF68C70),
                accentDeep: Color(hex: 0x9C4A30),
                accentSoft: Color(hex: 0xFFE0D2),
                skyTop: Color(hex: 0xFFD9B8),
                skyBottom: Color(hex: 0xFFF4E8),
                horizon: Color(hex: 0xF6BC8E),
                ground: Color(hex: 0xE8A06B),
                groundDeep: Color(hex: 0xB76A3E),
                sun: Color(hex: 0xFF9F5C),
                ink: Color(hex: 0x55291B)
            )
        case .tidalCove:
            BiomeTheme(
                accent: Color(hex: 0x39A0CA),
                accentDeep: Color(hex: 0x144D66),
                accentSoft: Color(hex: 0xD2ECF6),
                skyTop: Color(hex: 0xBCE3F2),
                skyBottom: Color(hex: 0xEFF9FC),
                horizon: Color(hex: 0x8FD0E2),
                ground: Color(hex: 0x4FB3CF),
                groundDeep: Color(hex: 0x21789B),
                sun: Color(hex: 0xFFE08A),
                ink: Color(hex: 0x0E3243)
            )
        case .alpineMeadow:
            BiomeTheme(
                accent: Color(hex: 0x8B7BD8),
                accentDeep: Color(hex: 0x4A3E78),
                accentSoft: Color(hex: 0xE4DEF8),
                skyTop: Color(hex: 0xD9D2F4),
                skyBottom: Color(hex: 0xF6F3FC),
                horizon: Color(hex: 0xB7ABE8),
                ground: Color(hex: 0x8FC98B),
                groundDeep: Color(hex: 0x55905E),
                sun: Color(hex: 0xFFD9A0),
                ink: Color(hex: 0x32294F)
            )
        }
    }
}

// MARK: - Theme tokens

struct BiomeTheme {
    let accent: Color
    let accentDeep: Color
    let accentSoft: Color
    let skyTop: Color
    let skyBottom: Color
    let horizon: Color
    let ground: Color
    let groundDeep: Color
    let sun: Color
    let ink: Color

    var skyGradient: LinearGradient {
        LinearGradient(colors: [skyTop, skyBottom], startPoint: .top, endPoint: .bottom)
    }

    var accentGradient: LinearGradient {
        LinearGradient(colors: [accent, accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var vitalityGradient: AngularGradient {
        AngularGradient(
            colors: [accent, sun, accent],
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }
}

// MARK: - Neutral + semantic palette (biome independent)

enum ZenithPalette {
    /// Coral brand color lifted straight from the wireframe splash screens.
    static let brand = Color(hex: 0xF68C70)
    static let brandSoft = Color(hex: 0xFFC1AA)
    static let brandDeep = Color(hex: 0xC75C42)

    static let ink = Color(hex: 0x1B2433)
    static let inkSecondary = Color(hex: 0x5B6677)
    static let inkTertiary = Color(hex: 0x97A0AE)

    static let surface = Color.white
    static let surfaceMuted = Color(hex: 0xF4F5F7)
    static let hairline = Color(hex: 0xE6E8EC)

    static let success = Color(hex: 0x3BA864)
    static let warning = Color(hex: 0xF2A93B)
    static let danger = Color(hex: 0xE25C5C)

    static let priorityHigh = Color(hex: 0xE25C5C)
    static let priorityMedium = Color(hex: 0xF2A93B)
    static let priorityLow = Color(hex: 0x39A0CA)
}

// MARK: - Environment plumbing

private struct BiomeThemeKey: EnvironmentKey {
    static let defaultValue = Biome.verdantForest.theme
}

extension EnvironmentValues {
    var biomeTheme: BiomeTheme {
        get { self[BiomeThemeKey.self] }
        set { self[BiomeThemeKey.self] = newValue }
    }
}
