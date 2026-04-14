package com.petitesnuits.app.ui.entry

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.petitesnuits.app.data.model.Mood
import com.petitesnuits.app.ui.components.TimePickerBottomSheet
import com.petitesnuits.app.ui.theme.MoodBad
import com.petitesnuits.app.ui.theme.MoodGood
import com.petitesnuits.app.ui.theme.MoodGreat
import com.petitesnuits.app.ui.theme.MoodOk
import com.petitesnuits.app.ui.theme.MoodTerrible
import com.petitesnuits.app.ui.theme.StarGold
import com.petitesnuits.app.ui.theme.WarmCoral
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EntryScreen(
    viewModel: EntryViewModel,
    onSaved: () -> Unit
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.saved) {
        if (state.saved) onSaved()
    }

    var showBedtimePicker by remember { mutableStateOf(false) }
    var showWakeUpPicker by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .imePadding()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = if (state.isEditing) "Modifier la nuit" else "Nouvelle nuit",
            style = MaterialTheme.typography.headlineMedium,
            color = StarGold
        )

        // Date selector
        var showDatePicker by remember { mutableStateOf(false) }
        val dateFormat = remember { SimpleDateFormat("EEEE d MMMM yyyy", Locale.FRENCH) }

        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { showDatePicker = true }
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.CalendarMonth,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.secondary
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(
                        "Date de la nuit",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        dateFormat.format(Date(state.selectedDateMillis)).replaceFirstChar { it.uppercase() },
                        style = MaterialTheme.typography.titleMedium,
                        color = StarGold
                    )
                }
            }
        }

        if (showDatePicker) {
            val datePickerState = rememberDatePickerState(
                initialSelectedDateMillis = state.selectedDateMillis
            )
            DatePickerDialog(
                onDismissRequest = { showDatePicker = false },
                confirmButton = {
                    TextButton(onClick = {
                        datePickerState.selectedDateMillis?.let { viewModel.setSelectedDate(it) }
                        showDatePicker = false
                    }) {
                        Text("OK")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showDatePicker = false }) {
                        Text("Annuler")
                    }
                }
            ) {
                DatePicker(state = datePickerState)
            }
        }

        // Time display row — tap to open bottom sheet
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.clickable { showBedtimePicker = true }
                ) {
                    Text(
                        "COUCHER",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        "${state.bedtimeHour.toString().padStart(2, '0')}:${state.bedtimeMinute.toString().padStart(2, '0')}",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = StarGold
                    )
                }

                Text(
                    " → ",
                    fontSize = 24.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(horizontal = 16.dp)
                )

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.clickable { showWakeUpPicker = true }
                ) {
                    Text(
                        "RÉVEIL",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        "${state.wakeUpHour.toString().padStart(2, '0')}:${state.wakeUpMinute.toString().padStart(2, '0')}",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = StarGold
                    )
                }
            }
        }

        // Bottom sheets
        if (showBedtimePicker) {
            TimePickerBottomSheet(
                title = "Heure de coucher",
                initialHour = state.bedtimeHour,
                initialMinute = state.bedtimeMinute,
                onConfirm = { h, m ->
                    viewModel.setBedtime(h, m)
                    showBedtimePicker = false
                },
                onDismiss = { showBedtimePicker = false }
            )
        }

        if (showWakeUpPicker) {
            TimePickerBottomSheet(
                title = "Heure de réveil",
                initialHour = state.wakeUpHour,
                initialMinute = state.wakeUpMinute,
                onConfirm = { h, m ->
                    viewModel.setWakeUp(h, m)
                    showWakeUpPicker = false
                },
                onDismiss = { showWakeUpPicker = false }
            )
        }

        // Duration
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Durée : ", style = MaterialTheme.typography.titleMedium)
                Text(
                    viewModel.computeDuration(),
                    style = MaterialTheme.typography.titleLarge,
                    color = StarGold
                )
            }
        }

        // Wake-ups during night
        SectionCard("Réveils nocturnes") {
            state.wakeUps.forEachIndexed { index, wu ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                "${wu.hour.toString().padStart(2, '0')}:${wu.minute.toString().padStart(2, '0')}",
                                style = MaterialTheme.typography.titleMedium,
                                color = StarGold
                            )
                            IconButton(onClick = { viewModel.removeWakeUp(index) }) {
                                Icon(Icons.Default.Close, "Supprimer", tint = WarmCoral)
                            }
                        }

                        // Duration stepper
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("Durée : ", style = MaterialTheme.typography.bodyMedium)
                            IconButton(onClick = {
                                viewModel.setWakeUpDuration(index, wu.durationMinutes - 5)
                            }) {
                                Icon(Icons.Default.Remove, "Moins", modifier = Modifier.size(18.dp))
                            }
                            Text(
                                "${wu.durationMinutes} min",
                                style = MaterialTheme.typography.bodyLarge,
                                modifier = Modifier.padding(horizontal = 4.dp)
                            )
                            IconButton(onClick = {
                                viewModel.setWakeUpDuration(index, wu.durationMinutes + 5)
                            }) {
                                Icon(Icons.Default.Add, "Plus", modifier = Modifier.size(18.dp))
                            }
                        }

                        // Feeding toggle
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Checkbox(
                                checked = wu.isFeeding,
                                onCheckedChange = { viewModel.toggleWakeUpFeeding(index) }
                            )
                            Text(
                                "Tétée / Biberon",
                                style = MaterialTheme.typography.bodyMedium
                            )
                        }

                        // Note field
                        OutlinedTextField(
                            value = wu.note,
                            onValueChange = { viewModel.setWakeUpNote(index, it) },
                            label = { Text("Note (optionnel)") },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true
                        )
                    }
                }
            }
            WakeUpAdder(onAdd = { h, m, dur, feeding, note ->
                viewModel.addWakeUp(h, m, dur, feeding, note)
            })
        }

        // Mood
        SectionCard("Humeur au réveil") {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Mood.entries.forEach { mood ->
                    val moodColor = when (mood) {
                        Mood.GREAT -> MoodGreat
                        Mood.GOOD -> MoodGood
                        Mood.OK -> MoodOk
                        Mood.BAD -> MoodBad
                        Mood.TERRIBLE -> MoodTerrible
                    }
                    FilterChip(
                        selected = state.mood == mood,
                        onClick = { viewModel.setMood(mood) },
                        label = { Text(mood.emoji, style = MaterialTheme.typography.titleLarge) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = moodColor.copy(alpha = 0.3f)
                        )
                    )
                }
            }
        }

        // Notes
        OutlinedTextField(
            value = state.notes,
            onValueChange = { viewModel.setNotes(it) },
            label = { Text("Notes") },
            modifier = Modifier.fillMaxWidth(),
            minLines = 2
        )

        // Save
        Button(
            onClick = { viewModel.save() },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
        ) {
            Text(
                if (state.isEditing) "Modifier" else "Enregistrer",
                style = MaterialTheme.typography.titleMedium
            )
        }

        Spacer(modifier = Modifier.height(16.dp))
    }
}

@Composable
private fun SectionCard(title: String, content: @Composable () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                title,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.secondary
            )
            Spacer(modifier = Modifier.height(8.dp))
            content()
        }
    }
}

@Composable
private fun WakeUpAdder(onAdd: (Int, Int, Int, Boolean, String) -> Unit) {
    var showForm by remember { mutableStateOf(false) }
    var showTimePicker by remember { mutableStateOf(false) }
    var selectedHour by remember { mutableIntStateOf(2) }
    var selectedMinute by remember { mutableIntStateOf(0) }

    if (showForm) {
        var durationMinutes by remember { mutableIntStateOf(15) }
        var isFeeding by remember { mutableStateOf(false) }
        var note by remember { mutableStateOf("") }

        Column {
            // Time display — tap to open bottom sheet
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { showTimePicker = true },
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Text("Heure : ", style = MaterialTheme.typography.bodyMedium)
                    Text(
                        "${selectedHour.toString().padStart(2, '0')}:${selectedMinute.toString().padStart(2, '0')}",
                        style = MaterialTheme.typography.titleLarge,
                        color = StarGold
                    )
                }
            }

            if (showTimePicker) {
                TimePickerBottomSheet(
                    title = "Heure du réveil",
                    initialHour = selectedHour,
                    initialMinute = selectedMinute,
                    onConfirm = { h, m ->
                        selectedHour = h
                        selectedMinute = m
                        showTimePicker = false
                    },
                    onDismiss = { showTimePicker = false }
                )
            }

            // Duration
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Durée : ", style = MaterialTheme.typography.bodyMedium)
                IconButton(onClick = { durationMinutes = (durationMinutes - 5).coerceAtLeast(0) }) {
                    Icon(Icons.Default.Remove, "Moins", modifier = Modifier.size(18.dp))
                }
                Text(
                    "$durationMinutes min",
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(horizontal = 4.dp)
                )
                IconButton(onClick = { durationMinutes += 5 }) {
                    Icon(Icons.Default.Add, "Plus", modifier = Modifier.size(18.dp))
                }
            }

            // Feeding
            Row(verticalAlignment = Alignment.CenterVertically) {
                Checkbox(checked = isFeeding, onCheckedChange = { isFeeding = it })
                Text("Tétée / Biberon", style = MaterialTheme.typography.bodyMedium)
            }

            // Note
            OutlinedTextField(
                value = note,
                onValueChange = { note = it.take(100) },
                label = { Text("Note (optionnel)") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = {
                    onAdd(selectedHour, selectedMinute, durationMinutes, isFeeding, note)
                    showForm = false
                    selectedHour = 2
                    selectedMinute = 0
                }) {
                    Text("Ajouter")
                }
                Button(onClick = {
                    showForm = false
                    selectedHour = 2
                    selectedMinute = 0
                }) {
                    Text("Annuler")
                }
            }
        }
    } else {
        Button(onClick = { showForm = true }) {
            Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(18.dp))
            Spacer(modifier = Modifier.width(4.dp))
            Text("Ajouter un réveil")
        }
    }
}
