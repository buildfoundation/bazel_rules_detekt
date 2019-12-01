@file:JvmName("Main")

package io.buildfoundation.bazel.rulesdetekt.wrapper

import java.io.File
import java.io.FileOutputStream
import java.io.PrintStream
import java.security.Permission
import java.util.concurrent.atomic.AtomicInteger
import kotlin.concurrent.thread

/**
 * Wrapper expects Detekt CLI jar on classpath.
 * All wrapper arguments are passed to Detekt main method.
 *
 * What this wrapper does:
 * - Silents Detekt's stdout/stderr (it is not configurable in Detekt).
 * - Prints Detekt's stdout/stderr if Detekt exits with non-zero exit code.
 *
 * Later it might be enhanced:
 * - By turning it into Persistent Worker
 * - By fixing Detekt design issues like absolute paths in reports/baselines.
 */
fun main(rawArgs: Array<String>) {
    val originalStdout = System.out
    val originalStderr = System.err

    val interceptedExitCode = AtomicInteger()

    val detektStdoutFile = File("detekt-stdout.txt")
    val detektStderrFile = File("detekt-stderr.txt")

    PrintStream(FileOutputStream(detektStdoutFile).buffered()).use { detektStdout ->
        PrintStream(FileOutputStream(detektStderrFile).buffered()).use { detektStderr ->

            Runtime.getRuntime().addShutdownHook(thread(start = false) {
                if (interceptedExitCode.get() != 0) {
                    // Remap streams back in case our code below crashes lol.
                    System.setOut(originalStdout)
                    System.setErr(originalStderr)

                    detektStdout.flush()
                    detektStdout.close()

                    detektStderr.flush()
                    detektStderr.close()

                    originalStdout.println(detektStdoutFile.readText())
                    originalStderr.println(detektStderrFile.readText())
                }
            })

            System.setSecurityManager(object : SecurityManager() {
                override fun checkExit(code: Int) {
                    interceptedExitCode.set(code)
                }

                override fun checkPermission(perm: Permission?) {
                    // Pass-through.
                }

                override fun checkPermission(perm: Permission?, context: Any?) {
                    // Pass-through.
                }
            })

            System.setOut(detektStdout)
            System.setErr(detektStderr)

            Class
                    .forName("io.gitlab.arturbosch.detekt.cli.Main")
                    .declaredMethods
                    .first { it.name == "main" }
                    .invoke(null, rawArgs)
        }
    }
}
