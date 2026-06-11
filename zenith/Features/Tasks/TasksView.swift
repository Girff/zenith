//
//  TasksView.swift
//  zenith
//
//  Wireframe Tasks: TASKS OVERVIEW with High / Medium / Personal Goals
//  sections and a FAB that fans out a radial HIGH · MED · LOW picker.
//

import SwiftUI

struct TasksView: View {
    @Environment(AppStore.self) private var store

    @State private var radialOpen = false
    @State private var composing: TaskPriority?

    var body: some View {
        let theme = store.theme

        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: Space.x5) {
                    header

                    VStack(spacing: Space.x5) {
                        ForEach(TaskPriority.allCases) { priority in
                            PrioritySectionCard(priority: priority)
                        }
                    }
                    .padding(.horizontal, Space.x5)
                }
                .padding(.bottom, 160)
            }
            .background(theme.skyBottom.opacity(0.55))
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)

            // Scrim while the radial menu is open.
            if radialOpen {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.4, bounce: 0.3)) { radialOpen = false }
                    }
            }

            radialFAB
                .padding(.trailing, Space.x5)
                .padding(.bottom, 104)
        }
        .sheet(item: $composing) { priority in
            NewTaskSheet(priority: priority)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: radialOpen)
    }

    // MARK: Header

    private var header: some View {
        let theme = store.theme

        return ZStack(alignment: .bottomLeading) {
            EcosystemView(biome: store.biome, vitality: store.vitality)
                .frame(height: 210)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: Radius.hero,
                        bottomTrailingRadius: Radius.hero,
                        style: .continuous
                    )
                )

            GlassPanel(padding: Space.x3) {
                VStack(alignment: .leading, spacing: 2) {
                    OverlineText(text: "Tend your day", color: theme.accentDeep.opacity(0.8))
                    Text("TASKS OVERVIEW")
                        .font(.zScreenTitle)
                        .foregroundStyle(theme.accentDeep)
                }
            }
            .padding(.horizontal, Space.x5)
            .padding(.bottom, Space.x4)
        }
    }

    // MARK: Radial FAB ("CHOOSE PRIORITY" from the wireframe)

    private var radialFAB: some View {
        ZStack(alignment: .bottomTrailing) {
            ForEach(Array(TaskPriority.allCases.enumerated()), id: \.element) { index, priority in
                let angle = Angle.degrees(90 + Double(index) * 45)   // fan: up → diagonal → left
                let radius: CGFloat = 108

                Button {
                    withAnimation(.spring(duration: 0.4, bounce: 0.3)) { radialOpen = false }
                    composing = priority
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: priority.symbol)
                            .font(.system(size: 16, weight: .bold))
                        Text(priority.shortLabel)
                            .font(.zMicro)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(priority.color, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(.pressable(scale: 0.85))
                .floatShadow()
                .offset(
                    x: radialOpen ? -cos(angle.radians) * radius + 0 : 0,
                    y: radialOpen ? -sin(angle.radians) * radius + 0 : 0
                )
                .scaleEffect(radialOpen ? 1 : 0.1, anchor: .center)
                .opacity(radialOpen ? 1 : 0)
                .animation(
                    .spring(duration: 0.45, bounce: 0.45).delay(Double(index) * 0.05),
                    value: radialOpen
                )
                .accessibilityLabel("New \(priority.label) task")
            }

            ZenithFAB(icon: "plus", rotated: radialOpen) {
                withAnimation(.spring(duration: 0.45, bounce: 0.4)) {
                    radialOpen.toggle()
                }
            }
            .accessibilityLabel(radialOpen ? "Close priority picker" : "Add task")
        }
    }
}

// MARK: - Priority section card

private struct PrioritySectionCard: View {
    let priority: TaskPriority

    @Environment(AppStore.self) private var store

    var body: some View {
        let tasks = store.tasks(for: priority)

        ZenithCard {
            VStack(alignment: .leading, spacing: Space.x2) {
                HStack(spacing: Space.x2) {
                    Image(systemName: priority.symbol)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(priority.color, in: Circle())

                    VStack(alignment: .leading, spacing: 0) {
                        Text(priority.label)
                            .font(.zSectionTitle)
                            .foregroundStyle(ZenithPalette.ink)
                        Text(priority.sectionSubtitle)
                            .font(.zCaption)
                            .foregroundStyle(ZenithPalette.inkTertiary)
                    }

                    Spacer()

                    Text("\(tasks.filter { !$0.isDone }.count)")
                        .font(.zCaption)
                        .fontWeight(.bold)
                        .foregroundStyle(priority.color)
                        .padding(.horizontal, Space.x2)
                        .padding(.vertical, 3)
                        .background(priority.color.opacity(0.12), in: Capsule())
                        .monospacedDigit()
                }

                if tasks.isEmpty {
                    HStack(spacing: Space.x2) {
                        Image(systemName: "moon.zzz.fill")
                            .foregroundStyle(ZenithPalette.inkTertiary)
                        Text("Nothing here yet — the \(priority.shortLabel.lowercased()) meadow rests.")
                            .font(.zSubhead)
                            .foregroundStyle(ZenithPalette.inkSecondary)
                    }
                    .padding(.vertical, Space.x3)
                } else {
                    VStack(spacing: 0) {
                        ForEach(tasks) { task in
                            TaskRow(task: task, showsPriorityDot: false) {
                                store.toggle(task)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.delete(task)
                                } label: {
                                    Label("Delete Task", systemImage: "trash")
                                }
                            }
                            if task.id != tasks.last?.id {
                                Divider().overlay(ZenithPalette.hairline)
                            }
                        }
                    }
                }
            }
        }
    }
}
