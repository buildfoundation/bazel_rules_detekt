package tests.integration.android

import android.content.Context

class AndroidClasspath(private val context: Context) {
    fun size(): Int? = AndroidApi.packageName(context)?.length
}
