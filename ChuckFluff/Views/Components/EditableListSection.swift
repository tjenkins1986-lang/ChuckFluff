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

    var body: some View {
        Section(header: Text(header), footer: Text(footer)) {
            ForEach(items, id: \.self) { item in
                Text(item)
            }
            .onDelete(perform: onDelete)
            Button(action: onAddTapped) {
                Label(addButtonLabel, systemImage: "plus.circle.fill")
            }
        }
    }
}
