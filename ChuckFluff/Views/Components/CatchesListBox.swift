import SwiftUI

/// Editable list of draft catches, shared by NewSessionView and EditSessionView.
struct CatchesListBox: View {
    @Binding var catches: [DraftCatch]
    @Binding var showAddCatch: Bool
    var emptyMessage: String = "No catches added yet"

    var body: some View {
        GroupBox(label: Label("Catches", systemImage: "fish.fill")) {
            VStack(spacing: 8) {
                if catches.isEmpty {
                    HStack {
                        Text(emptyMessage).foregroundColor(.ledgerTextLow)
                        Spacer()
                    }
                    .padding(.top, 4)
                } else {
                    ForEach(catches.indices, id: \.self) { i in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(catches[i].species).bold().foregroundColor(.ledgerTextHi)
                                Text(catchSummary(for: catches[i]))
                                    .font(.ledgerMono(12)).foregroundColor(.ledgerTextMid)
                                if !catches[i].method.isEmpty {
                                    Text("Method: \(catches[i].method)")
                                        .font(.caption).foregroundColor(.ledgerTextMid)
                                }
                            }
                            Spacer()
                            Button(action: { catches.remove(at: i) }) {
                                Image(systemName: "trash").foregroundColor(.ledgerClay)
                            }
                        }
                        .padding(.vertical, 4)
                        if i < catches.count - 1 { Divider().overlay(Color.ledgerLine) }
                    }
                }
                Divider().overlay(Color.ledgerLine)
                Button(action: { showAddCatch = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundColor(.ledgerBrass)
                        Text("Add Catch").foregroundColor(.ledgerBrass)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.top, 8)
        }
        .formBoxPadding()
    }

    private func catchSummary(for catch_: DraftCatch) -> String {
        var summary = "\(catch_.quantity) fish · \(String(format: "%.1f", catch_.weightLb)) lb each"
        if catch_.lengthInches != 0 {
            summary += " · \(String(format: "%.1f", catch_.lengthInches)) in"
        }
        return summary
    }
}
