package com.petitesnuits.app.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.automirrored.filled.ShowChart
import androidx.compose.material.icons.filled.TableChart
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.vector.ImageVector

data class BottomNavItem(
    val screen: Screen,
    val matchRoute: String,
    val label: String,
    val icon: ImageVector
)

val bottomNavItems = listOf(
    BottomNavItem(Screen.Saisie, Screen.Saisie.route, "Saisie", Icons.Default.Edit),
    BottomNavItem(Screen.Calendrier, Screen.Calendrier.route, "Calendrier", Icons.Default.CalendarMonth),
    BottomNavItem(Screen.Graphique, Screen.Graphique.route, "Graphique", Icons.AutoMirrored.Filled.ShowChart),
    BottomNavItem(Screen.Tableau, Screen.Tableau.route, "Tableau", Icons.Default.TableChart),
    BottomNavItem(Screen.Stats, Screen.Stats.route, "Stats", Icons.Default.AutoAwesome),
)

@Composable
fun BottomNavBar(
    currentRoute: String?,
    onNavigate: (Screen) -> Unit
) {
    NavigationBar {
        bottomNavItems.forEach { item ->
            NavigationBarItem(
                selected = currentRoute == item.matchRoute,
                onClick = { onNavigate(item.screen) },
                icon = { Icon(item.icon, contentDescription = item.label) },
                label = { Text(item.label) }
            )
        }
    }
}
