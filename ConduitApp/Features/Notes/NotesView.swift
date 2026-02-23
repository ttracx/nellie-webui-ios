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
    @State private var vm = NotesViewModel()

    var body: some View {
        NavigationStack {
            List(vm.notes) { note in
                VStack(alignment: .leading, spacing: 6) {
                    Text(note.title ?? "Untitled")
                        .font(.headline)
                    if let content = note.content {
                        Text(content)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
                .padding(.vertical, 4)
            }
            .overlay {
                if vm.notes.isEmpty {
                    ContentUnavailableView("No Notes", systemImage: "note.text", description: Text(vm.error.isEmpty ? "Notes endpoint may be empty or disabled." : vm.error))
                }
            }
            .navigationTitle("Notes")
            .task { await vm.load(settings: settings) }
            .refreshable { await vm.load(settings: settings) }
        }
    }
}
