package com.petitesnuits.app.ui.calendar

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.data.repository.NightRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import java.util.Calendar

data class CalendarUiState(
    val year: Int,
    val month: Int // 0-based (Calendar.JANUARY = 0)
)

class CalendarViewModel(private val repository: NightRepository) : ViewModel() {
    private val now = Calendar.getInstance()

    private val _calendarState = MutableStateFlow(
        CalendarUiState(year = now.get(Calendar.YEAR), month = now.get(Calendar.MONTH))
    )
    val calendarState: StateFlow<CalendarUiState> = _calendarState.asStateFlow()

    @OptIn(ExperimentalCoroutinesApi::class)
    val entries: StateFlow<List<NightEntry>> = _calendarState.flatMapLatest { state ->
        val start = Calendar.getInstance().apply {
            set(state.year, state.month, 1, 0, 0, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val end = Calendar.getInstance().apply {
            set(state.year, state.month, 1, 0, 0, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.MONTH, 1)
        }
        repository.getEntriesForMonth(start.timeInMillis, end.timeInMillis)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun previousMonth() {
        _calendarState.value = _calendarState.value.let { state ->
            val cal = Calendar.getInstance().apply { set(state.year, state.month, 1) }
            cal.add(Calendar.MONTH, -1)
            CalendarUiState(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH))
        }
    }

    fun nextMonth() {
        _calendarState.value = _calendarState.value.let { state ->
            val cal = Calendar.getInstance().apply { set(state.year, state.month, 1) }
            cal.add(Calendar.MONTH, 1)
            CalendarUiState(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH))
        }
    }

    class Factory(private val repository: NightRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return CalendarViewModel(repository) as T
        }
    }
}
