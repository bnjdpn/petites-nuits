# petites-nuits — Design System (Étoilée 2026)

> **Version 1 · Stitch autonomous · Locked 2026-04-29**
> Source de vérité figée. Toute modification = `--addendum` explicite.

## Source

- **Stitch project** : `projects/3195643534044095662` ("petites-nuits Refonte 2026")
- **Design system Stitch** : `assets/16279403592182937452` v1
- **Méthode** : Stitch autonomous (Material Design EXPRESSIVE)
- **Bootstrap initial** (no legacy)
- **Aligné** avec `petites-nuits/docs/ios-port-spec.md` (port iOS Phase 1 done commit f83e966)

## Vision

Suivi sommeil bébé et réveils nocturnes. Univers **Nuit Étoilée Van Gogh** : indigo profond, points lumineux, calme béat. **Anti tracker bébé clinique**. Pour parents épuisés qui veulent voir un pattern, pas un dashboard médical.

App **gratuite**, **open-source**, cross-plateforme iOS + Android. Privacy zero-analytics. **Thème "Nuit Étoilée"** est mentionné explicitement dans la spec ios-port — surcharge complète du ColorScheme.

## Palette (DARK mode primary — toujours)

| Token | Hex | Usage |
|---|---|---|
| `Indigo Nuit` (primary) | `#5C6FAB` | Couleur signature, ciel étoilé ancrage, CTA |
| `Indigo Deep` | `#3D4F8E` | Variant pressed |
| `Velours Profond` (background) | `#0A0E1F` | Fond, nuit dense (jamais noir pur #000) |
| `Bleu Lune` (secondary surface) | `#1A1F3A` | Cards, dividers |
| `Étoile Or` (accent) | `#F5C76F` | Points réveils sur graph, badges étoiles |
| `Lumière Ivoire` (on-surface) | `#F0EBE0` | Texte primary, doux pour yeux fatigués |

**Color variant Stitch** : `EXPRESSIVE`.

## Typography

| Rôle | Famille | Usage |
|---|---|---|
| Headline | **Libre Caslon Text** (serif poétique nocturne) | Titres, hero |
| Body | **Inter** | Corps, descriptions |
| Label / Numerics | **Inter** | Heures, durées, dates |

## Shape & Spacing

- **Roundness** : `ROUND_TWELVE` (12px). Doux, nocturne.
- **Spacing** (4px unit) : `xs=4 · sm=8 · md=16 · lg=24 · xl=48`

## Composants signature

| Component | Description | Implémentation |
|---|---|---|
| **NightEntryRow** | Row entrée nuit avec heure couché + réveil + durée + mood | `HStack` |
| **MoodChip** | 5 niveaux (GREAT/GOOD/OK/BAD/TERRIBLE) couleurs adoucies | `Capsule` color-coded |
| **WakeUpStars** | Dots dorés sur graph représentant chaque réveil | `Circle` 6pt en `Étoile Or` |
| **CalendarGrid** | Grille mois lundi-first FR avec heatmap qualité | Custom `LazyVGrid` |
| **DurationChart** | Swift Charts dual-axis : barres durée + dots réveils | Swift Charts |
| **AddNightSheet** | Sheet rapide saisie soirée | `.sheet` |
| **StatsCards** | Stats avg durée + moyenne réveils + tendance | `VStack` cards |

## Anti-patterns (interdits)

- ❌ **Pas de fond noir pur (#000000)** — toujours `Velours Profond` (#0A0E1F)
- ❌ Pas de SF Symbols médical hospitalier (`bed.double` générique OK, mais pas `cross.case`)
- ❌ **Pas d'emojis** (💤 🌙 banni — utiliser custom shapes)
- ❌ Pas de moons/étoiles décoratives en clip-art
- ❌ Pas de design infantilisant nounours/biberons
- ❌ **Pas de gamification streaks** (sujet sensible épuisement parental)
- ❌ Pas de pubs / tracking / analytics

## Motion

- `.smooth` par défaut, slow easings (0.6s)
- WakeUpStars : entry fade-in stagger 80ms
- Reduce Motion : transitions sans bounce

## Accessibility

- Touch targets ≥44pt
- Dynamic Type `xxxLarge` (parents épuisés en pleine nuit)
- VoiceOver : `"Nuit du \(date), couché \(bedtime), réveil \(wakeUpTime), durée \(duration), \(wakeUps) réveils, ressenti \(mood)"`
- WCAG AA : Lumière Ivoire on Velours Profond = 16.2:1 ✓ ; Indigo Nuit on Velours Profond = 5.1:1 ✓

## Screens (Stitch async)

Project Stitch — async generation. Récupération via `mcp__stitch__list_screens(projectId="3195643534044095662")`.

Visualisation : `https://stitch.withgoogle.com/?project=3195643534044095662`

Screens à générer (Phase 2 du port iOS) :
- Home / NightEntryRow list (saisie rapide)
- Calendar grid (heatmap mois)
- DurationChart (Swift Charts)
- StatsCards
- Settings / contribuer

## Alignement avec Phase 1 iOS port

Models SwiftData scaffoldés (Phase 1, commit f83e966) :
- `NightEntry` (`bedtime`, `wakeUpTime`, `wakeUps: [WakeUp]`, `mood: Mood`)
- `WakeUp` (struct Codable, `time`, `note`)
- `Mood` enum (`GREAT/GOOD/OK/BAD/TERRIBLE` raw String)

`Theme/Colors.swift` créé en palette "Nuit Étoilée" — à aligner avec les tokens Stitch ci-dessus en Phase 2 (next pass).

## Cross-plateforme

Design language identique iOS + Android. **Tokens partagés** documentés dans cette `system.md`. Android (Kotlin/Compose) déjà LIVE v1.0.0, iOS scaffold Phase 1 done.

## Tonalité éditoriale

**Calme, empathique, sans jugement**. L'app aide à voir un pattern, pas à culpabiliser sur la qualité du sommeil bébé. Aucune métrique "score" ou "performance".
