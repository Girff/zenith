//
//  PomodoroModel.swift
//  zenith
//

import SwiftUI
import Observation

@Observable
final class PomodoroModel {

    enum Phase: CaseIterable {
        case focus, shortBreak, longBreak

        var label: String {
            switch self {
            case .focus: "Focus"
            case .shortBreak: "Short Break"
            case .longBreak: "Long Break"
            }
        }

        var duration: TimeInterval {
            switch self {
            case .focus: 25 * 60
            case .shortBreak: 5 * 60
            case .longBreak: 15 * 60
            }
        }

        var symbol: String {
            switch self {
            case .focus: "brain.head.profile"
            case .shortBreak: "cup.and.saucer.fill"
            case .longBreak: "leaf.fill"
            }
        }
    }

    var phase: Phase = .focus
    var remaining: TimeInterval = Phase.focus.duration
    var isRunning = false
    var completedFocusSessions = 0

    @ObservationIgnored private var timer: Timer?

    var progress: Double {
        1 - remaining / phase.duration
    }

    var timeString: String {
        let total = max(0, Int(remaining.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        remaining = phase.duration
    }

    func select(_ newPhase: Phase) {
        pause()
        phase = newPhase
        remaining = newPhase.duration
    }

    private func tick() {
        guard remaining > 0 else {
            advance()
            return
        }
        remaining -= 1
    }

    /// Auto-advance: every 4th focus session earns a long break.
    private func advance() {
        pause()
        switch phase {
        case .focus:
            completedFocusSessions += 1
            phase = completedFocusSessions.isMultiple(of: 4) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            phase = .focus
        }
        remaining = phase.duration
    }

    deinit {
        timer?.invalidate()
    }
}
