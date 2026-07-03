package tests.integration.android

import android.content.Context

class AndroidStatic(private val context: Context) {
    fun packageName(): String = context.packageName
}
