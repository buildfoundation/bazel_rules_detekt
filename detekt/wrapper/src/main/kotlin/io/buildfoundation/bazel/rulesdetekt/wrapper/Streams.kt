package io.buildfoundation.bazel.rulesdetekt.wrapper

import java.io.InputStream
import java.io.OutputStream
import java.io.PrintStream

internal data class Streams(val input: InputStream, val output: PrintStream, val error: PrintStream) {

    companion object {
        fun system(): Streams {
            val systemInput = System.`in`
            val systemOutput = System.out
            val systemError = System.err

            // Suppressing system singleton stream to avoid accidental output from the tool.
            System.setOut(PrintStream(DevNullOutputStream()))

            return Streams(systemInput, systemOutput, systemError)
        }
    }

    class DevNullOutputStream : OutputStream() {
        override fun write(byte: Int) = Unit
    }
}