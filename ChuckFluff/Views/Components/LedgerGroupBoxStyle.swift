import SwiftUI

/// Renders every `GroupBox` in the app as a flush ink-surface tile with a
/// hairline border and a small mono uppercase label — matching the Ledger
/// design system's "Tile" component. Applied once at the app root so no
/// individual call site needs to change.
struct LedgerGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.ledgerMono(10, weight: .medium))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundColor(.ledgerTextLow)
            configuration.content
        }
        .padding(16)
        .background(Color.ledgerInkSurface)
        .overlay(
            RoundedRectangle(cornerRadius: LedgerMetric.radiusCard)
                .stroke(Color.ledgerLineStrong, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: LedgerMetric.radiusCard))
    }
}
