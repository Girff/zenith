//
//  Layout.swift
//  zenith
//
//  4pt spatial system, corner radii and elevation. All paddings and
//  radii in the app come from these tokens so surfaces stay on-grid.
//

import SwiftUI

enum Space {
    static let x1: CGFloat = 4
    static let x2: CGFloat = 8
    static let x3: CGFloat = 12
    static let x4: CGFloat = 16
    static let x5: CGFloat = 20
    static let x6: CGFloat = 24
    static let x8: CGFloat = 32
    static let x10: CGFloat = 40
    static let x12: CGFloat = 48
}

enum Radius {
    /// Inputs, chips, small controls (wireframe uses r=10).
    static let control: CGFloat = 12
    /// Cards (wireframe uses r=20).
    static let card: CGFloat = 20
    /// Hero panels, sheets.
    static let hero: CGFloat = 28
}

// MARK: - Elevation

extension View {
    /// Resting card elevation — soft ambient shadow, Things-3 style.
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    /// Floating elements (FAB, radial menus, overlays).
    func floatShadow() -> some View {
        shadow(color: .black.opacity(0.16), radius: 22, x: 0, y: 10)
    }
}

// MARK: - Press physics

/// Spring scale-down applied to every tappable surface.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(duration: 0.28, bounce: 0.45), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableStyle {
    static var pressable: PressableStyle { PressableStyle() }
    static func pressable(scale: CGFloat) -> PressableStyle { PressableStyle(scale: scale) }
}
