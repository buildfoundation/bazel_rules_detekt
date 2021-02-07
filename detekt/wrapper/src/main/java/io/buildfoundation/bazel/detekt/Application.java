package io.buildfoundation.bazel.detekt;

import io.buildfoundation.bazel.detekt.execute.Executable;
import io.buildfoundation.bazel.detekt.execute.ExecutableResult;
import io.buildfoundation.bazel.detekt.execute.WorkerExecutable;
import io.buildfoundation.bazel.detekt.stream.Streams;
import io.buildfoundation.bazel.detekt.stream.WorkerStreams;
import io.reactivex.rxjava3.core.Scheduler;

public interface Application {

    void run(String[] args);

    final class OneShot implements Application {

        private final Executable executable;
        private final Streams streams;
        private final Platform platform;

        OneShot(Executable executable, Streams streams, Platform platform) {
            this.executable = executable;
            this.streams = streams;
            this.platform = platform;
        }

        @Override
        public void run(String[] args) {
            ExecutableResult result = executable.execute(args);

            if (result instanceof ExecutableResult.Failure) {
                streams.error().println(result.output());
            }

            platform.exit(result.statusCode());
        }
    }

    final class Worker implements Application {

        private final WorkerExecutable executable;
        private final WorkerStreams streams;
        private final Scheduler scheduler;

        Worker(WorkerExecutable executable, WorkerStreams streams, Scheduler scheduler) {
            this.executable = executable;
            this.streams = streams;
            this.scheduler = scheduler;
        }

        @Override
        public void run(String[] args) {
            streams.request()
                .subscribeOn(scheduler)
                .map(executable::execute)
                .blockingSubscribe(streams.response());
        }
    }
}
