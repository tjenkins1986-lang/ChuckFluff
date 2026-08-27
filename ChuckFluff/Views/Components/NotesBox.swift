import SwiftUI

/// Shared by NewSessionView and EditSessionView.
struct NotesBox: View {
    @Binding var notes: String
    @Binding var showNoteSheet: Bool

    var body: some View {
        GroupBox(label: Label("Notes", systemImage: "note.text")) {
            VStack(alignment: .leading, spacing: 8) {
                if notes.isEmpty {
                    Button(action: { showNoteSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill").foregroundColor(.ledgerBrass)
                            Text("Add Note").foregroundColor(.ledgerBrass)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                } else {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.ledgerTextHi)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Button(action: { showNoteSheet = true }) {
                            Label("Edit", systemImage: "pencil").font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.ledgerBrass)
                        Spacer()
                        Button(action: { notes = "" }) {
                            Label("Delete", systemImage: "trash").font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.ledgerClay)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.top, 8)
        }
        .formBoxPadding(bottom: 24)
    }
}
