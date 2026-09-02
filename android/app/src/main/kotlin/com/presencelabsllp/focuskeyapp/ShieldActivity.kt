package com.presencelabsllp.focuskeyapp

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.app.Activity

class ShieldActivity : Activity() {

    companion object {
        private const val EXTRA_PACKAGE_NAME = "locked_package_name"

        fun createIntent(context: Context, lockedPackageName: String): Intent {
            val intent = Intent(context, ShieldActivity::class.java)
            intent.putExtra(EXTRA_PACKAGE_NAME, lockedPackageName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            return intent
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Native full-screen overlay configuration
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }

        // Build Native UI Programmatically (Reliable & Instant)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#F0EBE2"))
            setPadding(80, 0, 80, 0)
        }

        // 1. Icon (Native placeholder)
        val icon = TextView(this).apply {
            text = "🔒"
            textSize = 50f
            gravity = Gravity.CENTER
        }

        // 2. Title
        val title = TextView(this).apply {
            text = "App Locked"
            textSize = 30f
            setTextColor(Color.parseColor("#1A1814"))
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 50, 0, 20)
        }

        // 3. Reminder Message from SharedPreferences
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val message = prefs.getString("flutter.cached_reminder_message", 
            "You pity the moth for confusing a lamp for the moon, yet here you are confusing a screen for the world…")
        
        val messageView = TextView(this).apply {
            text = message
            textSize = 15f
            setTextColor(Color.parseColor("#8A8278"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 20)
        }

        // 4. Subtitle
        val subtitle = TextView(this).apply {
            text = "Open Focus Key and scan your NFC key to unlock."
            textSize = 13f
            setTextColor(Color.parseColor("#B5AFA5"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 80)
        }

        // 5. Got It Button
        val btn = Button(this).apply {
            text = "Got it"
            setBackgroundColor(Color.parseColor("#1A1814"))
            setTextColor(Color.parseColor("#F7F4EE"))
            setOnClickListener { finish() }
        }

        root.addView(icon)
        root.addView(title)
        root.addView(messageView)
        root.addView(subtitle)
        root.addView(btn)

        setContentView(root)
    }

    override fun onBackPressed() {
        // Block back button
    }
}
