package io.buildfoundation.bazel.detekt.execute

internal class TestExecutable(private val result: Result) : Executable {

    override fun execute(args: Array<String>) = result
}