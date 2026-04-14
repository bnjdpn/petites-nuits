package com.petitesnuits.app.ui.chart

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.data.repository.NightRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class ChartViewModel(repository: NightRepository) : ViewModel() {
    val last14Nights: StateFlow<List<NightEntry>> = repository.getLast14Nights()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    class Factory(private val repository: NightRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return ChartViewModel(repository) as T
        }
    }
}
