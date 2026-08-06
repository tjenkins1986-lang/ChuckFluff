import SwiftUI

/// Small sheet for adding a single named item (a species, rod, reel, session name, etc).
struct AddItemSheet: View {
    let title: String
    let placeholder: String
    @Binding var isPresented: Bool
    let onAdd: (String) -> Void

    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .focused($isFocused)
                        .onTapGesture { isFocused = true }
                        .onSubmit {
                            let trimmed = text.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                onAdd(trimmed)
                                isPresented = false
                            }
                        }
                        .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = text.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            onAdd(trimmed)
                            isPresented = false
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = true
                }
            }
        }
    }
}
