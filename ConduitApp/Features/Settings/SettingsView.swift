import SwiftUI

struct SettingsView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Environment(AuthSessionStore.self) private var auth

    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var status = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("OpenWebUI") {
                    TextField("Base URL", text: $settings.baseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.URL)

                    SecureField("API Key (optional if signed in)", text: $settings.apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    TextField("Preferred Model", text: $settings.selectedModel)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }

                Section("Session") {
                    TextField("Email", text: $loginEmail)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $loginPassword)

                    Button("Sign In") {
                        Task { await signIn() }
                    }

                    if auth.isSignedIn {
                        Button("Sign Out", role: .destructive) {
                            auth.signOut()
                            status = "Signed out"
                        }
                    }

                    Text(auth.isSignedIn ? "Signed in" : "Not signed in")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if !status.isEmpty {
                        Text(status)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Status") {
                    Text("Current server: \(settings.baseURL)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func signIn() async {
        do {
            let api = OpenWebUIAPI(settings: settings, auth: auth)
            let token = try await api.signIn(email: loginEmail, password: loginPassword)
            auth.token = token
            auth.email = loginEmail
            status = "Signed in successfully"
        } catch {
            status = error.localizedDescription
        }
    }
}
