//
//  GradesSuiteView.swift
//  zenith
//
//  Container for the academic suite (Grades · GPA · Transcript) with the
//  wireframe's floating radial MENU switcher. Dark, data-dense styling
//  per the reference shots.
//

import SwiftUI

/// Dark palette reserved for the academic power-tools.
enum GradesPalette {
    static let bg = Color(hex: 0x111419)
    static let card = Color(hex: 0x1C2129)
    static let cardElevated = Color(hex: 0x252B36)
    static let accent = Color(hex: 0x4F7DF9)
    static let accentSoft = Color(hex: 0x4F7DF9).opacity(0.18)
    static let positive = Color(hex: 0x35C76E)
    static let text = Color(hex: 0xF2F4F8)
    static let textSecondary = Color(hex: 0x8B93A3)
}

enum GradesSection: String, CaseIterable {
    case grades, gpa, transcript

    var label: String {
        switch self {
        case .grades: "GRADES"
        case .gpa: "GPA"
        case .transcript: "TRANSCRIPT"
        }
    }

    var icon: String {
        switch self {
        case .grades: "list.number"
        case .gpa: "chart.bar.fill"
        case .transcript: "doc.plaintext.fill"
        }
    }
}

struct GradesSuiteView: View {
    @State private var section: GradesSection = .grades
    @State private var menuOpen = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GradesPalette.bg.ignoresSafeArea()

            Group {
                switch section {
                case .grades: GradesListView()
                case .gpa: GPAView()
                case .transcript: TranscriptView()
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98)))

            if menuOpen {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.4, bounce: 0.3)) { menuOpen = false }
                    }
            }

            radialMenu
                .padding(.trailing, Space.x5)
                .padding(.bottom, Space.x6)
        }
        .animation(.spring(duration: 0.45, bounce: 0.2), value: section)
        .navigationTitle(section.label.capitalized)
        .inlineNavigationTitle()
        .darkNavigationBarChrome(GradesPalette.bg)
        .preferredColorScheme(.dark)
        .sensoryFeedback(.impact(weight: .medium), trigger: menuOpen)
    }

    // Radial MENU — GPA / GRADES / TRANSCRIPT satellites, per wireframe.
    private var radialMenu: some View {
        ZStack(alignment: .bottomTrailing) {
            ForEach(Array(GradesSection.allCases.enumerated()), id: \.element) { index, candidate in
                let angle = Angle.degrees(90 + Double(index) * 45)
                let radius: CGFloat = 100

                Button {
                    withAnimation(.spring(duration: 0.45, bounce: 0.35)) {
                        section = candidate
                        menuOpen = false
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: candidate.icon)
                            .font(.system(size: 14, weight: .bold))
                        Text(candidate.label)
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundStyle(section == candidate ? GradesPalette.bg : GradesPalette.text)
                    .frame(width: 58, height: 58)
                    .background(
                        section == candidate ? GradesPalette.text : GradesPalette.cardElevated,
                        in: Circle()
                    )
                    .overlay(Circle().strokeBorder(GradesPalette.accent.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(.pressable(scale: 0.85))
                .floatShadow()
                .offset(
                    x: menuOpen ? -cos(angle.radians) * radius : 0,
                    y: menuOpen ? -sin(angle.radians) * radius : 0
                )
                .scaleEffect(menuOpen ? 1 : 0.1)
                .opacity(menuOpen ? 1 : 0)
                .animation(.spring(duration: 0.45, bounce: 0.45).delay(0.04 * Double(index)), value: menuOpen)
                .accessibilityLabel("Show \(candidate.label.lowercased())")
            }

            Button {
                withAnimation(.spring(duration: 0.45, bounce: 0.4)) { menuOpen.toggle() }
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: menuOpen ? "xmark" : "circle.grid.3x3.fill")
                        .font(.system(size: 18, weight: .bold))
                        .contentTransition(.symbolEffect(.replace))
                    Text("MENU")
                        .font(.system(size: 9, weight: .heavy))
                }
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(GradesPalette.accent, in: Circle())
            }
            .buttonStyle(.pressable(scale: 0.88))
            .floatShadow()
            .accessibilityLabel(menuOpen ? "Close menu" : "Open section menu")
        }
    }
}

// MARK: - Shared dark card

struct GradesCard<Content: View>: View {
    var padding: CGFloat = Space.x4
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GradesPalette.card, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}

// MARK: - Grade pill

struct GradePill: View {
    let value: String

    var body: some View {
        Text(value)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(GradesPalette.accent)
            .monospacedDigit()
            .padding(.horizontal, Space.x3)
            .padding(.vertical, 6)
            .background(GradesPalette.accentSoft, in: Capsule())
            .overlay(Capsule().strokeBorder(GradesPalette.accent.opacity(0.45), lineWidth: 1))
    }
}
