package com.ahmetsemih.islamic_ai_app

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Sistem duvar kagidi ayarlamak icin Flutter-Dart ile Android arasi MethodChannel koprusu.
 * Kanal: com.ahmetsemih.islamic_ai_app/wallpaper
 */
class WallpaperPlugin(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    companion object {
        private const val CHANNEL = "com.ahmetsemih.islamic_ai_app/wallpaper"
    }

    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val assetPath = call.argument<String>("assetPath") ?: ""
                        setWallpaperFromAsset(assetPath, result)
                    }
                    "setWallpaperFromFile" -> {
                        val filePath = call.argument<String>("filePath") ?: ""
                        setWallpaperFromFile(filePath, result)
                    }
                    "saveToGallery" -> {
                        val filePath = call.argument<String>("filePath") ?: ""
                        saveToGallery(filePath, result)
                    }
                    "saveToPhotos" -> {
                        val assetPath = call.argument<String>("assetPath") ?: ""
                        saveAssetToGallery(assetPath, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Flutter asset'ten duvar kagidi ayarla.
     */
    private fun setWallpaperFromAsset(assetPath: String, result: MethodChannel.Result) {
        try {
            val assetManager = context.assets
            val cleanPath = assetPath.removePrefix("assets/").removePrefix("assets")
            val inputStream = assetManager.open("flutter_assets/$cleanPath")
                ?: assetManager.open(cleanPath)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream.close()

            if (bitmap == null) {
                result.error("NULL_BITMAP", "Asset bitmap olarak okunamadi: $cleanPath", null)
                return
            }

            val wallpaperManager = WallpaperManager.getInstance(context)
            wallpaperManager.setBitmap(bitmap)
            result.success(true)
        } catch (e: Exception) {
            result.error("WALLPAPER_ERROR", e.message ?: "Duvar kagidi ayarlanamadi", e.localizedMessage)
        }
    }

    /**
     * Dosya yolundan duvar kagidi ayarla (composite image icin).
     */
    private fun setWallpaperFromFile(filePath: String, result: MethodChannel.Result) {
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "Dosya bulunamadi: $filePath", null)
                return
            }

            val bitmap = BitmapFactory.decodeFile(filePath)
            if (bitmap == null) {
                result.error("NULL_BITMAP", "Dosya bitmap olarak okunamadi", null)
                return
            }

            val wallpaperManager = WallpaperManager.getInstance(context)
            wallpaperManager.setBitmap(bitmap)
            result.success(true)
        } catch (e: Exception) {
            result.error("WALLPAPER_ERROR", e.message ?: "Duvar kagidi ayarlanamadi", e.localizedMessage)
        }
    }

    /**
     * Dosya yolundaki gorseli galeriye kaydet.
     */
    private fun saveToGallery(filePath: String, result: MethodChannel.Result) {
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "Dosya bulunamadi: $filePath", null)
                return
            }

            val bitmap = BitmapFactory.decodeFile(filePath)
                ?: kotlin.run {
                    result.error("NULL_BITMAP", "Dosya okunamadi", null)
                    return
                }

            val filename = "tefsir_ai_${System.currentTimeMillis()}.png"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                    put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                    put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/TefsirAI")
                }
                val uri = context.contentResolver.insert(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values
                )
                uri?.let {
                    context.contentResolver.openOutputStream(it)?.use { out ->
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                    }
                }
            } else {
                val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                val destFile = File(dir, filename)
                FileOutputStream(destFile).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                }
                // Medya taramasi icin broadcast
                val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                intent.data = Uri.fromFile(destFile)
                context.sendBroadcast(intent)
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message ?: "Galeriye kaydedilemedi", e.localizedMessage)
        }
    }

    /**
     * Asset'teki gorseli galeriye kaydet (iOS benzeri davranis).
     */
    private fun saveAssetToGallery(assetPath: String, result: MethodChannel.Result) {
        try {
            val assetManager = context.assets
            val cleanPath = assetPath.removePrefix("assets/").removePrefix("assets")
            val inputStream = assetManager.open("flutter_assets/$cleanPath")
                ?: assetManager.open(cleanPath)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream.close()

            if (bitmap == null) {
                result.error("NULL_BITMAP", "Asset okunamadi", null)
                return
            }

            // Geçici dosyaya kaydet, sonra saveToGallery'i çağır
            val tempFile = File(context.cacheDir, "temp_save_${System.currentTimeMillis()}.png")
            FileOutputStream(tempFile).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            saveToGallery(tempFile.absolutePath, result)
            tempFile.delete()
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message ?: "Kaydedilemedi", e.localizedMessage)
        }
    }
}
