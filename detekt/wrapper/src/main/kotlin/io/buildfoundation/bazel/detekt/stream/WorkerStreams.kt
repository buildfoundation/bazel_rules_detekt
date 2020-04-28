package io.buildfoundation.bazel.detekt.stream

import bazel.worker.WorkerProtocol.WorkRequest
import bazel.worker.WorkerProtocol.WorkResponse
import io.reactivex.rxjava3.core.BackpressureStrategy
import io.reactivex.rxjava3.core.Flowable
import io.reactivex.rxjava3.core.FlowableEmitter
import io.reactivex.rxjava3.functions.Consumer

interface WorkerStreams {

    val request: Flowable<WorkRequest>
    val response: Consumer<WorkResponse>

    class Impl(private val streams: Streams) : WorkerStreams {

        private val requestSource = { emitter: FlowableEmitter<WorkRequest> ->
            while (!emitter.isCancelled) {
                val request = WorkRequest.parseDelimitedFrom(streams.input)

                if (request == null) {
                    emitter.onComplete()
                } else {
                    emitter.onNext(request)
                }
            }
        }

        override val request = Flowable.create(requestSource, BackpressureStrategy.BUFFER)
        override val response = Consumer<WorkResponse> { it.writeDelimitedTo(streams.output) }
    }
}
