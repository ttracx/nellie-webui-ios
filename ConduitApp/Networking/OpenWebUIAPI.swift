import Foundation

enum APIError: Error, LocalizedError {
    case badBaseURL
    case invalidResponse
    case server(Int, String)
    case missingToken

    var errorDescription: String? {
        switch self {
        case .badBaseURL: return "Invalid base URL"
        case .invalidResponse: return "Invalid server response"
        case let .server(code, msg): return "Server error \(code): \(msg)"
        case .missingToken: return "No auth token returned by server"
        }
    }
}

struct OpenWebUIAPI {
    private let settings: AppSettingsStore
    private let auth: AuthSessionStore
    private let session: URLSession

    init(settings: AppSettingsStore, auth: AuthSessionStore, session: URLSession = .shared) {
        self.settings = settings
        self.auth = auth
        self.session = session
    }

    func signIn(email: String, password: String) async throws -> String {
        let payload = SignInRequest(email: email, password: password)
        let response: SignInResponse = try await request(path: "/api/v1/auths/signin", method: "POST", body: payload)
        if let token = response.token ?? response.access_token ?? response.accessToken {
            return token
        }
        throw APIError.missingToken
    }

    func fetchModels() async throws -> [String] {
        let response: ModelsResponse = try await request(path: "/api/models", method: "GET")
        return response.data.map { $0.id }
    }

    func uploadAttachment(filename: String, mimeType: String, data: Data) async throws -> UploadedFile {
        try await firstSuccess([
            { try await multipartUpload(path: "/api/v1/files/", filename: filename, mimeType: mimeType, data: data) },
            { try await multipartUpload(path: "/api/v1/files", filename: filename, mimeType: mimeType, data: data) }
        ])
    }

    func streamChat(messages: [OutboundMessage], model: String, onDelta: @escaping @MainActor (String) -> Void) async throws {
        let payload = ChatCompletionRequest(model: model, messages: messages, stream: true)
        var req = try makeRequest(path: "/api/chat/completions", method: "POST", body: payload)
        req.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        let (bytes, response) = try await session.bytes(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.server(http.statusCode, "Streaming request failed")
        }

        for try await line in bytes.lines {
            guard line.hasPrefix("data:") else { continue }
            let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
            if payload == "[DONE]" { break }
            guard let data = payload.data(using: .utf8) else { continue }
            if let chunk = try? JSONDecoder().decode(ChatStreamChunk.self, from: data),
               let delta = chunk.choices.first?.delta.content,
               !delta.isEmpty {
                await onDelta(delta)
            }
        }
    }

    func fetchNotes() async throws -> [NoteItem] {
        try await firstSuccess([
            { try await request(path: "/api/v1/notes", method: "GET") as [NoteItem] },
            { try await request(path: "/api/v1/notes/list", method: "GET") as [NoteItem] }
        ])
    }

    func fetchMemories() async throws -> [MemoryItem] {
        try await firstSuccess([
            { try await request(path: "/api/v1/memories", method: "GET") as [MemoryItem] },
            { try await request(path: "/api/v1/memory", method: "GET") as [MemoryItem] }
        ])
    }

    func fetchTools() async throws -> [ToolItem] {
        try await firstSuccess([
            { try await request(path: "/api/v1/tools", method: "GET") as [ToolItem] },
            { try await request(path: "/api/v1/functions", method: "GET") as [ToolItem] }
        ])
    }

    private func makeURL(path: String) throws -> URL {
        guard let base = settings.normalizedBaseURL else { throw APIError.badBaseURL }
        return base.appending(path: path)
    }

    private func authHeaderValue() -> String? {
        if !auth.token.isEmpty { return auth.token }
        if !settings.apiKey.isEmpty { return settings.apiKey }
        return nil
    }

    private func makeRequest<B: Encodable>(path: String, method: String, body: B? = nil) throws -> URLRequest {
        var req = URLRequest(url: try makeURL(path: path))
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let key = authHeaderValue() {
            req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            req.setValue(key, forHTTPHeaderField: "X-API-Key")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    private func request<T: Decodable, B: Encodable>(path: String, method: String, body: B? = nil) async throws -> T {
        let req = try makeRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw APIError.server(http.statusCode, msg)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func multipartUpload(path: String, filename: String, mimeType: String, data: Data) async throws -> UploadedFile {
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: try makeURL(path: path))
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let key = authHeaderValue() {
            req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            req.setValue(key, forHTTPHeaderField: "X-API-Key")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        let (respData, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Upload failed"
            throw APIError.server(http.statusCode, msg)
        }
        if let wrapped = try? JSONDecoder().decode(UploadedFileEnvelope.self, from: respData) {
            return wrapped.data
        }
        return try JSONDecoder().decode(UploadedFile.self, from: respData)
    }

    private func firstSuccess<T>(_ attempts: [() async throws -> T]) async throws -> T {
        var lastError: Error = APIError.invalidResponse
        for attempt in attempts {
            do { return try await attempt() } catch { lastError = error }
        }
        throw lastError
    }
}

struct ModelsResponse: Decodable {
    struct ModelItem: Decodable { let id: String }
    let data: [ModelItem]
}

struct OutboundMessage: Encodable {
    let role: String
    let content: MessageContent
}

enum MessageContent: Encodable {
    case text(String)
    case parts([ContentPart])

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case let .text(text): try c.encode(text)
        case let .parts(parts): try c.encode(parts)
        }
    }
}

struct ContentPart: Encodable {
    let type: String
    let text: String?
    let image_url: ImageURL?

    static func text(_ text: String) -> ContentPart {
        ContentPart(type: "text", text: text, image_url: nil)
    }

    static func image(url: String) -> ContentPart {
        ContentPart(type: "image_url", text: nil, image_url: ImageURL(url: url))
    }
}

struct ImageURL: Encodable { let url: String }

struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [OutboundMessage]
    let stream: Bool
}

struct ChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable { let content: String }
        let message: Message
    }
    let choices: [Choice]
}

struct ChatStreamChunk: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable { let content: String? }
        let delta: Delta
    }
    let choices: [Choice]
}

struct SignInRequest: Encodable {
    let email: String
    let password: String
}

struct SignInResponse: Decodable {
    let token: String?
    let access_token: String?
    let accessToken: String?
}

struct UploadedFileEnvelope: Decodable {
    let data: UploadedFile
}

struct UploadedFile: Decodable {
    let id: String
    let url: String?
    let filename: String?
}

struct NoteItem: Decodable, Identifiable {
    let id: String
    let title: String?
    let content: String?
}

struct MemoryItem: Decodable, Identifiable {
    let id: String
    let content: String?
}

struct ToolItem: Decodable, Identifiable {
    let id: String
    let name: String?
    let description: String?
}
