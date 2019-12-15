package io.buildfoundation.bazel.rulesdetekt.wrapper

import java.io.File
import java.io.FileOutputStream
import java.io.PrintStream
import java.nio.charset.Charset
import java.util.concurrent.atomic.AtomicReference

interface SandboxExecutor {

    data class Result(val code: Int, val stdout: String, val stderr: String)

    fun execute(arguments: Array<String>): Result

    class Impl(private val executor: SandboxedExecutor) : SandboxExecutor {

        override fun execute(arguments: Array<String>): Result {
            val systemStdout = System.out
            val systemStderr = System.err

            val sandboxStdoutFile = File("sandbox-stdout.txt")
            val sandboxStderrFile = File("sandbox-stderr.txt")

            val result = AtomicReference<SandboxedExecutor.Result>()

            PrintStream(FileOutputStream(sandboxStdoutFile).buffered()).use { sandboxStdout ->
                PrintStream(FileOutputStream(sandboxStderrFile).buffered()).use { sandboxStderr ->
                    System.setOut(sandboxStdout)
                    System.setErr(sandboxStderr)

                    result.set(executor.execute(arguments))

                    sandboxStdout.flush()
                    sandboxStdout.close()

                    sandboxStderr.flush()
                    sandboxStderr.close()
                }
            }

            System.setOut(systemStdout)
            System.setErr(systemStderr)

            return Charset.defaultCharset().let { charset ->
                val code = when (result.get() ?: SandboxedExecutor.Result.Failure) {
                    SandboxedExecutor.Result.Success -> 0
                    SandboxedExecutor.Result.Failure -> 1
                }

                val stdout = sandboxStdoutFile.readText(charset)
                val stderr = sandboxStderrFile.readText(charset)

                sandboxStdoutFile.delete()
                sandboxStderrFile.delete()

                Result(code, stdout, stderr)
            }
        }
    }
}