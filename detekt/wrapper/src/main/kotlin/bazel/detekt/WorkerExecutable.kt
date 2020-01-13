package bazel.detekt

import bazel.worker.WorkerProtocol.WorkRequest
import bazel.worker.WorkerProtocol.WorkResponse

internal interface WorkerExecutable {

    fun execute(request: WorkRequest): WorkResponse

    class Impl(private val executable: Executable) : WorkerExecutable {

        override fun execute(request: WorkRequest): WorkResponse {
            val result = executable.execute(request.argumentsList.toTypedArray())

            val resultOutput = when (result) {
                is Result.Success -> WorkResponse.getDefaultInstance().output
                is Result.Failure -> result.description
            }

            return WorkResponse.newBuilder()
                    .setRequestId(request.requestId)
                    .setOutput(resultOutput)
                    .setExitCode(result.consoleStatusCode)
                    .build()
        }
    }
}