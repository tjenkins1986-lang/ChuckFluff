import SwiftUI
import SwiftData

@main
struct ChuckFluffApp: App {
    init() {
        configureLedgerAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [FishingSession.self, CatchEntry.self, UserConfig.self])
                .preferredColorScheme(.dark)
                .tint(.ledgerBrass)
                .groupBoxStyle(LedgerGroupBoxStyle())
        }
    }

    /// Ledger is single-theme by design (dark only), so the UIKit chrome that
    /// SwiftUI doesn't expose color overrides for — table view backgrounds,
    /// nav bar / tab bar backgrounds — is set once here rather than per screen.
    private func configureLedgerAppearance() {
        let ink = UIColor(Color.ledgerInk)
        let inkSurface = UIColor(Color.ledgerInkSurface)
        let textHi = UIColor(Color.ledgerTextHi)

        UITableView.appearance().backgroundColor = ink
        UITableViewCell.appearance().backgroundColor = inkSurface

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = ink
        navBarAppearance.titleTextAttributes = [.foregroundColor: textHi]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: textHi]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = ink
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
