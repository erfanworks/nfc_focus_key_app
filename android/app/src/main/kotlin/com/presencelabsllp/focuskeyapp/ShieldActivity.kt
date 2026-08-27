package com.presencelabsllp.focuskeyapp

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class ShieldActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.presencelabsllp.focuskeyapp/app_lock"
        private const val EXTRA_PACKAGE_NAME = "locked_package_name"

        fun createIntent(context: Context, lockedPackageName: String): Intent {
            // Using withCachedEngine to reuse the engine pre-warmed in MainApplication
            val intent = withCachedEngine(MainApplication.SHIELD_ENGINE_ID).build(context)
            intent.putExtra(EXTRA_PACKAGE_NAME, lockedPackageName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            return intent
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sendShieldSignal()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        sendShieldSignal()
    }

    private fun sendShieldSignal() {
        val lockedPackageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""
        
        // Use a small delay to ensure Flutter side has time to set its method call handler
        // Especially since this might be running in a separate engine
        Handler(Looper.getMainLooper()).postDelayed({
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL)
                    .invokeMethod("showShield", mapOf("packageName" to lockedPackageName))
            }
        }, 500)
    }
}
