package com.presencelabsllp.focuskeyapp

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class AppLockAccessibilityService : AccessibilityService() {

    private val TAG = "!!!FOCUS_LOCK!!!"

    // ---- WindowManager Overlay ----
    private var windowManager: WindowManager? = null
    private var currentShieldView: View? = null
    private var currentShieldPackage: String? = null

    // ---- In-Memory Cache for Instant Lock Check (< 1ms) ----
    @Volatile private var cachedIsLockActive: Boolean = false
    @Volatile private var cachedLockedApps = HashSet<String>()
    @Volatile private var cachedReminderMessage: String =
        "You pity the moth for confusing a lamp for the moon, yet here you are confusing a screen for the world…"

    private var prefsListener: SharedPreferences.OnSharedPreferenceChangeListener? = null

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
            handler.postDelayed(this, 400)
        }
    }

    // ----------------------------------------------------------------
    //  Service Lifecycle
    // ----------------------------------------------------------------

    override fun onServiceConnected() {
        super.onServiceConnected()

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOWS_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 10L
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
        serviceInfo = info

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefsListener = SharedPreferences.OnSharedPreferenceChangeListener { _, _ ->
            updateCache()
        }
        prefs.registerOnSharedPreferenceChangeListener(prefsListener)
        updateCache()

        Log.e(TAG, "🟢 SERVICE_CONNECTED: Overlay-based Shield Service ready.")

        startUsagePolling()
    }

    override fun onInterrupt() {
        Log.e(TAG, "⚠️ SERVICE_INTERRUPTED")
        stopUsagePolling()
    }

    override fun onDestroy() {
        super.onDestroy()
        removeShieldOverlay()
        stopUsagePolling()
        prefsListener?.let {
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .unregisterOnSharedPreferenceChangeListener(it)
        }
        Log.e(TAG, "🔴 SERVICE_DESTROYED")
    }

    // ----------------------------------------------------------------
    //  SharedPreferences Cache Update
    // ----------------------------------------------------------------

    private fun updateCache() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            val isActive = try {
                prefs.getBoolean("flutter.is_lock_active", false) ||
                        prefs.getBoolean("is_lock_active", false)
            } catch (e: Exception) {
                prefs.getString("flutter.is_lock_active", "false") == "true" ||
                        prefs.getString("is_lock_active", "false") == "true"
            }
            cachedIsLockActive = isActive

            val json = prefs.getString("flutter.locked_apps", null)
                ?: prefs.getString("locked_apps", null)

            val newSet = HashSet<String>()
            if (json != null) {
                try {
                    val arr = JSONArray(json)
                    for (i in 0 until arr.length()) {
                        val item = arr.get(i)
                        if (item is String && item.isNotEmpty()) {
                            newSet.add(item)
                        } else if (item is JSONObject) {
                            val pkg = item.optString("packageName")
                            if (pkg.isNotEmpty()) newSet.add(pkg)
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ CACHE_JSON_ERROR: ${e.message}")
                }
            }
            cachedLockedApps = newSet

            val msg = prefs.getString("flutter.cached_reminder_message", null)
                ?: prefs.getString("cached_reminder_message", null)
            if (!msg.isNullOrEmpty()) {
                cachedReminderMessage = msg
            }

            Log.e(TAG, "🔄 CACHE_UPDATED: active=$cachedIsLockActive, lockedCount=${cachedLockedApps.size}")
        } catch (e: Exception) {
            Log.e(TAG, "❌ CACHE_UPDATE_ERROR: ${e.message}")
        }
    }

    // ----------------------------------------------------------------
    //  Accessibility Event Handler
    // ----------------------------------------------------------------

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val pkg = event?.packageName?.toString() ?: return
        val type = event.eventType

        if (type == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
            type == AccessibilityEvent.TYPE_WINDOWS_CHANGED
        ) {
            processLockCheck(pkg)
        }
    }

    // ----------------------------------------------------------------
    //  UsageStats Polling
    // ----------------------------------------------------------------

    private fun startUsagePolling() {
        if (isPolling) return
        if (!hasUsageStatsPermission()) {
            Log.e(TAG, "⚠️ USAGE_POLL: Usage stats permission not granted.")
            return
        }
        isPolling = true
        handler.post(pollingRunnable)
        Log.e(TAG, "📊 USAGE_POLL: Polling started")
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
        // 1. Ignore events generated by our own app or overlay window itself
        if (packageName == applicationContext.packageName) {
            return
        }

        // 2. If user switches to home launcher, system UI, or settings, remove shield
        if (packageName == "com.android.systemui" ||
            packageName.contains("launcher") ||
            packageName.contains("settings")
        ) {
            if (currentShieldView != null) {
                removeShieldOverlay()
            }
            return
        }

        // 3. If lock is deactivated, remove shield
        if (!cachedIsLockActive) {
            if (currentShieldView != null) {
                removeShieldOverlay()
            }
            return
        }

        // 4. Check if target package is in locked list
        if (cachedLockedApps.contains(packageName)) {
            Log.e(TAG, "🎯 MATCH: $packageName is LOCKED → showing Shield Overlay")
            showShieldOverlay(packageName)
        } else {
            // Target package is an unlocked app → remove shield
            if (currentShieldView != null) {
                removeShieldOverlay()
            }
        }
    }

    // ----------------------------------------------------------------
    //  Instant Premium Overlay Shield
    // ----------------------------------------------------------------

    private fun showShieldOverlay(packageName: String) {
        if (currentShieldView != null && currentShieldPackage == packageName) {
            return
        }

        removeShieldOverlay()

        try {
            val shieldView = createShieldView(cachedReminderMessage)

            val layoutParams = WindowManager.LayoutParams().apply {
                type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                }
                format = PixelFormat.TRANSLUCENT
                flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_FULLSCREEN or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                width = WindowManager.LayoutParams.MATCH_PARENT
                height = WindowManager.LayoutParams.MATCH_PARENT
                gravity = Gravity.CENTER
            }

            windowManager?.addView(shieldView, layoutParams)
            currentShieldView = shieldView
            currentShieldPackage = packageName
            Log.e(TAG, "🚀 SHIELD_OVERLAY_ADDED instantly for $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "❌ SHIELD_OVERLAY_FAILED: ${e.message}, attempting Activity fallback")
            launchShieldActivity(packageName)
        }
    }

    private fun removeShieldOverlay() {
        val view = currentShieldView ?: return
        try {
            windowManager?.removeViewImmediate(view)
        } catch (e: Exception) {
            try {
                windowManager?.removeView(view)
            } catch (_: Exception) {}
        } finally {
            currentShieldView = null
            currentShieldPackage = null
            Log.e(TAG, "🔴 SHIELD_OVERLAY_REMOVED")
        }
    }

    private fun createShieldView(message: String): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#F0EBE2"))
            setPadding(dpToPx(28), 0, dpToPx(28), 0)
            isClickable = true
            isFocusable = true
            isFocusableInTouchMode = true
        }

        // 1. Circular Icon Container
        val iconContainer = FrameLayout(this).apply {
            val size = dpToPx(72)
            layoutParams = LinearLayout.LayoutParams(size, size).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#24C4A97D"))
            }
        }

        val iconText = TextView(this).apply {
            text = "🔒"
            textSize = 28f
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        iconContainer.addView(iconText)

        // 2. Title ("App Locked")
        val title = TextView(this).apply {
            text = "App Locked"
            textSize = 30f
            setTextColor(Color.parseColor("#1A1814"))
            typeface = Typeface.create(Typeface.SERIF, Typeface.NORMAL)
            gravity = Gravity.CENTER
            setPadding(0, dpToPx(28), 0, dpToPx(12))
        }

        // 3. Reminder Message
        val messageView = TextView(this).apply {
            text = message
            textSize = 14f
            setTextColor(Color.parseColor("#8A8278"))
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.3f)
            setPadding(0, 0, 0, dpToPx(8))
        }

        // 4. Subtitle
        val subtitle = TextView(this).apply {
            text = "Open Focus Key and scan your NFC key to unlock."
            textSize = 13f
            setTextColor(Color.parseColor("#B5AFA5"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(36))
        }

        // 5. "Got it" Pill Button
        val btn = Button(this).apply {
            text = "Got it"
            textSize = 15f
            setTextColor(Color.parseColor("#F7F4EE"))
            isAllCaps = false
            typeface = Typeface.DEFAULT_BOLD

            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(26).toFloat()
                setColor(Color.parseColor("#1A1814"))
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(52)
            )

            setOnClickListener {
                performGlobalAction(GLOBAL_ACTION_HOME)
                handler.postDelayed({
                    removeShieldOverlay()
                }, 500)
            }
        }

        root.addView(iconContainer)
        root.addView(title)
        root.addView(messageView)
        root.addView(subtitle)
        root.addView(btn)

        root.requestFocus()
        root.setOnKeyListener { _, keyCode, event ->
            if (keyCode == KeyEvent.KEYCODE_BACK && event.action == KeyEvent.ACTION_UP) {
                performGlobalAction(GLOBAL_ACTION_HOME)
                handler.postDelayed({
                    removeShieldOverlay()
                }, 500)
                true
            } else {
                false
            }
        }

        return root
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    private fun launchShieldActivity(packageName: String) {
        try {
            val intent = ShieldActivity.createIntent(this, packageName)
            startActivity(intent)
            Log.e(TAG, "🚀 SHIELD_ACTIVITY_LAUNCHED for $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "❌ SHIELD_ACTIVITY_LAUNCH_FAILED: ${e.message}")
        }
    }
}
