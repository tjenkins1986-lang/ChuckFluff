import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundColor(.ledgerBrass)
            Text(value).font(.ledgerDisplay(20)).foregroundColor(.ledgerTextHi)
            Text(title).font(.ledgerMono(10, weight: .medium))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundColor(.ledgerTextLow)
        }
        .frame(maxWidth: .infinity)
        .ledgerTile(padding: 14)
    }
}
