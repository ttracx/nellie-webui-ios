import SwiftUI
import Observation

@Observable
final class ToolsViewModel {
    var items: [ToolItem] = []
    var error = ""

    func load(settings: AppSettingsStore) async {
        do {
            items = try await OpenWebUIAPI(settings: settings).fetchTools()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct ToolsView: View {
    @Environment(AppSettingsStore.self) private var settings
    @State private var vm = ToolsViewModel()

    var body: some View {
        NavigationStack {
            List(vm.items) { tool in
                VStack(alignment: .leading, spacing: 5) {
                    Text(tool.name ?? tool.id)
                        .font(.headline)
                    if let description = tool.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
                .padding(.vertical, 3)
            }
            .overlay {
                if vm.items.isEmpty {
                    ContentUnavailableView("No Tools", systemImage: "wrench.and.screwdriver", description: Text(vm.error.isEmpty ? "Tools/Functions endpoint may be disabled." : vm.error))
                }
            }
            .navigationTitle("Tools")
            .task { await vm.load(settings: settings) }
            .refreshable { await vm.load(settings: settings) }
        }
    }
}
