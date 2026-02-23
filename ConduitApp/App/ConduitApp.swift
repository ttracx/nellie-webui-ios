import SwiftUI

@main
struct ConduitApp: App {
    @State private var settings = AppSettingsStore()
    @State private var session = AuthSessionStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(settings)
                .environment(session)
                .tint(.accentColor)
        }
    }
}
