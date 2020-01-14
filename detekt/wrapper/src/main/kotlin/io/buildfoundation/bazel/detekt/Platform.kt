package io.buildfoundation.bazel.detekt

import kotlin.system.exitProcess

internal interface Platform {

    fun exit(code: Int)

    class Impl : Platform {

        override fun exit(code: Int) = exitProcess(code)
    }
}