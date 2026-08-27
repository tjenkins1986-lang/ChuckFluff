import SwiftUI

/// Design tokens for the "Ledger" theme — a dark, brass-accented, ruled-page
/// aesthetic. Fonts approximate the reference system's Fraunces/IBM Plex Mono
/// with the closest built-in system faces (New York serif, SF Mono) rather
/// than embedding custom font files.
extension Color {
    init(ledgerHex hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    // Ground & surface — three ink steps instead of a neutral grey ramp.
    static let ledgerInk = Color(ledgerHex: 0x152029)
    static let ledgerInkSurface = Color(ledgerHex: 0x1E2C38)
    static let ledgerInkRaised = Color(ledgerHex: 0x263847)

    // Accent — brass is the only saturated color allowed to carry emphasis.
    static let ledgerBrass = Color(ledgerHex: 0xC9A227)

    // Verdict pair — sage/clay are semantic (positive/negative), never decorative.
    static let ledgerSage = Color(ledgerHex: 0x7C9473)
    static let ledgerClay = Color(ledgerHex: 0xA6462D)

    // Text — an opacity ramp on parchment (#F6F1E4), not flat greys.
    static let ledgerTextHi = Color(ledgerHex: 0xF6F1E4)
    static let ledgerTextMid = Color(ledgerHex: 0xF6F1E4, alpha: 0.68)
    static let ledgerTextLow = Color(ledgerHex: 0xF6F1E4, alpha: 0.42)

    // Hairlines — structure comes from these, not shadows or heavy borders.
    static let ledgerLine = Color(ledgerHex: 0xF1E8D6, alpha: 0.14)
    static let ledgerLineStrong = Color(ledgerHex: 0xF1E8D6, alpha: 0.28)
}

extension Font {
    /// Display & figures — approximates Fraunces with the system serif (New York).
    static func ledgerDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }
    /// Labels & data, uppercase eyebrows, table figures — approximates IBM Plex
    /// Mono with SF Mono.
    static func ledgerMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

enum LedgerMetric {
    static let radiusDot: CGFloat = 2
    static let radiusCard: CGFloat = 4
}

extension View {
    /// Full-bleed ink page background for a screen's root container.
    func ledgerScreenBackground() -> some View {
        self.background(Color.ledgerInk.ignoresSafeArea())
    }

    /// A flush ink-surface tile with a hairline border — the "ruled, not
    /// boxed" card replacement used in place of shadowed white cards.
    func ledgerTile(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.ledgerInkSurface)
            .overlay(
                RoundedRectangle(cornerRadius: LedgerMetric.radiusCard)
                    .stroke(Color.ledgerLineStrong, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: LedgerMetric.radiusCard))
    }
}
