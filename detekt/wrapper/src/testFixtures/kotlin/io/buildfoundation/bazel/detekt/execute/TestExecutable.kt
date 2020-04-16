package io.buildfoundation.bazel.detekt.execute

import io.buildfoundation.bazel.detekt.execute.Executable
import io.buildfoundation.bazel.detekt.execute.Result

internal class TestExecutable(private val result: Result) : Executable {

    override fun execute(args: Array<String>) = result
}