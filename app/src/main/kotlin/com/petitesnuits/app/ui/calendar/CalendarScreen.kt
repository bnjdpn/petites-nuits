package com.petitesnuits.app.ui.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.ui.theme.StarGold
import com.petitesnuits.app.ui.theme.SurfaceDark
import java.text.DateFormatSymbols
import java.util.Calendar
import java.util.Locale

@Composable
fun CalendarScreen(
    viewModel: CalendarViewModel,
    onDayClick: (entryId: Int?) -> Unit,
    onDayClickWithDate: (Long) -> Unit
) {
    val calState by viewModel.calendarState.collectAsState()
    val entries by viewModel.entries.collectAsState()

    val monthNames = DateFormatSymbols(Locale.FRENCH).months
    val dayHeaders = listOf("Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Month navigation
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = { viewModel.previousMonth() }) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, "Mois précédent")
            }
            Text(
                text = "${monthNames[calState.month].replaceFirstChar { it.uppercase() }} ${calState.year}",
                style = MaterialTheme.typography.titleLarge,
                color = StarGold
            )
            IconButton(onClick = { viewModel.nextMonth() }) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, "Mois suivant")
            }
        }

        // Day headers
        Row(modifier = Modifier.fillMaxWidth()) {
            dayHeaders.forEach { day ->
                Text(
                    text = day,
                    modifier = Modifier.weight(1f),
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Calendar grid
        val calendar = Calendar.getInstance().apply {
            set(calState.year, calState.month, 1)
        }
        val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
        // Monday = 1 in our grid. Calendar.DAY_OF_WEEK: Sunday=1, Monday=2...
        val firstDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)
        val offset = if (firstDayOfWeek == Calendar.SUNDAY) 6 else firstDayOfWeek - 2

        val entriesByDay = entries.associateBy { entry ->
            val c = Calendar.getInstance().apply { timeInMillis = entry.bedtime }
            c.get(Calendar.DAY_OF_MONTH)
        }

        val totalCells = offset + daysInMonth
        val rows = (totalCells + 6) / 7

        for (row in 0 until rows) {
            Row(modifier = Modifier.fillMaxWidth()) {
                for (col in 0..6) {
                    val cellIndex = row * 7 + col
                    val day = cellIndex - offset + 1

                    if (day in 1..daysInMonth) {
                        val entry = entriesByDay[day]
                        DayCell(
                            day = day,
                            entry = entry,
                            modifier = Modifier.weight(1f),
                            onClick = {
                                if (entry != null) {
                                    onDayClick(entry.id)
                                } else {
                                    val dateMillis = Calendar.getInstance().apply {
                                        set(calState.year, calState.month, day, 0, 0, 0)
                                        set(Calendar.MILLISECOND, 0)
                                    }.timeInMillis
                                    onDayClickWithDate(dateMillis)
                                }
                            }
                        )
                    } else {
                        Box(modifier = Modifier.weight(1f).aspectRatio(1f))
                    }
                }
            }
        }
    }
}

@Composable
private fun DayCell(
    day: Int,
    entry: NightEntry?,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .aspectRatio(1f)
            .padding(2.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(if (entry != null) SurfaceDark else MaterialTheme.colorScheme.surface)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                "$day",
                style = MaterialTheme.typography.bodySmall,
                color = if (entry != null) StarGold else MaterialTheme.colorScheme.onSurfaceVariant
            )
            if (entry != null) {
                Text(
                    if (entry.totalWakeUpMinutes > 0) entry.formatEffectiveDuration() else entry.formatDuration(),
                    fontSize = 9.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(entry.mood.emoji, fontSize = 10.sp)
            }
        }
    }
}
