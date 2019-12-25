package io.buildfoundation.bazel.rulesdetekt.wrapper

import bazel.worker.WorkerProtocol.WorkRequest
import bazel.worker.WorkerProtocol.WorkResponse
import io.reactivex.BackpressureStrategy
import io.reactivex.Flowable
import io.reactivex.FlowableEmitter
import io.reactivex.functions.Consumer

internal interface WorkerStreams {

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

        override val request = Flowable.create(requestSource, BackpressureStrategy.LATEST)
        override val response = Consumer<WorkResponse> { it.writeDelimitedTo(streams.output) }
    }
}