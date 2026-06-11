//
//  GPAView.swift
//  zenith
//
//  Estimated GPA dashboard: cumulative vs this year, animated
//  by-marking-period bars, and by-course breakdown.
//

import SwiftUI

struct GPAView: View {
    @Environment(AppStore.self) private var store
    @State private var weighted = true
    @State private var barsAppeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Estimated GPA")
                    .font(.zScreenTitle)
                    .foregroundStyle(GradesPalette.text)
                    .padding(.top, Space.x2)

                // Weighted / unweighted toggle
                HStack(spacing: Space.x2) {
                    segment("Weighted GPA", active: weighted) { weighted = true }
                    segment("Unweighted GPA", active: !weighted) { weighted = false }
                }

                // Headline numbers
                HStack(spacing: Space.x3) {
                    BigNumberCard(
                        label: "Cumulative",
                        value: weighted ? store.weightedGPA : store.unweightedGPA
                    )
                    BigNumberCard(
                        label: "This Year",
                        value: weighted ? store.weightedGPAThisYear : store.unweightedGPA
                    )
                }

                // Official chip
                GradesCard(padding: Space.x3) {
                    HStack {
                        Text("Official Weighted GPA")
                            .font(.zHeadline)
                            .foregroundStyle(GradesPalette.text)
                        Spacer()
                        GradePill(value: String(format: "%.4f", store.weightedGPA))
                    }
                }

                // Tools
                VStack(spacing: Space.x2) {
                    toolRow(icon: "slider.horizontal.3", title: "What If Calculator", caption: "Estimate GPA with custom grades")
                    toolRow(icon: "wrench.and.screwdriver.fill", title: "GPA Editor", caption: "Configure scales and exclusions")
                    toolRow(icon: "doc.badge.gearshape", title: "Transcript Configuration", caption: "Exclude credits from GPA")
                }

                // By marking period — animated bars
                GradesCard {
                    VStack(alignment: .leading, spacing: Space.x3) {
                        Text("Weighted GPA By MP")
                            .font(.zSectionTitle)
                            .foregroundStyle(GradesPalette.text)

                        HStack(alignment: .bottom, spacing: Space.x4) {
                            ForEach(Array(store.gpaByMP.enumerated()), id: \.offset) { index, value in
                                VStack(spacing: Space.x1) {
                                    Text(String(format: "%.2f", value))
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(GradesPalette.accent)
                                        .monospacedDigit()

                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [GradesPalette.accent, GradesPalette.accent.opacity(0.55)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(height: barsAppeared ? barHeight(value) : 4)

                                    Text("MP\(index + 1)")
                                        .font(.zMicro)
                                        .foregroundStyle(GradesPalette.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .animation(
                                    .spring(duration: 0.7, bounce: 0.3).delay(Double(index) * 0.08),
                                    value: barsAppeared
                                )
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Marking period \(index + 1): \(String(format: "%.2f", value))")
                            }
                        }
                        .frame(height: 150, alignment: .bottom)
                    }
                }
                .onAppear { barsAppeared = true }

                // By course
                GradesCard {
                    VStack(alignment: .leading, spacing: Space.x3) {
                        Text("Weighted GPA By Course")
                            .font(.zSectionTitle)
                            .foregroundStyle(GradesPalette.text)

                        VStack(spacing: Space.x3) {
                            ForEach(store.gpaCourses) { course in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(course.name)
                                            .font(.zHeadline)
                                            .foregroundStyle(GradesPalette.text)
                                        Text(course.code)
                                            .font(.zCaption)
                                            .foregroundStyle(GradesPalette.textSecondary)
                                    }
                                    Spacer()
                                    GradePill(value: String(format: "%.3f", course.weighted))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Space.x5)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
    }

    private func barHeight(_ value: Double) -> CGFloat {
        // Scale 3.0...6.0 → 12...120pt
        let normalized = max(0, min(1, (value - 3) / 3))
        return 12 + normalized * 108
    }

    private func segment(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.25)) { action() }
        } label: {
            Text(label)
                .font(.zCaption)
                .fontWeight(.bold)
                .foregroundStyle(active ? .white : GradesPalette.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.x2)
                .background(active ? GradesPalette.accent : GradesPalette.card, in: Capsule())
        }
        .buttonStyle(.pressable(scale: 0.95))
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func toolRow(icon: String, title: String, caption: String) -> some View {
        GradesCard(padding: Space.x3) {
            HStack(spacing: Space.x3) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GradesPalette.accent)
                    .frame(width: 38, height: 38)
                    .background(GradesPalette.accentSoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.zHeadline)
                        .foregroundStyle(GradesPalette.text)
                    Text(caption)
                        .font(.zCaption)
                        .foregroundStyle(GradesPalette.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(GradesPalette.textSecondary)
            }
        }
    }
}

// MARK: - Big number card

private struct BigNumberCard: View {
    let label: String
    let value: Double

    var body: some View {
        GradesCard(padding: Space.x4) {
            VStack(alignment: .leading, spacing: Space.x1) {
                Text(label)
                    .font(.zCaption)
                    .foregroundStyle(GradesPalette.textSecondary)
                Text(String(format: "%.3f", value))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(GradesPalette.text)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) GPA: \(String(format: "%.3f", value))")
    }
}
