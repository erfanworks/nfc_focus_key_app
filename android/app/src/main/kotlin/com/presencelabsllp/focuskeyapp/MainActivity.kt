package com.presencelabsllp.focuskeyapp

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.presencelabsllp.focuskeyapp/app_lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityPermissionGranted" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }
                "isOverlayPermissionGranted" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                    result.success(null)
                }
                "debugPrintPrefs" -> {
                    debugPrintSharedPreferences()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun debugPrintSharedPreferences() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val allEntries = prefs.all
        Log.e("!!!FOCUS_LOCK!!!", "--- CURRENT PREFERENCES ---")
        for ((key, value) in allEntries) {
            Log.e("!!!FOCUS_LOCK!!!", "$key: $value")
        }
        Log.e("!!!FOCUS_LOCK!!!", "---------------------------")
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val serviceClassName = AppLockAccessibilityService::class.java.name
        val expectedComponentName = "$packageName/$serviceClassName"
        
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            if (splitter.next().equals(expectedComponentName, ignoreCase = true)) return true
        }
        return false
    }
}
