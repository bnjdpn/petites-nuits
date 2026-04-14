package com.petitesnuits.app.ui.table

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.petitesnuits.app.data.model.NightEntry
import com.petitesnuits.app.data.repository.NightRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class TableViewModel(private val repository: NightRepository) : ViewModel() {
    val entries: StateFlow<List<NightEntry>> = repository.getAllEntries()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun delete(entry: NightEntry) {
        viewModelScope.launch { repository.delete(entry) }
    }

    class Factory(private val repository: NightRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return TableViewModel(repository) as T
        }
    }
}
