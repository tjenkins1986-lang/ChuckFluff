import SwiftUI

struct SessionRowView: View {
    let session: FishingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if !session.sessionName.isEmpty {
                        Text(session.sessionName).font(.headline)
                    }
                    Text(session.locationName.isEmpty ? "Unknown Location" : session.locationName)
                        .font(session.sessionName.isEmpty ? .headline : .subheadline)
                        .foregroundColor(session.sessionName.isEmpty ? .primary : .secondary)
                }
                Spacer()
                Text(session.date, style: .date).font(.subheadline).foregroundColor(.secondary)
            }
            HStack(spacing: 16) {
                Label("\(session.totalFish) fish", systemImage: "fish.fill")
                    .font(.caption).foregroundColor(.blue)
                Label(String(format: "%.1f lb", session.totalWeight), systemImage: "scalemass.fill")
                    .font(.caption).foregroundColor(.green)
                Label(session.weatherCondition, systemImage: "cloud.sun.fill")
                    .font(.caption).foregroundColor(.orange)
            }
            if !session.notes.isEmpty {
                Text(session.notes).font(.caption).foregroundColor(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
