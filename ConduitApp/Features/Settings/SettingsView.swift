import SwiftUI

struct SettingsView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Environment(AuthSessionStore.self) private var auth
    @Environment(\.vibeTheme) private var theme

    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var status = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    themeCard
                    serverCard
                    sessionCard
                }
                .padding()
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nellie WebUI")
                .font(VibeTypography.sans(22, weight: .bold))
                .foregroundStyle(theme.primaryForeground)
            Text("VibeCaaS themed OpenWebUI client")
                .font(VibeTypography.sans(15, weight: .medium))
                .foregroundStyle(theme.primaryForeground.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme.brandGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var themeCard: some View {
        VibeCard(theme: theme) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Theme")
                    .font(VibeTypography.sans(17, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)

                Picker("Appearance", selection: $settings.themePreferenceRawValue) {
                    ForEach(ThemePreference.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settings.themePreferenceRawValue) { _, newValue in
                    settings.themePreference = ThemePreference(rawValue: newValue) ?? .system
                }

                Text("Primary #6D4AFF  Secondary #14B8A6  Accent #FF8C00")
                    .font(VibeTypography.mono(12, weight: .medium))
                    .foregroundStyle(theme.textMuted)
            }
        }
    }

    private var serverCard: some View {
        VibeCard(theme: theme) {
            VStack(alignment: .leading, spacing: 10) {
                Text("OpenWebUI")
                    .font(VibeTypography.sans(17, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)

                themedField("Base URL", text: $settings.baseURL, secure: false)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled(true)

                themedField("API Key (optional)", text: $settings.apiKey, secure: true)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                themedField("Preferred Model", text: $settings.selectedModel, secure: false)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Text("Current server: \(settings.baseURL)")
                    .font(VibeTypography.sans(12, weight: .regular))
                    .foregroundStyle(theme.textMuted)
            }
        }
    }

    private var sessionCard: some View {
        VibeCard(theme: theme) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Session")
                        .font(VibeTypography.sans(17, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    Text(auth.isSignedIn ? "Signed in" : "Signed out")
                        .font(VibeTypography.sans(12, weight: .semibold))
                        .foregroundStyle(auth.isSignedIn ? theme.secondary : theme.textMuted)
                }

                themedField("Email", text: $loginEmail, secure: false)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                themedField("Password", text: $loginPassword, secure: true)

                HStack(spacing: 10) {
                    Button("Sign In") {
                        Task { await signIn() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.primary)
                    .foregroundStyle(theme.primaryForeground)

                    if auth.isSignedIn {
                        Button("Sign Out", role: .destructive) {
                            auth.signOut()
                            status = "Signed out"
                        }
                        .buttonStyle(.bordered)
                        .tint(theme.accent)
                    }
                }

                if !status.isEmpty {
                    Text(status)
                        .font(VibeTypography.sans(12, weight: .regular))
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
    }

    private func themedField(_ title: String, text: Binding<String>, secure: Bool) -> some View {
        Group {
            if secure {
                SecureField(title, text: text)
            } else {
                TextField(title, text: text)
            }
        }
        .padding(10)
        .background(theme.surfaceVariant)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(theme.textPrimary)
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
