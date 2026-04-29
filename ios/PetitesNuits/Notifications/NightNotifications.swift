import Foundation

/// Centralise les noms de notifications de cycle de vie d'une `NightEntry`.
/// Permet à toutes les vues d'observer les changements (insert / update /
/// delete) et de rafraîchir leurs données sans couplage direct entre
/// ViewModels.
enum NightNotifications {
    /// Postée après qu'une `NightEntry` a été sauvegardée (insert ou update).
    static let saved = Notification.Name("petitesnuits.nightSaved")

    /// Postée après qu'une `NightEntry` a été supprimée.
    static let deleted = Notification.Name("petitesnuits.nightDeleted")

    /// Séquence asynchrone qui émet à chaque `saved` ou `deleted`. Stream
    /// unique pour permettre aux ViewModels d'écouter avec un simple
    /// `for await` (pas de TaskGroup, donc pas de friction Swift 6 strict).
    static func merged(on center: NotificationCenter = .default) -> AsyncStream<Void> {
        AsyncStream<Void> { continuation in
            let tokens = TokenBag()
            tokens.add(center.addObserver(
                forName: saved,
                object: nil,
                queue: nil
            ) { _ in
                continuation.yield(())
            })
            tokens.add(center.addObserver(
                forName: deleted,
                object: nil,
                queue: nil
            ) { _ in
                continuation.yield(())
            })
            continuation.onTermination = { _ in
                tokens.removeAll(from: center)
            }
        }
    }
}

/// Petit conteneur thread-safe pour les `NSObjectProtocol` retournés par
/// `NotificationCenter.addObserver(forName:...)`. Évite le besoin de capture
/// directe de `any NSObjectProtocol` (non-Sendable) dans une closure
/// `@Sendable` — on ne capture que la classe, qui elle est Sendable via
/// `@unchecked` car protégée par un `NSLock`.
private final class TokenBag: @unchecked Sendable {
    private var tokens: [NSObjectProtocol] = []
    private let lock = NSLock()

    func add(_ token: NSObjectProtocol) {
        lock.lock()
        defer { lock.unlock() }
        tokens.append(token)
    }

    func removeAll(from center: NotificationCenter) {
        lock.lock()
        defer { lock.unlock() }
        for token in tokens {
            center.removeObserver(token)
        }
        tokens.removeAll()
    }
}
