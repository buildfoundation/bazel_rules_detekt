@file:JvmName("Main")

package io.buildfoundation.bazel.rulesdetekt.wrapper

/**
 * Wrapper expects Detekt CLI jar on classpath.
 * All wrapper arguments are passed to Detekt.
 *
 * What this wrapper does:
 * - Silents Detekt's stdout/stderr (it is not configurable in Detekt).
 * - Prints Detekt's stdout/stderr if Detekt exits with non-zero exit code.
 */
fun main(arguments: Array<String>) {
    val executor = SandboxExecutor.Impl(SandboxedExecutor.DetektExecutor())

    val application = if ("--persistent_worker" in arguments) {
        Application.Worker(executor)
    } else {
        Application.OneShot(executor)
    }

    application.run(arguments)
}