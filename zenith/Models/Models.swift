//
//  Models.swift
//  zenith
//

import SwiftUI

// MARK: - Tasks

enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case high, medium, low

    var id: String { rawValue }

    var label: String {
        switch self {
        case .high: "High Priority"
        case .medium: "Medium Priority"
        case .low: "Personal Goals"
        }
    }

    var shortLabel: String {
        switch self {
        case .high: "HIGH"
        case .medium: "MED"
        case .low: "LOW"
        }
    }

    var color: Color {
        switch self {
        case .high: ZenithPalette.priorityHigh
        case .medium: ZenithPalette.priorityMedium
        case .low: ZenithPalette.priorityLow
        }
    }

    var symbol: String {
        switch self {
        case .high: "flame.fill"
        case .medium: "bolt.fill"
        case .low: "sparkles"
        }
    }

    var sectionSubtitle: String {
        switch self {
        case .high: "Tackle these first — the biome is counting on you."
        case .medium: "Steady progress keeps the rivers running."
        case .low: "Low pressure, big meaning."
        }
    }

    /// XP awarded to the ecosystem when a task of this priority is completed.
    var xpReward: Int {
        switch self {
        case .high: 15
        case .medium: 10
        case .low: 5
        }
    }
}

enum TaskTag: String, CaseIterable, Identifiable, Codable {
    case school, personal, health, focus, home

    var id: String { rawValue }

    var label: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .school: "graduationcap.fill"
        case .personal: "heart.fill"
        case .health: "figure.run"
        case .focus: "scope"
        case .home: "house.fill"
        }
    }
}

struct ZenithTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var url: String
    var due: Date
    var tag: TaskTag?
    var priority: TaskPriority
    var isDone: Bool

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        url: String = "",
        due: Date = .now,
        tag: TaskTag? = nil,
        priority: TaskPriority = .medium,
        isDone: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.url = url
        self.due = due
        self.tag = tag
        self.priority = priority
        self.isDone = isDone
    }
}

// MARK: - Vitality

enum VitalityStatus {
    case flourishing, thriving, steady, wilting

    static func from(_ progress: Double) -> VitalityStatus {
        switch progress {
        case 0.85...: .flourishing
        case 0.6..<0.85: .thriving
        case 0.35..<0.6: .steady
        default: .wilting
        }
    }

    var label: String {
        switch self {
        case .flourishing: "Flourishing"
        case .thriving: "Thriving"
        case .steady: "Steady"
        case .wilting: "Wilting"
        }
    }

    var symbol: String {
        switch self {
        case .flourishing: "sparkles"
        case .thriving: "leaf.fill"
        case .steady: "cloud.sun.fill"
        case .wilting: "drop.fill"
        }
    }

    var encouragement: String {
        switch self {
        case .flourishing: "Your ecosystem is radiant. Keep the streak alive!"
        case .thriving: "The canopy is filling in beautifully."
        case .steady: "A few more tasks and things start to bloom."
        case .wilting: "Your biome needs a little attention today."
        }
    }
}

// MARK: - Grades suite

struct CourseGrade: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let markingPeriods: [Double?]
    let current: Double
    let delta: Double?
}

struct GPACourse: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let weighted: Double
}

struct TranscriptCourse: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let sem1: String
    let sem2: String
    let credit: Double
}

struct TranscriptYear: Identifiable {
    let id = UUID()
    let year: String
    let school: String
    let grade: String
    let courses: [TranscriptCourse]

    var totalCredit: Double { courses.reduce(0) { $0 + $1.credit } }
}

// MARK: - Leaderboard

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
    let xp: Int
    let isUser: Bool
}

// MARK: - App blocking

struct FocusSessionRule: Identifiable {
    enum Slot { case today, upcoming, idea }

    let id = UUID()
    let name: String
    let emoji: String
    let schedule: String
    let blockedMinutes: Int?
    let slot: Slot
    var isEnabled: Bool
}

// MARK: - Formula sheets

struct FormulaSheet: Identifiable {
    let id = UUID()
    let className: String
    let symbol: String
    let sheetCount: Int
}
