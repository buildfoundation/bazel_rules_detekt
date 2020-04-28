@file:JvmName("Main")

package io.buildfoundation.bazel.detekt

import io.buildfoundation.bazel.detekt.execute.Detekt
import io.buildfoundation.bazel.detekt.execute.Executable
import io.buildfoundation.bazel.detekt.execute.WorkerExecutable
import io.buildfoundation.bazel.detekt.stream.Streams
import io.buildfoundation.bazel.detekt.stream.WorkerStreams
import io.reactivex.rxjava3.schedulers.Schedulers

/**
 * The wrapper purpose:
 *
 * - switch between the continuous worker mode and the single-shot regular mode;
 * - pass arguments to Detekt;
 * - silence Detekt output on successful executions.
 */
fun main(arguments: Array<String>) {
    val executable = Executable.DetektImpl(Detekt.Impl())
    val streams = Streams.system()

    val application = if ("--persistent_worker" in arguments) {
        Application.Worker(WorkerExecutable.Impl(executable), WorkerStreams.Impl(streams), Schedulers.io())
    } else {
        Application.OneShot(executable, streams, Platform.Impl())
    }

    application.run(arguments)
}
