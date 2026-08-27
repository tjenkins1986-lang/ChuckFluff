import SwiftUI

struct SessionRowView: View {
    let session: FishingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if !session.sessionName.isEmpty {
                        Text(session.sessionName).font(.headline).foregroundColor(.ledgerTextHi)
                    }
                    Text(session.locationName.isEmpty ? "Unknown Location" : session.locationName)
                        .font(session.sessionName.isEmpty ? .headline : .subheadline)
                        .foregroundColor(session.sessionName.isEmpty ? .ledgerTextHi : .ledgerTextMid)
                }
                Spacer()
                Text(session.date, style: .date)
                    .font(.ledgerMono(12))
                    .foregroundColor(.ledgerTextLow)
            }
            HStack(spacing: 16) {
                Label("\(session.totalFish) fish", systemImage: "fish.fill")
                    .font(.caption).foregroundColor(.ledgerTextMid)
                Label(String(format: "%.1f lb", session.totalWeight), systemImage: "scalemass.fill")
                    .font(.caption).foregroundColor(.ledgerTextMid)
                Label(session.weatherCondition, systemImage: "cloud.sun.fill")
                    .font(.caption).foregroundColor(.ledgerTextMid)
            }
            if !session.notes.isEmpty {
                Text(session.notes).font(.caption).foregroundColor(.ledgerTextLow).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.ledgerInkSurface)
    }
}
