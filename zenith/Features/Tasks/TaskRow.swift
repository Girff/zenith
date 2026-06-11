//
//  TaskRow.swift
//  zenith
//
//  Tactile, checkable task row shared by Home and Tasks. The whole row
//  is a generous hit target; completion springs and strikes through.
//

import SwiftUI

struct TaskRow: View {
    let task: ZenithTask
    var showsPriorityDot: Bool = true
    let onToggle: () -> Void

    @Environment(\.biomeTheme) private var theme
    @State private var burst = false

    var body: some View {
        Button {
            if !task.isDone {
                burst.toggle()
            }
            onToggle()
        } label: {
            HStack(spacing: Space.x3) {
                checkmark

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.zHeadline)
                        .foregroundStyle(task.isDone ? ZenithPalette.inkTertiary : ZenithPalette.ink)
                        .strikethrough(task.isDone, color: ZenithPalette.inkTertiary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: Space.x2) {
                        Text(task.due, format: .dateTime.hour().minute())
                            .font(.zCaption)
                            .foregroundStyle(ZenithPalette.inkTertiary)
                        if let tag = task.tag {
                            HStack(spacing: 3) {
                                Image(systemName: tag.symbol)
                                    .font(.system(size: 9, weight: .semibold))
                                Text(tag.label)
                                    .font(.zCaption)
                            }
                            .foregroundStyle(theme.accentDeep.opacity(0.8))
                        }
                    }
                }

                Spacer(minLength: 0)

                if showsPriorityDot {
                    Circle()
                        .fill(task.priority.color)
                        .frame(width: 8, height: 8)
                        .opacity(task.isDone ? 0.3 : 1)
                }
            }
            .padding(.vertical, Space.x2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: burst)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isDone ? "completed" : "not completed")
        .accessibilityHint("Double tap to toggle completion")
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    task.isDone ? theme.accent : ZenithPalette.inkTertiary.opacity(0.6),
                    lineWidth: 2
                )
                .background(Circle().fill(task.isDone ? theme.accent : .clear))
                .frame(width: 26, height: 26)

            if task.isDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }

            // Completion burst ring
            Circle()
                .stroke(theme.accent.opacity(burst ? 0 : 0.5), lineWidth: 2)
                .frame(width: burst ? 44 : 26, height: burst ? 44 : 26)
                .animation(.easeOut(duration: 0.5), value: burst)
        }
        .animation(.spring(duration: 0.4, bounce: 0.5), value: task.isDone)
        .frame(width: 44, height: 44)
    }
}
