package com.petitesnuits.app.ui.stats

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.data.repository.NightRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.Calendar

data class StatsUiState(
    val averageDuration: String = "-",
    val bestNight: String = "-",
    val worstNight: String = "-",
    val averageWakeUps: String = "-",
    val averageFeedings: String = "-",
    val totalNights: Int = 0,
    val trend: String = "→"
)

class StatsViewModel(repository: NightRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(StatsUiState())
    val uiState: StateFlow<StatsUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            repository.getAllEntries().collect { entries ->
                if (entries.isEmpty()) {
                    _uiState.update { StatsUiState() }
                    return@collect
                }

                val avgMillis = entries.map { it.effectiveSleepMillis }.average().toLong()
                val best = entries.maxBy { it.effectiveSleepMillis }
                val worst = entries.minBy { it.effectiveSleepMillis }
                val avgWakeUps = entries.map { it.wakeUps.size }.average()
                val avgFeedings = entries.map { it.feedingCount }.average()

                val trend = computeTrend(entries)

                _uiState.update {
                    StatsUiState(
                        averageDuration = formatDuration(avgMillis),
                        bestNight = if (best.totalWakeUpMinutes > 0) best.formatEffectiveDuration() else best.formatDuration(),
                        worstNight = if (worst.totalWakeUpMinutes > 0) worst.formatEffectiveDuration() else worst.formatDuration(),
                        averageWakeUps = String.format("%.1f", avgWakeUps),
                        averageFeedings = String.format("%.1f", avgFeedings),
                        totalNights = entries.size,
                        trend = trend
                    )
                }
            }
        }
    }

    private fun computeTrend(entries: List<NightEntry>): String {
        val now = Calendar.getInstance()
        val oneWeekAgo = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -7) }
        val twoWeeksAgo = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -14) }

        val thisWeek = entries.filter { it.bedtime >= oneWeekAgo.timeInMillis && it.bedtime <= now.timeInMillis }
        val lastWeek = entries.filter { it.bedtime >= twoWeeksAgo.timeInMillis && it.bedtime < oneWeekAgo.timeInMillis }

        if (thisWeek.isEmpty() || lastWeek.isEmpty()) return "→"

        val avgThis = thisWeek.map { it.effectiveSleepMillis }.average()
        val avgLast = lastWeek.map { it.effectiveSleepMillis }.average()
        val diff = avgThis - avgLast

        return when {
            diff > 15 * 60_000 -> "↑"
            diff < -15 * 60_000 -> "↓"
            else -> "→"
        }
    }

    private fun formatDuration(millis: Long): String {
        val totalMinutes = millis / 60_000
        val hours = totalMinutes / 60
        val minutes = totalMinutes % 60
        return "${hours}h${minutes.toString().padStart(2, '0')}"
    }

    class Factory(private val repository: NightRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return StatsViewModel(repository) as T
        }
    }
}
