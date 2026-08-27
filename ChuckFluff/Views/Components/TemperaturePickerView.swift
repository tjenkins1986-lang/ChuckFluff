import SwiftUI

struct TemperaturePickerView: View {
    let title: String
    @Binding var temperatureCelsius: Double
    @Environment(\.dismiss) private var dismiss

    var temps: [Int] { Array(-15...40) }

    var selectedTemp: Int {
        temperatureCelsius == 999 ? 10 : Int(temperatureCelsius)
    }

    @State private var pickerSelection: Int = 10

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Temperature", selection: $pickerSelection) {
                    ForEach(temps, id: \.self) { t in
                        Text("\(t)°C").tag(t)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: 200)
                Spacer()
            }
            .padding(.top, 24)
            .ledgerScreenBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        temperatureCelsius = 999
                        dismiss()
                    }
                    .foregroundColor(.ledgerClay)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        temperatureCelsius = Double(pickerSelection)
                        dismiss()
                    }
                }
            }
            .onAppear {
                pickerSelection = selectedTemp
            }
        }
    }
}
