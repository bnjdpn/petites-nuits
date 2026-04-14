<div align="center">

# 🌙 Petites Nuits

**Suivez les nuits de bébé, tout simplement.**

[![Android](https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.1-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack%20Compose-Material%203-4285F4?logo=jetpackcompose&logoColor=white)](https://developer.android.com/jetpack/compose)
[![License: MIT](https://img.shields.io/badge/Licence-MIT-yellow.svg)](LICENSE)

App gratuite et open source — aucune inscription, aucun serveur, toutes les données restent sur votre appareil.

[Télécharger l'APK](https://github.com/bnjdpn/petites-nuits/releases/latest)

</div>

---

## ✨ Fonctionnalités

| | Fonctionnalité | Description |
|---|---|---|
| 🌙 | **Journal de nuit** | Coucher, lever, réveils, tétées, humeur du matin |
| 📅 | **Calendrier** | Vue d'ensemble mois par mois |
| 📊 | **Graphique** | Évolution du sommeil dans le temps |
| 📋 | **Tableau** | Historique chronologique détaillé |
| 📈 | **Statistiques** | Moyennes, tendances, durée de sommeil |

## 🎨 Thème — Nuit Étoilée

| Élément | Couleur |
|---------|---------|
| Background | Deep navy `#0B1026` |
| Surface | Dark blue `#141B3D` |
| Primary | Soft gold `#F5D76E` |
| Secondary | Lavender `#A78BFA` |
| Accent | Warm coral `#FF8A80` |

## 🏗️ Stack technique

```
Kotlin · Jetpack Compose · Room · Material 3 · MVVM
```

- **UI** — Jetpack Compose avec Material 3
- **Base de données** — Room (SQLite, stockage local)
- **Architecture** — MVVM, DI manuelle (pas de Hilt/Koin)
- **Vie privée** — 100 % hors ligne, aucune donnée ne quitte l'appareil

## 📥 Installation

Téléchargez l'APK depuis la [dernière release](https://github.com/bnjdpn/petites-nuits/releases/latest) et installez-le sur un appareil **Android 8.0+** (SDK 26).

## 🔨 Build

> Requiert **Java 17**

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"

./gradlew assembleRelease
```

L'APK signé est généré dans `app/build/outputs/apk/release/app-release.apk`.

## 🤝 Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une *issue* ou une *pull request*.

## 📄 Licence

Ce projet est distribué sous licence [MIT](LICENSE).
