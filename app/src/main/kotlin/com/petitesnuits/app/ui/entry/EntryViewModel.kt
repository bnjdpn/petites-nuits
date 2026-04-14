package com.petitesnuits.app.ui.entry

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.petitesnuits.app.data.model.Mood
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.data.model.WakeUp
import com.petitesnuits.app.data.repository.NightRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.Calendar

data class WakeUpUi(
    val hour: Int,
    val minute: Int,
    val durationMinutes: Int,
    val isFeeding: Boolean,
    val note: String = ""
)

data class EntryUiState(
    val bedtimeHour: Int = 20,
    val bedtimeMinute: Int = 0,
    val wakeUpHour: Int = 7,
    val wakeUpMinute: Int = 0,
    val wakeUps: List<WakeUpUi> = emptyList(),
    val mood: Mood = Mood.OK,
    val notes: String = "",
    val isEditing: Boolean = false,
    val editingId: Int = 0,
    val saved: Boolean = false,
    val selectedDateMillis: Long = System.currentTimeMillis()
)

class EntryViewModel(
    private val repository: NightRepository,
    private val entryId: Int?,
    initialDateMillis: Long?
) : ViewModel() {

    private val _uiState = MutableStateFlow(
        EntryUiState(selectedDateMillis = initialDateMillis ?: System.currentTimeMillis())
    )
    val uiState: StateFlow<EntryUiState> = _uiState.asStateFlow()

    init {
        if (entryId != null && entryId > 0) {
            viewModelScope.launch {
                repository.getById(entryId)?.let { entry ->
                    val bedCal = Calendar.getInstance().apply { timeInMillis = entry.bedtime }
                    val wakeCal = Calendar.getInstance().apply { timeInMillis = entry.wakeUpTime }
                    val wakeUpUis = entry.wakeUps.map { wu ->
                        val c = Calendar.getInstance().apply { timeInMillis = wu.time }
                        WakeUpUi(
                            hour = c.get(Calendar.HOUR_OF_DAY),
                            minute = c.get(Calendar.MINUTE),
                            durationMinutes = wu.durationMinutes,
                            isFeeding = wu.isFeeding,
                            note = wu.note
                        )
                    }
                    _uiState.update {
                        it.copy(
                            bedtimeHour = bedCal.get(Calendar.HOUR_OF_DAY),
                            bedtimeMinute = bedCal.get(Calendar.MINUTE),
                            wakeUpHour = wakeCal.get(Calendar.HOUR_OF_DAY),
                            wakeUpMinute = wakeCal.get(Calendar.MINUTE),
                            wakeUps = wakeUpUis,
                            mood = entry.mood,
                            notes = entry.notes,
                            isEditing = true,
                            editingId = entry.id,
                            selectedDateMillis = entry.bedtime
                        )
                    }
                }
            }
        }
    }

    fun setBedtime(hour: Int, minute: Int) {
        _uiState.update { it.copy(bedtimeHour = hour, bedtimeMinute = minute) }
    }

    fun setWakeUp(hour: Int, minute: Int) {
        _uiState.update { it.copy(wakeUpHour = hour, wakeUpMinute = minute) }
    }

    fun addWakeUp(hour: Int, minute: Int, durationMinutes: Int, isFeeding: Boolean, note: String = "") {
        _uiState.update {
            it.copy(wakeUps = it.wakeUps + WakeUpUi(hour, minute, durationMinutes, isFeeding, note))
        }
    }

    fun removeWakeUp(index: Int) {
        _uiState.update { it.copy(wakeUps = it.wakeUps.filterIndexed { i, _ -> i != index }) }
    }

    fun toggleWakeUpFeeding(index: Int) {
        _uiState.update {
            it.copy(wakeUps = it.wakeUps.mapIndexed { i, wu ->
                if (i == index) wu.copy(isFeeding = !wu.isFeeding) else wu
            })
        }
    }

    fun setWakeUpDuration(index: Int, durationMinutes: Int) {
        _uiState.update {
            it.copy(wakeUps = it.wakeUps.mapIndexed { i, wu ->
                if (i == index) wu.copy(durationMinutes = durationMinutes.coerceAtLeast(0)) else wu
            })
        }
    }

    fun setWakeUpNote(index: Int, note: String) {
        _uiState.update {
            it.copy(wakeUps = it.wakeUps.mapIndexed { i, wu ->
                if (i == index) wu.copy(note = note.take(100)) else wu
            })
        }
    }

    fun setMood(mood: Mood) {
        _uiState.update { it.copy(mood = mood) }
    }

    fun setNotes(notes: String) {
        _uiState.update { it.copy(notes = notes) }
    }

    fun setSelectedDate(millis: Long) {
        _uiState.update { it.copy(selectedDateMillis = millis) }
    }

    fun computeDuration(): String {
        val state = _uiState.value
        val bedMinutes = state.bedtimeHour * 60 + state.bedtimeMinute
        val wakeMinutes = state.wakeUpHour * 60 + state.wakeUpMinute
        val totalMinutes = if (wakeMinutes > bedMinutes) {
            wakeMinutes - bedMinutes
        } else {
            (24 * 60 - bedMinutes) + wakeMinutes
        }
        val hours = totalMinutes / 60
        val minutes = totalMinutes % 60
        val total = "${hours}h${minutes.toString().padStart(2, '0')}"

        val wakeUpMinutes = state.wakeUps.sumOf { it.durationMinutes }
        if (wakeUpMinutes == 0) return total

        val effectiveMinutes = (totalMinutes - wakeUpMinutes).coerceAtLeast(0)
        val effH = effectiveMinutes / 60
        val effM = effectiveMinutes % 60
        return "$total (effectif : ${effH}h${effM.toString().padStart(2, '0')})"
    }

    fun save() {
        viewModelScope.launch {
            val state = _uiState.value

            val baseCal = Calendar.getInstance().apply { timeInMillis = state.selectedDateMillis }

            val bedtime = Calendar.getInstance().apply {
                set(Calendar.YEAR, baseCal.get(Calendar.YEAR))
                set(Calendar.MONTH, baseCal.get(Calendar.MONTH))
                set(Calendar.DAY_OF_MONTH, baseCal.get(Calendar.DAY_OF_MONTH))
                set(Calendar.HOUR_OF_DAY, state.bedtimeHour)
                set(Calendar.MINUTE, state.bedtimeMinute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            val wakeUp = Calendar.getInstance().apply {
                timeInMillis = bedtime.timeInMillis
                set(Calendar.HOUR_OF_DAY, state.wakeUpHour)
                set(Calendar.MINUTE, state.wakeUpMinute)
                if (state.wakeUpHour < state.bedtimeHour ||
                    (state.wakeUpHour == state.bedtimeHour && state.wakeUpMinute <= state.bedtimeMinute)
                ) {
                    add(Calendar.DAY_OF_MONTH, 1)
                }
            }

            val wakeUps = state.wakeUps.map { wu ->
                val time = Calendar.getInstance().apply {
                    timeInMillis = bedtime.timeInMillis
                    set(Calendar.HOUR_OF_DAY, wu.hour)
                    set(Calendar.MINUTE, wu.minute)
                    if (wu.hour < state.bedtimeHour ||
                        (wu.hour == state.bedtimeHour && wu.minute <= state.bedtimeMinute)
                    ) {
                        add(Calendar.DAY_OF_MONTH, 1)
                    }
                }.timeInMillis
                WakeUp(
                    time = time,
                    durationMinutes = wu.durationMinutes,
                    isFeeding = wu.isFeeding,
                    note = wu.note
                )
            }

            val entry = NightEntry(
                id = if (state.isEditing) state.editingId else 0,
                bedtime = bedtime.timeInMillis,
                wakeUpTime = wakeUp.timeInMillis,
                wakeUps = wakeUps,
                mood = state.mood,
                notes = state.notes.trim()
            )

            if (state.isEditing) {
                repository.update(entry)
            } else {
                repository.insert(entry)
            }

            _uiState.update { it.copy(saved = true) }
        }
    }

    class Factory(
        private val repository: NightRepository,
        private val entryId: Int?,
        private val initialDateMillis: Long? = null
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return EntryViewModel(repository, entryId, initialDateMillis) as T
        }
    }
}
