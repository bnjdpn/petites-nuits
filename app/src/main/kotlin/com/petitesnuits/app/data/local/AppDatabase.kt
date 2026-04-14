package com.petitesnuits.app.data.local

import android.content.Context
import android.util.Log
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.petitesnuits.app.data.model.NightEntry
import java.io.File

@Database(entities = [NightEntry::class], version = 3, exportSchema = false)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun nightEntryDao(): NightEntryDao

    companion object {
        private const val DB_NAME = "petites_nuits.db"
        private const val TAG = "AppDatabase"

        @Volatile
        private var INSTANCE: AppDatabase? = null

        /**
         * Migration v1 → v2 :
         * - Suppression de la colonne feedingCount
         * - wakeUps passe de "ts1,ts2" (Long) à "ts1,dur,feeding;ts2,dur,feeding" (WakeUp)
         * - Les N premiers réveils sont marqués comme tétées (N = ancien feedingCount)
         */
        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL("""
                    CREATE TABLE IF NOT EXISTS night_entries_new (
                        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        bedtime INTEGER NOT NULL,
                        wakeUpTime INTEGER NOT NULL,
                        wakeUps TEXT NOT NULL DEFAULT '',
                        mood TEXT NOT NULL DEFAULT 'OK',
                        notes TEXT NOT NULL DEFAULT ''
                    )
                """)

                val cursor = db.query(
                    "SELECT id, bedtime, wakeUpTime, wakeUps, feedingCount, mood, notes FROM night_entries"
                )
                cursor.use {
                    while (it.moveToNext()) {
                        val id = it.getInt(0)
                        val bedtime = it.getLong(1)
                        val wakeUpTime = it.getLong(2)
                        val oldWakeUps = it.getString(3) ?: ""
                        val feedingCount = it.getInt(4)
                        val mood = it.getString(5) ?: "OK"
                        val notes = it.getString(6) ?: ""

                        val newWakeUps = convertWakeUps(oldWakeUps, feedingCount)

                        db.execSQL(
                            """INSERT INTO night_entries_new (id, bedtime, wakeUpTime, wakeUps, mood, notes)
                               VALUES (?, ?, ?, ?, ?, ?)""",
                            arrayOf<Any>(id, bedtime, wakeUpTime, newWakeUps, mood, notes)
                        )
                    }
                }

                db.execSQL("DROP TABLE night_entries")
                db.execSQL("ALTER TABLE night_entries_new RENAME TO night_entries")
            }

            private fun convertWakeUps(oldWakeUps: String, feedingCount: Int): String {
                if (oldWakeUps.isBlank()) return ""
                val timestamps = oldWakeUps.split(",").mapNotNull { it.trim().toLongOrNull() }
                if (timestamps.isEmpty()) return ""
                return timestamps.mapIndexed { index, ts ->
                    val isFeeding = index < feedingCount
                    "$ts,0,$isFeeding"
                }.joinToString(";")
            }
        }

        /**
         * Migration v2 → v3 :
         * - WakeUp serialization switches from CSV to JSON (handled in Converters)
         * - SQL schema unchanged (wakeUps column remains TEXT)
         */
        private val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(db: SupportSQLiteDatabase) {
                // No-op: serialization format change is transparent to Room
            }
        }

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: createDatabase(context).also { INSTANCE = it }
            }
        }

        private fun createDatabase(context: Context): AppDatabase {
            val db = buildDatabase(context)
            return try {
                db.openHelper.writableDatabase
                db
            } catch (e: Exception) {
                Log.e(TAG, "Échec ouverture DB, backup puis recréation", e)
                db.close()
                backupDatabase(context)
                context.applicationContext.deleteDatabase(DB_NAME)
                buildDatabase(context)
            }
        }

        private fun buildDatabase(context: Context): AppDatabase {
            return Room.databaseBuilder(
                context.applicationContext,
                AppDatabase::class.java,
                DB_NAME
            )
                .addMigrations(MIGRATION_1_2, MIGRATION_2_3)
                .fallbackToDestructiveMigration()
                .build()
        }

        private fun backupDatabase(context: Context) {
            try {
                val dbFile = context.getDatabasePath(DB_NAME)
                if (dbFile.exists()) {
                    val backupDir = File(context.filesDir, "db_backups")
                    backupDir.mkdirs()
                    val timestamp = System.currentTimeMillis()
                    dbFile.copyTo(
                        File(backupDir, "petites_nuits_$timestamp.db"),
                        overwrite = true
                    )
                    val walFile = File(dbFile.path + "-wal")
                    if (walFile.exists()) {
                        walFile.copyTo(
                            File(backupDir, "petites_nuits_${timestamp}.db-wal"),
                            overwrite = true
                        )
                    }
                    Log.i(TAG, "DB sauvegardée dans ${backupDir.path}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Échec backup DB", e)
            }
        }
    }
}
