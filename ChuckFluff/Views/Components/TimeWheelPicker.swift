import SwiftUI

struct TimeWheelPicker: View {
    let label: String
    @Binding var selection: Date

    var hours: [Int] { Array(0...23) }
    var minutes: [Int] { [0, 15, 30, 45] }

    var selectedHour: Int {
        Calendar.current.component(.hour, from: selection)
    }
    var selectedMinute: Int {
        let m = Calendar.current.component(.minute, from: selection)
        return [0, 15, 30, 45].min(by: { abs($0 - m) < abs($1 - m) }) ?? 0
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 0) {
                Picker("Hour", selection: Binding(
                    get: { selectedHour },
                    set: { newHour in
                        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selection)
                        comps.hour = newHour
                        if let d = Calendar.current.date(from: comps) { selection = d }
                    }
                )) {
                    ForEach(hours, id: \.self) { h in
                        Text(String(format: "%02d", h)).tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
                .clipped()

                Text(":").font(.headline)

                Picker("Minute", selection: Binding(
                    get: { selectedMinute },
                    set: { newMin in
                        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selection)
                        comps.minute = newMin
                        if let d = Calendar.current.date(from: comps) { selection = d }
                    }
                )) {
                    ForEach(minutes, id: \.self) { m in
                        Text(String(format: "%02d", m)).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
                .clipped()
            }
            .frame(height: 100)
        }
    }
}
