package com.presencelabsllp.focuskeyapp

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

class ShieldActivity : Activity() {

    companion object {
        private const val EXTRA_PACKAGE_NAME = "locked_package_name"

        fun createIntent(context: Context, lockedPackageName: String): Intent {
            val intent = Intent(context, ShieldActivity::class.java)
            intent.putExtra(EXTRA_PACKAGE_NAME, lockedPackageName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            return intent
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Instant window transition (0ms delay)
        overridePendingTransition(0, 0)
        
        // Prevent screen capture / recents preview of underlying app
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val message = prefs.getString("flutter.cached_reminder_message", 
            prefs.getString("cached_reminder_message",
            "You pity the moth for confusing a lamp for the moon, yet here you are confusing a screen for the world…")) ?: ""

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#F0EBE2"))
            setPadding(dpToPx(28), 0, dpToPx(28), 0)
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

            setOnClickListener { goToHomeScreenAndFinish() }
        }

        root.addView(iconContainer)
        root.addView(title)
        root.addView(messageView)
        root.addView(subtitle)
        root.addView(btn)

        setContentView(root)
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    override fun onBackPressed() {
        goToHomeScreenAndFinish()
    }

    override fun finish() {
        super.finish()
        overridePendingTransition(0, 0)
    }

    private fun goToHomeScreenAndFinish() {
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION
            }
            startActivity(homeIntent)
            overridePendingTransition(0, 0)
        } catch (e: Exception) {
            Log.e("ShieldActivity", "Failed to go home: ${e.message}")
        }
        finish()
        overridePendingTransition(0, 0)
    }
}
