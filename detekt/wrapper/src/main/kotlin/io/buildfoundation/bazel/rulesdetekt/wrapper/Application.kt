package io.buildfoundation.bazel.rulesdetekt.wrapper

import bazel.worker.WorkerProtocol
import kotlin.system.exitProcess

interface Application {

    fun run(arguments: Array<String>)

    class Worker(private val executor: SandboxExecutor) : Application {

        override fun run(arguments: Array<String>) {
            while (true) {
                val result = WorkerProtocol.WorkRequest.parseDelimitedFrom(System.`in`).let {
                    executor.execute(it.argumentsList.toTypedArray())
                }

                WorkerProtocol.WorkResponse.newBuilder()
                        .apply {
                            if (result.code != 0) {
                                output = listOf(result.stdout, result.stderr).joinToString(separator = "\n")
                            }
                        }
                        .setExitCode(result.code)
                        .build()
                        .writeDelimitedTo(System.out)
            }
        }
    }

    class OneShot(private val executor: SandboxExecutor) : Application {

        override fun run(arguments: Array<String>) {
            val result = executor.execute(arguments)

            if (result.code != 0) {
                System.out.println(result.stdout)
                System.err.println(result.stderr)
            }

            exitProcess(result.code)
        }
    }
}