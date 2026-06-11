//
//  AddOnsView.swift
//  zenith
//
//  Wireframe Add-Ons hub: an orbital cluster of circular launchers
//  around a central emblem.
//

import SwiftUI

enum AddOn: String, CaseIterable, Identifiable, Hashable {
    case pomodoro, appBlocking, grades, formulaSheets

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pomodoro: "Pomodoro"
        case .appBlocking: "Focus Shield"
        case .grades: "Grades"
        case .formulaSheets: "Formula Sheets"
        }
    }

    var caption: String {
        switch self {
        case .pomodoro: "Deep-work timer"
        case .appBlocking: "Block distractions"
        case .grades: "GPA · Transcript"
        case .formulaSheets: "Quick reference"
        }
    }

    var icon: String {
        switch self {
        case .pomodoro: "timer"
        case .appBlocking: "shield.lefthalf.filled"
        case .grades: "graduationcap.fill"
        case .formulaSheets: "doc.text.fill"
        }
    }

    /// Orbital placement around the central emblem (unit offsets).
    var orbit: CGPoint {
        switch self {
        case .pomodoro: CGPoint(x: -0.62, y: -0.52)
        case .appBlocking: CGPoint(x: 0.62, y: -0.52)
        case .grades: CGPoint(x: -0.62, y: 0.56)
        case .formulaSheets: CGPoint(x: 0.62, y: 0.56)
        }
    }
}

struct AddOnsView: View {
    @Environment(AppStore.self) private var store
    @State private var appeared = false
    @State private var path: [AddOn]

    init() {
        // Launch-argument override for simulator debugging/screenshots:
        // `simctl launch <device> <bundle-id> -zenithTab addOns -zenithAddOn grades`
        let initial = UserDefaults.standard.string(forKey: "zenithAddOn")
            .flatMap(AddOn.init(rawValue:))
        _path = State(initialValue: initial.map { [$0] } ?? [])
    }

    var body: some View {
        let theme = store.theme

        NavigationStack(path: $path) {
            ZStack {
                theme.skyGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: Space.x1) {
                        OverlineText(text: "Grow your toolkit", color: theme.accentDeep.opacity(0.7))
                        Text("ADD-ONS")
                            .font(.zScreenTitle)
                            .foregroundStyle(theme.accentDeep)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Space.x5)
                    .padding(.top, Space.x4)

                    Spacer()

                    orbitalCluster
                        .frame(maxWidth: .infinity)

                    Spacer()
                    Spacer().frame(height: 100)
                }
            }
            .navigationDestination(for: AddOn.self) { addOn in
                switch addOn {
                case .pomodoro: PomodoroView()
                case .appBlocking: AppBlockingView()
                case .grades: GradesSuiteView()
                case .formulaSheets: FormulaSheetsView()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.7, bounce: 0.4)) { appeared = true }
        }
    }

    private var orbitalCluster: some View {
        let theme = store.theme
        let orbitRadius: CGFloat = 130

        return ZStack {
            // Central emblem — purely decorative anchor.
            ZStack {
                Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 168, height: 168)
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 140, height: 140)
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .accessibilityHidden(true)

            ForEach(Array(AddOn.allCases.enumerated()), id: \.element) { index, addOn in
                NavigationLink(value: addOn) {
                    VStack(spacing: Space.x1) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 92, height: 92)
                                .cardShadow()
                            Image(systemName: addOn.icon)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(theme.accentDeep)
                        }
                        Text(addOn.label)
                            .font(.zCaption)
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.ink)
                        Text(addOn.caption)
                            .font(.zMicro)
                            .foregroundStyle(theme.ink.opacity(0.55))
                    }
                }
                .buttonStyle(.pressable(scale: 0.92))
                .offset(
                    x: addOn.orbit.x * orbitRadius * 1.7,
                    y: addOn.orbit.y * orbitRadius * 1.55
                )
                .scaleEffect(appeared ? 1 : 0.3)
                .opacity(appeared ? 1 : 0)
                .animation(
                    .spring(duration: 0.6, bounce: 0.45).delay(0.08 * Double(index + 1)),
                    value: appeared
                )
                .accessibilityLabel("\(addOn.label). \(addOn.caption)")
            }
        }
        .frame(height: 460)
    }
}
