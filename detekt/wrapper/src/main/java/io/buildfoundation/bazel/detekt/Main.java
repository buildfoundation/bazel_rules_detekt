package io.buildfoundation.bazel.detekt;

import io.buildfoundation.bazel.detekt.execute.Detekt;
import io.buildfoundation.bazel.detekt.execute.Executable;
import io.buildfoundation.bazel.detekt.execute.WorkerExecutable;
import io.buildfoundation.bazel.detekt.stream.Streams;
import io.buildfoundation.bazel.detekt.stream.WorkerStreams;
import io.reactivex.rxjava3.schedulers.Schedulers;

import java.util.Arrays;

public class Main {

    public static void main(String[] args) {
        createApplication(args).run(args);
    }

    private static Application createApplication(String[] args) {
        Executable executable = new Executable.DetektImpl(new Detekt.Impl());
        Streams streams = new Streams.Impl();

        if (Arrays.asList(args).contains("--persistent_worker")) {
            WorkerExecutable workerExecutable = new WorkerExecutable.Impl(executable);
            WorkerStreams workerStreams = new WorkerStreams.Impl(streams);

            return new Application.Worker(workerExecutable, workerStreams, Schedulers.io());
        } else {
            return new Application.OneShot(executable, streams, new Platform.Impl());
        }
    }
}
