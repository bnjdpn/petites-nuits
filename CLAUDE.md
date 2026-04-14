# petites-nuits

Journal de sommeil et de nuits pour bébé. Gratuit / open source. **Android uniquement.**

> **Hérite du** [`CLAUDE.md`](../CLAUDE.md) workspace — seules les spécificités sont documentées ici.
> **Apps sœurs :** [`petites-bouchées`](../petites-bouchees/CLAUDE.md), [`petites-gouttes`](../petites-gouttes/CLAUDE.md)

## Identifiants

| Clé | Valeur |
|-----|--------|
| Package Android | `com.petitesnuits.app` |
| Monétisation | Gratuit pour toujours, open source |
| Localisation | **Français uniquement** (strings hardcodées) |
| Architecture | Single-module MVVM |

## Stack

- Kotlin, Jetpack Compose, Room
- DI manuelle (pas de Hilt/Koin)
- Build : `export JAVA_HOME=/opt/homebrew/opt/openjdk@17 && ./gradlew assembleDebug`

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
| **Pas de iOS** | App Android uniquement — pas de parité cross-platform à maintenir |
