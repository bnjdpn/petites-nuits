import Foundation
import Testing
@testable import PetitesNuits

@Suite("WakeUp")
struct WakeUpTests {
    @Test("Default note is empty")
    func defaultNoteIsEmpty() {
        let wakeUp = WakeUp(time: Date(), durationMinutes: 10, isFeeding: true)
        #expect(wakeUp.note == "")
    }

    @Test("Custom note is preserved")
    func customNotePreserved() {
        let wakeUp = WakeUp(time: Date(), durationMinutes: 5, isFeeding: false, note: "rêve")
        #expect(wakeUp.note == "rêve")
    }

    @Test("Codable round-trip preserves all fields")
    func codableRoundTrip() throws {
        let original = WakeUp(
            time: Date(timeIntervalSince1970: 1_700_000_000),
            durationMinutes: 15,
            isFeeding: true,
            note: "biberon"
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(WakeUp.self, from: data)
        #expect(decoded.time == original.time)
        #expect(decoded.durationMinutes == original.durationMinutes)
        #expect(decoded.isFeeding == original.isFeeding)
        #expect(decoded.note == original.note)
    }

    @Test("Array of WakeUp encodes to JSON")
    func arrayCodable() throws {
        let wakeUps = [
            WakeUp(time: Date(timeIntervalSince1970: 1), durationMinutes: 5, isFeeding: false),
            WakeUp(time: Date(timeIntervalSince1970: 2), durationMinutes: 10, isFeeding: true, note: "tétée")
        ]
        let data = try JSONEncoder().encode(wakeUps)
        let decoded = try JSONDecoder().decode([WakeUp].self, from: data)
        #expect(decoded.count == 2)
        #expect(decoded[1].isFeeding == true)
        #expect(decoded[1].note == "tétée")
    }
}
