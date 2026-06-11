//
//  Typography.swift
//  zenith
//
//  Type scale. Productivity surfaces use the default SF design for
//  Things-3-style crispness; gamified numerals and biome headers use
//  the rounded design for warmth.
//

import SwiftUI

extension Font {
    /// Hero numerals (vitality %, pomodoro countdown, GPA).
    static let zHero = Font.system(size: 56, weight: .heavy, design: .rounded)
    /// Biome reveal / onboarding display.
    static let zDisplay = Font.system(size: 40, weight: .heavy, design: .rounded)
    /// Screen titles ("THE VERDANT FOREST", "TASKS OVERVIEW").
    static let zScreenTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    /// Card section titles ("TODAY'S TASKS", "HIGH PRIORITY").
    static let zSectionTitle = Font.system(size: 19, weight: .bold, design: .rounded)
    /// Row titles and primary buttons.
    static let zHeadline = Font.system(size: 16, weight: .semibold)
    /// Standard body copy.
    static let zBody = Font.system(size: 15, weight: .regular)
    /// Secondary row copy.
    static let zSubhead = Font.system(size: 13, weight: .regular)
    /// Metadata, timestamps, chips.
    static let zCaption = Font.system(size: 12, weight: .medium)
    /// Overline labels and tab bar captions.
    static let zMicro = Font.system(size: 10, weight: .semibold)
}

/// Uppercase tracked overline, used for section eyebrows.
struct OverlineText: View {
    let text: String
    var color: Color = ZenithPalette.inkTertiary

    var body: some View {
        Text(text.uppercased())
            .font(.zMicro)
            .tracking(1.6)
            .foregroundStyle(color)
    }
}
