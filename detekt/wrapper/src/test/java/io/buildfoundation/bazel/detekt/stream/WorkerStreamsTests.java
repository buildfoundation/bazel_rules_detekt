package io.buildfoundation.bazel.detekt.stream;

import bazel.worker.WorkerProtocol.WorkRequest;
import bazel.worker.WorkerProtocol.WorkResponse;
import io.reactivex.rxjava3.functions.Consumer;
import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

public class WorkerStreamsTests {

    @Test
    public void requestEmits() {
        TestStreams streams = new TestStreams();
        WorkerStreams workerStreams = new WorkerStreams.Impl(streams);

        WorkRequest request24 = WorkRequest.getDefaultInstance()
            .toBuilder()
            .setRequestId(24)
            .build();

        WorkRequest request42 = WorkRequest.getDefaultInstance()
            .toBuilder()
            .setRequestId(42)
            .build();

        try {
            request24.writeDelimitedTo(streams.inputSink);
            request42.writeDelimitedTo(streams.inputSink);
        } catch (IOException ignored) {
            fail();
        }

        workerStreams.request()
            .test()
            .assertResult(request24, request42);
    }

    @Test
    public void responseConsumes() {
        TestStreams streams = new TestStreams();
        WorkerStreams workerStreams = new WorkerStreams.Impl(streams);

        WorkResponse response24 = WorkResponse.getDefaultInstance()
            .toBuilder()
            .setRequestId(24)
            .build();

        WorkResponse response42 = WorkResponse.getDefaultInstance()
            .toBuilder()
            .setRequestId(42)
            .build();

        Consumer<WorkResponse> workerStreamsResponse = workerStreams.response();

        try {
            workerStreamsResponse.accept(response24);
            workerStreamsResponse.accept(response42);
        } catch (Throwable ignored) {
            fail();
        }

        InputStream streamsOutputSource = new ByteArrayInputStream(streams.outputSink.toByteArray());

        try {
            WorkResponse outputResponse24 = WorkResponse.parseDelimitedFrom(streamsOutputSource);
            WorkResponse outputResponse42 = WorkResponse.parseDelimitedFrom(streamsOutputSource);

            assertEquals(outputResponse24, response24);
            assertEquals(outputResponse42, response42);
        } catch (IOException ignored) {
            fail();
        }
    }
}
