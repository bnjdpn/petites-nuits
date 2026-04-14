package com.petitesnuits.app.ui.table

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.ui.theme.Lavender
import com.petitesnuits.app.ui.theme.StarGold
import com.petitesnuits.app.ui.theme.TextSecondary
import com.petitesnuits.app.ui.theme.WarmCoral
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun TableScreen(
    viewModel: TableViewModel,
    onEntryClick: (Int) -> Unit
) {
    val entries by viewModel.entries.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            "Toutes les nuits",
            style = MaterialTheme.typography.titleLarge,
            color = StarGold
        )

        Spacer(modifier = Modifier.height(12.dp))

        if (entries.isEmpty()) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("🌙", fontSize = 48.sp)
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        "Aucune nuit enregistrée",
                        style = MaterialTheme.typography.bodyLarge,
                        color = TextSecondary
                    )
                }
            }
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(entries, key = { it.id }) { entry ->
                    NightEntryRow(
                        entry = entry,
                        onEditClick = { onEntryClick(entry.id) },
                        onDelete = { viewModel.delete(entry) }
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun NightEntryRow(
    entry: NightEntry,
    onEditClick: () -> Unit,
    onDelete: () -> Unit
) {
    val dateFormat = remember { SimpleDateFormat("dd/MM/yyyy", Locale.FRENCH) }
    val timeFormat = remember { SimpleDateFormat("HH:mm", Locale.FRENCH) }
    var expanded by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { expanded = !expanded },
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            // Summary row
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        dateFormat.format(Date(entry.bedtime)),
                        style = MaterialTheme.typography.titleMedium,
                        color = StarGold
                    )
                    Text(
                        "${timeFormat.format(Date(entry.bedtime))} → ${timeFormat.format(Date(entry.wakeUpTime))}",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    val durationText = if (entry.totalWakeUpMinutes > 0) {
                        "${entry.formatDuration()} (${entry.formatEffectiveDuration()})"
                    } else {
                        entry.formatDuration()
                    }
                    Text(
                        durationText,
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    if (entry.wakeUps.isNotEmpty()) {
                        val feedingCount = entry.feedingCount
                        val wakeUpCount = entry.wakeUps.size
                        Text(
                            if (feedingCount > 0) "🌙 $wakeUpCount · 🍼 $feedingCount"
                            else "🌙 $wakeUpCount",
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                }
                Text(
                    entry.mood.emoji,
                    fontSize = 24.sp,
                    modifier = Modifier.padding(horizontal = 8.dp)
                )
                Icon(
                    if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = if (expanded) "Réduire" else "Détails",
                    tint = Lavender
                )
            }

            // Expanded content
            AnimatedVisibility(
                visible = expanded,
                enter = expandVertically(),
                exit = shrinkVertically()
            ) {
                Column(modifier = Modifier.padding(top = 12.dp)) {
                    if (entry.wakeUps.isNotEmpty()) {
                        FlowRow(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            entry.wakeUps.forEach { wu ->
                                Surface(
                                    shape = RoundedCornerShape(8.dp),
                                    color = MaterialTheme.colorScheme.surfaceVariant
                                ) {
                                    Row(
                                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(
                                            timeFormat.format(Date(wu.time)),
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = StarGold
                                        )
                                        Text(
                                            " · ${wu.durationMinutes}min",
                                            style = MaterialTheme.typography.bodySmall,
                                            color = TextSecondary
                                        )
                                        if (wu.isFeeding) {
                                            Text(
                                                " · 🍼",
                                                style = MaterialTheme.typography.bodySmall
                                            )
                                        }
                                        if (wu.note.isNotBlank()) {
                                            Spacer(modifier = Modifier.width(4.dp))
                                            Text(
                                                wu.note,
                                                style = MaterialTheme.typography.bodySmall,
                                                fontStyle = FontStyle.Italic,
                                                color = TextSecondary
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        Spacer(modifier = Modifier.height(12.dp))
                    }

                    // Action buttons
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.End
                    ) {
                        OutlinedButton(onClick = onEditClick) {
                            Icon(
                                Icons.Default.Edit,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp),
                                tint = Lavender
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Modifier", color = Lavender)
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        IconButton(onClick = onDelete) {
                            Icon(Icons.Default.Delete, "Supprimer", tint = WarmCoral)
                        }
                    }
                }
            }
        }
    }
}
