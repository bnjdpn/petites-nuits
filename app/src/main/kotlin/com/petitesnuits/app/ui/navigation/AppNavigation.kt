package com.petitesnuits.app.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.petitesnuits.app.PetitesNuitsApp
import com.petitesnuits.app.ui.calendar.CalendarScreen
import com.petitesnuits.app.ui.calendar.CalendarViewModel
import com.petitesnuits.app.ui.chart.ChartScreen
import com.petitesnuits.app.ui.chart.ChartViewModel
import com.petitesnuits.app.ui.entry.EntryScreen
import com.petitesnuits.app.ui.entry.EntryViewModel
import com.petitesnuits.app.ui.stats.StatsScreen
import com.petitesnuits.app.ui.stats.StatsViewModel
import com.petitesnuits.app.ui.table.TableScreen
import com.petitesnuits.app.ui.table.TableViewModel

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    val context = LocalContext.current
    val app = context.applicationContext as PetitesNuitsApp
    val repository = app.repository

    val mainRoutes = listOf(
        Screen.Saisie.route,
        Screen.Calendrier.route,
        Screen.Graphique.route,
        Screen.Tableau.route,
        Screen.Stats.route
    )
    val showBottomBar = currentRoute in mainRoutes

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                BottomNavBar(
                    currentRoute = currentRoute,
                    onNavigate = { screen ->
                        navController.navigate(screen.route) {
                            popUpTo(Screen.Saisie.BASE) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Saisie.BASE,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(
                route = Screen.Saisie.route,
                arguments = listOf(
                    navArgument("date") {
                        type = NavType.LongType
                        defaultValue = -1L
                    }
                )
            ) { backStackEntry ->
                val dateArg = backStackEntry.arguments?.getLong("date") ?: -1L
                val initialDate = if (dateArg > 0) dateArg else null
                val vm: EntryViewModel = viewModel(
                    factory = EntryViewModel.Factory(repository, null, initialDate)
                )
                EntryScreen(
                    viewModel = vm,
                    onSaved = {
                        navController.navigate(Screen.Tableau.route) {
                            popUpTo(Screen.Saisie.BASE) { inclusive = true }
                            launchSingleTop = true
                        }
                    }
                )
            }

            composable(
                route = Screen.EditEntry.route,
                arguments = listOf(navArgument("entryId") { type = NavType.IntType })
            ) { backStackEntry ->
                val entryId = backStackEntry.arguments?.getInt("entryId") ?: return@composable
                val vm: EntryViewModel = viewModel(
                    factory = EntryViewModel.Factory(repository, entryId)
                )
                EntryScreen(
                    viewModel = vm,
                    onSaved = { navController.popBackStack() }
                )
            }

            composable(Screen.Calendrier.route) {
                val vm: CalendarViewModel = viewModel(factory = CalendarViewModel.Factory(repository))
                CalendarScreen(
                    viewModel = vm,
                    onDayClick = { entryId ->
                        if (entryId != null) {
                            navController.navigate(Screen.EditEntry.createRoute(entryId))
                        }
                    },
                    onDayClickWithDate = { dateMillis ->
                        navController.navigate(Screen.Saisie.createRoute(dateMillis))
                    }
                )
            }

            composable(Screen.Graphique.route) {
                val vm: ChartViewModel = viewModel(factory = ChartViewModel.Factory(repository))
                ChartScreen(viewModel = vm)
            }

            composable(Screen.Tableau.route) {
                val vm: TableViewModel = viewModel(factory = TableViewModel.Factory(repository))
                TableScreen(
                    viewModel = vm,
                    onEntryClick = { entryId ->
                        navController.navigate(Screen.EditEntry.createRoute(entryId))
                    }
                )
            }

            composable(Screen.Stats.route) {
                val vm: StatsViewModel = viewModel(factory = StatsViewModel.Factory(repository))
                StatsScreen(viewModel = vm)
            }
        }
    }
}
