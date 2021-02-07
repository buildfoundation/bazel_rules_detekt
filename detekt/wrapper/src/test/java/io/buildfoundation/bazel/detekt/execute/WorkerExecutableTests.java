package io.buildfoundation.bazel.detekt.execute;

import bazel.worker.WorkerProtocol.WorkRequest;
import bazel.worker.WorkerProtocol.WorkResponse;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class WorkerExecutableTests {

    @Test
    public void successResponseOnExecutionSuccess() {
        check(new ExecutableResult.Success());
    }

    @Test
    public void failureResponseOnExecutionFailure() {
        check(new ExecutableResult.Failure("fake message"));
    }

    private void check(ExecutableResult executableResult) {
        WorkerExecutable workerExecutable = new WorkerExecutable.Impl(new TestExecutable(executableResult));

        WorkRequest workRequest = WorkRequest.getDefaultInstance()
            .toBuilder()
            .setRequestId(42)
            .build();

        WorkResponse workResponseActual = workerExecutable.execute(workRequest);

        WorkResponse workResponseExpected = WorkResponse.getDefaultInstance()
            .toBuilder()
            .setRequestId(workRequest.getRequestId())
            .setOutput(executableResult.output())
            .setExitCode(executableResult.statusCode())
            .build();

        assertEquals(workResponseExpected, workResponseActual);
    }
}
