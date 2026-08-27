import SwiftUI

struct NoteEditorView: View {
    @Binding var note: String
    @Environment(\.dismiss) private var dismiss
    @State private var draftNote: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $draftNote)
                    .focused($isFocused)
                    .foregroundColor(.ledgerTextHi)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ledgerScreenBackground()
            .scrollContentBackground(.hidden)
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        note = draftNote
                        dismiss()
                    }
                    .disabled(draftNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                draftNote = note
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = true
                }
            }
        }
    }
}
