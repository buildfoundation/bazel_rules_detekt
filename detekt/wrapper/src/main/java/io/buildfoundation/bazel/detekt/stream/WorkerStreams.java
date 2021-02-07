package io.buildfoundation.bazel.detekt.stream;

import bazel.worker.WorkerProtocol.WorkRequest;
import bazel.worker.WorkerProtocol.WorkResponse;
import io.reactivex.rxjava3.annotations.NonNull;
import io.reactivex.rxjava3.core.BackpressureStrategy;
import io.reactivex.rxjava3.core.Flowable;
import io.reactivex.rxjava3.core.FlowableEmitter;
import io.reactivex.rxjava3.core.FlowableOnSubscribe;
import io.reactivex.rxjava3.functions.Consumer;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public interface WorkerStreams {

    Flowable<WorkRequest> request();
    Consumer<WorkResponse> response();

    final class Impl implements WorkerStreams {

        private final Streams streams;

        public Impl(Streams streams) {
            this.streams = streams;
        }

        private static final class WorkRequestSource implements FlowableOnSubscribe<WorkRequest> {

            private final InputStream requestInput;

            WorkRequestSource(Streams streams) {
                this.requestInput = streams.input();
            }

            @Override
            public void subscribe(@NonNull FlowableEmitter<WorkRequest> emitter) {
                while (!emitter.isCancelled()) {
                    WorkRequest request = readRequest();

                    if (request == null) {
                        emitter.onComplete();
                    } else {
                        emitter.onNext(request);
                    }
                }
            }

            private WorkRequest readRequest() {
                try {
                    return WorkRequest.parseDelimitedFrom(requestInput);
                } catch (IOException e) {
                    return null;
                }
            }
        }

        private static final class WorkResponseSink implements Consumer<WorkResponse> {

            private final OutputStream responseOutput;

            WorkResponseSink(Streams streams) {
                this.responseOutput = streams.output();
            }

            @Override
            public void accept(WorkResponse response) {
                try {
                    response.writeDelimitedTo(responseOutput);
                } catch (IOException ignored) {
                }
            }
        }

        @Override
        public Flowable<WorkRequest> request() {
            return Flowable.create(new WorkRequestSource(streams), BackpressureStrategy.BUFFER);
        }

        @Override
        public Consumer<WorkResponse> response() {
            return new WorkResponseSink(streams);
        }
    }
}
