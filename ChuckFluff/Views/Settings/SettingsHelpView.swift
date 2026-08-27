import SwiftUI
import SwiftData

struct SettingsHelpView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [UserConfig]

    @State private var showAddSpecies = false
    @State private var showAddRod = false
    @State private var showAddReel = false
    @State private var expandedHowTo: String? = nil
    @State private var showPrivacy = false

    var config: UserConfig? { configs.first }

    let howToItems: [(title: String, body: String)] = [
        (
            "How do I log a new session?",
            "Tap the New Session tab at the bottom of the screen. Fill in the session details — name, date, start and end time. Add your location by typing a name and optionally dropping a pin on the map or using your current GPS location. Fill in weather and gear details as desired, add your catches, attach photos, and add a note if needed. Tap Save when done."
        ),
        (
            "How do I add a catch?",
            "In the New Session or Edit Session screen, tap Add Catch in the Catches section. Select the species from your configured list, set the quantity, then tap Next to enter the weight and method for each fish individually. Tap Add to save the catch to your session."
        ),
        (
            "How do I pin my location?",
            "In the Location section of a new or edited session, tap Drop a pin on the map. The map will open centred on your current location. Pan and zoom to your fishing spot, then tap Drop Pin Here to place a pin. Tap Confirm to save the location to your session."
        ),
        (
            "How do I add gear?",
            "Go to the Settings & Help tab and scroll to the Rods or Reels section. Tap Add Rod or Add Reel, type the name, and tap Add. These will then appear as options in the Gear section when logging a new session."
        ),
        (
            "How do I edit a past session?",
            "Tap the History tab, find the session you want to edit, and tap it to open the detail view. Tap Edit in the top right corner. All fields are editable including catches, photos, gear, and notes. Tap Save when done."
        ),
        (
            "How do I add species, rods and reels?",
            "Go to the Settings & Help tab. Under Target Species tap Add Species, type a name and tap Add. Do the same under Rods and Reels. To remove an item, swipe left on it. Species appear as options when logging catches. Rods and reels appear when logging a session."
        ),
        (
            "What does the Dashboard show?",
            "The Dashboard gives you a summary of all your fishing activity. It shows your total sessions, fish caught, and total weight landed. The Catches Over Time chart shows your catch history across the last 12 months. Species Breakdown shows which species you catch most. My Records shows your personal best weight for each species. My Favourite Method shows the method you use most frequently per species."
        ),
        (
            "Why does the app ask for location permission?",
            "Location permission is used solely to centre the map on your current position when pinning a fishing spot. Your location is never transmitted or stored outside your device."
        ),
        (
            "Why does the app ask for photo permission?",
            "Photo permission is used to allow you to attach images from your photo library to fishing sessions. Photos are stored locally on your device only."
        )
    ]

    var settingsSection: some View {
        Group {
            EditableListSection(
                header: "Target Species",
                footer: "These appear as options when logging a catch.",
                items: config?.speciesList ?? [],
                addButtonLabel: "Add Species",
                onDelete: { offsets in
                    guard let config = config else { return }
                    var updated = config.speciesList
                    updated.remove(atOffsets: offsets)
                    config.speciesList = updated
                },
                onAddTapped: { showAddSpecies = true }
            )
            EditableListSection(
                header: "Rods",
                footer: "These appear as options when logging a session.",
                items: config?.rodList ?? [],
                addButtonLabel: "Add Rod",
                onDelete: { offsets in
                    guard let config = config else { return }
                    var updated = config.rodList
                    updated.remove(atOffsets: offsets)
                    config.rodList = updated
                },
                onAddTapped: { showAddRod = true }
            )
            EditableListSection(
                header: "Reels",
                footer: "These appear as options when logging a session.",
                items: config?.reelList ?? [],
                addButtonLabel: "Add Reel",
                onDelete: { offsets in
                    guard let config = config else { return }
                    var updated = config.reelList
                    updated.remove(atOffsets: offsets)
                    config.reelList = updated
                },
                onAddTapped: { showAddReel = true }
            )
        }
    }

    private func ledgerHeader(_ title: String) -> some View {
        Text(title)
            .font(.ledgerMono(10.5, weight: .medium))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundColor(.ledgerTextLow)
    }

    var howToSection: some View {
        Section(header: ledgerHeader("How To")) {
            ForEach(howToItems, id: \.title) { item in
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation {
                            expandedHowTo = expandedHowTo == item.title ? nil : item.title
                        }
                    }) {
                        HStack {
                            Text(item.title)
                                .foregroundColor(.ledgerTextHi)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: expandedHowTo == item.title ? "chevron.up" : "chevron.down")
                                .foregroundColor(.ledgerTextLow)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)

                    if expandedHowTo == item.title {
                        Text(item.body)
                            .font(.subheadline)
                            .foregroundColor(.ledgerTextMid)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .listRowBackground(Color.ledgerInkSurface)
    }

    var privacySection: some View {
        Section(header: ledgerHeader("Privacy")) {
            Button(action: { withAnimation { showPrivacy.toggle() } }) {
                HStack {
                    Text("Privacy Policy")
                        .foregroundColor(.ledgerTextHi)
                    Spacer()
                    Image(systemName: showPrivacy ? "chevron.up" : "chevron.down")
                        .foregroundColor(.ledgerTextLow)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            if showPrivacy {
                Text(privacyPolicyText)
                    .font(.subheadline)
                    .foregroundColor(.ledgerTextMid)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .listRowBackground(Color.ledgerInkSurface)
    }

    var body: some View {
        NavigationStack {
            Form {
                settingsSection
                howToSection
                privacySection
            }
            .scrollContentBackground(.hidden)
            .ledgerScreenBackground()
            .navigationTitle("Settings & Help")
            .onAppear { ensureConfig() }
            .sheet(isPresented: $showAddSpecies) {
                AddItemSheet(
                    title: "Add Species",
                    placeholder: "e.g. Brown Trout",
                    isPresented: $showAddSpecies
                ) { name in
                    addItem(name: name, to: \.speciesList)
                }
                .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showAddRod) {
                AddItemSheet(
                    title: "Add Rod",
                    placeholder: "e.g. Hardy Sovereign 10ft #6",
                    isPresented: $showAddRod
                ) { name in
                    addItem(name: name, to: \.rodList)
                }
                .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showAddReel) {
                AddItemSheet(
                    title: "Add Reel",
                    placeholder: "e.g. Hardy Ultralite MTX-S",
                    isPresented: $showAddReel
                ) { name in
                    addItem(name: name, to: \.reelList)
                }
                .presentationDetents([.height(200)])
            }
        }
    }

    func ensureConfig() {
        if configs.isEmpty {
            let newConfig = UserConfig()
            modelContext.insert(newConfig)
            try? modelContext.save()
        }
    }

    func addItem(name: String, to keyPath: ReferenceWritableKeyPath<UserConfig, [String]>) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let descriptor = FetchDescriptor<UserConfig>()
        guard let freshConfig = try? modelContext.fetch(descriptor).first else { return }
        guard !freshConfig[keyPath: keyPath].contains(trimmed) else { return }
        freshConfig[keyPath: keyPath].append(trimmed)
        try? modelContext.save()
    }

    let privacyPolicyText = """
    Last updated: March 2026

    Chuck Fluff does not collect, transmit, store remotely, or share any personal data. All information you enter into the app — including session details, catch records, photos, and location data — is stored exclusively on your device using Apple's SwiftData framework.

    Location Permission
    The app requests access to your device's location solely to allow you to pin fishing spots on an in-app map. Your location is never transmitted to any server or shared with any third party.

    Photos Permission
    The app requests access to your photo library solely to allow you to attach images to fishing sessions. Photos are stored locally on your device only and are never transmitted or shared.

    Third Party Services
    Chuck Fluff does not use any third party analytics, advertising, or data collection services.

    Data Storage
    All app data is stored locally on your device. We recommend enabling iCloud device backup to protect your data against device loss.

    Contact
    If you have any questions about this privacy policy please open an issue at github.com/[yourusername]/chuck-fluff.
    """
}
