package io.buildfoundation.bazel.detekt

internal class TestPlatform : Platform {

    var exitCode = Int.MIN_VALUE

    override fun exit(code: Int) {
        exitCode = code
    }
}