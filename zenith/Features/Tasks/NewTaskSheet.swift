//
//  NewTaskSheet.swift
//  zenith
//
//  Wireframe "NEW TASK" card: Title / Notes / URL, Date & Time,
//  Tag chooser — recreated as a springy bottom sheet.
//

import SwiftUI

struct NewTaskSheet: View {
    let priority: TaskPriority

    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.biomeTheme) private var theme

    @State private var title = ""
    @State private var notes = ""
    @State private var urlString = ""
    @State private var due = Date.now.addingTimeInterval(3600)
    @State private var tag: TaskTag?
    @State private var selectedPriority: TaskPriority

    @FocusState private var focused: Field?
    private enum Field { case title, notes, url }

    init(priority: TaskPriority, initialDue: Date? = nil) {
        self.priority = priority
        _selectedPriority = State(initialValue: priority)
        if let initialDue {
            _due = State(initialValue: initialDue)
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.x5) {
                    // Text fields
                    VStack(spacing: Space.x3) {
                        UnderlinedField(placeholder: "Title", text: $title)
                            .focused($focused, equals: .title)
                            .submitLabel(.next)
                            .onSubmit { focused = .notes }

                        UnderlinedField(placeholder: "Notes", text: $notes)
                            .focused($focused, equals: .notes)
                            .submitLabel(.next)
                            .onSubmit { focused = .url }

                        UnderlinedField(placeholder: "URL", text: $urlString)
                            .focused($focused, equals: .url)
                            .urlKeyboard()
                            .noAutocapitalization()
                            .submitLabel(.done)
                    }

                    Divider()

                    // Date & time
                    VStack(alignment: .leading, spacing: Space.x2) {
                        OverlineText(text: "Date")
                        DatePicker(
                            "Due",
                            selection: $due,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(theme.accent)
                    }

                    Divider()

                    // Tag
                    VStack(alignment: .leading, spacing: Space.x2) {
                        OverlineText(text: "Tag")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Space.x2) {
                                ForEach(TaskTag.allCases) { candidate in
                                    ChipButton(
                                        label: candidate.label,
                                        icon: candidate.symbol,
                                        selected: tag == candidate
                                    ) {
                                        withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                                            tag = tag == candidate ? nil : candidate
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Divider()

                    // Priority
                    VStack(alignment: .leading, spacing: Space.x2) {
                        OverlineText(text: "Priority")
                        HStack(spacing: Space.x2) {
                            ForEach(TaskPriority.allCases) { candidate in
                                ChipButton(
                                    label: candidate.shortLabel,
                                    icon: candidate.symbol,
                                    selected: selectedPriority == candidate
                                ) {
                                    withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                                        selectedPriority = candidate
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Space.x5)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Task")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(ZenithPalette.inkSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Plant It") {
                        store.addTask(
                            ZenithTask(
                                title: title.trimmingCharacters(in: .whitespaces),
                                notes: notes,
                                url: urlString,
                                due: due,
                                tag: tag,
                                priority: selectedPriority
                            )
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(canSave ? theme.accentDeep : ZenithPalette.inkTertiary)
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheetCornerRadius(Radius.hero)
        .onAppear { focused = .title }
    }
}

// MARK: - Underlined text field (wireframe style)

private struct UnderlinedField: View {
    let placeholder: String
    @Binding var text: String

    @Environment(\.biomeTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 6) {
            TextField(placeholder, text: $text)
                .font(.zBody)
                .focused($isFocused)
                .frame(minHeight: 32)

            Rectangle()
                .fill(isFocused ? theme.accent : ZenithPalette.hairline)
                .frame(height: isFocused ? 2 : 1)
        }
        .animation(.easeOut(duration: 0.18), value: isFocused)
    }
}
