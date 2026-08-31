package com.presencelabsllp.focuskeyapp

import android.accessibilityservice.AccessibilityService
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray
import org.json.JSONObject

class AppLockAccessibilityService : AccessibilityService() {

    private var lastBlockedPackage: String? = null
    private val TAG = "!!!FOCUS_LOCK!!!"

    companion object {
        private const val NOTIFICATION_CHANNEL_ID = "focus_key_guard_channel"
        private const val NOTIFICATION_ID = 7821
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.e(TAG, "CONNECTED_SUCCESSFULLY")
        startGuardForeground()
    }

    /**
     * ColorOS/OxygenOS (OplusHansManager) aggressively freezes background
     * processes that don't hold an active foreground service, which silently
     * stops AccessibilityEvent dispatch even though the service stays "bound".
     * Running as a foreground service with a low-priority notification tells
     * the OS this process is actively needed, preventing the freeze.
     */
    private fun startGuardForeground() {
        try {
            createNotificationChannelIfNeeded()

            val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
            val contentPendingIntent = openAppIntent?.let {
                PendingIntent.getActivity(
                    this, 0, it,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
            }

            val notification = Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setContentTitle("Focus Key")
                .setContentText("Guarding your locked apps")
                .setSmallIcon(applicationInfo.icon)
                .setOngoing(true)
                .setContentIntent(contentPendingIntent)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }

            Log.e(TAG, "FOREGROUND_GUARD_STARTED")
        } catch (e: Exception) {
            Log.e(TAG, "FOREGROUND_GUARD_FAILED: ${e.message}")
        }
    }

    private fun createNotificationChannelIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = manager.getNotificationChannel(NOTIFICATION_CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Focus Key Guard",
                    NotificationManager.IMPORTANCE_MIN
                )
                channel.description = "Keeps app locking active in the background"
                channel.setShowBadge(false)
                manager.createNotificationChannel(channel)
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val eventType = event.eventType
        val packageName = event.packageName?.toString() ?: "unknown"

        Log.e(TAG, "RAW_EVENT -> Type: $eventType, App: $packageName")

        if (eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            processLockCheck(packageName)
        }
    }

    private fun processLockCheck(packageName: String) {
        if (packageName == applicationContext.packageName ||
            packageName == "com.android.systemui" ||
            packageName.contains("launcher") ||
            packageName.contains("settings")) {
            return
        }

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val isLockActive = prefs.getBoolean("flutter.is_lock_active", false) ||
                prefs.getBoolean("is_lock_active", false) ||
                prefs.getBoolean("flutter.flutter.is_lock_active", false)

        if (!isLockActive) return

        val json = prefs.getString("flutter.locked_apps", null) ?: return

        if (isPackageInLockedList(packageName, json)) {
            if (lastBlockedPackage == packageName) return
            lastBlockedPackage = packageName

            Log.e(TAG, ">>> LOCKING: $packageName <<<")

            try {
                val intent = ShieldActivity.createIntent(this, packageName)
                startActivity(intent)
            } catch (e: Exception) {
                Log.e(TAG, "Launch error: ${e.message}")
            }
        } else {
            lastBlockedPackage = null
        }
    }

    private fun isPackageInLockedList(target: String, json: String): Boolean {
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val item = arr.get(i)
                if (item is String && item == target) return true
                if (item is JSONObject && item.optString("packageName") == target) return true
            }
        } catch (e: Exception) {}
        return false
    }

    override fun onInterrupt() {
        Log.e(TAG, "SERVICE_INTERRUPTED")
    }
}