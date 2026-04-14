package com.petitesnuits.app.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

data class WakeUp(
    val time: Long,
    val durationMinutes: Int,
    val isFeeding: Boolean,
    val note: String = ""
)

@Entity(tableName = "night_entries")
data class NightEntry(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val bedtime: Long,
    val wakeUpTime: Long,
    val wakeUps: List<WakeUp> = emptyList(),
    val mood: Mood = Mood.OK,
    val notes: String = ""
) {
    val sleepDurationMillis: Long get() = wakeUpTime - bedtime
    val feedingCount: Int get() = wakeUps.count { it.isFeeding }
    val totalWakeUpMinutes: Int get() = wakeUps.sumOf { it.durationMinutes }
    val effectiveSleepMillis: Long
        get() = (sleepDurationMillis - (totalWakeUpMinutes * 60_000L)).coerceAtLeast(0L)

    fun formatEffectiveDuration(): String {
        val totalMinutes = effectiveSleepMillis / 60_000
        val hours = totalMinutes / 60
        val minutes = totalMinutes % 60
        return "${hours}h${minutes.toString().padStart(2, '0')}"
    }

    fun formatDuration(): String {
        val totalMinutes = sleepDurationMillis / 60_000
        val hours = totalMinutes / 60
        val minutes = totalMinutes % 60
        return "${hours}h${minutes.toString().padStart(2, '0')}"
    }
}
