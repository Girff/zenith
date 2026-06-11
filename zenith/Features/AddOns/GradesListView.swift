//
//  GradesListView.swift
//  zenith
//
//  Course grades by marking period, after the reference shot.
//

import SwiftUI

struct GradesListView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedMP = 3

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Grades")
                    .font(.zScreenTitle)
                    .foregroundStyle(GradesPalette.text)
                    .padding(.top, Space.x2)

                // Marking period selector
                HStack(spacing: Space.x2) {
                    ForEach(0..<4, id: \.self) { mp in
                        let isActive = selectedMP == mp
                        Button {
                            withAnimation(.spring(duration: 0.35, bounce: 0.3)) { selectedMP = mp }
                        } label: {
                            Text("MP\(mp + 1)")
                                .font(.zCaption)
                                .fontWeight(.bold)
                                .foregroundStyle(isActive ? .white : GradesPalette.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Space.x2)
                                .background(
                                    isActive ? GradesPalette.accent : GradesPalette.card,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.pressable(scale: 0.93))
                        .accessibilityAddTraits(isActive ? [.isSelected] : [])
                    }
                }

                VStack(spacing: Space.x3) {
                    ForEach(store.courseGrades) { course in
                        GradeRow(course: course, mp: selectedMP)
                    }
                }
                .animation(.spring(duration: 0.4, bounce: 0.2), value: selectedMP)
            }
            .padding(.horizontal, Space.x5)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
    }
}

private struct GradeRow: View {
    let course: CourseGrade
    let mp: Int

    private var score: Double? {
        course.markingPeriods.indices.contains(mp) ? course.markingPeriods[mp] : nil
    }

    var body: some View {
        GradesCard(padding: Space.x3) {
            HStack(spacing: Space.x3) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(course.name)
                        .font(.zHeadline)
                        .foregroundStyle(GradesPalette.text)
                        .lineLimit(1)
                    HStack(spacing: Space.x2) {
                        Text(course.code)
                            .font(.zCaption)
                            .foregroundStyle(GradesPalette.textSecondary)
                        if let delta = course.delta {
                            Text(String(format: "%+.2f", delta))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(GradesPalette.positive, in: Capsule())
                        }
                    }
                }

                Spacer()

                GradePill(value: score.map { String(format: "%.2f", $0) } ?? "—")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(course.name), marking period \(mp + 1): \(score.map { String(format: "%.1f", $0) } ?? "no grade")"
        )
    }
}
