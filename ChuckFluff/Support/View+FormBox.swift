import SwiftUI

extension View {
    /// Standard horizontal/vertical padding used around each `GroupBox` in the session forms.
    func formBoxPadding(top: CGFloat = 12, bottom: CGFloat = 0) -> some View {
        self
            .padding(.horizontal)
            .padding(.top, top)
            .padding(.bottom, bottom)
    }
}
