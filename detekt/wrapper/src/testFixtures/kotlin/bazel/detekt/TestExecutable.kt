package bazel.detekt

import bazel.detekt.Executable
import bazel.detekt.Result

internal class TestExecutable(private val result: Result) : Executable {

    override fun execute(args: Array<String>) = result
}