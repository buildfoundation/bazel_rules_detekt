package io.buildfoundation.bazel.detekt.execute;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class DetektExecutableTests {

    @Test
    public void successResultOnDetektExecutionSuccess() {
        Executable executable = new Executable.DetektImpl(new TestDetekt(TestDetekt.ExecuteResult.Success));
        ExecutableResult executableResult = executable.execute(new String[0]);

        assertEquals(executableResult.getClass(), ExecutableResult.Success.class);
    }

    @Test
    public void failureResultOnDetektExecutionFailure() {
        Executable executable = new Executable.DetektImpl(new TestDetekt(TestDetekt.ExecuteResult.Failure));
        ExecutableResult executableResult = executable.execute(new String[0]);

        assertEquals(executableResult.getClass(), ExecutableResult.Failure.class);
    }
}
