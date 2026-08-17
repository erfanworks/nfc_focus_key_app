package com.presencelabsllp.focuskeyapp

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray

class AppLockAccessibilityService : AccessibilityService() {

    private lateinit var prefs: SharedPreferences
    private var lastBlockedPackage: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return

        if (packageName == applicationContext.packageName) {
            lastBlockedPackage = null
            return
        }

        val isLockActive = prefs.getBoolean("flutter.is_lock_active", false)
        if (!isLockActive) return

        val lockedApps = getLockedApps()
        if (lockedApps.contains(packageName)) {
            if (lastBlockedPackage == packageName) return
            lastBlockedPackage = packageName
            launchShield(packageName)
        } else {
            lastBlockedPackage = null
        }
    }

    private fun getLockedApps(): Set<String> {
        val json = prefs.getString("flutter.locked_apps", null) ?: return emptySet()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).map { arr.getString(it) }.toSet()
        } catch (e: Exception) {
            emptySet()
        }
    }

    private fun launchShield(packageName: String) {
        val intent = ShieldActivity.createIntent(this, packageName)
        startActivity(intent)
    }

    override fun onInterrupt() {}
}
