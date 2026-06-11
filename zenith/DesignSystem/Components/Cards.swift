//
//  Cards.swift
//  zenith
//

import SwiftUI

// MARK: - Standard surface card

struct ZenithCard<Content: View>: View {
    var padding: CGFloat = Space.x4
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ZenithPalette.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .cardShadow()
    }
}

// MARK: - Glass panel (overlays on biome scenery)

struct GlassPanel<Content: View>: View {
    var padding: CGFloat = Space.x4
    var cornerRadius: CGFloat = Radius.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
            )
    }
}

// MARK: - Section header with optional accessory

struct SectionHeader: View {
    let title: String
    var tint: Color = ZenithPalette.ink
    var accessory: String? = nil
    var accessoryAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.zSectionTitle)
                .foregroundStyle(tint)
            Spacer()
            if let accessory, let accessoryAction {
                Button(action: accessoryAction) {
                    Text(accessory)
                        .font(.zCaption)
                        .foregroundStyle(ZenithPalette.inkSecondary)
                }
                .buttonStyle(.pressable)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}
