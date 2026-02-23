import SwiftUI
import UIKit

enum ThemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    case highContrast

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .highContrast: return "High Contrast"
        }
    }
}

struct VibeTheme {
    let mode: ThemePreference
    let background: Color
    let surface: Color
    let surfaceVariant: Color
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color
    let border: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let primaryForeground: Color
    let link: Color
    let linkVisited: Color
    let focusRing: Color
    let selectionBackground: Color
    let selectionForeground: Color

    var brandGradient: LinearGradient {
        LinearGradient(colors: [primary, secondary], startPoint: .leading, endPoint: .trailing)
    }

    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark, .highContrast: return .dark
        }
    }

    var baseAnimationDuration: Double {
        mode == .highContrast ? 0.01 : 0.25
    }

    static func resolve(
        preference: ThemePreference,
        systemColorScheme: ColorScheme,
        increasedContrast: Bool
    ) -> VibeTheme {
        let effectiveMode: ThemePreference
        switch preference {
        case .system:
            effectiveMode = increasedContrast ? .highContrast : (systemColorScheme == .dark ? .dark : .light)
        case .light, .dark, .highContrast:
            effectiveMode = preference
        }

        switch effectiveMode {
        case .light, .system:
            return VibeTheme(
                mode: .light,
                background: Color(red: 246 / 255, green: 247 / 255, blue: 251 / 255),
                surface: .white,
                surfaceVariant: Color(red: 245 / 255, green: 247 / 255, blue: 252 / 255),
                textPrimary: Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255),
                textSecondary: Color(red: 55 / 255, green: 65 / 255, blue: 81 / 255),
                textMuted: Color(red: 107 / 255, green: 114 / 255, blue: 128 / 255),
                border: Color(red: 203 / 255, green: 213 / 255, blue: 225 / 255),
                primary: Color(red: 109 / 255, green: 74 / 255, blue: 255 / 255),
                secondary: Color(red: 20 / 255, green: 184 / 255, blue: 166 / 255),
                accent: Color(red: 255 / 255, green: 140 / 255, blue: 0 / 255),
                primaryForeground: .white,
                link: Color(red: 92 / 255, green: 62 / 255, blue: 224 / 255),
                linkVisited: Color(red: 102 / 255, green: 63 / 255, blue: 200 / 255),
                focusRing: Color(red: 109 / 255, green: 74 / 255, blue: 255 / 255),
                selectionBackground: Color(red: 211 / 255, green: 199 / 255, blue: 255 / 255),
                selectionForeground: Color(red: 23 / 255, green: 12 / 255, blue: 64 / 255)
            )
        case .dark:
            return VibeTheme(
                mode: .dark,
                background: Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255),
                surface: Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255),
                surfaceVariant: Color(red: 42 / 255, green: 53 / 255, blue: 70 / 255),
                textPrimary: Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255),
                textSecondary: Color(red: 203 / 255, green: 213 / 255, blue: 225 / 255),
                textMuted: Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255),
                border: Color(red: 71 / 255, green: 85 / 255, blue: 105 / 255),
                primary: Color(red: 173 / 255, green: 148 / 255, blue: 255 / 255),
                secondary: Color(red: 45 / 255, green: 212 / 255, blue: 191 / 255),
                accent: Color(red: 251 / 255, green: 191 / 255, blue: 36 / 255),
                primaryForeground: Color(red: 23 / 255, green: 12 / 255, blue: 64 / 255),
                link: Color(red: 173 / 255, green: 148 / 255, blue: 255 / 255),
                linkVisited: Color(red: 180 / 255, green: 139 / 255, blue: 255 / 255),
                focusRing: Color(red: 173 / 255, green: 148 / 255, blue: 255 / 255),
                selectionBackground: Color(red: 59 / 255, green: 36 / 255, blue: 147 / 255),
                selectionForeground: Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
            )
        case .highContrast:
            return VibeTheme(
                mode: .highContrast,
                background: .black,
                surface: .black,
                surfaceVariant: .black,
                textPrimary: .white,
                textSecondary: .yellow,
                textMuted: Color(red: 200 / 255, green: 200 / 255, blue: 200 / 255),
                border: .yellow,
                primary: .yellow,
                secondary: .yellow,
                accent: .yellow,
                primaryForeground: .black,
                link: .yellow,
                linkVisited: Color(red: 173 / 255, green: 1.0, blue: 47 / 255),
                focusRing: .yellow,
                selectionBackground: .yellow,
                selectionForeground: .black
            )
        }
    }
}

private struct VibeThemeKey: EnvironmentKey {
    static let defaultValue = VibeTheme.resolve(preference: .light, systemColorScheme: .light, increasedContrast: false)
}

extension EnvironmentValues {
    var vibeTheme: VibeTheme {
        get { self[VibeThemeKey.self] }
        set { self[VibeThemeKey.self] = newValue }
    }
}

struct VibeCard<Content: View>: View {
    let theme: VibeTheme
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.border.opacity(0.55), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

enum VibeTypography {
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom("Inter", size: size).weight(weight)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom("JetBrainsMono-Regular", size: size).weight(weight)
    }
}
