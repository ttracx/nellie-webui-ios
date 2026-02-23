import Foundation
import Observation

@Observable
final class AppSettingsStore {
    var baseURL: String {
        didSet { UserDefaults.standard.set(baseURL, forKey: Keys.baseURL) }
    }

    var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: Keys.apiKey) }
    }

    var selectedModel: String {
        didSet { UserDefaults.standard.set(selectedModel, forKey: Keys.selectedModel) }
    }

    var themePreferenceRawValue: String {
        didSet { UserDefaults.standard.set(themePreferenceRawValue, forKey: Keys.themePreference) }
    }

    var themePreference: ThemePreference {
        get { ThemePreference(rawValue: themePreferenceRawValue) ?? .system }
        set { themePreferenceRawValue = newValue.rawValue }
    }

    init() {
        self.baseURL = UserDefaults.standard.string(forKey: Keys.baseURL) ?? "http://100.105.6.57:3001"
        self.apiKey = UserDefaults.standard.string(forKey: Keys.apiKey) ?? ""
        self.selectedModel = UserDefaults.standard.string(forKey: Keys.selectedModel) ?? ""
        self.themePreferenceRawValue = UserDefaults.standard.string(forKey: Keys.themePreference) ?? ThemePreference.system.rawValue
    }

    var normalizedBaseURL: URL? {
        guard var c = URLComponents(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        if c.scheme == nil { c.scheme = "http" }
        return c.url
    }

    enum Keys {
        static let baseURL = "conduit.baseURL"
        static let apiKey = "conduit.apiKey"
        static let selectedModel = "conduit.selectedModel"
        static let themePreference = "conduit.themePreference"
    }
}
