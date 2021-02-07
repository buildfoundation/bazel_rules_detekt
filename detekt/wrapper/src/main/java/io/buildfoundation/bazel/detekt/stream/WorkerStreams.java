package io.buildfoundation.bazel.detekt.stream;

import com.squareup.moshi.JsonAdapter;
import com.squareup.moshi.Moshi;
import io.buildfoundation.bazel.detekt.value.WorkRequest;
import io.buildfoundation.bazel.detekt.value.WorkResponse;
import io.reactivex.rxjava3.annotations.NonNull;
import io.reactivex.rxjava3.core.BackpressureStrategy;
import io.reactivex.rxjava3.core.Flowable;
import io.reactivex.rxjava3.core.FlowableEmitter;
import io.reactivex.rxjava3.core.FlowableOnSubscribe;
import io.reactivex.rxjava3.functions.Consumer;
import okio.BufferedSink;
import okio.BufferedSource;
import okio.Okio;

import java.io.IOException;

public interface WorkerStreams {

    Flowable<WorkRequest> request();
    Consumer<WorkResponse> response();

    final class Impl implements WorkerStreams {

        private final Streams streams;

        public Impl(Streams streams) {
            this.streams = streams;
        }

        private static final class WorkRequestSource implements FlowableOnSubscribe<WorkRequest> {

            private final BufferedSource requestSource;
            private final JsonAdapter<WorkRequest> requestAdapter;

            WorkRequestSource(Streams streams) {
                this.requestSource = Okio.buffer(Okio.source(streams.input()));
                this.requestAdapter = new Moshi.Builder().build().adapter(WorkRequest.class);
            }

            @Override
            public void subscribe(@NonNull FlowableEmitter<WorkRequest> emitter) {
                while (!emitter.isCancelled()) {
                    try {
                        WorkRequest request = requestAdapter.fromJson(requestSource);

                        if (request == null) {
                            emitter.onComplete();
                        } else {
                            emitter.onNext(request);
                        }
                    } catch (IOException e) {
                        emitter.onComplete();
                    }
                }
            }
        }

        private static final class WorkResponseSink implements Consumer<WorkResponse> {

            private final BufferedSink responseSink;
            private final JsonAdapter<WorkResponse> responseAdapter;

            WorkResponseSink(Streams streams) {
                this.responseSink = Okio.buffer(Okio.sink(streams.output()));
                this.responseAdapter = new Moshi.Builder().build().adapter(WorkResponse.class);
            }

            @Override
            public void accept(WorkResponse response) throws Throwable {
                responseAdapter.toJson(responseSink, response);
                responseSink.flush();
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
