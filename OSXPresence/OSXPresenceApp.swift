import SwiftUI

@main
struct OSXPresenceApp: App {
    @StateObject private var presenceManager = PresenceManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(presenceManager)
        } label: {
            Image(systemName: presenceManager.isConnected ? "house.fill" : "house.badge.exclamationmark.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
