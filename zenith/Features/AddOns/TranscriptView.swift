//
//  TranscriptView.swift
//  zenith
//
//  Transcript by school year with credit totals and GPA/rank footer.
//

import SwiftUI

struct TranscriptView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Transcript")
                    .font(.zScreenTitle)
                    .foregroundStyle(GradesPalette.text)
                    .padding(.top, Space.x2)

                ForEach(store.transcript) { year in
                    TranscriptYearCard(year: year)
                }

                // GPA and Rank footer
                GradesCard {
                    VStack(alignment: .leading, spacing: Space.x3) {
                        Text("GPA and Rank")
                            .font(.zSectionTitle)
                            .foregroundStyle(GradesPalette.text)

                        gpaRow(type: "Weighted GPA", gpa: String(format: "%.4f", store.weightedGPA), rank: store.classRank)
                        Divider().overlay(GradesPalette.cardElevated)
                        gpaRow(type: "4.0 College GPA", gpa: String(format: "%.4f", store.unweightedGPA), rank: "—")
                    }
                }
            }
            .padding(.horizontal, Space.x5)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
    }

    private func gpaRow(type: String, gpa: String, rank: String) -> some View {
        HStack {
            Text(type)
                .font(.zHeadline)
                .foregroundStyle(GradesPalette.text)
            Spacer()
            Text(gpa)
                .font(.zHeadline)
                .foregroundStyle(GradesPalette.accent)
                .monospacedDigit()
            Text(rank)
                .font(.zCaption)
                .foregroundStyle(GradesPalette.textSecondary)
                .frame(width: 64, alignment: .trailing)
                .monospacedDigit()
        }
    }
}

private struct TranscriptYearCard: View {
    let year: TranscriptYear

    var body: some View {
        GradesCard {
            VStack(alignment: .leading, spacing: Space.x3) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Year: \(year.year)")
                            .font(.zHeadline)
                            .foregroundStyle(GradesPalette.text)
                        Text(year.school)
                            .font(.zCaption)
                            .foregroundStyle(GradesPalette.textSecondary)
                    }
                    Spacer()
                    Text("Grade: \(year.grade)")
                        .font(.zCaption)
                        .fontWeight(.bold)
                        .foregroundStyle(GradesPalette.textSecondary)
                }

                // Column headers
                HStack {
                    Text("Course").frame(maxWidth: .infinity, alignment: .leading)
                    Text("SEM1").frame(width: 44, alignment: .trailing)
                    Text("SEM2").frame(width: 44, alignment: .trailing)
                    Text("Credit").frame(width: 52, alignment: .trailing)
                }
                .font(.zMicro)
                .foregroundStyle(GradesPalette.textSecondary)

                VStack(spacing: Space.x2) {
                    ForEach(year.courses) { course in
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(course.name)
                                    .font(.zSubhead)
                                    .fontWeight(.medium)
                                    .foregroundStyle(GradesPalette.text)
                                    .lineLimit(1)
                                Text(course.code)
                                    .font(.system(size: 10))
                                    .foregroundStyle(GradesPalette.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Text(course.sem1).frame(width: 44, alignment: .trailing)
                            Text(course.sem2).frame(width: 44, alignment: .trailing)
                            Text(String(format: "%.1f", course.credit)).frame(width: 52, alignment: .trailing)
                        }
                        .font(.zSubhead)
                        .foregroundStyle(GradesPalette.text)
                        .monospacedDigit()
                    }
                }

                HStack {
                    Spacer()
                    Text("Total Credit: \(String(format: "%.4f", year.totalCredit))")
                        .font(.zCaption)
                        .fontWeight(.bold)
                        .foregroundStyle(GradesPalette.accent)
                        .monospacedDigit()
                }
                .padding(.top, Space.x1)
            }
        }
    }
}
