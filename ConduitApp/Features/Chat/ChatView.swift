import SwiftUI
import Observation
import PhotosUI

struct ChatBubble: Identifiable {
    let id = UUID()
    let role: String
    var content: String
}

@Observable
final class ChatViewModel {
    var bubbles: [ChatBubble] = []
    var input = ""
    var isSending = false
    var errorMessage = ""
    var availableModels: [String] = []
    var selectedImageData: Data?
    var selectedImagePreview: UIImage?

    func loadModels(settings: AppSettingsStore, auth: AuthSessionStore) async {
        do {
            let api = OpenWebUIAPI(settings: settings, auth: auth)
            let models = try await api.fetchModels()
            await MainActor.run {
                self.availableModels = models
                if settings.selectedModel.isEmpty, let first = models.first {
                    settings.selectedModel = first
                }
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }

    func setImage(item: PhotosPickerItem?) async {
        guard let item else {
            selectedImageData = nil
            selectedImagePreview = nil
            return
        }
        if let data = try? await item.loadTransferable(type: Data.self) {
            selectedImageData = data
            selectedImagePreview = UIImage(data: data)
        }
    }

    func send(settings: AppSettingsStore, auth: AuthSessionStore) async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || selectedImageData != nil else { return }
        guard !settings.selectedModel.isEmpty else {
            errorMessage = "Pick a model in Settings or from the model picker."
            return
        }

        isSending = true
        errorMessage = ""

        let userPreview = text.isEmpty ? "[Image]" : text
        bubbles.append(ChatBubble(role: "user", content: userPreview))
        input = ""

        do {
            let api = OpenWebUIAPI(settings: settings, auth: auth)

            var parts: [ContentPart] = []
            if !text.isEmpty { parts.append(.text(text)) }
            if let data = selectedImageData {
                let uploaded = try await api.uploadAttachment(filename: "photo.jpg", mimeType: "image/jpeg", data: data)
                if let url = uploaded.url {
                    parts.append(.image(url: url))
                }
            }

            selectedImageData = nil
            selectedImagePreview = nil

            let history = bubbles.map { bubble in
                OutboundMessage(role: bubble.role, content: .text(bubble.content))
            }
            let pending = OutboundMessage(role: "user", content: parts.isEmpty ? .text(text) : .parts(parts))

            bubbles.append(ChatBubble(role: "assistant", content: ""))
            let assistantIndex = bubbles.count - 1

            try await api.streamChat(messages: history + [pending], model: settings.selectedModel) { [weak self] delta in
                guard let self else { return }
                self.bubbles[assistantIndex].content += delta
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSending = false
    }
}

struct ChatView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Environment(AuthSessionStore.self) private var auth
    @State private var vm = ChatViewModel()
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if !vm.availableModels.isEmpty {
                    Picker("Model", selection: $settings.selectedModel) {
                        ForEach(vm.availableModels, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(vm.bubbles) { msg in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(msg.role.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(msg.content.isEmpty && msg.role == "assistant" ? "Thinking..." : msg.content)
                                    .padding(10)
                                    .background(msg.role == "assistant" ? Color.blue.opacity(0.12) : Color.gray.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let preview = vm.selectedImagePreview {
                    HStack {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 54, height: 54)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Image attached")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Remove") {
                            vm.selectedImageData = nil
                            vm.selectedImagePreview = nil
                            pickerItem = nil
                        }
                        .font(.footnote)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack(spacing: 8) {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Image(systemName: "photo")
                            .font(.title3)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.bordered)
                    .onChange(of: pickerItem) { _, newValue in
                        Task { await vm.setImage(item: newValue) }
                    }

                    TextField("Message", text: $vm.input, axis: .vertical)
                        .textFieldStyle(.roundedBorder)

                    Button(vm.isSending ? "..." : "Send") {
                        Task { await vm.send(settings: settings, auth: auth) }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isSending)
                }

                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .navigationTitle("Chat")
            .task { await vm.loadModels(settings: settings, auth: auth) }
        }
    }
}
