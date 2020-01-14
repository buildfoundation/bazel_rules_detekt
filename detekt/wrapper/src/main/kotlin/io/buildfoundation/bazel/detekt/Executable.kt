package io.buildfoundation.bazel.detekt

import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.nio.charset.Charset

internal interface Executable {

    fun execute(args: Array<String>): Result

    class DetektImpl(private val detekt: Detekt) : Executable {

        override fun execute(args: Array<String>): Result {
            val outputPrinter = PrintStream(Streams.DevNullOutputStream().buffered())

            val errorPrinterBuffer = ByteArrayOutputStream()
            val errorPrinter = PrintStream(errorPrinterBuffer.buffered())

            return try {
                detekt.execute(args, outputPrinter, errorPrinter)

                Result.Success
            } catch (e: Exception) {
                e.printStackTrace(errorPrinter)
                errorPrinter.flush()

                Result.Failure(errorPrinterBuffer.toString(Charset.defaultCharset()))
            } finally {
                outputPrinter.close()
                errorPrinter.close()
            }
        }
    }
}