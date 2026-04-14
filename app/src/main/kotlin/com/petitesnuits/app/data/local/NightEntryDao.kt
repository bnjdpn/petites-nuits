package com.petitesnuits.app.data.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import com.petitesnuits.app.data.model.NightEntry
import kotlinx.coroutines.flow.Flow

@Dao
interface NightEntryDao {
    @Query("SELECT * FROM night_entries ORDER BY bedtime DESC")
    fun getAllEntries(): Flow<List<NightEntry>>

    @Query("SELECT * FROM night_entries WHERE id = :id")
    suspend fun getById(id: Int): NightEntry?

    @Query("SELECT * FROM night_entries ORDER BY bedtime DESC LIMIT 14")
    fun getLast14Nights(): Flow<List<NightEntry>>

    @Query("SELECT * FROM night_entries WHERE bedtime >= :startOfMonth AND bedtime < :endOfMonth ORDER BY bedtime ASC")
    fun getEntriesForMonth(startOfMonth: Long, endOfMonth: Long): Flow<List<NightEntry>>

    @Insert
    suspend fun insert(entry: NightEntry)

    @Update
    suspend fun update(entry: NightEntry)

    @Delete
    suspend fun delete(entry: NightEntry)
}
