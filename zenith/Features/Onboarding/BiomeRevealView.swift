//
//  BiomeRevealView.swift
//  zenith
//
//  Wireframe "Splash Screen 2": WELCOME TO… THE [BIOME].
//  The user picks a starting biome and the whole palette shifts live.
//

import SwiftUI

struct BiomeRevealView: View {
    let onEnter: () -> Void

    @Environment(AppStore.self) private var store
    @State private var appeared = false

    var body: some View {
        let theme = store.biome.theme

        ZStack {
            theme.skyGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: Space.x10)

                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("WELCOME TO…")
                        .font(.zSectionTitle)
                        .tracking(3)
                        .foregroundStyle(theme.accentDeep.opacity(0.75))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    Text(store.biome.displayName.uppercased())
                        .font(.zDisplay)
                        .foregroundStyle(theme.accentDeep)
                        .contentTransition(.numericText())
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 24)

                    Text(store.biome.tagline)
                        .font(.zBody)
                        .foregroundStyle(theme.ink.opacity(0.7))
                        .opacity(appeared ? 1 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Space.x6)

                // Live biome preview
                EcosystemView(biome: store.biome, vitality: 0.85)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.hero, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
                            .strokeBorder(.white.opacity(0.5), lineWidth: 1.5)
                    )
                    .cardShadow()
                    .padding(.horizontal, Space.x5)
                    .padding(.top, Space.x6)
                    .scaleEffect(appeared ? 1 : 0.92)
                    .opacity(appeared ? 1 : 0)

                // Biome picker
                VStack(alignment: .leading, spacing: Space.x3) {
                    OverlineText(text: "Choose your starting biome", color: theme.ink.opacity(0.55))
                        .padding(.horizontal, Space.x6)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Space.x3) {
                            ForEach(Biome.allCases) { biome in
                                BiomeChoiceCard(
                                    biome: biome,
                                    isSelected: store.biome == biome
                                ) {
                                    withAnimation(.spring(duration: 0.6, bounce: 0.25)) {
                                        store.biome = biome
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Space.x6)
                    }
                }
                .padding(.top, Space.x6)

                Spacer()

                ZenithPrimaryButton(
                    title: "Enter the \(store.biome.shortName)",
                    icon: "arrow.right",
                    fill: theme.accentDeep
                ) {
                    onEnter()
                }
                .padding(.horizontal, Space.x6)
                .padding(.bottom, Space.x6)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.25).delay(0.15)) { appeared = true }
        }
    }
}

private struct BiomeChoiceCard: View {
    let biome: Biome
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let theme = biome.theme

        Button(action: action) {
            VStack(alignment: .leading, spacing: Space.x2) {
                HStack {
                    Image(systemName: biome.emblem)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(theme.accentDeep)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.accentDeep)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                Spacer()
                Text(biome.creatures.joined())
                    .font(.system(size: 15))
                Text(biome.shortName)
                    .font(.zHeadline)
                    .foregroundStyle(theme.ink)
            }
            .padding(Space.x3)
            .frame(width: 124, height: 110, alignment: .leading)
            .background(
                LinearGradient(colors: [theme.skyTop, theme.skyBottom], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(
                        isSelected ? theme.accentDeep : .white.opacity(0.6),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.04 : 1)
        }
        .buttonStyle(.pressable)
        .animation(.spring(duration: 0.4, bounce: 0.4), value: isSelected)
        .accessibilityLabel("\(biome.displayName)\(isSelected ? ", selected" : "")")
    }
}
