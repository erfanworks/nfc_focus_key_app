package com.presencelabsllp.focuskeyapp

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MainApplication : Application() {

    companion object {
        const val SHIELD_ENGINE_ID = "shield_engine"
    }

    override fun onCreate() {
        super.onCreate()

        // Pre-warm the FlutterEngine for the shield to make it appear instantly
        val flutterEngine = FlutterEngine(this)
        
        // Ensure plugins are registered for the new engine
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        FlutterEngineCache.getInstance().put(SHIELD_ENGINE_ID, flutterEngine)
    }
}
