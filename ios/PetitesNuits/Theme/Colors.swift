import SwiftUI

/// Palette Étoilée — Stitch v1 (cf. `petites-nuits/design/system.md`).
/// Dark mode primary, jamais de noir pur. WCAG AA validé.
enum Theme {
    // MARK: - Couleurs signature

    /// `#5C6FAB` — couleur signature, ciel étoilé ancrage, CTA.
    static let indigoNuit = Color(red: 0.361, green: 0.435, blue: 0.671)
    /// `#3D4F8E` — variant pressed.
    static let indigoDeep = Color(red: 0.239, green: 0.310, blue: 0.557)
    /// `#0A0E1F` — fond, nuit dense (jamais noir pur #000).
    static let veloursProfond = Color(red: 0.039, green: 0.055, blue: 0.122)
    /// `#1A1F3A` — cards, dividers, surface secondaire.
    static let bleuLune = Color(red: 0.102, green: 0.122, blue: 0.227)
    /// `#F5C76F` — points réveils, badges étoiles, accent.
    static let etoileOr = Color(red: 0.961, green: 0.780, blue: 0.435)
    /// `#F0EBE0` — texte primary, doux pour yeux fatigués.
    static let lumiereIvoire = Color(red: 0.941, green: 0.922, blue: 0.878)

    // MARK: - Layout

    /// Roundness `ROUND_TWELVE` — 12pt par défaut sur cards.
    static let cornerRadius: CGFloat = 12

    /// Spacing tokens (4px unit).
    enum Spacing {
        // swiftlint:disable identifier_name
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 48
        // swiftlint:enable identifier_name
    }

    // MARK: - Typographie

    /// Headline serif (proxy iOS de Libre Caslon Text — pas de dépendance bundle).
    static func headline(_ style: Font.TextStyle = .title) -> Font {
        .system(style, design: .serif).weight(.semibold)
    }

    /// Body Inter-like (San Francisco).
    static func body(_ style: Font.TextStyle = .body) -> Font {
        .system(style, design: .default)
    }

    /// Numerics monospaced pour heures et durées.
    static func numerics(_ style: Font.TextStyle = .body) -> Font {
        .system(style, design: .default).monospacedDigit()
    }
}
