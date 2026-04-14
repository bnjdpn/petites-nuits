package com.petitesnuits.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = StarGold,
    onPrimary = DeepNavy,
    primaryContainer = DarkBlue,
    onPrimaryContainer = StarGold,
    secondary = Lavender,
    onSecondary = DeepNavy,
    secondaryContainer = SurfaceDark,
    onSecondaryContainer = Lavender,
    tertiary = WarmCoral,
    onTertiary = DeepNavy,
    background = DeepNavy,
    onBackground = TextPrimary,
    surface = DarkBlue,
    onSurface = TextPrimary,
    surfaceVariant = SurfaceDark,
    onSurfaceVariant = TextSecondary,
)

@Composable
fun PetitesNuitsTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = Typography,
        content = content
    )
}
