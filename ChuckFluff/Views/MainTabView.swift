import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NewSessionView()
                .tabItem { Label("New Session", systemImage: "plus.circle.fill") }
            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet") }
            SessionMapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }
            SettingsHelpView()
                .tabItem { Label("Settings & Help", systemImage: "gearshape.fill") }
        }
    }
}
