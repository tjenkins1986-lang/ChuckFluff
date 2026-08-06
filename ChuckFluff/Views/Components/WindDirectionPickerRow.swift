import SwiftUI

/// Shared by NewSessionView and EditSessionView's Conditions box.
struct WindDirectionPickerRow: View {
    @Binding var windDirection: String

    var body: some View {
        HStack {
            Text("Wind Direction")
            Spacer()
            Picker("Wind Direction", selection: $windDirection) {
                Text("–").tag("")
                ForEach(SessionOptions.windDirections, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
        }
    }
}
