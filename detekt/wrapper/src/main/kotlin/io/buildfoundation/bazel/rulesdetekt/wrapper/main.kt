@file:JvmName("Main")

package io.buildfoundation.bazel.rulesdetekt.wrapper

/**
 * The wrapper purpose:
 *
 * - switch between the continuous worker mode and the single-shot regular mode;
 * - pass arguments to Detekt;
 * - silence Detekt output on successful executions.
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
