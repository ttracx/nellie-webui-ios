import SwiftUI
import Observation

@Observable
final class MemoriesViewModel {
    var items: [MemoryItem] = []
    var error = ""

    func load(settings: AppSettingsStore) async {
        do {
            items = try await OpenWebUIAPI(settings: settings).fetchMemories()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct MemoriesView: View {
    @Environment(AppSettingsStore.self) private var settings
    @State private var vm = MemoriesViewModel()

    var body: some View {
        NavigationStack {
            List(vm.items) { item in
                Text(item.content ?? "(empty)")
            }
            .overlay {
                if vm.items.isEmpty {
                    ContentUnavailableView("No Memories", systemImage: "brain", description: Text(vm.error.isEmpty ? "Memory endpoint may be empty or disabled." : vm.error))
                }
            }
            .navigationTitle("Memories")
            .task { await vm.load(settings: settings) }
            .refreshable { await vm.load(settings: settings) }
        }
    }
}
