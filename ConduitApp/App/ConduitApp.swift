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
                .tint(Color(red: 109 / 255, green: 74 / 255, blue: 1.0))
        }
    }
}
