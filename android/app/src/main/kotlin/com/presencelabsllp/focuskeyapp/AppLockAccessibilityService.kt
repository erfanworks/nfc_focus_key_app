package com.presencelabsllp.focuskeyapp

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray
import org.json.JSONObject

class AppLockAccessibilityService : AccessibilityService() {

    private var lastBlockedPackage: String? = null
    private val TAG = "!!!FOCUS_LOCK!!!"

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.e(TAG, "CONNECTED_SUCCESSFULLY")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        val eventType = event.eventType
        val packageName = event.packageName?.toString() ?: "unknown"

        // --- OnePlus ডিবাগিং: ফোনের যেকোনো নড়াচড়া এখানে লগ দিবে ---
        Log.e(TAG, "RAW_EVENT -> Type: $eventType, App: $packageName")

        // লকের লজিক (শুধুমাত্র উইন্ডো চেঞ্জ হলে কাজ করবে)
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
        
        // OnePlus Compatibility: Check multiple possible key formats
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
