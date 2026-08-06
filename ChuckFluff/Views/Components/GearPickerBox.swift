import SwiftUI

/// Rod/reel pickers, identical in NewSessionView and EditSessionView.
struct GearPickerBox: View {
    @Binding var rodUsed: String
    @Binding var reelUsed: String
    let rodList: [String]
    let reelList: [String]

    var body: some View {
        GroupBox(label: Label("Gear (Optional)", systemImage: "case.fill")) {
            VStack(spacing: 12) {
                HStack {
                    Text("Rod")
                    Spacer()
                    Picker("Rod", selection: $rodUsed) {
                        Text("–").tag("")
                        ForEach(rodList, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                }
                Divider()
                HStack {
                    Text("Reel")
                    Spacer()
                    Picker("Reel", selection: $reelUsed) {
                        Text("–").tag("")
                        ForEach(reelList, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.top, 8)
        }
        .formBoxPadding()
    }
}
