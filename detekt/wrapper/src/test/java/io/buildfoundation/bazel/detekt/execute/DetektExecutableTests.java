package io.buildfoundation.bazel.detekt.execute;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class DetektExecutableTests {

    @Test
    public void successResultOnDetektExecutionSuccess() {
        check(TestDetekt.ExecuteResult.Success, ExecutableResult.Success.class);
    }

    @Test
    public void failureResultOnDetektExecutionFailure() {
        check(TestDetekt.ExecuteResult.Failure, ExecutableResult.Failure.class);
    }

    private <T extends ExecutableResult> void check(TestDetekt.ExecuteResult detektResult, Class<T> result) {
        Executable executable = new Executable.DetektImpl(new TestDetekt(detektResult));
        ExecutableResult executableResult = executable.execute(new String[0]);

        assertEquals(result, executableResult.getClass());
    }
}
