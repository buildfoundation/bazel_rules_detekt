package io.buildfoundation.bazel.detekt;

import com.google.devtools.build.lib.worker.ProtoWorkerMessageProcessor;
import com.google.devtools.build.lib.worker.WorkRequestHandler;
import io.buildfoundation.bazel.detekt.execute.Detekt;
import io.buildfoundation.bazel.detekt.execute.Executable;
import io.buildfoundation.bazel.detekt.execute.ExecutableResult;

import java.io.PrintStream;
import java.util.Arrays;
import java.util.List;

public final class Main {

    public static void main(String[] args) {
        Executable executable = new Executable.DetektImpl(new Detekt.Impl());

        if (Arrays.asList(args).contains("--persistent_worker")) {
            runPersistentWorker(executable);
        } else {
            runOneShot(executable, args);
        }
    }

    private static void runOneShot(Executable executable, String[] args) {
        ExecutableResult result = executable.execute(args);

        if (result instanceof ExecutableResult.Failure) {
            System.err.println(result.output());
        }

        System.exit(result.statusCode());
    }

    private static void runPersistentWorker(Executable executable) {
        // Capture the original streams before they're wrapped by WorkRequestHandler
        PrintStream stderr = System.err;

        WorkRequestHandler handler = new WorkRequestHandler.WorkRequestHandlerBuilder(
            new WorkRequestHandler.WorkRequestCallback((request, pw) -> {
                List<String> arguments = request.getArgumentsList();
                String[] args = arguments.toArray(new String[0]);

                ExecutableResult result = executable.execute(args);

                if (result instanceof ExecutableResult.Failure) {
                    pw.println(result.output());
                }

                return result.statusCode();
            }),
            stderr,
            new ProtoWorkerMessageProcessor(System.in, System.out)
        ).build();

        try {
            handler.processRequests();
        } catch (Exception e) {
            stderr.println("Worker error: " + e.getMessage());
            e.printStackTrace(stderr);
            System.exit(1);
        }
    }
}
