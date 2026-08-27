import SwiftUI

/// Date/start-time/end-time/duration block inside the Session Details box, shared by
/// NewSessionView and EditSessionView. `duration` and `isNextDay` are computed by the
/// caller (each form also needs them when saving, not just for display here).
struct SessionTimingFields: View {
    @Binding var date: Date
    @Binding var startTime: Date
    @Binding var endTime: Date
    let duration: Double
    let isNextDay: Bool

    var body: some View {
        Group {
            Divider()
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .padding(.vertical, 4)
            Divider()
            TimeWheelPicker(label: "Start Time", selection: $startTime)
            Divider()
            TimeWheelPicker(label: "End Time", selection: $endTime)
            Divider()
            HStack {
                Text("Duration")
                Spacer()
                Text(String(format: "%.1f hrs", duration))
                    .foregroundColor(.ledgerTextMid)
            }
            if isNextDay {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.ledgerClay)
                        .font(.caption)
                    Text("Looks like you fished past midnight — we've assumed the end time is the following day. Please check these details are correct.")
                        .font(.caption)
                        .foregroundColor(.ledgerClay)
                }
                .padding(.top, 2)
            }
        }
    }
}
