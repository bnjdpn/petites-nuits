package com.petitesnuits.app.data.model

enum class Mood(val displayName: String, val emoji: String) {
    GREAT("Super", "😊"),
    GOOD("Bien", "🙂"),
    OK("Moyen", "😐"),
    BAD("Difficile", "😟"),
    TERRIBLE("Terrible", "😫")
}
