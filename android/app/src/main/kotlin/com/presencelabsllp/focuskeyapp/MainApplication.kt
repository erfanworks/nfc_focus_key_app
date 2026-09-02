package com.presencelabsllp.focuskeyapp

import android.app.Application
import android.util.Log
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
        val pid = android.os.Process.myPid()
        Log.e("!!!FOCUS_LOCK!!!", "⭐ MainApplication Created | PID: $pid")
    }
}
