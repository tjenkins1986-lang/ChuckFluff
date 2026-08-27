import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case mostFish = "Most Fish"
    case heaviest = "Heaviest Catch"
}

struct HistoryView: View {
    @Query private var allSessions: [FishingSession]
    @Environment(\.modelContext) private var modelContext
    @State private var sortOption: SortOption = .dateNewest

    var sortedSessions: [FishingSession] {
        switch sortOption {
        case .dateNewest:
            return allSessions.sorted { $0.date > $1.date }
        case .dateOldest:
            return allSessions.sorted { $0.date < $1.date }
        case .mostFish:
            return allSessions.sorted { $0.totalFish > $1.totalFish }
        case .heaviest:
            return allSessions.sorted { $0.totalWeight > $1.totalWeight }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if allSessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "fish",
                        description: Text("Your logged fishing sessions will appear here.")
                    )
                } else {
                    List {
                        ForEach(sortedSessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionRowView(session: session)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .ledgerScreenBackground()
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
        }
    }

    func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedSessions[index])
        }
    }
}
