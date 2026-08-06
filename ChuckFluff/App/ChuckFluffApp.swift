import SwiftUI
import SwiftData

@main
struct ChuckFluffApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [FishingSession.self, CatchEntry.self, UserConfig.self])
        }
    }
}
