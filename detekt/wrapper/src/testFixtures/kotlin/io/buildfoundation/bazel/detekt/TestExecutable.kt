package io.buildfoundation.bazel.detekt

import io.buildfoundation.bazel.detekt.Executable
import io.buildfoundation.bazel.detekt.Result

internal class TestExecutable(private val result: Result) : Executable {

    override fun execute(args: Array<String>) = result
}