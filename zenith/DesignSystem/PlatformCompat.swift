//
//  PlatformCompat.swift
//  zenith
//
//  The target builds for iOS, visionOS and macOS. These shims apply
//  iOS/visionOS-only modifiers where they exist and no-op on macOS.
//

import SwiftUI

extension View {
    /// `navigationBarTitleDisplayMode(.inline)` where available.
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if os(macOS)
        self
        #else
        navigationBarTitleDisplayMode(.inline)
        #endif
    }

    /// Dark, opaque navigation bar chrome where available.
    @ViewBuilder
    func darkNavigationBarChrome(_ background: Color) -> some View {
        #if os(macOS)
        self
        #else
        self
            .toolbarBackground(background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
    }

    /// Email-address software keyboard where available.
    @ViewBuilder
    func emailKeyboard() -> some View {
        #if os(macOS)
        self
        #else
        keyboardType(.emailAddress)
        #endif
    }

    /// URL software keyboard where available.
    @ViewBuilder
    func urlKeyboard() -> some View {
        #if os(macOS)
        self
        #else
        keyboardType(.URL)
        #endif
    }

    /// `textInputAutocapitalization(.never)` where available.
    @ViewBuilder
    func noAutocapitalization() -> some View {
        #if os(macOS)
        self
        #else
        textInputAutocapitalization(.never)
        #endif
    }

    /// `presentationCornerRadius` where available.
    @ViewBuilder
    func sheetCornerRadius(_ radius: CGFloat) -> some View {
        #if os(macOS)
        self
        #else
        presentationCornerRadius(radius)
        #endif
    }
}
