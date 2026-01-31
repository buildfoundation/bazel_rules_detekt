package io.buildfoundation.bazel.detekt;

import com.google.devtools.build.lib.worker.ProtoWorkerMessageProcessor;
import com.google.devtools.build.lib.worker.WorkRequestHandler;
import io.buildfoundation.bazel.detekt.execute.Detekt;
import io.buildfoundation.bazel.detekt.execute.Executable;
import io.buildfoundation.bazel.detekt.execute.ExecutableResult;

import java.io.IOException;
import java.io.PrintStream;
import java.time.Duration;
import java.util.Arrays;
import java.util.List;

public final class Main {

    public static void main(String[] args) {
        Executable executable = new Executable.DetektImpl(new Detekt.Impl());

        if (Arrays.asList(args).contains("--persistent_worker")) {
            System.exit(runPersistentWorker(executable));
        } else {
            System.exit(runOneShot(executable, args));
        }
    }

    private static int runOneShot(Executable executable, String[] args) {
        ExecutableResult result = executable.execute(args);

        if (result instanceof ExecutableResult.Failure) {
            System.err.println(result.output());
        }

        return result.statusCode();
    }

    private static int runPersistentWorker(Executable executable) {
        PrintStream stderr = System.err;

        try (WorkRequestHandler handler = new WorkRequestHandler.WorkRequestHandlerBuilder(
                new WorkRequestHandler.WorkRequestCallback((request, pw) -> {
                    List<String> arguments = request.getArgumentsList();
                    String[] args = arguments.toArray(new String[0]);

                    ExecutableResult result = executable.execute(args);

                    String output = result.output();
                    if (!output.isEmpty()) {
                        pw.print(output);
                    }

                    return result.statusCode();
                }),
                stderr,
                new ProtoWorkerMessageProcessor(System.in, System.out))
            .setCpuUsageBeforeGc(Duration.ofSeconds(10))
            .setIdleTimeBeforeGc(Duration.ofSeconds(30))
            .setCancelCallback((requestId, thread) -> thread.interrupt())
            .build()) {

            handler.processRequests();
        } catch (IOException e) {
            stderr.println("Worker error: " + e.getMessage());
            e.printStackTrace(stderr);
            return 1;
        }
        return 0;
    }
}
