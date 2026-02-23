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
    @Environment(\.vibeTheme) private var theme
    @State private var vm = MemoriesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.items) { item in
                        VibeCard(theme: theme) {
                            Text(item.content ?? "(empty)")
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .foregroundStyle(theme.textPrimary)
                        }
                    }
                }
                .padding()
            }
            .background(theme.background.ignoresSafeArea())
            .overlay {
                if vm.items.isEmpty {
                    ContentUnavailableView(
                        "No Memories",
                        systemImage: "brain",
                        description: Text(vm.error.isEmpty ? "Memory endpoint may be empty or disabled." : vm.error)
                    )
                    .foregroundStyle(theme.textSecondary)
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.load(settings: settings) }
            .refreshable { await vm.load(settings: settings) }
        }
    }
}
