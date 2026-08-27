import SwiftUI

struct MapSessionSummaryView: View {
    let session: FishingSession
    @Environment(\.dismiss) private var dismiss

    var navTitle: String {
        if !session.sessionName.isEmpty { return session.sessionName }
        if !session.locationName.isEmpty { return session.locationName }
        return "Session Detail"
    }

    var body: some View {
        NavigationStack {
            Form {
                if !session.sessionName.isEmpty {
                    Section {
                        Text(session.sessionName)
                            .font(.ledgerDisplay(22))
                            .foregroundColor(.ledgerTextHi)
                    }
                    .listRowBackground(Color.ledgerInkSurface)
                }
                SessionDetailsSection(session: session, showCoordinates: false)
                SessionConditionsSection(session: session)
                SessionGearSection(session: session)
                SessionCatchesSection(session: session)
                if !session.notes.isEmpty {
                    Section("Notes") { Text(session.notes).foregroundColor(.ledgerTextMid) }
                        .listRowBackground(Color.ledgerInkSurface)
                }
            }
            .scrollContentBackground(.hidden)
            .ledgerScreenBackground()
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
