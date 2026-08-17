package com.presencelabsllp.focuskeyapp

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class ShieldActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.presencelabsllp.focuskeyapp/shield"
        private const val EXTRA_PACKAGE_NAME = "locked_package_name"

        fun createIntent(context: Context, lockedPackageName: String): Intent {
            val intent = withCachedEngine(MainApplication.SHIELD_ENGINE_ID).build(context)
            intent.putExtra(EXTRA_PACKAGE_NAME, lockedPackageName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            return intent
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val lockedPackageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("showShield", mapOf("packageName" to lockedPackageName))
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val lockedPackageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("showShield", mapOf("packageName" to lockedPackageName))
    }
}
