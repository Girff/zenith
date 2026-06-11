//
//  AppStore.swift
//  zenith
//
//  Single observable source of truth. Vitality is derived from task
//  completion so the ecosystem visibly reacts to productivity.
//

import SwiftUI
import Observation

@Observable
final class AppStore {

    // MARK: Onboarding & biome

    var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: "zenith.hasOnboarded") }
    }

    var biome: Biome {
        didSet { UserDefaults.standard.set(biome.rawValue, forKey: "zenith.biome") }
    }

    var theme: BiomeTheme { biome.theme }

    // MARK: Tasks

    var tasks: [ZenithTask]

    /// XP banked from completed tasks; feeds the leaderboard.
    var xp: Int = 120
    var streakDays: Int = 6

    func tasks(for priority: TaskPriority) -> [ZenithTask] {
        tasks
            .filter { $0.priority == priority }
            .sorted {
                if $0.isDone != $1.isDone { return !$0.isDone }
                return $0.due < $1.due
            }
    }

    var todaysTasks: [ZenithTask] {
        tasks
            .filter { Calendar.current.isDateInToday($0.due) }
            .sorted { !$0.isDone && $1.isDone }
    }

    var completedTodayCount: Int {
        todaysTasks.filter(\.isDone).count
    }

    func addTask(_ task: ZenithTask) {
        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
            tasks.insert(task, at: 0)
        }
    }

    func toggle(_ task: ZenithTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation(.spring(duration: 0.5, bounce: 0.35)) {
            tasks[index].isDone.toggle()
        }
        if tasks[index].isDone {
            xp += tasks[index].priority.xpReward
        } else {
            xp = max(0, xp - tasks[index].priority.xpReward)
        }
    }

    func delete(_ task: ZenithTask) {
        withAnimation(.spring(duration: 0.45)) {
            tasks.removeAll { $0.id == task.id }
        }
    }

    // MARK: Vitality

    /// 0...1 — the heartbeat of the ecosystem. A baseline keeps a fresh
    /// biome alive; every completed task feeds it.
    var vitality: Double {
        let due = tasks.filter { $0.due <= Calendar.current.date(byAdding: .day, value: 1, to: .now)! }
        guard !due.isEmpty else { return 0.6 }
        let ratio = Double(due.filter(\.isDone).count) / Double(due.count)
        return min(1, 0.22 + ratio * 0.78)
    }

    var vitalityStatus: VitalityStatus { .from(vitality) }

    // MARK: Demo content (grades, leaderboard, focus, sheets)

    let courseGrades: [CourseGrade] = [
        CourseGrade(name: "Video Game Prog 1", code: "CATE2770", markingPeriods: [96.4, 98.2, 95.1, 97.1], current: 97.1, delta: 10.1),
        CourseGrade(name: "English 2 Adv", code: "ELA1220", markingPeriods: [98.0, 99.2, 100, 100], current: 100, delta: nil),
        CourseGrade(name: "AP Pre Calculus", code: "MTH3430", markingPeriods: [97.5, 96.8, 99.0, 100], current: 100, delta: nil),
        CourseGrade(name: "Chemistry Adv", code: "SCI2220", markingPeriods: [95.2, 97.7, 98.4, 100], current: 100, delta: nil),
        CourseGrade(name: "AP Physics 1", code: "SCI3440", markingPeriods: [94.0, 92.5, 95.8, 97.0], current: 97.0, delta: nil),
        CourseGrade(name: "GT Humanities 2 / AP World", code: "SST2240", markingPeriods: [96.1, 97.4, 98.9, 100], current: 100, delta: 5.6),
        CourseGrade(name: "AP Seminar", code: "SST8530", markingPeriods: [98.7, 99.0, 99.5, 100], current: 100, delta: nil),
        CourseGrade(name: "AP Computer Science A", code: "TEC2130", markingPeriods: [99.0, 100, 100, 100], current: 100, delta: nil)
    ]

    let weightedGPA: Double = 5.593
    let weightedGPAThisYear: Double = 5.681
    let unweightedGPA: Double = 4.0
    let gpaByMP: [Double] = [5.61, 5.71, 5.71, 5.68]
    let classRank = "2 / 470"

    let gpaCourses: [GPACourse] = [
        GPACourse(name: "Video Game Prog 1", code: "CATE2770A", weighted: 4.8),
        GPACourse(name: "English 2 Adv", code: "ELA1220A", weighted: 5.5),
        GPACourse(name: "AP Pre Calculus", code: "MTH3430A", weighted: 5.95),
        GPACourse(name: "Chemistry Adv", code: "SCI2220A", weighted: 5.5),
        GPACourse(name: "AP Physics 1", code: "SCI3440A", weighted: 5.9)
    ]

    let transcript: [TranscriptYear] = [
        TranscriptYear(
            year: "2023–2024", school: "Vandeventer Middle School", grade: "08",
            courses: [
                TranscriptCourse(code: "03100500", name: "Algebra 1", sem1: "99", sem2: "98", credit: 1.0),
                TranscriptCourse(code: "03810100", name: "Health Ed 1", sem1: "100", sem2: "—", credit: 0.5)
            ]
        ),
        TranscriptYear(
            year: "2024–2025", school: "Liberty High School", grade: "09",
            courses: [
                TranscriptCourse(code: "A3360100", name: "AP Human Geography", sem1: "99", sem2: "98", credit: 1.0),
                TranscriptCourse(code: "PES00053", name: "Lifetime Fitness", sem1: "100", sem2: "99", credit: 1.0),
                TranscriptCourse(code: "03580200", name: "Geometry Adv", sem1: "99", sem2: "100", credit: 1.0),
                TranscriptCourse(code: "03220100", name: "English 1 Adv", sem1: "92", sem2: "99", credit: 1.0),
                TranscriptCourse(code: "03100600", name: "Algebra 2 Adv", sem1: "100", sem2: "100", credit: 1.0),
                TranscriptCourse(code: "03010200", name: "Biology Adv", sem1: "99", sem2: "100", credit: 1.0)
            ]
        ),
        TranscriptYear(
            year: "2025–2026", school: "Liberty High School", grade: "10",
            courses: [
                TranscriptCourse(code: "A3580110", name: "AP Pre Calculus", sem1: "100", sem2: "100", credit: 1.0),
                TranscriptCourse(code: "A3370100", name: "AP World History", sem1: "99", sem2: "98", credit: 1.0),
                TranscriptCourse(code: "N1300994", name: "AP Seminar", sem1: "99", sem2: "99", credit: 1.0),
                TranscriptCourse(code: "03220200", name: "English 2 Adv", sem1: "98", sem2: "100", credit: 1.0),
                TranscriptCourse(code: "A3100101", name: "AP Physics 1", sem1: "97", sem2: "96", credit: 1.0),
                TranscriptCourse(code: "03380400", name: "Chemistry Adv", sem1: "99", sem2: "100", credit: 1.0)
            ]
        )
    ]

    var leaderboard: [LeaderboardEntry] {
        [
            LeaderboardEntry(name: "Richie", avatar: "🦊", xp: 240, isUser: false),
            LeaderboardEntry(name: "Rae", avatar: "🦉", xp: 215, isUser: false),
            LeaderboardEntry(name: "Oscar", avatar: "🐻", xp: 180, isUser: false),
            LeaderboardEntry(name: "You", avatar: "🌱", xp: xp, isUser: true),
            LeaderboardEntry(name: "Biff", avatar: "🐨", xp: 95, isUser: false),
            LeaderboardEntry(name: "Bea", avatar: "🦋", xp: 80, isUser: false),
            LeaderboardEntry(name: "Nemo", avatar: "🐠", xp: 65, isUser: false)
        ].sorted { $0.xp > $1.xp }
    }

    var focusRules: [FocusSessionRule] = [
        FocusSessionRule(name: "Deep Work Hours", emoji: "💻", schedule: "Mon–Fri · 9:00 AM – 5:00 PM", blockedMinutes: 60, slot: .today, isEnabled: true),
        FocusSessionRule(name: "Mindful Morning", emoji: "🌅", schedule: "Every day · 9:00 – 10:00 AM", blockedMinutes: 60, slot: .upcoming, isEnabled: true),
        FocusSessionRule(name: "Sleep", emoji: "💤", schedule: "Every day · 11:00 PM – 7:00 AM", blockedMinutes: nil, slot: .idea, isEnabled: false),
        FocusSessionRule(name: "Dinner With Family", emoji: "🍽️", schedule: "Sunday · 5:00 – 6:00 PM", blockedMinutes: nil, slot: .idea, isEnabled: false)
    ]

    let formulaSheets: [FormulaSheet] = [
        FormulaSheet(className: "AP Physics", symbol: "atom", sheetCount: 12),
        FormulaSheet(className: "AP Calc", symbol: "function", sheetCount: 9),
        FormulaSheet(className: "Chemistry", symbol: "testtube.2", sheetCount: 7),
        FormulaSheet(className: "Statistics", symbol: "chart.bar.xaxis", sheetCount: 5)
    ]

    // MARK: Init

    init() {
        hasOnboarded = UserDefaults.standard.bool(forKey: "zenith.hasOnboarded")
        biome = UserDefaults.standard.string(forKey: "zenith.biome")
            .flatMap(Biome.init(rawValue:)) ?? .verdantForest

        let cal = Calendar.current
        let today = Date.now
        func at(_ hour: Int, dayOffset: Int = 0) -> Date {
            let day = cal.date(byAdding: .day, value: dayOffset, to: today)!
            return cal.date(bySettingHour: hour, minute: 0, second: 0, of: day)!
        }

        tasks = [
            ZenithTask(title: "Finish AP Physics problem set", notes: "Unit 4 rotational motion", due: at(15), tag: .school, priority: .high),
            ZenithTask(title: "Submit AP Seminar essay draft", due: at(18), tag: .school, priority: .high),
            ZenithTask(title: "Review chemistry lab report", due: at(20), tag: .school, priority: .medium, isDone: true),
            ZenithTask(title: "30-minute run", due: at(7), tag: .health, priority: .medium, isDone: true),
            ZenithTask(title: "Plan weekend study schedule", due: at(12, dayOffset: 1), tag: .focus, priority: .medium),
            ZenithTask(title: "Read 20 pages of a novel", due: at(21), tag: .personal, priority: .low),
            ZenithTask(title: "Learn 3 new piano bars", due: at(17, dayOffset: 2), tag: .personal, priority: .low)
        ]
    }
}
