//
//  RootView.swift
//  zenith
//
//  Top-level flow router: splash → onboarding → biome reveal → main app.
//

import SwiftUI

enum AppFlow: Equatable {
    case splash
    case welcome
    case redirect
    case auth(signUp: Bool)
    case biomeReveal
    case main
}

struct RootView: View {
    @State private var store = AppStore()
    @State private var flow: AppFlow

    init() {
        // Launch-argument override for simulator debugging/screenshots:
        // `simctl launch <device> <bundle-id> -zenithFlow redirect|auth|signup|biomeReveal`
        switch UserDefaults.standard.string(forKey: "zenithFlow") {
        case "welcome": _flow = State(initialValue: .welcome)
        case "redirect": _flow = State(initialValue: .redirect)
        case "auth": _flow = State(initialValue: .auth(signUp: false))
        case "signup": _flow = State(initialValue: .auth(signUp: true))
        case "biomeReveal": _flow = State(initialValue: .biomeReveal)
        default: _flow = State(initialValue: .splash)
        }
    }

    var body: some View {
        ZStack {
            switch flow {
            case .splash:
                SplashView {
                    advance(to: store.hasOnboarded ? .main : .welcome)
                }
                .transition(.opacity)

            case .welcome:
                WelcomeView { advance(to: .redirect) }
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .redirect:
                RedirectView(
                    onGetStarted: { advance(to: .auth(signUp: true)) },
                    onLogIn: { advance(to: .auth(signUp: false)) }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            case .auth(let signUp):
                AuthView(
                    isSignUp: signUp,
                    onBack: { advance(to: .redirect) },
                    onComplete: { advance(to: .biomeReveal) }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))

            case .biomeReveal:
                BiomeRevealView {
                    store.hasOnboarded = true
                    advance(to: .main)
                }
                .transition(.opacity)

            case .main:
                MainView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }
        }
        .environment(store)
        .environment(\.biomeTheme, store.theme)
        .animation(.spring(duration: 0.6, bounce: 0.12), value: flow)
    }

    private func advance(to next: AppFlow) {
        withAnimation(.spring(duration: 0.6, bounce: 0.12)) {
            flow = next
        }
    }
}

// MARK: - Splash

struct SplashView: View {
    let onFinished: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ZenithPalette.brand, ZenithPalette.brandDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Space.x4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(.white)
                        .frame(width: 132, height: 132)
                        .shadow(color: .black.opacity(0.18), radius: 30, y: 16)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ZenithPalette.brand, ZenithPalette.brandDeep],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)

                Text("ZENITH")
                    .font(.zDisplay)
                    .tracking(10)
                    .foregroundStyle(.white)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                Text("Grow while you get things done")
                    .font(.zSubhead)
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.4)) { appeared = true }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            onFinished()
        }
    }
}
