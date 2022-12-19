package io.buildfoundation.bazel.detekt.execute;

import io.buildfoundation.bazel.detekt.value.WorkRequest;
import io.buildfoundation.bazel.detekt.value.WorkResponse;
import org.junit.Test;

import java.util.Arrays;

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

        WorkRequest workRequest = new WorkRequest();
        workRequest.requestId = 42;
        workRequest.arguments = Arrays.asList("fake", "fake", "fake");

        WorkResponse workResponseActual = workerExecutable.execute(workRequest);

        WorkResponse workResponseExpected = new WorkResponse();
        workResponseExpected.requestId = workRequest.requestId;
        workResponseExpected.output = executableResult.output();
        workResponseExpected.exitCode = executableResult.statusCode();

        assertEquals(workResponseExpected, workResponseActual);
    }
}
