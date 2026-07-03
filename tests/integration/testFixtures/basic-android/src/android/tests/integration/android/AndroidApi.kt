package tests.integration.android

import android.content.Context

object AndroidApi {
    fun packageName(context: Context): String = context.packageName
}
