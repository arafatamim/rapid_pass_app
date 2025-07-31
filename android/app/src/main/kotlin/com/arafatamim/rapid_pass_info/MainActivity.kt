package com.arafatamim.rapid_pass_info

import io.flutter.embedding.android.FlutterActivity
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun onPostResume()  {
        super.onPostResume()
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.navigationBarColor = 0 // for transparent nav bar
        window.statusBarColor = 0 // for transparent status bar
    }
}
