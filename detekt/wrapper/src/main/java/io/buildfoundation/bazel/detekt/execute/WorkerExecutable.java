package io.buildfoundation.bazel.detekt.execute;

import io.buildfoundation.bazel.detekt.value.WorkRequest;
import io.buildfoundation.bazel.detekt.value.WorkResponse;

public interface WorkerExecutable {

    WorkResponse execute(WorkRequest request);

    final class Impl implements WorkerExecutable {

        private final Executable executable;

        public Impl(Executable executable) {
            this.executable = executable;
        }

        @Override
        public WorkResponse execute(WorkRequest request) {
            String[] arguments = new String[request.arguments.size()];
            request.arguments.toArray(arguments);

            ExecutableResult result = executable.execute(arguments);

            WorkResponse response = new WorkResponse();
            response.requestId = request.requestId;
            response.output = result.output();
            response.exitCode = result.statusCode();

            return response;
        }
    }
}
