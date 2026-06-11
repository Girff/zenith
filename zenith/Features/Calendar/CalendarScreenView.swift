//
//  CalendarScreenView.swift
//  zenith
//
//  Stacked pastel day-cards with a month switcher, after the calendar
//  reference shot. Each card shows the day's tasks on a timeline.
//

import SwiftUI

struct CalendarScreenView: View {
    @Environment(AppStore.self) private var store
    @State private var composingFor: Date?
    @State private var appeared = false

    private let pastels: [(bg: Color, ink: Color)] = [
        (Color(hex: 0xC5BBE2), Color(hex: 0x453A6B)),   // lavender
        (Color(hex: 0xD9A8A8), Color(hex: 0x6B3535)),   // rose
        (Color(hex: 0x9ED4C6), Color(hex: 0x1F5C4D)),   // teal
        (Color(hex: 0xEAC98F), Color(hex: 0x6B4A1F)),   // sand
        (Color(hex: 0xA8C4DC), Color(hex: 0x2E4A66))    // sky
    ]

    private var days: [Date] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Space.x4) {
                monthHeader
                    .padding(.top, Space.x2)

                VStack(spacing: Space.x4) {
                    ForEach(Array(days.enumerated()), id: \.element) { index, day in
                        DayCard(
                            day: day,
                            palette: pastels[index % pastels.count],
                            tasks: tasks(on: day),
                            onAdd: { composingFor = day },
                            onToggle: { store.toggle($0) }
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 36)
                        .animation(
                            .spring(duration: 0.6, bounce: 0.25).delay(Double(index) * 0.06),
                            value: appeared
                        )
                    }
                }
                .padding(.horizontal, Space.x5)
            }
            .padding(.bottom, 140)
        }
        .background(Color(hex: 0xF3F1EC))
        .scrollIndicators(.hidden)
        .sheet(item: $composingFor) { day in
            NewTaskSheet(priority: .medium, initialDue: day.addingTimeInterval(9 * 3600))
        }
        .onAppear { appeared = true }
    }

    private func tasks(on day: Date) -> [ZenithTask] {
        store.tasks
            .filter { Calendar.current.isDate($0.due, inSameDayAs: day) }
            .sorted { $0.due < $1.due }
    }

    // MARK: Month switcher (‹ DEC › with neighbors ghosted)

    private var monthHeader: some View {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        let current = Date.now
        let prev = cal.date(byAdding: .month, value: -1, to: current)!
        let next = cal.date(byAdding: .month, value: 1, to: current)!

        return HStack {
            Text(fmt.string(from: prev).uppercased())
                .font(.zSectionTitle)
                .foregroundStyle(ZenithPalette.inkTertiary.opacity(0.45))

            Spacer()

            HStack(spacing: Space.x3) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ZenithPalette.inkTertiary)
                Text(fmt.string(from: current).uppercased())
                    .font(.zScreenTitle)
                    .foregroundStyle(ZenithPalette.ink)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ZenithPalette.inkTertiary)
            }

            Spacer()

            Text(fmt.string(from: next).uppercased())
                .font(.zSectionTitle)
                .foregroundStyle(ZenithPalette.inkTertiary.opacity(0.45))
        }
        .padding(.horizontal, Space.x5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Month: \(fmt.string(from: current))")
    }
}

// Date needs Identifiable for sheet(item:).
extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSinceReferenceDate }
}

// MARK: - Day card

private struct DayCard: View {
    let day: Date
    let palette: (bg: Color, ink: Color)
    let tasks: [ZenithTask]
    let onAdd: () -> Void
    let onToggle: (ZenithTask) -> Void

    private var weekday: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return Calendar.current.isDateInToday(day) ? "Today" : fmt.string(from: day)
    }

    private var dayNumber: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d"
        return fmt.string(from: day)
    }

    private var monthAbbrev: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: day).uppercased()
    }

    var body: some View {
        HStack(alignment: .top, spacing: Space.x4) {
            // Big date block
            VStack(alignment: .leading, spacing: 0) {
                Text(weekday)
                    .font(.zSubhead)
                    .fontWeight(.medium)
                    .foregroundStyle(palette.ink.opacity(0.75))
                Text(dayNumber)
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(palette.ink)
                Text(monthAbbrev)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(palette.ink.opacity(0.85))
            }

            // Timeline of tasks
            VStack(alignment: .leading, spacing: Space.x2) {
                if tasks.isEmpty {
                    VStack(alignment: .leading, spacing: Space.x2) {
                        Text("Nothing planned")
                            .font(.zCaption)
                            .foregroundStyle(palette.ink.opacity(0.6))
                        addButton
                    }
                    .padding(.top, Space.x2)
                } else {
                    ForEach(tasks) { task in
                        Button {
                            onToggle(task)
                        } label: {
                            HStack(spacing: Space.x2) {
                                Text(task.due, format: .dateTime.hour().minute())
                                    .font(.zMicro)
                                    .foregroundStyle(palette.ink.opacity(0.65))
                                    .frame(width: 46, alignment: .leading)

                                Text(task.title)
                                    .font(.zCaption)
                                    .fontWeight(.semibold)
                                    .strikethrough(task.isDone)
                                    .lineLimit(1)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Space.x2)
                                    .padding(.vertical, 5)
                                    .background(
                                        palette.ink.opacity(task.isDone ? 0.45 : 0.9),
                                        in: Capsule()
                                    )
                            }
                        }
                        .buttonStyle(.pressable(scale: 0.95))
                    }
                    addButton
                        .padding(.top, Space.x1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Space.x1)
        }
        .padding(Space.x4)
        .background(palette.bg, in: RoundedRectangle(cornerRadius: Radius.hero, style: .continuous))
        .cardShadow()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(weekday), \(dayNumber) \(monthAbbrev), \(tasks.count) tasks")
    }

    private var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.ink)
                .frame(width: 26, height: 26)
                .background(Circle().strokeBorder(palette.ink.opacity(0.5), lineWidth: 1.5))
        }
        .buttonStyle(.pressable(scale: 0.85))
        .accessibilityLabel("Add task on \(weekday)")
    }
}
