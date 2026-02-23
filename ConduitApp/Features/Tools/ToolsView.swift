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
    @Environment(\.vibeTheme) private var theme
    @State private var vm = ToolsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.items) { tool in
                        VibeCard(theme: theme) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(tool.name ?? tool.id)
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(theme.textPrimary)
                                if let description = tool.description {
                                    Text(description)
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
                if vm.items.isEmpty {
                    ContentUnavailableView(
                        "No Tools",
                        systemImage: "wrench.and.screwdriver",
                        description: Text(vm.error.isEmpty ? "Tools/Functions endpoint may be disabled." : vm.error)
                    )
                    .foregroundStyle(theme.textSecondary)
                }
            }
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.load(settings: settings) }
            .refreshable { await vm.load(settings: settings) }
        }
    }
}
