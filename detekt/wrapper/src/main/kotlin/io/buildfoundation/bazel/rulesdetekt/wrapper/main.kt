@file:JvmName("Main")

package io.buildfoundation.bazel.rulesdetekt.wrapper

import io.reactivex.schedulers.Schedulers

/**
 * The wrapper purpose:
 *
 * - switch between the continuous worker mode and the single-shot regular mode;
 * - pass arguments to Detekt;
 * - silence Detekt output on successful executions.
 */
fun main(arguments: Array<String>) {
    val executable = Executable.DetektImpl(Detekt.Impl())
    val consoleStreams = Streams.system()

    val application = if ("--persistent_worker" in arguments) {
        Application.Worker(Schedulers.io(), WorkerExecutable.Impl(executable), WorkerStreams.Impl(consoleStreams))
    } else {
        Application.OneShot(executable, consoleStreams, Platform.Impl())
    }

    application.run(arguments)
}
