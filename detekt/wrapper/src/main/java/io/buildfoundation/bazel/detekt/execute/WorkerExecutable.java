package io.buildfoundation.bazel.detekt.execute;

import com.google.devtools.build.lib.worker.WorkerProtocol.WorkRequest;
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkResponse;

public interface WorkerExecutable {

    WorkResponse execute(WorkRequest request);

    final class Impl implements WorkerExecutable {

        private final Executable executable;

        public Impl(Executable executable) {
            this.executable = executable;
        }

        @Override
        public WorkResponse execute(WorkRequest request) {
            String[] arguments = new String[request.getArgumentsCount()];
            request.getArgumentsList().toArray(arguments);

            ExecutableResult result = executable.execute(arguments);

            return WorkResponse.newBuilder()
                .setRequestId(request.getRequestId())
                .setOutput(result.output())
                .setExitCode(result.statusCode())
                .build();
        }
    }
}
