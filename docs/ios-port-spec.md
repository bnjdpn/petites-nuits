# Spec — Port iOS de Petites Nuits

**Statut :** Draft — prêt pour ios-developer  
**Date :** 2026-04-29  
**Pattern de référence :** petites-bouchees / petites-gouttes (iOS cross-platform)  
**Source Android :** Room v3, DB `petites_nuits.db`, app v1.0.0

---

## 1. Identifiants et configuration

| Clé | Valeur |
|-----|--------|
| Bundle ID | `com.bnjdpn.petitesnuits` |
| Display name | `Petites Nuits` |
| Deployment target | iOS 17.0 (iPhone uniquement, pas d'iPad) |
| Swift | 6.0, `strict concurrency: complete` |
| Monétisation | Gratuit pour toujours, open source |
| Localisation | Français uniquement, strings hardcodées (pas de `.xcstrings`) |
| Team ID | `767SX34A7Z` |
| Catégorie ASC | `public.app-category.healthcare-fitness` |
| Age rating | 4+ (aucun contenu sensible) |
| Privacy Policy | Requise ASC — pointer vers GitHub Pages comme les apps sœurs |

---

## 2. Data model — Room → SwiftData

### 2.1 Entité principale : `NightEntry`

| Champ Android (Room) | Type Android | Champ iOS (@Model) | Type Swift | Notes |
|----------------------|-------------|---------------------|------------|-------|
| `id` (autoGenerate) | `Int` | `id` | `UUID` | SwiftData utilise UUID, pas d'Int autoincrement |
| `bedtime` | `Long` (epoch ms) | `bedtime` | `Date` | Conversion automatique epoch ms → Date |
| `wakeUpTime` | `Long` (epoch ms) | `wakeUpTime` | `Date` | Idem |
| `wakeUps` | `List<WakeUp>` (JSON en colonne TEXT) | `wakeUps` | `[WakeUp]` (Codable) | SwiftData stocke les tableaux Codable nativement |
| `mood` | `Mood` (String raw) | `mood` | `Mood` (String rawValue) | Enum persisté via rawValue String |
| `notes` | `String` | `notes` | `String` | Direct |

**Computed properties à reproduire dans le @Model :**

```
sleepDurationSeconds: TimeInterval  → wakeUpTime.timeIntervalSince(bedtime)
effectiveSleepSeconds: TimeInterval → max(0, sleepDurationSeconds - totalWakeUpSeconds)
feedingCount: Int                   → wakeUps.filter { $0.isFeeding }.count
totalWakeUpSeconds: TimeInterval    → Double(wakeUps.reduce(0) { $0 + $1.durationMinutes }) * 60
formatDuration() -> String          → "Xh00" depuis sleepDurationSeconds
formatEffectiveDuration() -> String → "Xh00" depuis effectiveSleepSeconds
```

**Attention cross-midnight :** la logique Android gère explicitement le cas où `wakeUpTime < bedtime` (réveil le lendemain). iOS doit reproduire ce comportement dans le ViewModel lors du save (si `wakeUpHour < bedtimeHour`, ajouter 1 jour à la date de réveil).

### 2.2 Struct embarquée : `WakeUp`

`WakeUp` n'est pas une entité Room séparée — c'est un type sérialisé en JSON dans une colonne TEXT. Sur iOS, on reproduit la même approche : struct `Codable` stockée dans le tableau `wakeUps` de `NightEntry`.

| Champ | Type Android | Type Swift |
|-------|-------------|------------|
| `time` | `Long` (epoch ms) | `time` | `Date` |
| `durationMinutes` | `Int` | `durationMinutes` | `Int` |
| `isFeeding` | `Boolean` | `isFeeding` | `Bool` |
| `note` | `String` (défaut `""`) | `note` | `String` |

### 2.3 Enum `Mood`

```swift
enum Mood: String, Codable, CaseIterable {
    case great = "GREAT"
    case good = "GOOD"
    case ok = "OK"
    case bad = "BAD"
    case terrible = "TERRIBLE"

    var displayName: String { /* ... */ }
    var emoji: String { /* ... */ }
    var color: Color { /* ... */ }  // MoodGreat → MoodTerrible
}
```

Les raw values sont identiques aux valeurs Android pour une future compatibilité export.

### 2.4 Queries à reproduire (DAO → service/repository)

| Query Android | Équivalent iOS |
|--------------|----------------|
| `getAllEntries() ORDER BY bedtime DESC` | `FetchDescriptor<NightEntry>(sortBy: [.init(\.bedtime, order: .reverse)])` |
| `getById(id)` | Fetch by UUID |
| `getLast14Nights() ORDER BY bedtime DESC LIMIT 14` | FetchDescriptor avec `.fetchLimit = 14` |
| `getEntriesForMonth(start, end)` | Predicate `bedtime >= start && bedtime < end` |
| insert / update / delete | `context.insert` / `context.save` / `context.delete` |

### 2.5 Migration de données Android → iOS

**Hors scope V1.** Les données vivent dans une DB Room SQLite Android locale — aucune migration automatique n'est prévue. L'app iOS démarre sur un store vide. À documenter dans l'onboarding si nécessaire (empty state explicatif).

---

## 3. Screens map — Compose → SwiftUI

| Écran Android (Compose) | Vue SwiftUI iOS | Navigation |
|------------------------|-----------------|------------|
| `EntryScreen` (nouvelle nuit + édition) | `EntryView` | Tab "Saisie" + push depuis CalendarView / TableView |
| `CalendarScreen` | `CalendarView` | Tab "Calendrier" |
| `ChartScreen` | `ChartView` | Tab "Graphique" |
| `TableScreen` | `TableView` | Tab "Tableau" |
| `StatsScreen` | `StatsView` | Tab "Stats" |
| `WakeUpAdder` (sous-composant) | `WakeUpAdderView` | Inline dans EntryView |
| `TimePickerBottomSheet` | `.sheet` + `DatePicker` mode `.hourAndMinute` | Modal depuis EntryView |
| `NightEntryRow` (expandable) | `NightEntryRowView` (DisclosureGroup ou custom) | Inline dans TableView |
| `DayCell` (calendar grid) | `DayCellView` | Grid dans CalendarView |

**Navigation iOS :** `TabView` avec 5 onglets. Pas de `NavigationStack` inter-tabs sauf pour l'édition (push depuis Tableau/Calendrier vers EntryView). Pattern identique à petites-gouttes (TabView + NavigationStack conditionnel).

---

## 4. Features in/out V1

### Incluses (parité Android)

- Saisie nouvelle nuit : date picker, heure coucher, heure réveil, affichage durée calculée
- Gestion réveils nocturnes : ajout inline, heure, durée (stepper 5 min), flag tétée/biberon, note
- Sélection humeur au réveil (5 niveaux GREAT/GOOD/OK/BAD/TERRIBLE + emoji)
- Notes libres
- Edition d'une nuit existante (même formulaire)
- Suppression d'une nuit (swipe-to-delete ou bouton dans TableView)
- Calendrier mensuel navigation mois précédent/suivant, tap → édition ou nouvelle saisie
- Graphique 14 dernières nuits : durée totale, durée effective, nombre de réveils (Swift Charts)
- Tableau chronologique inversé expandable (détail réveils)
- Stats : durée moyenne, meilleure/pire nuit, réveils moyens, tétées moyennes, total nuits, tendance 7j vs 7j précédents
- Empty states illustrés sur toutes les vues sans données

### Différées (hors V1)

- Export CSV ou PDF des données
- Widget iOS (WidgetKit) — dernière nuit en un coup d'œil
- Notifications/rappels de saisie (pas d'analytics, donc opt-in pur)
- Partage d'une nuit (sheet Share Sheet)

### Coupées (not applicable iOS)

- WheelTimePicker custom (Compose) → `.datePickerStyle(.wheel)` natif iOS suffit
- `TimePickerBottomSheet` custom → sheet standard iOS

---

## 5. Chart — spécificité iOS

L'Android utilise un `Canvas` custom pour le graphique (pas de lib tierce). iOS doit utiliser **Swift Charts** (iOS 16+, déjà disponible iOS 17 cible).

Structure du graphique :
- Ligne doree : durée totale sommeil (`sleepDurationSeconds` en heures)
- Ligne lavande : durée effective (`effectiveSleepSeconds` en heures)  
- Barres corail semi-transparentes : nombre de réveils (axe secondaire relatif)
- Axe X : dates (14 dernières nuits)
- Axe Y : heures (0 → max + 1)
- Légende identique à Android

Le ChartViewModel ne charge que les 14 dernières nuits (`getLast14Nights`).

---

## 6. Thème — Nuit Étoilée (identité visuelle obligatoire)

À reproduire fidèlement depuis Android (couleurs identiques) :

```swift
// Theme/Colors.swift
let deepNavy    = Color(hex: "0B1026")   // background principal
let darkBlue    = Color(hex: "141B3D")   // surface
let starGold    = Color(hex: "F5D76E")   // primary, titres
let lavender    = Color(hex: "A78BFA")   // secondary
let warmCoral   = Color(hex: "FF8A80")   // accent, suppression
let textPrimary = Color.white
let textSecondary = Color(hex: "B0BEC5")
let surfaceDark = Color(hex: "1A2147")   // cellules calendrier avec entrée

// Mood colors
let moodGreat   = Color(hex: "66BB6A")
let moodGood    = Color(hex: "A5D6A7")
let moodOk      = Color(hex: "FFCA28")
let moodBad     = Color(hex: "FF8A65")
let moodTerrible = Color(hex: "EF5350")
```

Dark mode first — le thème est intrinsèquement sombre, pas de light mode distinct à prévoir pour V1.

**App icon et design system :** a bootstrapper via Stitch après la spec, comme petites-bouchees et petites-gouttes. Flagué `system_gap` pour l'agent ux-designer.

---

## 7. i18n

UI 100% française hardcodée. Pas de `String(localized:)`, pas de `.xcstrings`. Pattern identique aux apps sœurs. Les strings en dur couvrent :

- Labels onglets : "Saisie", "Calendrier", "Graphique", "Tableau", "Stats"
- EntryView : "Nouvelle nuit" / "Modifier la nuit", "Date de la nuit", "COUCHER", "RÉVEIL", "Durée", "Réveils nocturnes", "Ajouter un réveil", "Humeur au réveil", "Notes", "Enregistrer" / "Modifier"
- WakeUpAdder : "Heure", "Durée", "Tétée / Biberon", "Note (optionnel)", "Ajouter", "Annuler"
- Mood labels : "Super", "Bien", "Moyen", "Difficile", "Terrible"
- Stats : "Statistiques", "Durée moyenne", "Meilleure nuit", "Pire nuit", "Réveils moyens", "Tétées moyennes", "Nuits enregistrées", "Tendance", "En amélioration", "En baisse", "Stable"
- Empty states : "Aucune nuit enregistrée"
- ChartView titre : "Évolution des 14 dernières nuits"
- CalendarView : jours semaine FR (Lu, Ma, Me, Je, Ve, Sa, Di), mois FR
- Accessibilité : labels VoiceOver en FR sur tous les interactifs

---

## 8. Project layout

Suivre exactement le pattern petites-bouchees et petites-gouttes.

```
petites-nuits/
├── app/                          # Android (existant, inchangé)
├── docs/
│   └── ios-port-spec.md          # ce fichier
├── ios/                          # PORT IOS (à créer)
│   ├── project.yml               # XcodeGen — source de vérité
│   ├── Gemfile
│   ├── PetitesNuits/             # Sources Swift
│   │   ├── App/
│   │   │   ├── PetitesNuitsApp.swift
│   │   │   └── ScreenshotDataService.swift
│   │   ├── Models/
│   │   │   ├── NightEntry.swift   # @Model SwiftData
│   │   │   ├── WakeUp.swift       # struct Codable
│   │   │   └── Mood.swift         # enum String Codable
│   │   ├── ViewModels/
│   │   │   ├── EntryViewModel.swift
│   │   │   ├── CalendarViewModel.swift
│   │   │   ├── ChartViewModel.swift
│   │   │   ├── TableViewModel.swift
│   │   │   └── StatsViewModel.swift
│   │   ├── Views/
│   │   │   ├── Entry/
│   │   │   │   ├── EntryView.swift
│   │   │   │   └── WakeUpAdderView.swift
│   │   │   ├── Calendar/
│   │   │   │   ├── CalendarView.swift
│   │   │   │   └── DayCellView.swift
│   │   │   ├── Chart/
│   │   │   │   └── ChartView.swift
│   │   │   ├── Table/
│   │   │   │   ├── TableView.swift
│   │   │   │   └── NightEntryRowView.swift
│   │   │   └── Stats/
│   │   │       └── StatsView.swift
│   │   ├── Navigation/
│   │   │   └── ContentView.swift   # TabView 5 onglets
│   │   ├── Theme/
│   │   │   └── Colors.swift
│   │   └── Resources/
│   │       ├── Assets.xcassets     # AppIcon + AccentColor
│   │       └── PrivacyInfo.xcprivacy
│   ├── PetitesNuitsTests/          # Swift Testing
│   ├── PetitesNuitsUITests/        # Fastlane screenshots
│   ├── fastlane/
│   │   ├── Appfile
│   │   ├── Fastfile                # lanes : test, beta, release, release_quick, screenshots, metadata, create_app
│   │   ├── Matchfile               # git_url BarPath + branch certificates
│   │   ├── Snapfile
│   │   ├── asc_api_key.json
│   │   └── metadata/
│   │       └── fr-FR/              # name, subtitle, description, keywords, release_notes
│   └── app_store_screenshots/
└── CLAUDE.md                      # à mettre à jour après création du port
```

**project.yml** — calqué sur petites-bouchees/ios/project.yml :

```yaml
name: PetitesNuits
options:
  bundleIdPrefix: com.bnjdpn
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "16.0"
  createIntermediateGroups: true
  developmentLanguage: fr
  defaultConfig: Release

settings:
  base:
    SWIFT_VERSION: "6.0"
    SWIFT_STRICT_CONCURRENCY: complete
    GENERATE_INFOPLIST_FILE: YES
    DEVELOPMENT_TEAM: 767SX34A7Z
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: 1

targets:
  PetitesNuits:
    type: application
    platform: iOS
    sources:
      - path: PetitesNuits
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.bnjdpn.petitesnuits
        INFOPLIST_KEY_CFBundleDisplayName: "Petites Nuits"
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: UIInterfaceOrientationPortrait
        INFOPLIST_KEY_UIRequiresFullScreen: YES
        INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.healthcare-fitness
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        ENABLE_PREVIEWS: YES
    dependencies: []
    scheme:
      testTargets:
        - PetitesNuitsTests
        - PetitesNuitsUITests
      gatherCoverageData: true

  PetitesNuitsTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: PetitesNuitsTests
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.bnjdpn.petitesnuits.tests
        GENERATE_INFOPLIST_FILE: YES
    dependencies:
      - target: PetitesNuits

  PetitesNuitsUITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - path: PetitesNuitsUITests
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.bnjdpn.petitesnuits.uitests
        GENERATE_INFOPLIST_FILE: YES
    dependencies:
      - target: PetitesNuits
```

---

## 9. Dependencies

**Zéro package SPM tiers.** Conformément à la philosophie portfolio (privacy-first, 0 analytics, 0 serveur externe) et au pattern des apps sœurs.

Frameworks Apple uniquement :
- SwiftUI (vues)
- SwiftData (persistance locale)
- Swift Charts (graphique 14 nuits)
- Foundation (dates, formatage)

---

## 10. Privacy

### PrivacyInfo.xcprivacy

```xml
<!-- Déclarations obligatoires -->
NSPrivacyTracking: false
NSPrivacyTrackingDomains: []
NSPrivacyCollectedDataTypes: []  <!-- aucune donnée collectée -->
NSPrivacyAccessedAPITypes:
  - NSPrivacyAccessedAPIType: NSPrivacyAccessedAPICategoryUserDefaults
    NSPrivacyAccessedAPITypeReasons: ["CA92.1"]  <!-- si @AppStorage utilisé -->
```

Aucun accès HealthKit dans V1 (les données de sommeil sont saisies manuellement). Si une version future propose l'import HealthKit, ajouter le entitlement + déclaration Privacy Manifest à ce moment.

### App Store Privacy Nutrition Label

- Données collectées : **aucune**
- Suivi : **non**
- Données liées à l'identité : **aucune**

---

## 11. Conventions iOS spécifiques

Héritées des apps sœurs et du workspace CLAUDE.md :

- `@Observable` ViewModels avec `@MainActor` — jamais `ObservableObject`
- `NavigationStack` — jamais `NavigationView`
- `.foregroundStyle()` — jamais `.foregroundColor()`
- `#Preview {}` — jamais `PreviewProvider`
- Swift Testing (`@Test`, `@Suite`, `#expect`) — jamais XCTest
- Pas de DI framework — instanciation manuelle (pattern petites-gouttes)
- DEBUG : `ModelContainer` in-memory pour previews et tests
- VoiceOver labels obligatoires sur tous les interactifs (boutons, cellules calendrier, chips humeur)
- `ModelContainer` initialisé dans `PetitesNuitsApp` avec `do-catch` (jamais `try!`)
- Swipe-to-delete sur `List` dans TableView (`.onDelete` modifier)

---

## 12. Tests

### Unit tests (PetitesNuitsTests — Swift Testing)

Couverture cible : ≥80% sur fichiers touchés.

| Test | Cible |
|------|-------|
| `NightEntryTests` | `sleepDurationSeconds`, `effectiveSleepSeconds`, `feedingCount`, `formatDuration()`, `formatEffectiveDuration()`, cross-midnight |
| `EntryViewModelTests` | `addWakeUp`, `removeWakeUp`, `toggleWakeUpFeeding`, `setWakeUpDuration`, `computeDuration()` (incl. cross-midnight), `save()` round-trip avec ModelContainer in-memory |
| `StatsViewModelTests` | `computeTrend()` (3 cas : up/down/stable), moyennes sur jeu de données fixe |
| `CalendarViewModelTests` | navigation mois, `getEntriesForMonth` avec dates limites |
| `MoodTests` | displayName, emoji, rawValue round-trip |

### UI tests (PetitesNuitsUITests)

Utilisés par Fastlane screenshots. Launch argument `-screenshot` → `ScreenshotDataService` injecte des données réalistes (3-5 nuits avec réveils et tétées variés).

Captures par onglet : EntryView (nuit pré-remplie), CalendarView (mois avec données), ChartView (14 nuits), TableView (liste expandée), StatsView (stats calculées).

---

## 13. ASC — Première soumission

> **HARD LIMIT NOTIFICATION** : première soumission d'une app neuve sur iOS ASC. Requiert intervention manuelle pour valider l'app dans App Store Connect (informations de contact review, content rights declaration). Le release-manager doit notifier Benjamin avant toute tentative de submit. Ne pas tenter de soumission automatique sur une première version sans confirmation.

Checklist première soumission :
- [ ] Bundle ID `com.bnjdpn.petitesnuits` enregistré sur Developer Portal (lane `create_app`)
- [ ] App créée sur ASC avec locale primaire `fr-FR`
- [ ] Privacy Policy URL configurée manuellement sur ASC (champ non mis à jour par fastlane deliver — gotcha workspace)
- [ ] Screenshots iPhone 6.9" (iPhone 17 Pro Max) obligatoires
- [ ] Contact review renseigné (email `dupinbenjam@gmail.com`, nom Benjamin Dupin)
- [ ] Content rights declaration cochée
- [ ] Export compliance : `export_compliance_uses_encryption: false`
- [ ] `releaseType: AFTER_APPROVAL` patché par `asc-submit` en preflight

---

## 14. CLAUDE.md à mettre à jour

Après création du port iOS, mettre à jour `petites-nuits/CLAUDE.md` :
- Supprimer "Pas de iOS" dans Gotchas
- Ajouter Bundle iOS `com.bnjdpn.petitesnuits`
- Ajouter section iOS (mirror du pattern petites-bouchees/CLAUDE.md)
- Mettre à jour la ligne "Android uniquement" en en-tête

---

## 15. Estimation effort et risk areas

### Estimation

| Phase | Effort (jours dev) |
|-------|--------------------|
| Setup projet (XcodeGen, project.yml, Fastlane, structure dossiers) | 0.5 |
| Models SwiftData (NightEntry, WakeUp, Mood) + tests | 1 |
| NightRepository + ViewModels (5 VMs) + tests | 2 |
| EntryView + WakeUpAdderView (formulaire le plus complexe) | 2 |
| TableView + NightEntryRowView (expandable) | 1 |
| CalendarView + DayCellView (grid custom) | 1.5 |
| ChartView (Swift Charts, 3 séries) | 1 |
| StatsView (simple) | 0.5 |
| ContentView TabView + navigation | 0.5 |
| Theme / couleurs | 0.5 |
| Privacy Manifest + entitlements | 0.25 |
| ScreenshotDataService + UI tests | 0.5 |
| SwiftLint + polish + VoiceOver labels | 0.5 |
| **Total estimé** | **~11.75 jours** |

Arrondi conservateur : **12-14 jours dev** (marge pour les risk areas).

### Risk areas

1. **Cross-midnight time arithmetic** : la logique Android de calcul bedtime/wakeUpTime/wakeUpTimes nocturnes quand l'heure de réveil est inférieure à l'heure de coucher (jour suivant) doit être reproduite exactement. Un bug ici fausse toutes les stats. Couvrir avec des tests paramétrés.

2. **WakeUp comme struct Codable dans SwiftData** : les tableaux de structs `Codable` dans `@Model` SwiftData sont supportés mais présentent des edge cases (array mutation + `@Observable` interaction). Tester le round-trip insert/fetch avec wakeUps non vides.

3. **CalendarView — grille custom** : pas de composant calendrier natif iOS 17 avec données custom. La grille doit être construite manuellement (LazyVGrid ou boucle). La logique de calcul `offset` premier jour de la semaine (lundi = 0 en FR) est un source de bugs.

4. **Swift Charts — axe secondaire réveils** : les barres de réveils utilisent un axe secondaire relatif (pas de valeur absolue). Swift Charts gère cela via `.chartYScale` et séries distinctes. S'assurer que la légende et les couleurs correspondent exactement au design Android.

5. **Première soumission ASC** : app neuve sur iOS, jamais publiée. Toutes les étapes manuelles ASC (privacy policy URL, content rights) doivent être faites avant le submit automatisé. Le release-manager doit notifier Benjamin.

---

## 16. Design system

**Bootstrap via Stitch requis** (`/bootstrap-design petites-nuits`) avant le développement des vues finales. Le thème Nuit Étoilée est l'identité visuelle imposée (couleurs déjà définies section 6). Stitch génère les composants SwiftUI de base en respectant ce thème.

Flag `system_gap` pour l'agent ux-designer : le thème sombre custom (DeepNavy/DarkBlue) nécessite une surcharge complète du `ColorScheme` SwiftUI — pas de `.preferredColorScheme(.dark)` seul, il faut définir un `Theme` custom avec les couleurs exactes.
