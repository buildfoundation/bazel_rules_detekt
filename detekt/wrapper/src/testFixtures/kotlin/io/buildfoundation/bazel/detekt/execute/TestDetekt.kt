package io.buildfoundation.bazel.detekt.execute

import java.io.PrintStream

internal class TestDetekt(private val executionResult: ExecutionResult) : Detekt {

    enum class ExecutionResult {
        Success, Failure
    }

    override fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream) {
        if (executionResult == ExecutionResult.Failure) {
            throw RuntimeException()
        }
    }
}