# petites-nuits

Journal de sommeil et de nuits pour bébé. Gratuit / open source. Android + iOS.

> **Hérite du** [`CLAUDE.md`](../CLAUDE.md) workspace — seules les spécificités sont documentées ici.
> **Apps sœurs :** [`petites-bouchées`](../petites-bouchees/CLAUDE.md), [`petites-gouttes`](../petites-gouttes/CLAUDE.md)

## Structure

| Plateforme | Répertoire | Détails |
|----------|-----------|---------|
| Android | `app/` | Kotlin + Jetpack Compose + Room (existant) |
| iOS | `ios/` | Swift 6 + SwiftUI + SwiftData (port en cours, voir [`ios/CLAUDE.md`](./ios/CLAUDE.md)) |

## Identifiants

| Clé | Valeur |
|-----|--------|
| Package Android | `com.petitesnuits.app` |
| Bundle iOS | `com.bnjdpn.petitesnuits` |
| Monétisation | Gratuit pour toujours, open source |
| Localisation | **Français uniquement** (strings hardcodées) |
| Architecture | Single-module MVVM |

## Stack spécifique

- Android : Kotlin, Jetpack Compose, Room (KSP), DI manuelle (pas de Hilt/Koin)
- iOS : Swift 6, SwiftUI, SwiftData, XcodeGen, Fastlane (voir `ios/CLAUDE.md`)

## Build & Test

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
./gradlew assembleDebug
./gradlew kspDebugKotlin     # après modif source Kotlin
```

Aucun test ni linter configurés.

## Modèles de données

| Modèle | Champs clés |
|--------|------------|
| `NightEntry` | bedtime, wakeUpTime (`Long` epoch ms), wakeUps (`List<WakeUp>`), mood (`Mood`), notes |
| `WakeUp` | time, durationMinutes, isFeeding |

**Enum `Mood` :** GREAT, GOOD, OK, BAD, TERRIBLE (avec noms d'affichage FR + emoji)

**Champs calculés :** `sleepDurationMillis`, `feedingCount`, `totalWakeUpMinutes`

## Écrans principaux

Saisie (entry), Calendrier (calendar), Graphique (chart), Tableau (table), Stats

## Design — Thème Nuit Étoilée

| Élément | Couleur |
|---------|---------|
| Background | Deep navy `#0B1026` |
| Surface | Dark blue `#141B3D` |
| Primary | Soft gold `#F5D76E` |
| Secondary | Lavender `#A78BFA` |
| Accent | Warm coral `#FF8A80` |
| Mood colors | Gradient vert → jaune → orange → rouge |

⚠️ Ce thème est l'identité visuelle de l'app — le respecter dans toute modification UI.

## Gotchas spécifiques

| Piège | Détail |
|-------|--------|
| **Room DB version** | Actuellement **version 2**. Prochain changement → version 3 + `MIGRATION_2_3` |
| Migration obligatoire | **TOUJOURS** incrémenter la version DB **ET** écrire la migration (jamais l'un sans l'autre) |
| KSP après modif Kotlin | `./gradlew kspDebugKotlin` après tout changement de source Kotlin |
| JAVA_HOME | Doit pointer vers openjdk@17 |
