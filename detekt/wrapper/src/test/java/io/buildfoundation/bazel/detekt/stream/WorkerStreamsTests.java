package io.buildfoundation.bazel.detekt.stream;

import com.google.devtools.build.lib.worker.WorkerProtocol.WorkRequest;
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkResponse;
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

        WorkRequest request1 = WorkRequest.getDefaultInstance()
            .toBuilder()
            .setRequestId(1)
            .build();

        WorkRequest request2 = WorkRequest.getDefaultInstance()
            .toBuilder()
            .setRequestId(2)
            .build();

        try {
            request1.writeDelimitedTo(streams.inputSink);
            request2.writeDelimitedTo(streams.inputSink);
        } catch (IOException ignored) {
            fail();
        }

        workerStreams.request()
            .test()
            .assertResult(request1, request2);
    }

    @Test
    public void responseConsumes() {
        TestStreams streams = new TestStreams();
        WorkerStreams workerStreams = new WorkerStreams.Impl(streams);

        WorkResponse response1 = WorkResponse.getDefaultInstance()
            .toBuilder()
            .setRequestId(1)
            .build();

        WorkResponse response2 = WorkResponse.getDefaultInstance()
            .toBuilder()
            .setRequestId(2)
            .build();

        Consumer<WorkResponse> workerStreamsResponse = workerStreams.response();

        try {
            workerStreamsResponse.accept(response1);
            workerStreamsResponse.accept(response2);
        } catch (Throwable ignored) {
            fail();
        }

        InputStream streamsOutputSource = new ByteArrayInputStream(streams.outputSink.toByteArray());

        try {
            WorkResponse outputResponse1 = WorkResponse.parseDelimitedFrom(streamsOutputSource);
            WorkResponse outputResponse2 = WorkResponse.parseDelimitedFrom(streamsOutputSource);

            assertEquals(response1, outputResponse1);
            assertEquals(response2, outputResponse2);
        } catch (IOException ignored) {
            fail();
        }
    }
}
