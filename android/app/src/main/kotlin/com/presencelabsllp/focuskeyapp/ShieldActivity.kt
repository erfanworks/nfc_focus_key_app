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
import android.widget.LinearLayout
import android.widget.RelativeLayout
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
            intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
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

        val root = RelativeLayout(this).apply {
            setBackgroundColor(Color.parseColor("#18181A"))
            setPadding(dpToPx(28), dpToPx(48), dpToPx(28), dpToPx(36))
        }

        // Center Content Container (Icon, Title, Reminder Message)
        val centerContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
        }

        val centerParams = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.MATCH_PARENT,
            RelativeLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            addRule(RelativeLayout.CENTER_IN_PARENT)
        }

        // 1. Hourglass Icon
        val iconText = TextView(this).apply {
            text = "⌛"
            textSize = 54f
            setTextColor(Color.parseColor("#0085FF"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(24))
        }

        // 2. Title ("App Locked")
        val title = TextView(this).apply {
            text = "App Locked"
            textSize = 26f
            setTextColor(Color.parseColor("#FFFFFF"))
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(12))
        }

        // 3. Reminder Message
        val messageView = TextView(this).apply {
            text = message
            textSize = 15f
            setTextColor(Color.parseColor("#C7C7CC"))
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.3f)
        }

        centerContainer.addView(iconText)
        centerContainer.addView(title)
        centerContainer.addView(messageView)

        // Bottom Container pinned at the bottom of the screen
        val bottomContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.BOTTOM
        }

        val bottomParams = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.MATCH_PARENT,
            RelativeLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
        }

        // 4. "Got it" Pill Button
        val btnGotIt = Button(this).apply {
            text = "Got it"
            textSize = 16f
            setTextColor(Color.parseColor("#FFFFFF"))
            isAllCaps = false
            typeface = Typeface.DEFAULT_BOLD

            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(26).toFloat()
                setColor(Color.parseColor("#00C2FF"))
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(52)
            ).apply {
                setMargins(0, 0, 0, dpToPx(12))
            }

            setOnClickListener { goToHomeScreenAndFinish() }
        }

        // 5. "Close" Pill Outline Button
        val btnClose = Button(this).apply {
            text = "Close"
            textSize = 16f
            setTextColor(Color.parseColor("#E5E5EA"))
            isAllCaps = false
            typeface = Typeface.DEFAULT

            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(26).toFloat()
                setColor(Color.parseColor("#2C2C2E"))
                setStroke(dpToPx(1), Color.parseColor("#3A3A3C"))
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(52)
            )

            setOnClickListener { goToHomeScreenAndFinish() }
        }

        bottomContainer.addView(btnGotIt)
        bottomContainer.addView(btnClose)

        root.addView(centerContainer, centerParams)
        root.addView(bottomContainer, bottomParams)

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
