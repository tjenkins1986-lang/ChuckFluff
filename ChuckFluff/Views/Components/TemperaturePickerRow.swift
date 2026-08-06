import SwiftUI

/// A tappable row that shows the current air/water temperature (or "optional") and opens a
/// `TemperaturePickerView`. Shared by NewSessionView and EditSessionView's Conditions box.
struct TemperaturePickerRow: View {
    let title: String
    @Binding var temperatureCelsius: Double
    let onTap: () -> Void

    private var isSet: Bool { temperatureCelsius != 999 }
    private var display: String {
        isSet ? String(format: "%.0f°C", temperatureCelsius) : "optional"
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title).foregroundColor(.primary)
                Spacer()
                Text(display).foregroundColor(isSet ? .primary : .secondary)
                Image(systemName: "chevron.right").foregroundColor(.secondary).font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}
