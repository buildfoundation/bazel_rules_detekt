package bazel.detekt

import io.gitlab.arturbosch.detekt.cli.buildRunner
import java.io.PrintStream

internal interface Detekt {

    fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream)

    class Impl : Detekt {

        override fun execute(args: Array<String>, outputPrinter: PrintStream, errorPrinter: PrintStream) {
            buildRunner(args, outputPrinter, errorPrinter).execute()
        }
    }
}