import SwiftUI

/// Palette Nuit Étoilée (cf. spec §6). Identique au thème Android.
enum Theme {
    static let deepNavy = Color(red: 0.043, green: 0.063, blue: 0.149) // #0B1026
    static let darkBlue = Color(red: 0.078, green: 0.106, blue: 0.239) // #141B3D
    static let surfaceDark = Color(red: 0.102, green: 0.129, blue: 0.278) // #1A2147
    static let starGold = Color(red: 0.961, green: 0.843, blue: 0.431) // #F5D76E
    static let lavender = Color(red: 0.655, green: 0.545, blue: 0.980) // #A78BFA
    static let warmCoral = Color(red: 1.0, green: 0.541, blue: 0.502) // #FF8A80
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.690, green: 0.745, blue: 0.773) // #B0BEC5
}
