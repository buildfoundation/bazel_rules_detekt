package io.buildfoundation.bazel.rulesdetekt.wrapper

import java.io.File
import java.io.FileOutputStream
import java.io.PrintStream
import java.nio.charset.Charset

internal interface Executable {

    fun execute(args: Array<String>): Result

    class DetektImpl(private val detekt: Detekt) : Executable {

        override fun execute(args: Array<String>): Result {
            val outputPrinter = PrintStream(Streams.DevNullOutputStream().buffered())

            val errorPrinterFile = File.createTempFile("detekt-errors", null)
            val errorPrinter = PrintStream(FileOutputStream(errorPrinterFile).buffered())

            return try {
                detekt.execute(args, outputPrinter, errorPrinter)

                Result.Success
            } catch (e: Exception) {
                e.printStackTrace(errorPrinter)
                errorPrinter.flush()

                Result.Failure(errorPrinterFile.readText(Charset.defaultCharset()))
            } finally {
                outputPrinter.close()

                errorPrinter.close()
                errorPrinterFile.delete()
            }
        }
    }
}