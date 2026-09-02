package com.presencelabsllp.focuskeyapp

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray
import org.json.JSONObject

class AppLockAccessibilityService : AccessibilityService() {

    private val TAG = "!!!FOCUS_LOCK!!!"

    // ---- UsageStats polling (fallback mechanism) ----
    private val handler = Handler(Looper.getMainLooper())
    private var lastPolledPackage: String = ""
    private var isPolling = false

    private val pollingRunnable = object : Runnable {
        override fun run() {
            try {
                val foreground = getForegroundPackage()
                if (foreground != null && foreground != lastPolledPackage) {
                    lastPolledPackage = foreground
                    Log.e(TAG, "📊 USAGE_POLL: Foreground app changed → $foreground")
                    processLockCheck(foreground)
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ POLL_ERROR: ${e.message}")
            }
            handler.postDelayed(this, 500)
        }
    }

    // ----------------------------------------------------------------
    //  Service Lifecycle
    // ----------------------------------------------------------------

    override fun onServiceConnected() {
        super.onServiceConnected()

        // ✅ FIX 1: Set service info PROGRAMMATICALLY at runtime.
        // OEMs (especially OPPO/Vivo) often ignore the XML config.
        // This is the authoritative, always-respected registration path.
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPES_ALL_MASK
            feedbackType = AccessibilityServiceInfo.FEEDBACK_ALL_MASK
            notificationTimeout = 0L
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        }
        serviceInfo = info

        Log.e(TAG, "🟢 SERVICE_CONNECTED: serviceInfo set dynamically. Event mask = TYPES_ALL_MASK")

        // ✅ FIX 2: Start UsageStats polling as a fallback.
        // If OPPO suppresses accessibility events, polling ensures we still detect app switches.
        startUsagePolling()
    }

    override fun onInterrupt() {
        Log.e(TAG, "⚠️ SERVICE_INTERRUPTED")
        stopUsagePolling()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopUsagePolling()
        Log.e(TAG, "🔴 SERVICE_DESTROYED")
    }

    // ----------------------------------------------------------------
    //  Accessibility Event Handler (Primary Path)
    // ----------------------------------------------------------------

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val pkg = event?.packageName?.toString() ?: return
        val type = event.eventType

        Log.e(TAG, "📡 EVENT: pkg=$pkg | type=$type")

        if (type == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
            type == AccessibilityEvent.TYPE_VIEW_FOCUSED ||
            type == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
        ) {
            processLockCheck(pkg)
        }
    }

    // ----------------------------------------------------------------
    //  UsageStats Polling (Fallback / Secondary Path)
    // ----------------------------------------------------------------

    private fun startUsagePolling() {
        if (isPolling) return
        if (!hasUsageStatsPermission()) {
            Log.e(TAG, "⚠️ USAGE_POLL: Usage stats permission not granted. Polling disabled.")
            return
        }
        isPolling = true
        handler.post(pollingRunnable)
        Log.e(TAG, "📊 USAGE_POLL: Polling started (500ms interval)")
    }

    private fun stopUsagePolling() {
        isPolling = false
        handler.removeCallbacks(pollingRunnable)
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getForegroundPackage(): String? {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        // Query last 3 seconds to find the most recent foreground app
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, now - 3000, now)
        return stats
            ?.filter { it.lastTimeUsed > 0 }
            ?.maxByOrNull { it.lastTimeUsed }
            ?.packageName
    }

    // ----------------------------------------------------------------
    //  Lock Check Logic
    // ----------------------------------------------------------------

    private fun processLockCheck(packageName: String) {
        // Skip system packages and our own app
        if (packageName == applicationContext.packageName ||
            packageName == "com.android.systemui" ||
            packageName.contains("launcher") ||
            packageName.contains("settings")
        ) return

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Check if lock is active
        val isLockActive = try {
            prefs.getBoolean("flutter.is_lock_active", false) ||
                    prefs.getBoolean("is_lock_active", false)
        } catch (e: Exception) {
            prefs.getString("flutter.is_lock_active", "false") == "true"
        }

        if (!isLockActive) return

        val json = prefs.getString("flutter.locked_apps", null) ?: return

        if (isPackageInLockedList(packageName, json)) {
            Log.e(TAG, "🎯 MATCH: $packageName is LOCKED → launching Shield")
            launchShield(packageName)
        }
    }

    private fun launchShield(packageName: String) {
        if (!android.provider.Settings.canDrawOverlays(this)) {
            Log.e(TAG, "🚫 No overlay permission — cannot show shield")
            return
        }
        try {
            val intent = ShieldActivity.createIntent(this, packageName)
            startActivity(intent)
            Log.e(TAG, "🚀 SHIELD_LAUNCHED for $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "❌ SHIELD_LAUNCH_FAILED: ${e.message}")
        }
    }

    private fun isPackageInLockedList(target: String, json: String): Boolean {
        return try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val item = arr.get(i)
                if (item is String && item == target) return true
                if (item is JSONObject && item.optString("packageName") == target) return true
            }
            false
        } catch (e: Exception) {
            false
        }
    }
}
