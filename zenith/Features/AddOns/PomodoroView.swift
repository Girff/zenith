//
//  PomodoroView.swift
//  zenith
//
//  Pomodoro timer with an animated vitality-style ring.
//

import SwiftUI

struct PomodoroView: View {
    @Environment(AppStore.self) private var store
    @State private var model = PomodoroModel()

    var body: some View {
        let theme = store.theme

        ZStack {
            theme.skyGradient.ignoresSafeArea()

            VStack(spacing: Space.x6) {
                // Phase selector
                HStack(spacing: Space.x2) {
                    ForEach(PomodoroModel.Phase.allCases, id: \.self) { phase in
                        ChipButton(
                            label: phase.label,
                            icon: phase.symbol,
                            selected: model.phase == phase
                        ) {
                            withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                                model.select(phase)
                            }
                        }
                    }
                }
                .padding(.top, Space.x4)

                Spacer()

                // Timer ring
                ZStack {
                    Circle()
                        .stroke(theme.accent.opacity(0.12), lineWidth: 18)

                    Circle()
                        .trim(from: 0, to: max(0.002, model.progress))
                        .stroke(
                            theme.vitalityGradient,
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.4), value: model.progress)

                    VStack(spacing: Space.x1) {
                        Text(model.timeString)
                            .font(.zHero)
                            .foregroundStyle(theme.accentDeep)
                            .monospacedDigit()
                            .contentTransition(.numericText())

                        Text(model.phase.label.uppercased())
                            .font(.zMicro)
                            .tracking(2)
                            .foregroundStyle(ZenithPalette.inkTertiary)

                        if model.completedFocusSessions > 0 {
                            HStack(spacing: 4) {
                                ForEach(0..<min(model.completedFocusSessions, 8), id: \.self) { _ in
                                    Circle()
                                        .fill(theme.accent)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .padding(.top, Space.x1)
                        }
                    }
                }
                .frame(width: 280, height: 280)
                .padding(Space.x4)
                .background(.white.opacity(0.55), in: Circle())

                Spacer()

                // Transport controls
                HStack(spacing: Space.x5) {
                    CircleIconButton(icon: "arrow.counterclockwise", size: 56, fill: .white) {
                        withAnimation { model.reset() }
                    }
                    .accessibilityLabel("Reset timer")

                    Button {
                        model.toggle()
                    } label: {
                        Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 84, height: 84)
                            .background(theme.accentGradient, in: Circle())
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.pressable(scale: 0.88))
                    .floatShadow()
                    .accessibilityLabel(model.isRunning ? "Pause" : "Start")

                    CircleIconButton(icon: "forward.end.fill", size: 56, fill: .white) {
                        withAnimation { model.select(model.phase == .focus ? .shortBreak : .focus) }
                    }
                    .accessibilityLabel("Skip phase")
                }
                .padding(.bottom, Space.x10)
            }
            .padding(.horizontal, Space.x5)
        }
        .navigationTitle("Pomodoro")
        .inlineNavigationTitle()
        .sensoryFeedback(.impact(weight: .light), trigger: model.isRunning)
        .onDisappear { model.pause() }
    }
}
