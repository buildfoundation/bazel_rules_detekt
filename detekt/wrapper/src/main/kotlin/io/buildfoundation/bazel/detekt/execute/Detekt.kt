package io.buildfoundation.bazel.detekt.execute

import io.gitlab.arturbosch.detekt.cli.CliRunner
import java.io.PrintStream

interface Detekt {

    fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream)

    class Impl : Detekt {

        private val runner by lazy { CliRunner() }

        override fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream) {
            runner.run(args, outputPrinter, errorPrinter).error?.let { resultError ->
                throw resultError
            }
        }
    }
}
