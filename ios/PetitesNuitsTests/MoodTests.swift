import Testing
@testable import PetitesNuits

@Suite("Mood")
struct MoodTests {
    @Test("All moods have non-empty display name and emoji")
    func allMoodsHaveDisplayInfo() {
        for mood in Mood.allCases {
            #expect(!mood.displayName.isEmpty)
            #expect(!mood.emoji.isEmpty)
        }
    }

    @Test("Five moods exist")
    func fiveMoods() {
        #expect(Mood.allCases.count == 5)
    }

    @Test("Raw values match Android contract", arguments: [
        (Mood.great, "GREAT"),
        (Mood.good, "GOOD"),
        (Mood.ok, "OK"),
        (Mood.bad, "BAD"),
        (Mood.terrible, "TERRIBLE")
    ])
    func rawValuesMatchAndroid(mood: Mood, expectedRaw: String) {
        #expect(mood.rawValue == expectedRaw)
    }

    @Test("Round-trip via rawValue")
    func roundTripRawValue() throws {
        for mood in Mood.allCases {
            let restored = Mood(rawValue: mood.rawValue)
            #expect(restored == mood)
        }
    }

    @Test("Display names are French")
    func displayNamesFrench() {
        #expect(Mood.great.displayName == "Super")
        #expect(Mood.good.displayName == "Bien")
        #expect(Mood.ok.displayName == "Moyen")
        #expect(Mood.bad.displayName == "Difficile")
        #expect(Mood.terrible.displayName == "Terrible")
    }
}
