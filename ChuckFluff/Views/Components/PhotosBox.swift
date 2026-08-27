import SwiftUI
import PhotosUI
import UIKit

/// Photo picker + thumbnail strip, shared by NewSessionView and EditSessionView.
struct PhotosBox: View {
    @Binding var photoData: [Data]
    @Binding var selectedPhotos: [PhotosPickerItem]
    var title: String = "Photos"

    var body: some View {
        GroupBox(label: Label(title, systemImage: "photo.on.rectangle")) {
            VStack(alignment: .leading, spacing: 12) {
                if !photoData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(photoData.indices, id: \.self) { i in
                                if let uiImage = UIImage(data: photoData[i]) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: LedgerMetric.radiusCard))
                                        Button(action: { photoData.remove(at: i) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                PhotosPicker(selection: $selectedPhotos,
                             maxSelectionCount: 10,
                             matching: .images) {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundColor(.ledgerBrass)
                        Text(photoData.isEmpty ? "Add Photos" : "Add More Photos")
                            .foregroundColor(.ledgerBrass)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
        }
        .formBoxPadding()
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        photoData.append(data)
                    }
                }
                selectedPhotos = []
            }
        }
    }
}
