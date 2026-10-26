package com.presencelabsllp.focuskeyapp

import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import android.os.Build
import android.os.Process
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.presencelabsllp.focuskeyapp/app_lock"

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Consumes NFC intents to prevent system TagDispatcher popups
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityPermissionGranted" -> {
                    val enabled = isAccessibilityServiceEnabled()
                    Log.e("!!!FOCUS_LOCK!!!", "UI_CHECK: Accessibility Enabled? $enabled")
                    result.success(enabled)
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
                "requestNotificationPermission" -> {
                    requestNotificationPermissionIfNeeded()
                    result.success(null)
                }
                "isBatteryOptimizationIgnored" -> {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestIgnoreBatteryOptimization" -> {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                    intent.data = Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(null)
                }
                "isUsageAccessPermissionGranted" -> {
                    result.success(isUsageAccessPermissionGranted())
                }
                "requestUsageAccessPermission" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }
                "getPhoneBrand" -> {
                    result.success(Build.MANUFACTURER.lowercase())
                }
                "requestAutoStartPermission" -> {
                    openAutoStartSettings()
                    result.success(null)
                }
                "isDeviceAdminActive" -> {
                    result.success(isDeviceAdminActive())
                }
                "requestDeviceAdminActivation" -> {
                    requestDeviceAdminActivation()
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

    private fun isUsageAccessPermissionGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
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
    /**
     * Opens the OEM-specific "Auto Start" / "Background activity" settings screen.
     * Each manufacturer hides this in a different location under their custom ROM.
     * Without this enabled, ColorOS (OPPO/OnePlus) silently kills the accessibility binding.
     */
    private fun openAutoStartSettings() {
        val brand = Build.MANUFACTURER.lowercase()
        val intentsToTry: List<Intent> = when {
            // OPPO / OnePlus (ColorOS)
            brand.contains("oppo") || brand.contains("oneplus") -> listOf(
                Intent().setComponent(ComponentName("com.coloros.safecenter",
                    "com.coloros.permissionmanager.PermissionTopActivity")),
                Intent().setComponent(ComponentName("com.oppo.safe",
                    "com.oppo.safe.permission.startup.StartupAppListActivity")),
                Intent().setComponent(ComponentName("com.coloros.safecenter",
                    "com.coloros.safecenter.permission.startup.StartupAppListActivity")),
                Intent().setComponent(ComponentName("com.coloros.oppoguardelf",
                    "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity"))
            )
            // Vivo / iQOO (FuntouchOS / OriginOS)
            brand.contains("vivo") -> listOf(
                Intent().setComponent(ComponentName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")),
                Intent().setComponent(ComponentName("com.iqoo.secure",
                    "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")),
                Intent().setComponent(ComponentName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.PurviewTabActivity"))
            )
            // Xiaomi / POCO / Redmi (MIUI / HyperOS)
            brand.contains("xiaomi") || brand.contains("redmi") || brand.contains("poco") -> listOf(
                Intent("miui.intent.action.OP_AUTO_START").addCategory(Intent.CATEGORY_DEFAULT),
                Intent().setComponent(ComponentName("com.miui.securitycenter",
                    "com.miui.powercenter.PowerSettings")),
                Intent().setComponent(ComponentName("com.miui.securitycenter",
                    "com.miui.securitycenter.MainActivity"))
            )
            // Huawei / Honor (EMUI / MagicUI)
            brand.contains("huawei") || brand.contains("honor") -> listOf(
                Intent().setComponent(ComponentName("com.huawei.systemmanager",
                    "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")),
                Intent().setComponent(ComponentName("com.huawei.systemmanager",
                    "com.huawei.systemmanager.optimize.process.ProtectActivity"))
            )
            // Samsung (One UI)
            brand.contains("samsung") -> listOf(
                Intent().setComponent(ComponentName("com.samsung.android.lool",
                    "com.samsung.android.sm.ui.battery.BatteryActivity")),
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.parse("package:$packageName"))
            )
            // Generic fallback — open app info page
            else -> listOf(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.parse("package:$packageName"))
            )
        }

        for (intent in intentsToTry) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                Log.e("!!!FOCUS_LOCK!!!", "✅ AUTO_START: Opened settings for brand=$brand")
                return
            } catch (e: Exception) {
                Log.e("!!!FOCUS_LOCK!!!", "⚠️ AUTO_START: Intent failed, trying next... ${e.message}")
            }
        }
        Log.e("!!!FOCUS_LOCK!!!", "❌ AUTO_START: No working intent found for brand=$brand")
    }

    private fun isDeviceAdminActive(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponent = ComponentName(this, FocusKeyDeviceAdminReceiver::class.java)
        return dpm.isAdminActive(adminComponent)
    }

    private fun requestDeviceAdminActivation() {
        val adminComponent = ComponentName(this, FocusKeyDeviceAdminReceiver::class.java)
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
            putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Prevents Focus Key from being accidentally removed."
            )
        }
        startActivity(intent)
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                this, android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED

            if (!granted) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    1001
                )
            }
        }
    }
}
