package io.buildfoundation.bazel.detekt.stream

import bazel.worker.WorkerProtocol.WorkRequest
import org.junit.Test
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream

class WorkerStreamsTests {

    @Test
    fun `it emits requests on requests in input stream`() {
        val request24 = WorkRequest.getDefaultInstance()
                .toBuilder()
                .setRequestId(24)
                .build()

        val request42 = WorkRequest.getDefaultInstance()
                .toBuilder()
                .setRequestId(42)
                .build()

        val outputStream = ByteArrayOutputStream().apply {
            request24.writeDelimitedTo(this)
            request42.writeDelimitedTo(this)
        }
        val inputStream = ByteArrayInputStream(outputStream.toByteArray())

        WorkerStreams.Impl(Streams.system().copy(input = inputStream)).request
                .test()
                .assertResult(request24, request42)
    }
}