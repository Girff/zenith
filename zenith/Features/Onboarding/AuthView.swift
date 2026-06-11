//
//  AuthView.swift
//  zenith
//
//  Sign Up / Log In — email plus Apple & Google, per the wireframe.
//  Auth is mocked; any non-empty input proceeds.
//

import SwiftUI

struct AuthView: View {
    let isSignUp: Bool
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var appeared = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var canSubmit: Bool {
        email.contains("@") && (isSignUp || password.count >= 4)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ZenithPalette.brand, Color(hex: 0xE3744F)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: Space.x10)

                // Logo mark
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white)
                        .frame(width: 84, height: 84)
                        .shadow(color: .black.opacity(0.15), radius: 18, y: 10)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(ZenithPalette.brand)
                }
                .padding(.bottom, Space.x4)

                Text(isSignUp ? "Create your world" : "Welcome back")
                    .font(.zScreenTitle)
                    .foregroundStyle(.white)
                Text(isSignUp ? "One account, endless biomes." : "Your biome kept growing without you.")
                    .font(.zSubhead)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, Space.x1)

                // Form card
                VStack(spacing: Space.x3) {
                    AuthField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $email,
                        isSecure: false
                    )
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .emailKeyboard()
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                    AuthField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    .focused($focusedField, equals: .password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .submitLabel(.go)
                    .onSubmit { if canSubmit { onComplete() } }

                    ZenithPrimaryButton(
                        title: isSignUp ? "Continue with Email" : "Log In",
                        icon: isSignUp ? "arrow.right" : "leaf.fill"
                    ) {
                        onComplete()
                    }
                    .opacity(canSubmit ? 1 : 0.45)
                    .disabled(!canSubmit)
                    .animation(.easeOut(duration: 0.2), value: canSubmit)

                    // OR divider
                    HStack(spacing: Space.x3) {
                        Rectangle().fill(ZenithPalette.hairline).frame(height: 1)
                        Text("OR")
                            .font(.zMicro)
                            .tracking(1.5)
                            .foregroundStyle(ZenithPalette.inkTertiary)
                        Rectangle().fill(ZenithPalette.hairline).frame(height: 1)
                    }
                    .padding(.vertical, Space.x1)

                    HStack(spacing: Space.x3) {
                        SocialButton(provider: .apple) { onComplete() }
                        SocialButton(provider: .google) { onComplete() }
                    }
                }
                .padding(Space.x5)
                .background(
                    Color(hex: 0xFFF8F3),
                    in: RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
                )
                .floatShadow()
                .padding(.horizontal, Space.x5)
                .padding(.top, Space.x6)
                .offset(y: appeared ? 0 : 60)
                .opacity(appeared ? 1 : 0)

                Spacer()

                // Swipe-to-return affordance from the wireframe.
                Button(action: onBack) {
                    VStack(spacing: Space.x1) {
                        Image(systemName: "chevron.compact.down")
                            .font(.system(size: 30, weight: .semibold))
                        Text("swipe to return")
                            .font(.zCaption)
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.bottom, Space.x4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.pressable)
                .accessibilityLabel("Go back")
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40).onEnded { value in
                if value.translation.height > 80 { onBack() }
            }
        )
        .onAppear {
            withAnimation(.spring(duration: 0.7, bounce: 0.3).delay(0.1)) { appeared = true }
            focusedField = .email
        }
    }
}

private struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Space.x3) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isFocused ? ZenithPalette.brand : ZenithPalette.inkTertiary)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.zBody)
            .focused($isFocused)
            .noAutocapitalization()
            .autocorrectionDisabled()
        }
        .padding(.horizontal, Space.x4)
        .frame(height: 50)
        .background(.white, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .strokeBorder(
                    isFocused ? ZenithPalette.brand : ZenithPalette.hairline,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.easeOut(duration: 0.18), value: isFocused)
    }
}
