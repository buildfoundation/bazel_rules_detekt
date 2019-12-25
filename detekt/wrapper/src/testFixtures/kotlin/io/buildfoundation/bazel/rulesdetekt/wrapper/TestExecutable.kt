package io.buildfoundation.bazel.rulesdetekt.wrapper

internal class TestExecutable(private val result: Result) : Executable {

    override fun execute(args: Array<String>) = result
}