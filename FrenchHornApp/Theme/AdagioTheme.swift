import SwiftUI
import UIKit

/// Shared semantic tokens for the Adagio instrument apps (Design/adagio-tokens.json).
enum AdagioTheme {
    enum Colors {
        static let canvas = adaptive(0xF5F3EC, 0x151C18)
        static let surface = adaptive(0xFFFEFA, 0x202B24)
        static let surfaceMuted = adaptive(0xEBEAE2, 0x2B3930)
        static let ink = adaptive(0x232D28, 0xF1F3EA)
        static let secondaryInk = adaptive(0x616B63, 0xB4C0B3)
        static let border = adaptive(0xCBCFC5, 0x536357)
        static let borderStrong = adaptive(0x7D897E, 0x7D9383)
        static let accent = adaptive(0x82601F, 0xDFC18A)
        static let accentMuted = adaptive(0xEEE4CA, 0x403B29)
        static let success = adaptive(0x306247, 0xAED5B5)
        static let successMuted = adaptive(0xE4EDE2, 0x293E2E)
        static let attention = adaptive(0xA13E35, 0xF5ADA3)
        static let attentionMuted = adaptive(0xF6E6E0, 0x482D28)

        private static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
            Color(UIColor { traits in
                uiColor(traits.userInterfaceStyle == .dark ? dark : light)
            })
        }

        private static func uiColor(_ hex: UInt32) -> UIColor {
            UIColor(red: CGFloat((hex >> 16) & 255) / 255,
                    green: CGFloat((hex >> 8) & 255) / 255,
                    blue: CGFloat(hex & 255) / 255, alpha: 1)
        }
    }

    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let hero: CGFloat = 48
    }

    enum Radius {
        static let control: CGFloat = 12
        static let panel: CGFloat = 20
    }

    enum TypeStyle {
        static let screenTitle = Font.largeTitle.weight(.semibold)
        static let sectionTitle = Font.title3.weight(.semibold)
        static let body = Font.body
        static let support = Font.subheadline
        static let label = Font.footnote.weight(.medium)
        static let wordmark = Font.system(.title2, design: .serif)
    }

    enum Control {
        static let minimumTarget: CGFloat = 44
        static let primaryHeight: CGFloat = 54
    }

    /// UIKit appearances keep navigation and tab bars themed on iOS 15 as well.
    static func configureNavigationAppearance() {
        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = UIColor(Colors.canvas)
        navigation.titleTextAttributes = [.foregroundColor: UIColor(Colors.ink)]
        navigation.largeTitleTextAttributes = [.foregroundColor: UIColor(Colors.ink)]
        navigation.shadowColor = UIColor(Colors.border)
        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
        UINavigationBar.appearance().compactAppearance = navigation
        UINavigationBar.appearance().tintColor = UIColor(Colors.accent)

        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = UIColor(Colors.canvas)
        tabBar.shadowColor = UIColor(Colors.border)
        for item in [tabBar.stackedLayoutAppearance, tabBar.inlineLayoutAppearance,
                     tabBar.compactInlineLayoutAppearance] {
            item.normal.iconColor = UIColor(Colors.secondaryInk)
            item.normal.titleTextAttributes = [.foregroundColor: UIColor(Colors.secondaryInk)]
            item.selected.iconColor = UIColor(Colors.accent)
            item.selected.titleTextAttributes = [.foregroundColor: UIColor(Colors.accent)]
        }
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
    }
}

enum AdagioAppearance: String, CaseIterable, Identifiable {
    case system, light, lowLight
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .lowLight: return "Low light"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .lowLight: return .dark
        }
    }
}
