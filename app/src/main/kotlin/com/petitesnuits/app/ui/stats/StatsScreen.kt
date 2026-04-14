package com.petitesnuits.app.ui.stats

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.petitesnuits.app.ui.theme.Lavender
import com.petitesnuits.app.ui.theme.MoodGood
import com.petitesnuits.app.ui.theme.MoodTerrible
import com.petitesnuits.app.ui.theme.StarGold
import com.petitesnuits.app.ui.theme.WarmCoral

@Composable
fun StatsScreen(viewModel: StatsViewModel) {
    val state by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            "Statistiques",
            style = MaterialTheme.typography.titleLarge,
            color = StarGold
        )

        Spacer(modifier = Modifier.height(4.dp))

        StatCard("😴", "Durée moyenne", state.averageDuration, StarGold)
        StatCard("🌟", "Meilleure nuit", state.bestNight, MoodGood)
        StatCard("😫", "Pire nuit", state.worstNight, MoodTerrible)
        StatCard("🌙", "Réveils moyens", state.averageWakeUps, Lavender)
        StatCard("🍼", "Tétées moyennes", state.averageFeedings, WarmCoral)
        StatCard("📊", "Nuits enregistrées", "${state.totalNights}", Lavender)

        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("📈", fontSize = 28.sp, modifier = Modifier.padding(end = 16.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        "Tendance",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        when (state.trend) {
                            "↑" -> "En amélioration ↑"
                            "↓" -> "En baisse ↓"
                            else -> "Stable →"
                        },
                        style = MaterialTheme.typography.titleLarge,
                        color = when (state.trend) {
                            "↑" -> MoodGood
                            "↓" -> MoodTerrible
                            else -> StarGold
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun StatCard(
    emoji: String,
    label: String,
    value: String,
    valueColor: androidx.compose.ui.graphics.Color
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(emoji, fontSize = 28.sp, modifier = Modifier.padding(end = 16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    label,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(value, style = MaterialTheme.typography.titleLarge, color = valueColor)
            }
        }
    }
}
