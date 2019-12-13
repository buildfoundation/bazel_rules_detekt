@file:JvmName("Main")

package io.buildfoundation.bazel.rulesdetekt.wrapper

import kotlin.system.exitProcess

/**
 * Wrapper expects Detekt CLI jar on classpath.
 * All wrapper arguments are passed to Detekt.
 *
 * What this wrapper does:
 * - Silents Detekt's stdout/stderr (it is not configurable in Detekt).
 * - Prints Detekt's stdout/stderr if Detekt exits with non-zero exit code.
 *
 * Later it might be enhanced:
 * - By turning it into Persistent Worker
 * - By fixing Detekt design issues like absolute paths in reports/baselines.
 */
fun main(arguments: Array<String>) {
    val result = SandboxExecutor.Impl(SandboxedExecutor.DetektExecutor).execute(arguments)

    if (result.code != 0) {
        System.out.println(result.stdout)
        System.err.println(result.stderr)
    }

    exitProcess(result.code)
}
