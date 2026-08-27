import SwiftUI
import UIKit

struct SessionDetailView: View {
    let session: FishingSession
    @State private var selectedPhotoIndex: Int? = nil
    @State private var showEdit = false

    var photosSection: some View {
        Group {
            if !session.photoData.isEmpty {
                Section("Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(session.photoData.indices, id: \.self) { i in
                                if let uiImage = UIImage(data: session.photoData[i]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: LedgerMetric.radiusCard))
                                        .onTapGesture { selectedPhotoIndex = i }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(Color.ledgerInkSurface)
            }
        }
    }

    var navTitle: String {
        if !session.sessionName.isEmpty { return session.sessionName }
        if !session.locationName.isEmpty { return session.locationName }
        return "Session Detail"
    }

    var body: some View {
        Form {
            if !session.sessionName.isEmpty {
                Section {
                    Text(session.sessionName)
                        .font(.ledgerDisplay(22))
                        .foregroundColor(.ledgerTextHi)
                }
                .listRowBackground(Color.ledgerInkSurface)
            }
            photosSection
            SessionDetailsSection(session: session)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEdit = true }
            }
        }
        .sheet(item: $selectedPhotoIndex) { index in
            if let uiImage = UIImage(data: session.photoData[index]) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditSessionView(session: session)
        }
    }
}
