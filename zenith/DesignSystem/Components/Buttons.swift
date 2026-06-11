//
//  Buttons.swift
//  zenith
//

import SwiftUI

// MARK: - Primary CTA

struct ZenithPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var fill: Color = ZenithPalette.ink
    var foreground: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.x2) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.zHeadline)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(fill, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        }
        .buttonStyle(.pressable)
    }
}

// MARK: - Social sign-in

struct SocialButton: View {
    enum Provider {
        case apple, google

        var icon: String {
            switch self {
            case .apple: "apple.logo"
            case .google: "g.circle.fill"
            }
        }

        var label: String {
            switch self {
            case .apple: "Apple"
            case .google: "Google"
            }
        }
    }

    let provider: Provider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.x2) {
                Image(systemName: provider.icon)
                    .font(.system(size: 17, weight: .medium))
                Text(provider.label)
                    .font(.zHeadline)
            }
            .foregroundStyle(ZenithPalette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(.white, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .strokeBorder(ZenithPalette.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("Continue with \(provider.label)")
    }
}

// MARK: - Circular icon button

struct CircleIconButton: View {
    let icon: String
    var size: CGFloat = 40
    var fill: Color = ZenithPalette.surfaceMuted
    var foreground: Color = ZenithPalette.ink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(fill, in: Circle())
        }
        .buttonStyle(.pressable(scale: 0.9))
    }
}

// MARK: - Floating action button

struct ZenithFAB: View {
    let icon: String
    var rotated: Bool = false
    let action: () -> Void

    @Environment(\.biomeTheme) private var theme

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(rotated ? 45 : 0))
                .frame(width: 60, height: 60)
                .background(theme.accentGradient, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.pressable(scale: 0.88))
        .floatShadow()
        .animation(.spring(duration: 0.35, bounce: 0.5), value: rotated)
    }
}

// MARK: - Tag chip

struct ChipButton: View {
    let label: String
    var icon: String? = nil
    var selected: Bool = false
    let action: () -> Void

    @Environment(\.biomeTheme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.x1) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(label)
                    .font(.zCaption)
            }
            .foregroundStyle(selected ? .white : ZenithPalette.inkSecondary)
            .padding(.horizontal, Space.x3)
            .padding(.vertical, Space.x2)
            .background(
                selected ? theme.accent : ZenithPalette.surfaceMuted,
                in: Capsule()
            )
        }
        .buttonStyle(.pressable(scale: 0.93))
    }
}
