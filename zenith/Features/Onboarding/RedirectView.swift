//
//  RedirectView.swift
//  zenith
//
//  Wireframe "Redirect Screen": two giant tangent circles — dark for
//  new users, coral for returning ones.
//

import SwiftUI

struct RedirectView: View {
    let onGetStarted: () -> Void
    let onLogIn: () -> Void

    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let d = max(w, h) * 1.05

            ZStack {
                Color(hex: 0xFFF8F3).ignoresSafeArea()

                // New account — dark sphere anchored top-right.
                Button(action: onGetStarted) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0x3A3F4A).opacity(0.35))
                            .frame(width: d + 60, height: d + 60)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: 0x2A303C), Color(hex: 0x141821)],
                                    center: .topTrailing,
                                    startRadius: 40,
                                    endRadius: d
                                )
                            )
                            .frame(width: d, height: d)

                        // Label sits in the on-screen quadrant of the circle.
                        VStack(alignment: .trailing, spacing: Space.x2) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(ZenithPalette.brandSoft)
                            Text("Get\nStarted")
                                .font(.zScreenTitle)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.white)
                            Text("Plant your first biome")
                                .font(.zCaption)
                                .foregroundStyle(.white.opacity(0.65))
                        }
                        .offset(x: -d * 0.16, y: d * 0.22)
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.pressable(scale: 0.97))
                .position(x: w * 0.92, y: h * 0.06)
                .offset(y: appeared ? 0 : -h * 0.4)
                .accessibilityLabel("Get started, create an account")

                // Returning — coral sphere anchored bottom-left.
                Button(action: onLogIn) {
                    ZStack {
                        Circle()
                            .fill(ZenithPalette.brandSoft.opacity(0.55))
                            .frame(width: d + 60, height: d + 60)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: 0xFFA98B), ZenithPalette.brand],
                                    center: .bottomLeading,
                                    startRadius: 40,
                                    endRadius: d
                                )
                            )
                            .frame(width: d, height: d)

                        VStack(alignment: .leading, spacing: Space.x2) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                            Text("I Already\nHave an\nAccount")
                                .font(.zScreenTitle)
                                .foregroundStyle(.white)
                            Text("Your ecosystem missed you")
                                .font(.zCaption)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .offset(x: d * 0.16, y: -d * 0.2)
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.pressable(scale: 0.97))
                .position(x: w * 0.08, y: h * 0.94)
                .offset(y: appeared ? 0 : h * 0.4)
                .accessibilityLabel("Log in to an existing account")
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.3)) { appeared = true }
        }
    }
}
