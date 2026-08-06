import SwiftUI

/// Shared by NewSessionView and EditSessionView's Conditions box.
struct WeatherPickerRow: View {
    @Binding var weatherCondition: String

    var body: some View {
        HStack {
            Text("Weather")
            Spacer()
            Picker("Weather", selection: $weatherCondition) {
                ForEach(SessionOptions.weatherConditions, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
        }
    }
}
