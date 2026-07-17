package com.ahmetsemih.islamic_ai_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var wallpaperPlugin: WallpaperPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        wallpaperPlugin = WallpaperPlugin(this, flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        wallpaperPlugin = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
