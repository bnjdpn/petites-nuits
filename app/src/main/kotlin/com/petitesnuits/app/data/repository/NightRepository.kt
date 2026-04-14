package com.petitesnuits.app.data.repository

import com.petitesnuits.app.data.local.NightEntryDao
import com.petitesnuits.app.data.model.NightEntry
import kotlinx.coroutines.flow.Flow

class NightRepository(private val dao: NightEntryDao) {
    fun getAllEntries(): Flow<List<NightEntry>> = dao.getAllEntries()
    suspend fun getById(id: Int): NightEntry? = dao.getById(id)
    fun getLast14Nights(): Flow<List<NightEntry>> = dao.getLast14Nights()
    fun getEntriesForMonth(startOfMonth: Long, endOfMonth: Long): Flow<List<NightEntry>> =
        dao.getEntriesForMonth(startOfMonth, endOfMonth)

    suspend fun insert(entry: NightEntry) = dao.insert(entry)
    suspend fun update(entry: NightEntry) = dao.update(entry)
    suspend fun delete(entry: NightEntry) = dao.delete(entry)
}
