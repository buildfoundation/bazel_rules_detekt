package io.buildfoundation.bazel.detekt

import io.buildfoundation.bazel.detekt.Platform

internal class TestPlatform : Platform {

    var exitCode = Int.MIN_VALUE

    override fun exit(code: Int) {
        exitCode = code
    }
}