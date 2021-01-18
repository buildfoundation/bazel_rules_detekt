package io.buildfoundation.bazel.detekt.execute

import io.github.detekt.tooling.api.DetektCli
import java.io.PrintStream

interface Detekt {

    fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream)

    class Impl : Detekt {

        override fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream) {
            DetektCli.load().run(args = args, outputChannel = outputPrinter, errorChannel = errorPrinter)
        }
    }
}
