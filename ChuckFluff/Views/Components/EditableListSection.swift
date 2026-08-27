import SwiftUI

/// A named, swipe-to-delete list with an "Add" button — used for the Target Species, Rods,
/// and Reels sections in Settings & Help.
struct EditableListSection: View {
    let header: String
    let footer: String
    let items: [String]
    let addButtonLabel: String
    let onDelete: (IndexSet) -> Void
    let onAddTapped: () -> Void

    private var ledgerHeader: some View {
        Text(header)
            .font(.ledgerMono(10.5, weight: .medium))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundColor(.ledgerTextLow)
    }

    var body: some View {
        Section(header: ledgerHeader, footer: Text(footer).foregroundColor(.ledgerTextLow)) {
            ForEach(items, id: \.self) { item in
                Text(item).foregroundColor(.ledgerTextHi)
            }
            .onDelete(perform: onDelete)
            Button(action: onAddTapped) {
                Label(addButtonLabel, systemImage: "plus.circle.fill")
                    .foregroundColor(.ledgerBrass)
            }
        }
        .listRowBackground(Color.ledgerInkSurface)
    }
}
