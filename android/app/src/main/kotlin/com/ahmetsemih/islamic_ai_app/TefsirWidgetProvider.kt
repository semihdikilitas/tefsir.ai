package com.ahmetsemih.islamic_ai_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import java.io.File

/**
 * Tefsir AI Ana Ekran Widget Provider.
 * home_widget paketi uzerinden Flutter'dan gelen veriyi gosterir.
 * Duvar kagidi resmi + ayet metnini birlikte goruntuler.
 */
class TefsirWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // home_widget SharedPreferences uzerinden veriyi oku
            val prefs = context.getSharedPreferences(
                "HomeWidgetPreferences",
                Context.MODE_PRIVATE
            )

            val verseText = prefs.getString("widget_verse_text", "\"Suphesiz guclukle beraber bir kolaylik vardir.\"")
            val surahName = prefs.getString("widget_surah_name", "Insirah Suresi, 5-6")

            views.setTextViewText(R.id.widget_verse_text, verseText)
            views.setTextViewText(R.id.widget_surah_name, surahName)

            // home_widget tarafindan kaydedilen duvar kagidi resmini yukle
            val imagePath = prefs.getString("widget_bg", null)
            if (imagePath != null) {
                try {
                    val imgFile = File(imagePath)
                    if (imgFile.exists()) {
                        val bitmap = BitmapFactory.decodeFile(imagePath)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_image, bitmap)
                        }
                    }
                } catch (_: Exception) {
                    // Resim yuklenemezse metin yine de gorunur
                }
            }

            // Tiklandiginda uygulamayi ac
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context, widgetId, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
