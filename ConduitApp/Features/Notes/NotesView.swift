import SwiftUI
import Observation

@Observable
final class NotesViewModel {
    var notes: [NoteItem] = []
    var error = ""

    func load(settings: AppSettingsStore) async {
        do {
            notes = try await OpenWebUIAPI(settings: settings).fetchNotes()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct NotesView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Environment(\.vibeTheme) private var theme
    @State private var vm = NotesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.notes) { note in
                        VibeCard(theme: theme) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(note.title ?? "Untitled")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(theme.textPrimary)

                                if let content = note.content {
                                    Text(content)
                                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                                        .foregroundStyle(theme.textSecondary)
                                        .lineLimit(4)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(theme.background.ignoresSafeArea())
            .overlay {
                if vm.notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text(vm.error.isEmpty ? "Notes endpoint may be empty or disabled." : vm.error)
                    )
                    .foregroundStyle(theme.textSecondary)
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.load(settings: settings) }
            .refreshable { await vm.load(settings: settings) }
        }
    }
}
