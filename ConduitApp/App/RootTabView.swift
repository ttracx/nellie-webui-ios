import SwiftUI

struct RootTabView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.accessibilityContrast) private var accessibilityContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var theme: VibeTheme {
        VibeTheme.resolve(
            preference: settings.themePreference,
            systemColorScheme: systemColorScheme,
            increasedContrast: accessibilityContrast == .high
        )
    }

    var body: some View {
        TabView {
            ChatView()
                .tabItem { Label("Chat", systemImage: "message") }

            MemoriesView()
                .tabItem { Label("Memories", systemImage: "brain") }

            NotesView()
                .tabItem { Label("Notes", systemImage: "note.text") }

            ToolsView()
                .tabItem { Label("Tools", systemImage: "wrench.and.screwdriver") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .environment(\.vibeTheme, theme)
        .preferredColorScheme(theme.preferredColorScheme)
        .tint(theme.primary)
        .background(theme.background)
        .animation(.easeInOut(duration: reduceMotion ? 0.01 : theme.baseAnimationDuration), value: settings.themePreferenceRawValue)
    }
}
