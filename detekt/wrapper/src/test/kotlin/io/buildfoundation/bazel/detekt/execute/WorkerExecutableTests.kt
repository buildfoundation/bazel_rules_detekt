package io.buildfoundation.bazel.detekt.execute

import bazel.worker.WorkerProtocol
import org.junit.Assert.assertEquals
import org.junit.Test

class WorkerExecutableTests {

    @Test
    fun `it returns successful response on successful execution`() {
        val request = WorkerProtocol.WorkRequest.newBuilder()
                .setRequestId(42)
                .build()

        val actualResponse = WorkerExecutable.Impl(TestExecutable(Result.Success)).execute(request)

        val expectedResponse = WorkerProtocol.WorkResponse.newBuilder()
                .setRequestId(request.requestId)
                .setOutput("")
                .setExitCode(0)
                .build()

        assertEquals(expectedResponse, actualResponse)
    }

    @Test
    fun `it returns failure response on failed execution`() {
        val request = WorkerProtocol.WorkRequest.newBuilder()
                .setRequestId(42)
                .build()

        val result = Result.Failure("result description")

        val actualResponse = WorkerExecutable.Impl(TestExecutable(result)).execute(request)

        val expectedResponse = WorkerProtocol.WorkResponse.newBuilder()
                .setRequestId(request.requestId)
                .setOutput(result.description)
                .setExitCode(1)
                .build()

        assertEquals(expectedResponse, actualResponse)
    }
}