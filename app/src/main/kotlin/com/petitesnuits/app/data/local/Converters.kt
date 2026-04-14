package com.petitesnuits.app.data.local

import androidx.room.TypeConverter
import com.petitesnuits.app.data.model.Mood
import com.petitesnuits.app.data.model.WakeUp
import org.json.JSONArray
import org.json.JSONObject

class Converters {
    @TypeConverter
    fun fromMood(value: Mood): String = value.name

    @TypeConverter
    fun toMood(value: String): Mood = Mood.valueOf(value)

    @TypeConverter
    fun fromWakeUpList(value: List<WakeUp>): String {
        if (value.isEmpty()) return ""
        val array = JSONArray()
        value.forEach { wu ->
            array.put(JSONObject().apply {
                put("time", wu.time)
                put("durationMinutes", wu.durationMinutes)
                put("isFeeding", wu.isFeeding)
                put("note", wu.note)
            })
        }
        return array.toString()
    }

    @TypeConverter
    fun toWakeUpList(value: String): List<WakeUp> {
        if (value.isBlank()) return emptyList()
        return if (value.trimStart().startsWith("[")) {
            parseJson(value)
        } else {
            parseLegacyCsv(value)
        }
    }

    private fun parseJson(value: String): List<WakeUp> {
        return try {
            val array = JSONArray(value)
            (0 until array.length()).map { i ->
                val obj = array.getJSONObject(i)
                WakeUp(
                    time = obj.getLong("time"),
                    durationMinutes = obj.getInt("durationMinutes"),
                    isFeeding = obj.getBoolean("isFeeding"),
                    note = obj.optString("note", "")
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun parseLegacyCsv(value: String): List<WakeUp> {
        return try {
            value.split(";").map { item ->
                val parts = item.split(",")
                WakeUp(
                    time = parts[0].toLong(),
                    durationMinutes = parts[1].toInt(),
                    isFeeding = parts[2].toBoolean()
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }
}
