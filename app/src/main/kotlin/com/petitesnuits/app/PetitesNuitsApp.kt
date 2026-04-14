package com.petitesnuits.app

import android.app.Application
import com.petitesnuits.app.data.local.AppDatabase
import com.petitesnuits.app.data.repository.NightRepository

class PetitesNuitsApp : Application() {
    val database by lazy { AppDatabase.getInstance(this) }
    val repository by lazy { NightRepository(database.nightEntryDao()) }
}
