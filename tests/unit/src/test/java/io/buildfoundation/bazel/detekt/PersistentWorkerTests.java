package io.buildfoundation.bazel.detekt;

import com.google.devtools.build.lib.worker.WorkerProtocol.WorkRequest;
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkResponse;
import com.google.protobuf.InvalidProtocolBufferException;
import io.buildfoundation.bazel.detekt.execute.Executable;
import io.buildfoundation.bazel.detekt.execute.ExecutableResult;
import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class PersistentWorkerTests {

    @Test
    public void passesEachRequestSandboxDirAsAnAbsolutePath() throws Exception {
        Map<String, Optional<Path>> sandboxDirs = new ConcurrentHashMap<>();
        Executable executable = (args, sandboxDir) -> {
            sandboxDirs.put(args[0], Optional.ofNullable(sandboxDir));
            // A stray print must not corrupt the response framing on the protocol stream.
            System.out.println("stray output");
            return new ExecutableResult.Failure("finding in " + args[0]);
        };

        Map<Integer, WorkResponse> responses = serve(executable,
                WorkRequest.newBuilder().setRequestId(1).addArguments("one").setSandboxDir("r1").build(),
                WorkRequest.newBuilder().setRequestId(2).addArguments("two").setSandboxDir("nested/../r2").build(),
                WorkRequest.newBuilder().setRequestId(3).addArguments("three").build());

        Path cwd = Paths.get("").toAbsolutePath();
        assertEquals(Optional.of(cwd.resolve("r1")), sandboxDirs.get("one"));
        assertEquals(Optional.of(cwd.resolve("r2")), sandboxDirs.get("two"));
        assertEquals(Optional.empty(), sandboxDirs.get("three"));
        for (int id = 1; id <= 3; id++) {
            WorkResponse response = responses.get(id);
            assertEquals(1, response.getExitCode());
            assertTrue(response.getOutput(), response.getOutput().contains("finding in "));
        }
    }

    @Test
    public void reportsSuccessForSandboxedRequest() throws Exception {
        Executable executable = (args, sandboxDir) -> new ExecutableResult.Success();

        Map<Integer, WorkResponse> responses = serve(executable,
                WorkRequest.newBuilder().setRequestId(7).addArguments("one").setSandboxDir("r7").build());

        assertEquals(0, responses.get(7).getExitCode());
        assertFalse(responses.get(7).getOutput().contains("finding"));
    }

    private static Map<Integer, WorkResponse> serve(Executable executable, WorkRequest... requests)
            throws IOException, InterruptedException {
        PipedOutputStream requestSink = new PipedOutputStream();
        PipedInputStream requestSource = new PipedInputStream(requestSink, 1 << 16);
        ByteArrayOutputStream responseBytes = new ByteArrayOutputStream();
        PrintStream protocolOut = new PrintStream(responseBytes, true);
        PrintStream stderr = new PrintStream(new ByteArrayOutputStream(), true);

        Thread worker = new Thread(() -> Main.runPersistentWorker(executable, requestSource, protocolOut, stderr));
        worker.start();

        for (WorkRequest request : requests) {
            request.writeDelimitedTo(requestSink);
        }
        requestSink.flush();

        // Multiplex requests answer on their own threads; read every response before closing the
        // input, which makes the handler interrupt requests still in flight.
        long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(30);
        Map<Integer, WorkResponse> responses = parse(responseBytes);
        while (responses.size() < requests.length && System.nanoTime() < deadline) {
            Thread.sleep(10);
            responses = parse(responseBytes);
        }
        assertEquals("responses received", requests.length, responses.size());

        requestSink.close();
        worker.join(TimeUnit.SECONDS.toMillis(30));
        assertFalse("worker did not stop after its input closed", worker.isAlive());
        return responses;
    }

    private static Map<Integer, WorkResponse> parse(ByteArrayOutputStream responseBytes) throws IOException {
        Map<Integer, WorkResponse> responses = new HashMap<>();
        byte[] bytes;
        synchronized (responseBytes) {
            bytes = responseBytes.toByteArray();
        }
        ByteArrayInputStream input = new ByteArrayInputStream(bytes);
        while (input.available() > 0) {
            WorkResponse response;
            try {
                response = WorkResponse.parseDelimitedFrom(input);
            } catch (InvalidProtocolBufferException partiallyWritten) {
                break;
            }
            if (response == null) {
                break;
            }
            responses.put(response.getRequestId(), response);
        }
        return responses;
    }
}
