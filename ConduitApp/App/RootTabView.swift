import SwiftUI

struct RootTabView: View {
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
    }
}
