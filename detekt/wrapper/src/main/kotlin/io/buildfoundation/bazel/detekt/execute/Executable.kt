package io.buildfoundation.bazel.detekt.execute

import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.nio.charset.Charset

interface Executable {

    fun execute(args: Array<String>): Result

    class DetektImpl(private val detekt: Detekt) : Executable {

        override fun execute(args: Array<String>): Result {
            val outputBuffer = ByteArrayOutputStream()
            val outputPrinter = PrintStream(outputBuffer.buffered())

            val errorBuffer = ByteArrayOutputStream()
            val errorPrinter = PrintStream(errorBuffer.buffered())

            return try {
                detekt.execute(args, outputPrinter, errorPrinter)

                Result.Success
            } catch (e: Exception) {
                outputPrinter.flush()

                e.printStackTrace(errorPrinter)
                errorPrinter.flush()

                Result.Failure(arrayOf(outputBuffer, errorBuffer).joinToString(separator = "") {
                    it.toString(Charset.defaultCharset())
                })
            } finally {
                outputPrinter.close()
                errorPrinter.close()
            }
        }
    }
}