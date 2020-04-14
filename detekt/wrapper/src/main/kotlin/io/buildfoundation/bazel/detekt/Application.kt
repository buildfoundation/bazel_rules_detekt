package io.buildfoundation.bazel.detekt

import io.buildfoundation.bazel.detekt.execute.Executable
import io.buildfoundation.bazel.detekt.execute.Result
import io.buildfoundation.bazel.detekt.execute.WorkerExecutable
import io.buildfoundation.bazel.detekt.stream.Streams
import io.buildfoundation.bazel.detekt.stream.WorkerStreams
import io.reactivex.Scheduler

internal interface Application {

    fun run(args: Array<String>)

    class OneShot(
            private val executable: Executable,
            private val streams: Streams,
            private val platform: Platform
    ) : Application {

        override fun run(args: Array<String>) {
            val result = executable.execute(args)

            if (result is Result.Failure) {
                streams.error.println(result.description)
            }

            platform.exit(result.consoleStatusCode)
        }
    }

    class Worker(
            private val executable: WorkerExecutable,
            private val streams: WorkerStreams,
            private val scheduler: Scheduler
    ) : Application {

        override fun run(args: Array<String>) {
            streams.request
                    .subscribeOn(scheduler)
                    .map { executable.execute(it) }
                    .blockingSubscribe(streams.response)
        }
    }
}