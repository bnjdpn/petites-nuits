import SwiftUI

/// Humeur au réveil. Raw values alignées avec le contrat Android pour
/// compatibilité d'export future.
enum Mood: String, Codable, CaseIterable, Identifiable, Sendable {
    case great = "GREAT"
    case good = "GOOD"
    // swiftlint:disable:next identifier_name
    case ok = "OK"
    case bad = "BAD"
    case terrible = "TERRIBLE"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .great: "Super"
        case .good: "Bien"
        case .ok: "Moyen"
        case .bad: "Difficile"
        case .terrible: "Terrible"
        }
    }

    var emoji: String {
        switch self {
        case .great: "\u{1F60A}"
        case .good: "\u{1F642}"
        case .ok: "\u{1F610}"
        case .bad: "\u{1F61F}"
        case .terrible: "\u{1F62B}"
        }
    }

    /// Couleur associée — palette Nuit Étoilée (cf. spec §6).
    var color: Color {
        switch self {
        case .great: Color(red: 0.4, green: 0.733, blue: 0.416)
        case .good: Color(red: 0.647, green: 0.839, blue: 0.655)
        case .ok: Color(red: 1.0, green: 0.792, blue: 0.157)
        case .bad: Color(red: 1.0, green: 0.541, blue: 0.396)
        case .terrible: Color(red: 0.937, green: 0.325, blue: 0.314)
        }
    }
}
