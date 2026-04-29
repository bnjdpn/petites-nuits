import SwiftUI
import Testing
@testable import PetitesNuits

@Suite("Theme — Étoilée Stitch palette")
struct ThemeTests {
    @Test("Theme exposes Stitch tokens")
    func tokensExist() {
        // Compile-time guarantee + simple equality
        _ = Theme.indigoNuit
        _ = Theme.indigoDeep
        _ = Theme.veloursProfond
        _ = Theme.bleuLune
        _ = Theme.etoileOr
        _ = Theme.lumiereIvoire
        // Roundness constant
        #expect(Theme.cornerRadius == 12)
    }

    @Test("Spacing tokens follow 4px unit")
    func spacingTokens() {
        #expect(Theme.Spacing.xs == 4)
        #expect(Theme.Spacing.sm == 8)
        #expect(Theme.Spacing.md == 16)
        #expect(Theme.Spacing.lg == 24)
        #expect(Theme.Spacing.xl == 48)
    }
}
