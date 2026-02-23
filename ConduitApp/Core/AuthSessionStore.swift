import Foundation
import Observation

@Observable
final class AuthSessionStore {
    var token: String {
        didSet { UserDefaults.standard.set(token, forKey: Keys.token) }
    }

    var email: String {
        didSet { UserDefaults.standard.set(email, forKey: Keys.email) }
    }

    init() {
        self.token = UserDefaults.standard.string(forKey: Keys.token) ?? ""
        self.email = UserDefaults.standard.string(forKey: Keys.email) ?? ""
    }

    var isSignedIn: Bool { !token.isEmpty }

    func signOut() {
        token = ""
    }

    enum Keys {
        static let token = "conduit.auth.token"
        static let email = "conduit.auth.email"
    }
}
