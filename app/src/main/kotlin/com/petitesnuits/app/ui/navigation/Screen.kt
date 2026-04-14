package com.petitesnuits.app.ui.navigation

sealed class Screen(val route: String) {
    data object Saisie : Screen("saisie?date={date}") {
        const val BASE = "saisie"
        fun createRoute(dateMillis: Long? = null): String {
            return if (dateMillis != null) "saisie?date=$dateMillis" else "saisie"
        }
    }
    data object Calendrier : Screen("calendrier")
    data object Graphique : Screen("graphique")
    data object Tableau : Screen("tableau")
    data object Stats : Screen("stats")
    data object EditEntry : Screen("saisie/{entryId}") {
        fun createRoute(entryId: Int) = "saisie/$entryId"
    }
}
