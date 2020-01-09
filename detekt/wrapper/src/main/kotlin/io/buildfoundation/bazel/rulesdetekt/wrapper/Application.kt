package io.buildfoundation.bazel.rulesdetekt.wrapper

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
            private val streams: WorkerStreams
    ) : Application {

        override fun run(args: Array<String>) {
            streams.request
                    .map { executable.execute(it) }
                    .blockingSubscribe(streams.response)
        }
    }
}