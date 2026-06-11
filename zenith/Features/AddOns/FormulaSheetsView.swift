//
//  FormulaSheetsView.swift
//  zenith
//
//  Wireframe "FORMULA SHEETS": a two-column grid of class binders.
//

import SwiftUI

struct FormulaSheetsView: View {
    @Environment(AppStore.self) private var store
    @State private var appeared = false

    private let columns = [
        GridItem(.flexible(), spacing: Space.x3),
        GridItem(.flexible(), spacing: Space.x3)
    ]

    var body: some View {
        let theme = store.theme

        ScrollView {
            VStack(alignment: .leading, spacing: Space.x4) {
                VStack(alignment: .leading, spacing: Space.x1) {
                    OverlineText(text: "Your classes", color: theme.accentDeep.opacity(0.7))
                    Text("FORMULA SHEETS")
                        .font(.zScreenTitle)
                        .foregroundStyle(theme.accentDeep)
                }
                .padding(.top, Space.x2)

                LazyVGrid(columns: columns, spacing: Space.x3) {
                    ForEach(Array(store.formulaSheets.enumerated()), id: \.element.id) { index, sheet in
                        SheetCard(sheet: sheet)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 26)
                            .animation(
                                .spring(duration: 0.55, bounce: 0.3).delay(Double(index) * 0.07),
                                value: appeared
                            )
                    }

                    // "MORE…" tile from the wireframe.
                    AddSheetCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 26)
                        .animation(
                            .spring(duration: 0.55, bounce: 0.3)
                                .delay(Double(store.formulaSheets.count) * 0.07),
                            value: appeared
                        )
                }
            }
            .padding(.horizontal, Space.x5)
            .padding(.bottom, 140)
        }
        .background(theme.skyBottom.opacity(0.55))
        .scrollIndicators(.hidden)
        .navigationTitle("Formula Sheets")
        .inlineNavigationTitle()
        .onAppear { appeared = true }
    }
}

private struct SheetCard: View {
    let sheet: FormulaSheet
    @Environment(\.biomeTheme) private var theme

    var body: some View {
        Button {
            // Placeholder: would open the sheet binder.
        } label: {
            VStack(alignment: .leading, spacing: Space.x3) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(theme.accentSoft)
                        .frame(height: 96)
                    Image(systemName: sheet.symbol)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(theme.accentDeep)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(sheet.className)
                        .font(.zHeadline)
                        .foregroundStyle(ZenithPalette.ink)
                        .lineLimit(1)
                    Text("\(sheet.sheetCount) sheets")
                        .font(.zCaption)
                        .foregroundStyle(ZenithPalette.inkTertiary)
                }
            }
            .padding(Space.x3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .cardShadow()
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("\(sheet.className), \(sheet.sheetCount) formula sheets")
    }
}

private struct AddSheetCard: View {
    @Environment(\.biomeTheme) private var theme

    var body: some View {
        Button {
            // Placeholder: would create a new binder.
        } label: {
            VStack(spacing: Space.x2) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(theme.accentDeep)
                Text("More…")
                    .font(.zHeadline)
                    .foregroundStyle(ZenithPalette.inkSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 170)
            .background(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(
                        theme.accentDeep.opacity(0.35),
                        style: StrokeStyle(lineWidth: 2, dash: [7, 6])
                    )
            )
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("Add a class")
    }
}
