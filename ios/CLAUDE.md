# petites-nuits iOS

Journal de sommeil et de nuits pour bébé. Port iOS. Gratuit / open source. iOS 17.0+.

> **Hérite du** [`CLAUDE.md`](../../CLAUDE.md) workspace et de [`../CLAUDE.md`](../CLAUDE.md) — seules les spécificités iOS sont documentées ici.

## Statut

**Phase 1 (en cours) :** scaffold projet + data model SwiftData + tests.
**Phase 2 (à venir) :** screens SwiftUI complets (TabView 5 onglets), bootstrap design Stitch préalable.

Spec complète : `../docs/ios-port-spec.md`.

## Identifiants

| Clé | Valeur |
|-----|--------|
| Bundle | `com.bnjdpn.petitesnuits` |
| Deployment target | iOS 17.0 (iPhone uniquement, pas d'iPad) |
| Monétisation | Gratuit / open source |
| Localisation | **Français uniquement** (strings hardcodées, pas de `.xcstrings`) |
| Swift | 6.0 `strict concurrency: complete` |

## Stack spécifique

- SwiftUI + SwiftData (local uniquement, **pas de CloudKit**)
- Swift Charts (Phase 2 — graphique 14 dernières nuits)
- XcodeGen (`project.yml` = source de vérité, `.xcodeproj` gitignored)
- Fastlane (Phase 2)
- Zéro package SPM tiers

## Build & Test

```bash
cd ios && xcodegen generate
xcodebuild -project PetitesNuits.xcodeproj -scheme PetitesNuits \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild test -project PetitesNuits.xcodeproj -scheme PetitesNuits \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
swiftlint --fix && swiftlint
```

## Modèles de données

| Modèle | Champs clés | Notes |
|--------|------------|-------|
| `NightEntry` (`@Model`) | id, bedtime, wakeUpTime, wakeUps, mood, notes | Mirroir de l'entité Room Android |
| `WakeUp` (`Codable`) | id, time, durationMinutes, isFeeding, note | Stocké en JSON dans le tableau `wakeUps` du `NightEntry` |
| `Mood` (enum String) | great, good, ok, bad, terrible | Raw values alignées Android (`GREAT/GOOD/OK/BAD/TERRIBLE`) |

**Computed properties `NightEntry`** : `sleepDurationSeconds`, `effectiveSleepSeconds`, `feedingCount`, `totalWakeUpSeconds`, `formatDuration()`, `formatEffectiveDuration()`.

## Conventions spécifiques

- `@Observable` ViewModels avec `@MainActor` (Phase 2)
- Pas de DI framework — instanciation manuelle (pattern petites-gouttes)
- UI 100% française hardcodée
- Cross-midnight : le ViewModel d'édition garantit que `wakeUpTime > bedtime` (ajoute +1 jour si nécessaire) — risk area #1 de la spec
- DEBUG : `ModelContainer` in-memory pour previews/tests et mode `-screenshot`
- Jamais `try!` sur `ModelContainer` — toujours `do-catch`

## Première soumission ASC

⚠️ **HARD LIMIT NOTIFICATION** — première soumission iOS de l'app. Voir spec §13 pour la checklist (privacy policy URL, contact review, content rights, screenshots iPhone 6.9"). Aucune soumission automatique avant validation manuelle.
